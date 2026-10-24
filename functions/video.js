const crypto = require("crypto");
const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFile } = require("child_process");
const admin = require("firebase-admin");
const Anthropic = require("@anthropic-ai/sdk");
const { GoogleGenAI } = require("@google/genai");
const ffmpegPath = require("ffmpeg-static");

const BUCKET = "funparks-779c6.firebasestorage.app";
const MODELS = ["veo-3.1-fast-generate-001", "veo-3.1-lite-generate-001", "veo-3.1-generate-001"];
const ENDCARD = path.join(__dirname, "assets", "endcard.png");
const ENDCARD_SECONDS = 4; // 6 s clip + 4 s end card = about 10 s, the length of the song
const SONG = path.join(__dirname, "assets", "funparks_audio.mp3");
const NEGATIVE =
  "collision, crash, head-on, near miss, derailment, accident, fire, explosion, smoke, injury, danger, first-person view on tracks, " +
  "oncoming train, second train, text, letters, watermark, logo, cartoon character";

// The scene that already worked in videoTest. Used when the article-based scene is refused.
const FALLBACK_PROMPT =
  "Photorealistic vertical video of a theme park at golden hour: a steel roller coaster train swoops through a drop above a happy crowd, " +
  "gentle camera movement, natural colors, cinematic. No text, no logos, no cartoon characters.";

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const errText = (e) => String(e && e.message ? e.message : e).slice(0, 400);

// Claude turns the article into a short, safe scene description for the video model.
async function writeScenePrompt(title, excerpt) {
  const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
  const msg = await client.messages.create({
    model: "claude-haiku-5-5",
    max_tokens: 2500,
    messages: [{
      role: "user",
      content:
        "Write ONE scene description (max 70 words) for a 6-second vertical (9:16) photorealistic video that fits this theme park article. " +
        "It must feel exciting and cinematic but completely SAFE. Choose ONE of these styles:\n" +
        "- a side-angle or low-angle exterior shot of a single roller coaster train passing by with cheering riders, camera smoothly tracking it\n" +
        "- a slow aerial drone shot over a theme park at golden hour\n" +
        "- colourful rides glowing at dusk with happy crowds\n" +
        "- a ferris wheel or swing ride against a dramatic sky\n" +
        "Strict rules: never a first-person or on-the-tracks view; never more than one train, and never any train or vehicle coming toward the camera; " +
        "no collision, near-miss, crash, derailment, fire, explosion, smoke or anyone in danger or distress; " +
        "no text or letters anywhere, no logos, no brand names, no cartoon or mascot characters, no real people's faces in close-up, no named rides or parks. " +
        "Do not describe how the video was made.\n" +
        "Output only the scene description.\n\n" +
        "Article title: " + title + "\nSummary: " + excerpt,
    }],
  });
  const scene = msg.content.filter((b) => b.type === "text").map((b) => b.text).join("").trim();
  console.log("Scene writer: stop_reason " + msg.stop_reason + ", " + scene.length + " characters.");
  return scene;
}

async function generateClip(ai, prompt) {
  for (const model of MODELS) {
    try {
      let op = await ai.models.generateVideos({
        model,
        prompt,
        config: { numberOfVideos: 1, aspectRatio: "9:16", durationSeconds: 6, resolution: "720p", generateAudio: false, negativePrompt: NEGATIVE },
      });
      const started = Date.now();
      while (!op.done) {
        if (Date.now() - started > 300000) throw new Error("timed out waiting for the video");
        await sleep(10000);
        op = await ai.operations.getVideosOperation({ operation: op });
      }
      if (op.error) throw new Error(JSON.stringify(op.error));
      const resp = op.response || {};
      const vid = resp.generatedVideos && resp.generatedVideos[0] && resp.generatedVideos[0].video;
      if (!vid) {
        console.log("Veo " + model + ": no video returned. " + JSON.stringify(resp.raiMediaFilteredReasons || ""));
        continue;
      }
      if (vid.videoBytes) return { buffer: Buffer.from(vid.videoBytes, "base64"), model };
      if (vid.uri && vid.uri.startsWith("gs://")) {
        const m = vid.uri.match(/^gs:\/\/([^/]+)\/(.+)$/);
        const [buf] = await admin.storage().bucket(m[1]).file(m[2]).download();
        return { buffer: buf, model };
      }
      console.log("Veo " + model + ": unexpected video form.");
    } catch (e) {
      console.log("Veo " + model + " failed: " + errText(e));
    }
  }
  return null;
}

function run(cmd, args) {
  return new Promise((resolve, reject) => {
    execFile(cmd, args, { maxBuffer: 20 * 1024 * 1024 }, (err, stdout, stderr) => {
      if (err) reject(new Error("ffmpeg failed: " + String(stderr || err.message).slice(-500)));
      else resolve();
    });
  });
}

// Sticks the Funparks end card (still picture) on the end of the clip. Returns the finished mp4 as a Buffer.
async function addEndCard(clipBuffer) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "vid-"));
  const inPath = path.join(dir, "clip.mp4");
  const outPath = path.join(dir, "final.mp4");
  fs.writeFileSync(inPath, clipBuffer);
  const hasSong = fs.existsSync(SONG);
  const filter =
    "[0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,setsar=1,fps=30,format=yuv420p[a];" +
    "[1:v]scale=720:1280,setsar=1,fps=30,format=yuv420p[b];" +
    "[a][b]concat=n=2:v=1:a=0[v]" +
    (hasSong ? ";[2:a]afade=t=out:st=9.4:d=0.5,apad=whole_dur=10[aud]" : "");
  const args = ["-y", "-i", inPath, "-loop", "1", "-t", String(ENDCARD_SECONDS), "-i", ENDCARD];
  if (hasSong) args.push("-i", SONG);
  args.push("-filter_complex", filter, "-map", "[v]");
  if (hasSong) args.push("-map", "[aud]", "-c:a", "aac", "-b:a", "128k", "-t", "10");
  args.push("-c:v", "libx264", "-preset", "veryfast", "-crf", "23", "-movflags", "+faststart", outPath);
  await run(ffmpegPath, args);
  const out = fs.readFileSync(outPath);
  fs.rmSync(dir, { recursive: true, force: true });
  return out;
}

// Pulls a dozen still frames out of the clip (2 per second), in order, as base64 JPEGs.
async function extractFrames(clipBuffer) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "frames-"));
  try {
    fs.writeFileSync(path.join(dir, "clip.mp4"), clipBuffer);
    await run(ffmpegPath, [
      "-y", "-i", path.join(dir, "clip.mp4"),
      "-vf", "fps=2,scale=400:-2", "-q:v", "5",
      path.join(dir, "f_%02d.jpg"),
    ]);
    return fs.readdirSync(dir)
      .filter((f) => f.startsWith("f_") && f.endsWith(".jpg"))
      .sort()
      .map((f) => fs.readFileSync(path.join(dir, f)).toString("base64"));
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

// Claude looks at the frames in order. Returns { ok: true|false|null, reason, model }.
// ok === null means the check itself could not be done.
async function reviewClip(clipBuffer) {
  const model = "claude-haiku-5-5";
  try {
    const frames = await extractFrames(clipBuffer);
    if (frames.length < 4) throw new Error("only " + frames.length + " frames extracted");
    const content = [];
    frames.forEach((data, i) => {
      content.push({ type: "text", text: "Frame " + (i + 1) + " of " + frames.length + " (0.5 s apart):" });
      content.push({ type: "image", source: { type: "base64", media_type: "image/jpeg", data } });
    });
    content.push({
      type: "text",
      text:
        "These frames, in time order, are from a short promotional video for a theme park app. You are the safety reviewer. " +
        "Answer UNSAFE if the video shows or strongly suggests ANY of: a collision or near-collision between rides or vehicles; " +
        "a train or vehicle heading toward the camera on the same track, or two trains on one track; a crash, derailment, fire, smoke or explosion; " +
        "an accident; a person in danger, distress or injured; readable text or letters; a logo or brand; a cartoon or mascot character; " +
        "anything distorted, broken or disturbing (for example warped bodies or faces). Otherwise answer SAFE. " +
        "The first line of your answer must be exactly SAFE or UNSAFE. Then one short sentence of reason.",
    });
    const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });
    const msg = await client.messages.create({ model, max_tokens: 2500, messages: [{ role: "user", content }] });
    console.log("Safety reviewer: stop_reason " + msg.stop_reason + ", blocks " + msg.content.map((b) => b.type).join(","));
    const text = msg.content.filter((b) => b.type === "text").map((b) => b.text).join("").trim();
    const first = (text.split("\n")[0] || "").toUpperCase();
    const ok = first.includes("UNSAFE") ? false : first.includes("SAFE") ? true : null;
    console.log("SAFETY CHECK (" + model + ", " + frames.length + " frames): " + text.slice(0, 300));
    return { ok, reason: text.slice(0, 300), model };
  } catch (e) {
    console.log("Safety check failed: " + errText(e));
    return { ok: null, reason: "safety check failed: " + errText(e), model: null };
  }
}

// Makes the finished vertical video for one article and saves it in Firebase Storage.
// Returns { url, path, buffer, prompt, model, check }.
// check.ok === true only when Gemini watched the clip and found it safe.
async function generateArticleVideo(slug, title, excerpt) {
  const ai = new GoogleGenAI({ vertexai: true, enterprise: true, project: "funparks-779c6", location: "us-central1" });

  let articlePrompt = "";
  try {
    articlePrompt = await writeScenePrompt(title, excerpt);
  } catch (e) {
    console.log("Scene prompt from Claude failed, using the standard scene: " + errText(e));
  }
  // Up to three tries: the article scene, then the standard scene twice.
  const prompts = [];
  if (articlePrompt) prompts.push(articlePrompt);
  prompts.push(FALLBACK_PROMPT, FALLBACK_PROMPT);

  let best = null;
  for (const prompt of prompts) {
    console.log("Video scene: " + prompt.slice(0, 300));
    const clip = await generateClip(ai, prompt);
    if (!clip) { console.log("No clip for that scene."); continue; }
    const check = await reviewClip(clip.buffer);
    const candidate = { clip, prompt, check };
    if (check.ok === true) { best = candidate; break; }
    if (!best) best = candidate; // keep something to upload privately for review
    if (check.ok === null) break; // checker unavailable: more tries will not help
    console.log("Clip rejected by the safety check, trying another.");
  }
  if (!best) throw new Error("No video model produced a clip");

  const finalBuffer = await addEndCard(best.clip.buffer);
  const token = crypto.randomUUID();
  const filePath = "social-videos/" + slug + "-" + Date.now() + ".mp4";
  await admin.storage().bucket(BUCKET).file(filePath).save(finalBuffer, {
    contentType: "video/mp4",
    metadata: { metadata: { firebaseStorageDownloadTokens: token } },
  });
  const url = "https://firebasestorage.googleapis.com/v0/b/" + BUCKET + "/o/" + encodeURIComponent(filePath) + "?alt=media&token=" + token;
  return { url, path: filePath, buffer: finalBuffer, prompt: best.prompt, model: best.clip.model, check: best.check };
}

module.exports = { generateArticleVideo };
