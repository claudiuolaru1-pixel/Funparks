const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");

const YT_CLIENT_ID = defineSecret("YT_CLIENT_ID");
const YT_CLIENT_SECRET = defineSecret("YT_CLIENT_SECRET");
const YT_REFRESH_TOKEN = defineSecret("YT_REFRESH_TOKEN");

const BUCKET = "funparks-779c6.firebasestorage.app";
// The test video that videoTest made earlier.
const TEST_VIDEO_PATH = "social-test/video-veo-3.1-fast-generate-001-1792600179920.mp4";
// "unlisted" = not shown in search or on the channel page, only people with the link can open it.
// This test uses it to find out whether Google lets the app set a video to unlisted or forces private.
const PRIVACY = "unlisted";

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

// Uploads one video (a Buffer) to the channel that granted permission. Returns YouTube's answer.
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

exports.youtubeTest = onSchedule(
  {
    schedule: "0 4 1 1 *",
    timeZone: "Europe/Paris",
    region: "europe-west1",
    timeoutSeconds: 300,
    memory: "1GiB",
    secrets: [YT_CLIENT_ID, YT_CLIENT_SECRET, YT_REFRESH_TOKEN],
  },
  async () => {
    try {
      const token = await getAccessToken();
      console.log("YOUTUBE STEP 1 OK: permission token works.");
      const [videoBuffer] = await admin.storage().bucket(BUCKET).file(TEST_VIDEO_PATH).download();
      console.log("YOUTUBE STEP 2 OK: test video loaded, " + videoBuffer.length + " bytes.");
      const result = await uploadVideo(
        videoBuffer,
        {
          snippet: {
            title: "Funparks upload test #Shorts",
            description: "Test upload from the Funparks app. https://funparks.app",
            categoryId: "19",
          },
          status: {
            privacyStatus: PRIVACY,
            selfDeclaredMadeForKids: false,
            containsSyntheticMedia: true,
          },
        },
        token
      );
      console.log(
        "YOUTUBE UPLOAD WORKS. video id: " + result.id +
        " | privacy answered: " + (result.status && result.status.privacyStatus) +
        " | link: https://www.youtube.com/watch?v=" + result.id
      );
    } catch (e) {
      console.log("YOUTUBE TEST FAILED: " + errText(e));
    }
  }
);
