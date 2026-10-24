const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

const esc = (s) =>
  String(s || "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");

// A small phone-friendly page: the latest TikTok captions with a Copy button.
exports.tiktokCaption = onRequest(
  { region: "europe-west1", invoker: "public", memory: "256MiB" },
  async (req, res) => {
    try {
      const snap = await admin.firestore().collection("social_posts").where("status", "==", "posted").get();
      const items = snap.docs
        .map((d) => ({ id: d.id, ...d.data() }))
        .filter((x) => x.tiktokCaption && x.createdAt && x.createdAt.toMillis)
        .sort((a, b) => b.createdAt.toMillis() - a.createdAt.toMillis())
        .slice(0, 6);

      const cards = items
        .map((x, i) => {
          const when = new Date(x.createdAt.toMillis()).toLocaleDateString("en-GB", { day: "numeric", month: "short", timeZone: "Europe/Paris" });
          const title = x.title || x.id.replace(/-/g, " ");
          return (
            '<div class="card"><div class="meta">' + esc(when) + (i === 0 ? " · latest" : "") + "</div>" +
            "<h2>" + esc(title) + "</h2>" +
            '<textarea id="c' + i + '" readonly>' + esc(x.tiktokCaption) + "</textarea>" +
            '<button onclick="copyIt(' + i + ', this)">Copy caption</button></div>'
          );
        })
        .join("");

      res.set("Cache-Control", "no-store");
      res.status(200).send(
        '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' +
          "<title>Funparks TikTok captions</title><style>" +
          "body{margin:0;padding:16px;font-family:-apple-system,system-ui,sans-serif;background:#0b1f3a;color:#fff}" +
          "h1{font-size:20px;margin:4px 0 16px}.card{background:#14305a;border-radius:14px;padding:14px;margin-bottom:16px}" +
          ".meta{font-size:12px;opacity:.7}h2{font-size:16px;margin:4px 0 10px}" +
          "textarea{width:100%;box-sizing:border-box;height:190px;border-radius:10px;border:0;padding:10px;font-size:15px;font-family:inherit}" +
          "button{width:100%;margin-top:10px;padding:14px;font-size:17px;font-weight:600;border:0;border-radius:12px;background:#19c3b1;color:#06223a}" +
          "</style></head><body><h1>Funparks · TikTok captions</h1>" +
          (cards || "<p>No captions yet.</p>") +
          "<script>function copyIt(i,b){var t=document.getElementById('c'+i);t.select();t.setSelectionRange(0,99999);" +
          "var done=function(){b.textContent='Copied ✓';setTimeout(function(){b.textContent='Copy caption'},2000)};" +
          "if(navigator.clipboard){navigator.clipboard.writeText(t.value).then(done,function(){document.execCommand('copy');done()})}" +
          "else{document.execCommand('copy');done()}}</script></body></html>"
      );
    } catch (e) {
      res.status(500).send("Could not load captions: " + String(e && e.message ? e.message : e).slice(0, 200));
    }
  }
);
