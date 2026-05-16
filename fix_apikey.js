const fs = require("fs");
let h = fs.readFileSync("lib/ios_auth_helper.dart", "utf8").replace(/\r\n/g, "\n");
h = h.replace(
  "    final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;",
  "    final apiKey = DefaultFirebaseOptions.android.apiKey; // Android key works for REST API"
);
fs.writeFileSync("lib/ios_auth_helper.dart", h, "utf8");
console.log("fixed:", h.includes("android.apiKey"));