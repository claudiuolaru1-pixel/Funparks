const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const crypto = require("crypto");
const { GoogleGenAI } = require("@google/genai");

const BUCKET = "funparks-779c6.firebasestorage.app";
const PROMPT = "Photorealistic vertical video of a theme park at golden hour: a steel roller coaster train swoops through a drop above a happy crowd, gentle camera movement, natural colors, cinematic. No text, no logos, no cartoon characters.";
const MODELS = ["veo-3.1-fast-generate-001", "veo-3.1-lite-generate-001", "veo-3.1-generate-001"];
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const errText = (e) => String(e && e.message ? e.message : e).slice(0, 400);

exports.videoTest = onSchedule(
  {
    schedule: "0 4 1 1 *",
    timeZone: "Europe/Paris",
    region: "europe-west1",
    timeoutSeconds: 540,
    memory: "1GiB",
  },
  async () => {
    const ai = new GoogleGenAI({
      vertexai: true,
      enterprise: true,
      project: "funparks-779c6",
      location: "us-central1",
    });
    const bucket = admin.storage().bucket(BUCKET);
    for (const model of MODELS) {
      try {
        let op = await ai.models.generateVideos({
          model,
          prompt: PROMPT,
          config: { numberOfVideos: 1, aspectRatio: "9:16", durationSeconds: 6, resolution: "720p", generateAudio: false },
        });
        const started = Date.now();
        while (!op.done) {
          if (Date.now() - started > 200000) throw new Error("timed out waiting for the video");
          await sleep(10000);
          op = await ai.operations.getVideosOperation({ operation: op });
        }
        if (op.error) throw new Error(JSON.stringify(op.error));
        const resp = op.response || {};
        const vid = resp.generatedVideos && resp.generatedVideos[0] && resp.generatedVideos[0].video;
        if (!vid) {
          console.log("MODEL " + model + ": no video returned. " + JSON.stringify(resp.raiMediaFilteredReasons || ""));
          continue;
        }
        const token = crypto.randomUUID();
        let path;
        if (vid.videoBytes) {
          path = "social-test/video-" + model + "-" + Date.now() + ".mp4";
          await bucket.file(path).save(Buffer.from(vid.videoBytes, "base64"), {
            contentType: "video/mp4",
            metadata: { metadata: { firebaseStorageDownloadTokens: token } },
          });
        } else if (vid.uri && vid.uri.startsWith("gs://" + BUCKET + "/")) {
          path = vid.uri.slice(("gs://" + BUCKET + "/").length);
          await bucket.file(path).setMetadata({ metadata: { firebaseStorageDownloadTokens: token } });
        } else {
          console.log("MODEL " + model + ": video came back in an unexpected form: " + String(vid.uri || "").slice(0, 200));
          continue;
        }
        console.log("MODEL " + model + " WORKS. VIDEO URL: https://firebasestorage.googleapis.com/v0/b/" + BUCKET + "/o/" + encodeURIComponent(path) + "?alt=media&token=" + token);
        return;
      } catch (e) {
        console.log("MODEL " + model + " FAILED: " + errText(e));
      }
    }
    console.log("No video model worked.");
  }
);