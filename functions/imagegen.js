const admin = require("firebase-admin");
const crypto = require("crypto");
const sharp = require("sharp");
const { GoogleGenAI } = require("@google/genai");

const BUCKET = "funparks-779c6.firebasestorage.app";
const IMAGE_MODEL = "gemini-2.5-flash-image";

function buildPrompt(title) {
  return (
    "Photorealistic, natural-looking travel photograph for a theme park guide. " +
    "Topic: " + title + ". " +
    "Show a generic, believable theme park scene that fits the topic: rides, people enjoying the day, good natural light. " +
    "Wide 16:9 composition, high detail, true-to-life colors. " +
    "No text, no letters, no logos, no signs with writing, no watermarks, no recognizable real people, no cartoon characters."
  );
}

// Makes one picture (saved as JPEG) for an article and returns its public URL.
async function generateArticleImage(slug, title) {
  const ai = new GoogleGenAI({
    vertexai: true,
    enterprise: true,
    project: "funparks-779c6",
    location: "global",
  });
  const res = await ai.models.generateContent({
    model: IMAGE_MODEL,
    contents: buildPrompt(title),
    config: { responseModalities: ["TEXT", "IMAGE"], imageConfig: { aspectRatio: "16:9" } },
  });
  const parts = (res.candidates && res.candidates[0] && res.candidates[0].content && res.candidates[0].content.parts) || [];
  const part = parts.find((p) => p.inlineData && p.inlineData.data);
  if (!part) throw new Error("Image model returned no image");
  const raw = Buffer.from(part.inlineData.data, "base64");
  const jpg = await sharp(raw).flatten({ background: "#ffffff" }).jpeg({ quality: 90 }).toBuffer();
  const token = crypto.randomUUID();
  const safeSlug = String(slug).replace(/[^a-z0-9-]/gi, "-").slice(0, 60);
  const path = "social-images/" + safeSlug + "-" + Date.now() + ".jpg";
  await admin.storage().bucket(BUCKET).file(path).save(jpg, {
    contentType: "image/jpeg",
    metadata: { metadata: { firebaseStorageDownloadTokens: token } },
  });
  const url = "https://firebasestorage.googleapis.com/v0/b/" + BUCKET + "/o/" + encodeURIComponent(path) + "?alt=media&token=" + token;
  return { url, path };
}

module.exports = { generateArticleImage };