const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { generateArticleVideo } = require("./video");

const SITE = "https://funparks.app";
const errText = (e) => String(e && e.message ? e.message : e).slice(0, 600);

// Runs before the Facebook/Instagram post (17:00 Paris). Makes the video for the newest article
// once, so that Facebook, Instagram, YouTube and TikTok can all use the same file.
exports.prepareArticleVideo = onSchedule(
  {
    schedule: "0 17 * * 1,3,5",
    timeZone: "Europe/Paris",
    region: "europe-west1",
    timeoutSeconds: 900,
    memory: "2GiB",
  },
  async () => {
    const db = admin.firestore();
    const res = await fetch(SITE + "/blog-posts.json?t=" + Date.now());
    if (!res.ok) throw new Error("Could not load blog posts: " + res.status);
    const posts = await res.json(); // newest first
    if (!Array.isArray(posts) || posts.length === 0) return;

    const snap = await db.collection("social_posts").get();
    const handled = new Set(snap.docs.map((d) => d.id));
    const post = posts.find((p) => p.slug && !handled.has(p.slug));
    if (!post) {
      console.log("Video step: no new article waiting.");
      return;
    }
    const ref = db.collection("social_posts").doc(post.slug);

    const claimed = await db.runTransaction(async (tx) => {
      if ((await tx.get(ref)).exists) return false;
      tx.set(ref, { status: "preparing", title: post.title, createdAt: admin.firestore.FieldValue.serverTimestamp() });
      return true;
    });
    if (!claimed) { console.log("Video step: already handled " + post.slug); return; }

    // Saves the result. If posting has already moved on (the 18:00 step did not wait), only the video fields are added.
    async function finish(status, fields) {
      await db.runTransaction(async (tx) => {
        const cur = await tx.get(ref);
        const data = cur.exists ? cur.data() : {};
        if (data.status === "preparing") tx.update(ref, { status, ...fields });
        else tx.update(ref, fields);
      });
    }

    try {
      const video = await generateArticleVideo(post.slug, post.title, post.excerpt || "");
      console.log("VIDEO READY (" + video.model + ", " + video.buffer.length + " bytes): " + video.url);
      const check = video.check ? { ok: video.check.ok, reason: video.check.reason, model: video.check.model } : { ok: null, reason: "no check", model: null };
      await finish("video-ready", {
        videoUrl: video.url,
        videoPrompt: video.prompt,
        videoModel: video.model,
        videoCheck: check,
      });
      console.log("Safety check for " + post.slug + ": ok=" + check.ok + " " + (check.reason || ""));
    } catch (e) {
      console.error("Video step failed:", errText(e));
      await finish("video-failed", { videoError: errText(e) });
    }
  }
);
