const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Anthropic = require("@anthropic-ai/sdk");

const TIKTOK_CLIENT_KEY = defineSecret("TIKTOK_CLIENT_KEY");
const TIKTOK_CLIENT_SECRET = defineSecret("TIKTOK_CLIENT_SECRET");
const TIKTOK_REFRESH_TOKEN = defineSecret("TIKTOK_REFRESH_TOKEN");

const BUCKET = "funparks-779c6.firebasestorage.app";
const SITE = "https://funparks.app";
const API = "https://open.tiktokapis.com";
const MAX_AGE_DAYS = 4;
const MAX_ATTEMPTS = 2;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const errText = (e) => String(e && e.message ? e.message : e).slice(0, 600);

// TikTok may hand out a new refresh token when we refresh. The newest one is kept in Firestore;
// the secret is only the starting point.
async function getAccessToken(db) {
  const ref = db.collection("social_state").doc("tiktok");
  const snap = await ref.get();
  const refreshToken = (snap.exists && snap.data().refreshToken) || TIKTOK_REFRESH_TOKEN.value();
  const r = await fetch(API + "/v2/oauth/token/", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_key: TIKTOK_CLIENT_KEY.value(),
      client_secret: TIKTOK_CLIENT_SECRET.value(),
      grant_type: "refresh_token",
      refresh_token: refreshToken,
    }),
  });
  const data = await r.json();
  if (!r.ok || !data.access_token) throw new Error("TikTok token refresh failed: " + JSON.stringify(data));
  if (data.refresh_token && data.refresh_token !== refreshToken) {
    await ref.set({ refreshToken: data.refresh_token, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  }
  // Log which TikTok account this token belongs to, so we know where drafts are delivered.
  try {
    const u = await fetch(API + "/v2/user/info/?fields=open_id,display_name,avatar_url", {
      headers: { Authorization: "Bearer " + data.access_token },
    });
    console.log("TIKTOK ACCOUNT: " + JSON.stringify(await u.json()) + " | scopes: " + (data.scope || "unknown"));
  } catch (e) {
    console.log("TikTok account lookup failed: " + errText(e));
  }
  return data.access_token;
}

async function fetchStatus(accessToken, publishId) {
  const r = await fetch(API + "/v2/post/publish/status/fetch/", {
    method: "POST",
    headers: { Authorization: "Bearer " + accessToken, "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify({ publish_id: publishId }),
  });
  return await r.json();
}

// Sends the video to the TikTok account's drafts (inbox) in one piece.
async function sendToDrafts(videoBuffer, accessToken) {
  const size = videoBuffer.length;
  const init = await fetch(API + "/v2/post/publish/inbox/video/init/", {
    method: "POST",
    headers: { Authorization: "Bearer " + accessToken, "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify({
      source_info: { source: "FILE_UPLOAD", video_size: size, chunk_size: size, total_chunk_count: 1 },
    }),
  });
  const initData = await init.json();
  if (!init.ok || (initData.error && initData.error.code && initData.error.code !== "ok")) {
    throw new Error("TikTok init failed: " + JSON.stringify(initData.error || initData));
  }
  const { publish_id, upload_url } = initData.data || {};
  if (!publish_id || !upload_url) throw new Error("TikTok init gave no upload address: " + JSON.stringify(initData));

  const put = await fetch(upload_url, {
    method: "PUT",
    headers: {
      "Content-Type": "video/mp4",
      "Content-Range": "bytes 0-" + (size - 1) + "/" + size,
    },
    body: videoBuffer,
  });
  const putBody = (await put.text()).slice(0, 300);
  console.log("TikTok upload PUT: HTTP " + put.status + " " + putBody + " (video " + size + " bytes)");
  if (!put.ok) throw new Error("TikTok upload failed: HTTP " + put.status + " " + putBody);

  // Wait for TikTok to confirm the draft arrived (up to about 3 minutes).
  let status = "UNKNOWN";
  let detail = null;
  for (let i = 0; i < 36; i++) {
    await sleep(5000);
    detail = await fetchStatus(accessToken, publish_id);
    status = (detail.data && detail.data.status) || "UNKNOWN";
    if (i % 3 === 0 || status !== "PROCESSING_UPLOAD") console.log("TikTok status check " + (i + 1) + ": " + JSON.stringify(detail));
    if (status === "SEND_TO_USER_INBOX" || status === "PUBLISH_COMPLETE" || status === "FAILED") break;
  }
  if (status === "FAILED") throw new Error("TikTok reported FAILED: " + JSON.stringify(detail).slice(0, 400));
  return { publishId: publish_id, status };
}

function plain(text) {
  return String(text || "").replace(/https?:\/\/\S+/g, "").replace(/[#*_`>\[\]]/g, "").replace(/\s+/g, " ").trim();
}

// The upload-to-drafts route does not take a caption, so a suggested one is saved for you to paste in TikTok.
async function writeCaption(post) {
  const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const msg = await client.messages.create({
    model: "claude-haiku-5-5",
    max_tokens: 2500,
    messages: [{
      role: "user",
      content:
        "Write a TikTok caption for a Funparks theme park app video based on the article below.\n" +
        "Rules: English only. One punchy hook line (max 12 words, one emoji at most), then one short sentence using ONLY facts from the article " +
        "(no statistics, counts, sizes, prices, dates or records, no invented names). Mention the free Funparks app on iOS and Android. " +
        "No links. Last line: 4 or 5 hashtags including #Funparks and #ThemePark. Do not mention how the video was made. Output only the caption.\n\n" +
        "Title: " + post.title + "\nSummary: " + post.excerpt + "\nArticle: " + plain(post.content).slice(0, 2000),
    }],
  });
  return msg.content.filter((b) => b.type === "text").map((b) => b.text).join("").trim();
}

function storagePathFromUrl(url) {
  const m = String(url).match(/\/o\/([^?]+)/);
  if (!m) throw new Error("Cannot read the storage path from the video address");
  return decodeURIComponent(m[1]);
}

exports.postBlogToTikTok = onSchedule(
  {
    schedule: "45 18 * * 1,3,5",
    timeZone: "Europe/Paris",
    region: "europe-west1",
    timeoutSeconds: 420,
    memory: "1GiB",
    secrets: [TIKTOK_CLIENT_KEY, TIKTOK_CLIENT_SECRET, TIKTOK_REFRESH_TOKEN],
  },
  async () => {
    const db = admin.firestore();
    const snap = await db.collection("social_posts").where("status", "==", "posted").get();

    // Re-check drafts that were still processing when they were sent, and log what TikTok says now.
    try {
      const pending = snap.docs.filter((d) => {
        const x = d.data();
        return x.tiktokStatus === "sent-to-drafts" && x.tiktokPublishId && x.tiktokApiStatus !== "SEND_TO_USER_INBOX" && x.tiktokApiStatus !== "PUBLISH_COMPLETE";
      });
      if (pending.length) {
        const token = await getAccessToken(db);
        for (const d of pending) {
          const detail = await fetchStatus(token, d.data().tiktokPublishId);
          const st = (detail.data && detail.data.status) || "UNKNOWN";
          console.log("TIKTOK RECHECK " + d.id + ": " + JSON.stringify(detail));
          await d.ref.update({ tiktokApiStatus: st });
        }
      }
    } catch (e) {
      console.log("TikTok recheck failed: " + errText(e));
    }
    const cutoff = Date.now() - MAX_AGE_DAYS * 24 * 3600 * 1000;
    const candidates = snap.docs
      .filter((d) => {
        const x = d.data();
        const c = x.createdAt;
        if (!x.videoUrl || !c || !c.toMillis || c.toMillis() < cutoff) return false;
        return !x.tiktokStatus || (x.tiktokStatus === "failed" && (x.tiktokAttempts || 0) < MAX_ATTEMPTS);
      })
      .sort((a, b) => b.data().createdAt.toMillis() - a.data().createdAt.toMillis());
    if (candidates.length === 0) {
      console.log("TikTok: no video waiting to be sent.");
      return;
    }
    const doc = candidates[0];
    const slug = doc.id;

    const claimed = await db.runTransaction(async (tx) => {
      const x = (await tx.get(doc.ref)).data();
      if (x.tiktokStatus && !(x.tiktokStatus === "failed" && (x.tiktokAttempts || 0) < MAX_ATTEMPTS)) return false;
      tx.update(doc.ref, { tiktokStatus: "sending", tiktokAttempts: (x.tiktokAttempts || 0) + 1 });
      return true;
    });
    if (!claimed) { console.log("TikTok: already handled " + slug); return; }

    try {
      const [videoBuffer] = await admin.storage().bucket(BUCKET).file(storagePathFromUrl(doc.data().videoUrl)).download();
      const accessToken = await getAccessToken(db);
      const result = await sendToDrafts(videoBuffer, accessToken);

      let caption = "";
      try {
        const res = await fetch(SITE + "/blog-posts.json?t=" + Date.now());
        const posts = res.ok ? await res.json() : [];
        const post = Array.isArray(posts) ? posts.find((p) => p.slug === slug) : null;
        if (post) caption = await writeCaption(post);
      } catch (e) {
        console.log("TikTok caption not written: " + errText(e));
      }
      await doc.ref.update({
        tiktokStatus: "sent-to-drafts",
        tiktokPublishId: result.publishId,
        tiktokApiStatus: result.status,
        tiktokCaption: caption,
      });
      console.log("TIKTOK DRAFT SENT: " + slug + " (" + result.status + ")\nSuggested caption:\n" + caption);
    } catch (e) {
      console.error("TikTok error:", errText(e));
      await doc.ref.update({ tiktokStatus: "failed", tiktokError: errText(e) });
    }
  }
);
