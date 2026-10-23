const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const Anthropic = require("@anthropic-ai/sdk");
const { generateArticleImage } = require("./imagegen");

const FACEBOOK_PAGE_TOKEN = defineSecret("FACEBOOK_PAGE_TOKEN");
const PAGE_ID = "1166040799926353";
const IG_ID = "17841402111399337";
const GRAPH = "https://graph.facebook.com/v26.0";
const SITE = "https://funparks.app";
// Safety switch: while true, nothing is published (only safe pre-flight checks run).
const DRY_RUN = false;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const errText = (e) => String(e && e.message ? e.message : e).slice(0, 400);

function plain(text) {
  return String(text || "")
    .replace(/https?:\/\/\S+/g, "")
    .replace(/[#*_`>\[\]]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

async function graphPost(path, params) {
  const r = await fetch(GRAPH + path, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams(params),
  });
  const data = await r.json();
  if (!r.ok) throw new Error(JSON.stringify(data.error || data));
  return data;
}

async function graphGet(path, params) {
  const r = await fetch(GRAPH + path + "?" + new URLSearchParams(params));
  const data = await r.json();
  if (!r.ok) throw new Error(JSON.stringify(data.error || data));
  return data;
}

async function graphDelete(id, token) {
  const r = await fetch(GRAPH + "/" + id + "?" + new URLSearchParams({ access_token: token }), { method: "DELETE" });
  return r.ok;
}

// Instagram has no clickable links in captions: put "link in bio" above the hashtags.
function instagramCaption(caption) {
  const lines = caption.trim().split("\n");
  let tags = "";
  if (lines.length > 1 && lines[lines.length - 1].trim().startsWith("#")) {
    tags = lines.pop().trim();
  }
  const body = lines.join("\n").trim();
  return body + "\n\nFull guide: link in bio \uD83D\uDD17" + (tags ? "\n\n" + tags : "");
}

// Prepares an Instagram post (not yet public) and waits until Instagram accepts the picture.
async function createInstagramContainer(imageUrl, caption, token) {
  const c = await graphPost("/" + IG_ID + "/media", { image_url: imageUrl, caption: caption, access_token: token });
  for (let i = 0; i < 12; i++) {
    const s = await graphGet("/" + c.id, { fields: "status_code", access_token: token });
    if (s.status_code === "FINISHED") return c.id;
    if (s.status_code === "ERROR" || s.status_code === "EXPIRED") {
      throw new Error("Instagram container status: " + s.status_code);
    }
    await sleep(3000);
  }
  throw new Error("Instagram container was not ready in time");
}

async function writeCaption(post) {
  const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const msg = await client.messages.create({
    model: "claude-haiku-5-5",
    max_tokens: 1500,
    messages: [{
      role: "user",
      content:
        "Write a Facebook post for the Funparks theme park app page.\n\n" +
        "Rules:\n" +
        "- English only.\n" +
        "- Line 1: a punchy hook (max 12 words), one emoji at most.\n" +
        "- Then 2 short sentences using ONLY facts stated in the article below. Do not include any statistics, visitor counts, sizes, prices, dates or records, even if the article mentions them. Do not invent ride names or claims, and do not use praise words like world-class or best unless the article says so.\n" +
        "- Mention that the free Funparks app is on iOS and Android.\n" +
        "- Do not include any link.\n" +
        "- Last line: 4 or 5 relevant hashtags, always including #Funparks and #ThemePark.\n" +
        "- Output only the post text.\n\n" +
        "Title: " + post.title + "\n" +
        "Summary: " + post.excerpt + "\n" +
        "Article: " + plain(post.content).slice(0, 2500),
    }],
  });
  console.log("Claude stop_reason:", msg.stop_reason, "blocks:", msg.content.map((b) => b.type).join(","));
  return msg.content.filter((b) => b.type === "text").map((b) => b.text).join("").trim();
}

exports.postBlogToFacebook = onSchedule(
  {
    schedule: "0 18 * * 1,3,5",
    timeZone: "Europe/Paris",
    region: "europe-west1",
    timeoutSeconds: 300,
    memory: "512MiB",
    secrets: [FACEBOOK_PAGE_TOKEN],
  },
  async () => {
    const db = admin.firestore();
    const res = await fetch(SITE + "/blog-posts.json?t=" + Date.now());
    if (!res.ok) throw new Error("Could not load blog posts: " + res.status);
    const posts = await res.json(); // newest first
    if (!Array.isArray(posts) || posts.length === 0) return;

    // First real run: treat every older article as already handled.
    const seedRef = db.collection("social_state").doc("facebook_seed");
    if (!DRY_RUN && !(await seedRef.get()).exists) {
      const batch = db.batch();
      posts.slice(1).forEach((p) => {
        batch.set(db.collection("social_posts").doc(p.slug), {
          status: "skipped",
          title: p.title,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
      batch.set(seedRef, { done: true, at: admin.firestore.FieldValue.serverTimestamp() });
      await batch.commit();
    }

    const doneSnap = await db.collection("social_posts").get();
    const done = new Set(doneSnap.docs.map((d) => d.id));
    const post = posts.find((p) => p.slug && !done.has(p.slug));
    if (!post) {
      console.log("No new article to post.");
      return;
    }

    const caption = await writeCaption(post);
    if (!caption) throw new Error("Empty caption from Claude - not posting");
    const link = SITE + "/blog/" + post.slug;
    const igCaption = instagramCaption(caption);
    const token = FACEBOOK_PAGE_TOKEN.value();

    // Make a picture. If that fails, Facebook falls back to a normal link post and Instagram is skipped.
    let image = null;
    try {
      image = await generateArticleImage(post.slug, post.title);
      console.log("Image ready:", image.url);
    } catch (e) {
      console.error("Image generation failed, will post without picture:", errText(e));
    }

    if (DRY_RUN) {
      console.log("DRY RUN - would post to Facebook:\n" + caption + "\n" + link);
      console.log("DRY RUN - would post to Instagram:\n" + igCaption);
      console.log("Image: " + (image ? image.url : "none"));
      if (image) {
        try {
          const cid = await createInstagramContainer(image.url, igCaption, token);
          console.log("PREFLIGHT Instagram OK: post prepared (id " + cid + "), NOT published");
        } catch (e) {
          console.error("PREFLIGHT Instagram FAILED:", errText(e));
        }
        try {
          const p = await graphPost("/" + PAGE_ID + "/photos", { url: image.url, published: "false", access_token: token });
          const removed = await graphDelete(p.id, token);
          console.log("PREFLIGHT Facebook OK: hidden test photo " + p.id + " created, removed=" + removed);
        } catch (e) {
          console.error("PREFLIGHT Facebook FAILED:", errText(e));
        }
      }
      return;
    }

    const claimRef = db.collection("social_posts").doc(post.slug);
    const claimed = await db.runTransaction(async (tx) => {
      if ((await tx.get(claimRef)).exists) return false;
      tx.set(claimRef, { status: "posting", title: post.title, createdAt: admin.firestore.FieldValue.serverTimestamp() });
      return true;
    });
    if (!claimed) { console.log("Already handled:", post.slug); return; }

    // 1) Facebook
    let fbData;
    try {
      if (image) {
        fbData = await graphPost("/" + PAGE_ID + "/photos", {
          url: image.url,
          message: caption + "\n\n" + link,
          access_token: token,
        });
      } else {
        fbData = await graphPost("/" + PAGE_ID + "/feed", {
          message: caption,
          link: link,
          access_token: token,
        });
      }
    } catch (e) {
      console.error("Facebook error:", errText(e));
      await claimRef.delete();
      throw new Error("Facebook post failed");
    }
    const fbId = fbData.post_id || fbData.id;
    await claimRef.set({
      status: "posted",
      title: post.title,
      facebookPostId: fbId,
      imageUrl: image ? image.url : null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("Posted to Facebook:", fbId);

    // 2) Instagram (a failure here never undoes or repeats the Facebook post)
    if (!image) {
      await claimRef.update({ instagramStatus: "skipped-no-image" });
      console.log("Instagram skipped: no image.");
      return;
    }
    try {
      const cid = await createInstagramContainer(image.url, igCaption, token);
      const pub = await graphPost("/" + IG_ID + "/media_publish", { creation_id: cid, access_token: token });
      await claimRef.update({ instagramStatus: "posted", instagramPostId: pub.id });
      console.log("Posted to Instagram:", pub.id);
    } catch (e) {
      console.error("Instagram error:", errText(e));
      await claimRef.update({ instagramStatus: "failed", instagramError: errText(e) });
    }
  }
);