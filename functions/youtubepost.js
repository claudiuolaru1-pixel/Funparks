const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Anthropic = require("@anthropic-ai/sdk");
const { generateArticleVideo } = require("./video");

const YT_CLIENT_ID = defineSecret("YT_CLIENT_ID");
const YT_CLIENT_SECRET = defineSecret("YT_CLIENT_SECRET");
const YT_REFRESH_TOKEN = defineSecret("YT_REFRESH_TOKEN");

const SITE = "https://funparks.app";
const BUCKET = "funparks-779c6.firebasestorage.app";
// Videos that pass the safety check are published with this setting.
// Videos that fail or cannot be checked are always uploaded as "private" for you to look at.
// Use "private" here to stop publishing and review everything yourself first.
const YT_PRIVACY = "public";
// Only articles posted to Facebook within this many days get a video (avoids posting old articles).
const MAX_AGE_DAYS = 4;
// A failed article is tried again on the next run, up to this many times in total.
const MAX_ATTEMPTS = 2;

const errText = (e) => String(e && e.message ? e.message : e).slice(0, 600);

async function getAccessToken() {
  const r = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: YT_CLIENT_ID.value(),
      client_secret: YT_CLIENT_SECRET.value(),
      refresh_token: YT_REFRESH_TOKEN.value(),
      grant_type: "refresh_token",
    }),
  });
  const data = await r.json();
  if (!r.ok || !data.access_token) throw new Error("Token refresh failed: " + JSON.stringify(data));
  return data.access_token;
}

async function uploadVideo(videoBuffer, meta, accessToken) {
  const boundary = "funparks" + Date.now();
  const head = Buffer.from(
    "--" + boundary + "\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n" +
    JSON.stringify(meta) + "\r\n--" + boundary + "\r\nContent-Type: video/mp4\r\n\r\n"
  );
  const tail = Buffer.from("\r\n--" + boundary + "--");
  const body = Buffer.concat([head, videoBuffer, tail]);
  const r = await fetch(
    "https://www.googleapis.com/upload/youtube/v3/videos?uploadType=multipart&part=snippet,status",
    {
      method: "POST",
      headers: {
        Authorization: "Bearer " + accessToken,
        "Content-Type": "multipart/related; boundary=" + boundary,
        "Content-Length": String(body.length),
      },
      body,
    }
  );
  const data = await r.json();
  if (!r.ok) throw new Error("Upload failed: " + JSON.stringify(data.error || data));
  return data;
}

function storagePathFromUrl(url) {
  const m = String(url).match(/\/o\/([^?]+)/);
  if (!m) throw new Error("Cannot read the storage path from the video address");
  return decodeURIComponent(m[1]);
}

function plain(text) {
  return String(text || "").replace(/https?:\/\/\S+/g, "").replace(/[#*_`>\[\]]/g, "").replace(/\s+/g, " ").trim();
}

// Claude writes the YouTube title and description from the article, with the same strict rules as the Facebook post.
function splitTitleAndDescription(text) {
  const clean = (t) => String(t || "").replace(/\*+/g, "").replace(/^\s*(title|description)\s*:\s*/i, "").replace(/["\u201c\u201d]/g, "").trim();
  let title = "";
  let description = "";
  // 1) labelled: "Title: ... Description: ..."
  const m = text.match(/title\s*:\s*([^\n]+)[\s\S]*?description\s*:\s*([\s\S]+)/i);
  if (m) {
    title = m[1];
    description = m[2];
  } else {
    // 2) separated by a line of dashes
    const parts = text.split(/\n\s*-{3,}\s*\n/);
    if (parts.length >= 2) {
      title = parts[0];
      description = parts.slice(1).join("\n");
    } else {
      // 3) first line = title, the rest = description
      const lines = text.split("\n").map((l) => l.trim()).filter(Boolean);
      title = lines.shift() || "";
      description = lines.join(" ");
    }
  }
  title = clean(title).replace(/\s*#\w+/g, "").slice(0, 70).trim();
  description = clean(description).replace(/\n-{3,}\s*$/g, "").trim();
  return { title, description };
}

// Claude writes the YouTube title and description from the article, with the same strict rules as the Facebook post.
async function writeTitleAndDescription(post) {
  const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const msg = await client.messages.create({
    model: "claude-haiku-5-5",
    max_tokens: 1500,
    messages: [{
      role: "user",
      content:
        "Write the YouTube Shorts title and description for a Funparks theme park app video based on the article below.\n\n" +
        "Rules:\n" +
        "- English only.\n" +
        "- Title: a punchy hook, max 55 characters, no hashtags, at most one emoji.\n" +
        "- Description: 2 short sentences using ONLY facts stated in the article. No statistics, counts, sizes, prices, dates or records. " +
        "Do not invent ride names or claims. Mention that the free Funparks app is on iOS and Android. Do not include any link.\n" +
        "- Do not mention how the video was made.\n" +
        "- Output exactly in this format and nothing else:\n" +
        "Title: <the title>\nDescription: <the description>\n\n" +
        "Article title: " + post.title + "\nSummary: " + post.excerpt + "\nArticle: " + plain(post.content).slice(0, 2500),
    }],
  });
  console.log("Claude stop_reason:", msg.stop_reason, "blocks:", msg.content.map((b) => b.type).join(","));
  const text = msg.content.filter((b) => b.type === "text").map((b) => b.text).join("").trim();
  const { title, description } = splitTitleAndDescription(text);
  if (!title || !description) {
    throw new Error("Claude did not return a usable title and description. Raw answer: " + JSON.stringify(text.slice(0, 300)));
  }
  return { title, description };
}

exports.postBlogToYouTube = onSchedule(
  {
    schedule: "30 18 * * 1,3,5",
    timeZone: "Europe/Paris",
    region: "europe-west1",
    timeoutSeconds: 900,
    memory: "2GiB",
    secrets: [YT_CLIENT_ID, YT_CLIENT_SECRET, YT_REFRESH_TOKEN],
  },
  async () => {
    const db = admin.firestore();
    const snap = await db.collection("social_posts").where("status", "==", "posted").get();
    const cutoff = Date.now() - MAX_AGE_DAYS * 24 * 3600 * 1000;
    const candidates = snap.docs
      .filter((d) => {
        const x = d.data();
        return !x.youtubeStatus || (x.youtubeStatus === "failed" && (x.youtubeAttempts || 0) < MAX_ATTEMPTS);
      })
      .filter((d) => {
        const c = d.data().createdAt;
        return c && c.toMillis && c.toMillis() >= cutoff;
      })
      .sort((a, b) => b.data().createdAt.toMillis() - a.data().createdAt.toMillis());
    if (candidates.length === 0) {
      console.log("YouTube: no new article waiting for a video.");
      return;
    }
    const doc = candidates[0];
    const slug = doc.id;

    // Claim it so a second run can never post it twice.
    const claimed = await db.runTransaction(async (tx) => {
      const cur = await tx.get(doc.ref);
      const x = cur.data();
      if (x.youtubeStatus && !(x.youtubeStatus === "failed" && (x.youtubeAttempts || 0) < MAX_ATTEMPTS)) return false;
      tx.update(doc.ref, { youtubeStatus: "posting", youtubeAttempts: (x.youtubeAttempts || 0) + 1 });
      return true;
    });
    if (!claimed) { console.log("YouTube: already handled " + slug); return; }

    try {
      const res = await fetch(SITE + "/blog-posts.json?t=" + Date.now());
      if (!res.ok) throw new Error("Could not load blog posts: " + res.status);
      const posts = await res.json();
      const post = Array.isArray(posts) ? posts.find((p) => p.slug === slug) : null;
      if (!post) throw new Error("Article not found on the website: " + slug);

      const { title, description } = await writeTitleAndDescription(post);
      // Use the video made by the 17:00 step. Only if there is none, make one now.
      const stored = doc.data();
      let video;
      if (stored.videoUrl) {
        const [buffer] = await admin.storage().bucket(BUCKET).file(storagePathFromUrl(stored.videoUrl)).download();
        video = { buffer, url: stored.videoUrl, prompt: stored.videoPrompt || null, model: stored.videoModel || null, check: stored.videoCheck || stored.youtubeCheck || null };
        console.log("YouTube: using the video already made (" + buffer.length + " bytes): " + video.url);
      } else {
        video = await generateArticleVideo(slug, post.title, post.excerpt || "");
        console.log("YouTube: video ready (" + video.model + ", " + video.buffer.length + " bytes): " + video.url);
      }

      // Public only when Gemini confirmed the clip is safe. Otherwise private, for you to check.
      const privacy = video.check && video.check.ok === true ? YT_PRIVACY : "private";
      if (privacy !== YT_PRIVACY) console.log("YouTube: safety check not passed (" + (video.check && video.check.reason) + ") - uploading as private.");

      const token = await getAccessToken();
      const result = await uploadVideo(
        video.buffer,
        {
          snippet: {
            title: (title + " #Shorts").slice(0, 100),
            description: description + "\n\nFull guide: " + SITE + "/blog/" + slug + "\n\n#Funparks #ThemePark #Shorts",
            tags: ["Funparks", "theme park", "roller coaster", "amusement park", "Shorts"],
            categoryId: "19",
          },
          status: {
            privacyStatus: privacy,
            selfDeclaredMadeForKids: false,
            containsSyntheticMedia: true,
          },
        },
        token
      );
      await doc.ref.update({
        youtubeStatus: "posted",
        youtubeVideoId: result.id,
        youtubePrivacy: privacy,
        youtubeCheck: video.check ? { ok: video.check.ok, reason: video.check.reason, model: video.check.model } : null,
        videoUrl: video.url,
        videoPrompt: video.prompt,
      });
      console.log("YOUTUBE POSTED: https://www.youtube.com/watch?v=" + result.id + " (" + privacy + ")");
    } catch (e) {
      console.error("YouTube error:", errText(e));
      await doc.ref.update({ youtubeStatus: "failed", youtubeError: errText(e) });
    }
  }
);
