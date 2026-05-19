const fs = require("fs");
let m = fs.readFileSync("lib/main.dart", "utf8").replace(/\r\n/g, "\n");
m = m.replace("AndroidMapRenderer.latest", "AndroidMapRenderer.legacy");
fs.writeFileSync("lib/main.dart", m, "utf8");
console.log("reverted:", m.includes("AndroidMapRenderer.legacy"));