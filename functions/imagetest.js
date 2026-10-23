const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const { GoogleGenAI } = require("@google/genai");
const crypto = require("crypto");

const BUCKET = "funparks-779c6.firebasestorage.app";
const PROMPT = "Photorealistic wide shot of a giant steel roller coaster at golden hour, train mid-drop above a cheering crowd, motion blur, dramatic sky, cinematic, no text, no logos";
const MODELS = [
  "gemini-3.1-flash-image-preview",
  "gemini-3.1-flash-image",
  "gemini-3.1-flash-lite-image-preview",
  "gemini-2.5-flash-image",
  "gemini-3-pro-image-preview",
];

exports.imageTest = onSchedule(
  {
    schedule: "0 4 1 1 *",
    timeZone: "Europe/Paris",
    region: "europe-west1",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const ai = new GoogleGenAI({
      vertexai: true,
      enterprise: true,
      project: "funparks-779c6",
      location: "global",
    });
    for (const model of MODELS) {
      try {
        const res = await ai.models.generateContent({
          model,
          contents: PROMPT,
          config: { responseModalities: ["TEXT", "IMAGE"], imageConfig: { aspectRatio: "16:9" } },
        });
        const parts = (res.candidates && res.candidates[0] && res.candidates[0].content && res.candidates[0].content.parts) || [];
        const part = parts.find((p) => p.inlineData && p.inlineData.data);
        if (!part) {
          console.log("MODEL " + model + ": no image in reply");
          continue;
        }
        const mime = part.inlineData.mimeType || "image/png";
        const ext = mime.includes("jpeg") ? "jpg" : "png";
        const token = crypto.randomUUID();
        const path = "social-test/" + model + "-" + Date.now() + "." + ext;
        await admin.storage().bucket(BUCKET).file(path).save(Buffer.from(part.inlineData.data, "base64"), {
          contentType: mime,
          metadata: { metadata: { firebaseStorageDownloadTokens: token } },
        });
        console.log("MODEL " + model + " WORKS. IMAGE URL: https://firebasestorage.googleapis.com/v0/b/" + BUCKET + "/o/" + encodeURIComponent(path) + "?alt=media&token=" + token);
      } catch (e) {
        console.log("MODEL " + model + " FAILED: " + String(e && e.message ? e.message : e).slice(0, 300));
      }
    }
  }
);