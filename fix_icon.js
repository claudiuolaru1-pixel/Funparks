const fs = require("fs");
let c = fs.readFileSync("pubspec.yaml", "utf8").replace(/\r\n/g, "\n");
c = c.replace("  adaptive_icon_background: \"#72C8FF\"\n  adaptive_icon_foreground: assets/icons/icon_foreground.png\n  remove_alpha_ios: true", "  remove_alpha_ios: true");
fs.writeFileSync("pubspec.yaml", c, "utf8");
console.log("adaptive removed:", !c.includes("adaptive_icon_background"));