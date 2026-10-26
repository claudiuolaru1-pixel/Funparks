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
// Statuses written by the 17:00 video step. These articles are not posted yet.
const PREP_STATUSES = ["preparing", "video-ready", "video-failed"];
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

// Prepares an Instagram Reel (not yet public) and waits until Instagram has processed the video.
async function createInstagramReelContainer(videoUrl, caption, token) {
  const c = await graphPost("/" + IG_ID + "/media", {
    media_type: "REELS",
    video_url: videoUrl,
    caption: caption,
    share_to_feed: "true",
    access_token: token,
  });
  for (let i = 0; i < 60; i++) {
    await sleep(5000);
    const s = await graphGet("/" + c.id, { fields: "status_code,status", access_token: token });
    if (s.status_code === "FINISHED") return c.id;
    if (s.status_code === "ERROR" || s.status_code === "EXPIRED") {
      throw new Error("Instagram Reel status: " + s.status_code + " " + JSON.stringify(s.status || ""));
    }
  }
  throw new Error("Instagram Reel was not ready in time");
}

// Publishes the video as a Facebook Reel on the Page (start -> upload from URL -> finish).
async function postFacebookReel(videoUrl, description, token) {
  const start = await graphPost("/" + PAGE_ID + "/video_reels", { upload_phase: "start", access_token: token });
  if (!start.video_id || !start.upload_url) throw new Error("Facebook Reel start gave no upload address: " + JSON.stringify(start));
  const up = await fetch(start.upload_url, {
    method: "POST",
    headers: { Authorization: "OAuth " + token, file_url: videoUrl },
  });
  const upData = await up.json().catch(() => ({}));
  if (!up.ok || upData.success === false) throw new Error("Facebook Reel upload failed: HTTP " + up.status + " " + JSON.stringify(upData).slice(0, 300));
  // Give Facebook a little time to take the file in, then publish.
  for (let i = 0; i < 12; i++) {
    await sleep(5000);
    try {
      const s = await graphGet("/" + start.video_id, { fields: "status", access_token: token });
      const st = s.status || {};
      const phase = st.uploading_phase && st.uploading_phase.status;
      console.log("Facebook Reel upload status: " + JSON.stringify(st).slice(0, 200));
      if (st.video_status === "error" || phase === "error") throw new Error("Facebook Reel upload error: " + JSON.stringify(st).slice(0, 300));
      if (phase === "complete" || st.video_status === "upload_complete" || st.video_status === "ready") break;
    } catch (e) {
      if (String(e.message).startsWith("Facebook Reel upload error")) throw e;
      console.log("Facebook Reel status check skipped: " + errText(e));
    }
  }
  const fin = await graphPost("/" + PAGE_ID + "/video_reels", {
    access_token: token,
    video_id: start.video_id,
    upload_phase: "finish",
    video_state: "PUBLISHED",
    description: description,
  });
  if (fin.success === false) throw new Error("Facebook Reel publish failed: " + JSON.stringify(fin).slice(0, 300));
  return { id: start.video_id };
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
    timeoutSeconds: 900,
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
    // Articles the 17:00 video step has only prepared are not posted yet.
    const done = new Set(doneSnap.docs.filter((d) => !PREP_STATUSES.includes(d.data().status)).map((d) => d.id));
    const post = posts.find((p) => p.slug && !done.has(p.slug));
    if (!post) {
      console.log("No new article to post.");
      return;
    }

    const claimRef = db.collection("social_posts").doc(post.slug);

    // The video step (17:00) may have prepared a video. Wait a little if it is still working.
    let prep = await claimRef.get();
    for (let i = 0; i < 24 && prep.exists && prep.data().status === "preparing"; i++) {
      console.log("Video is still being prepared, waiting...");
      await sleep(10000);
      prep = await claimRef.get();
    }
    const prepData = prep.exists ? prep.data() : null;
    const priorStatus = prepData ? prepData.status : null;
    // A Reel is only posted when the video passed the safety check.
    const reelOk = !!(prepData && prepData.status === "video-ready" && prepData.videoUrl && prepData.videoCheck && prepData.videoCheck.ok === true);
    if (reelOk) console.log("Safe video found - posting as a Reel: " + prepData.videoUrl);
    else console.log("No safe video for this article (" + (priorStatus || "none") + ") - posting the picture.");

    const caption = await writeCaption(post);
    if (!caption) throw new Error("Empty caption from Claude - not posting");
    const link = SITE + "/blog/" + post.slug;
    const igCaption = instagramCaption(caption);
    const token = FACEBOOK_PAGE_TOKEN.value();

    // The picture is only made when it is needed (no Reel, or the Reel failed).
    let image = null;
    let imageTried = false;
    async function ensureImage() {
      if (imageTried) return image;
      imageTried = true;
      try {
        image = await generateArticleImage(post.slug, post.title);
        console.log("Image ready:", image.url);
      } catch (e) {
        console.error("Image generation failed, will post without picture:", errText(e));
      }
      return image;
    }
    if (DRY_RUN || !reelOk) await ensureImage();

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

    const claimed = await db.runTransaction(async (tx) => {
      const cur = await tx.get(claimRef);
      if (cur.exists && !PREP_STATUSES.includes(cur.data().status)) return false;
      tx.set(claimRef, { status: "posting", title: post.title, createdAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      return true;
    });
    if (!claimed) { console.log("Already handled:", post.slug); return; }

    // 1) Facebook: Reel if there is a safe video, otherwise (or if the Reel fails) the picture.
    let fbData = null;
    let fbFormat = null;
    let reelError = null;
    try {
      if (reelOk) {
        try {
          fbData = await postFacebookReel(prepData.videoUrl, caption + "\n\n" + link, token);
          fbFormat = "reel";
        } catch (e) {
          reelError = errText(e);
          console.error("Facebook Reel failed, falling back to the picture:", reelError);
        }
      }
      if (!fbData) {
        await ensureImage();
        if (image) {
          fbData = await graphPost("/" + PAGE_ID + "/photos", {
            url: image.url,
            message: caption + "\n\n" + link,
            access_token: token,
          });
          fbFormat = "photo";
        } else {
          fbData = await graphPost("/" + PAGE_ID + "/feed", {
            message: caption,
            link: link,
            access_token: token,
          });
          fbFormat = "link";
        }
      }
    } catch (e) {
      console.error("Facebook error:", errText(e));
      // Put the article back as it was, so the next run can try again (the video stays saved).
      if (priorStatus) await claimRef.update({ status: priorStatus });
      else await claimRef.delete();
      throw new Error("Facebook post failed");
    }
    const fbId = fbData.post_id || fbData.id;
    await claimRef.set({
      status: "posted",
      title: post.title,
      facebookPostId: fbId,
      facebookFormat: fbFormat,
      facebookReelError: reelError,
      imageUrl: image ? image.url : null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    console.log("Posted to Facebook (" + fbFormat + "):", fbId);

    // 2) Instagram (a failure here never undoes or repeats the Facebook post)
    let igReelError = null;
    if (reelOk) {
      try {
        const cid = await createInstagramReelContainer(prepData.videoUrl, igCaption, token);
        const pub = await graphPost("/" + IG_ID + "/media_publish", { creation_id: cid, access_token: token });
        await claimRef.update({ instagramStatus: "posted", instagramPostId: pub.id, instagramFormat: "reel" });
        console.log("Posted to Instagram (reel):", pub.id);
        return;
      } catch (e) {
        igReelError = errText(e);
        console.error("Instagram Reel failed, trying the picture:", igReelError);
      }
    }
    await ensureImage();
    if (!image) {
      await claimRef.update({ instagramStatus: "skipped-no-image", instagramReelError: igReelError });
      console.log("Instagram skipped: no image.");
      return;
    }
    try {
      const cid = await createInstagramContainer(image.url, igCaption, token);
      const pub = await graphPost("/" + IG_ID + "/media_publish", { creation_id: cid, access_token: token });
      await claimRef.update({ instagramStatus: "posted", instagramPostId: pub.id, instagramFormat: "photo", instagramReelError: igReelError });
      console.log("Posted to Instagram (photo):", pub.id);
    } catch (e) {
      console.error("Instagram error:", errText(e));
      await claimRef.update({ instagramStatus: "failed", instagramError: errText(e), instagramReelError: igReelError });
    }
  }
);
