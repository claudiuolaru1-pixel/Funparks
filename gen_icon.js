const sharp = require("./node_modules/sharp");
const fs = require("fs");

const svg = Buffer.from(`<svg width="1024" height="1024" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
<defs>
  <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%" stop-color="#38BDF8"/>
    <stop offset="100%" stop-color="#0D9488"/>
  </linearGradient>
  <linearGradient id="fg" x1="0%" y1="0%" x2="0%" y2="100%">
    <stop offset="0%" stop-color="#ffffff"/>
    <stop offset="40%" stop-color="#90caf9"/>
    <stop offset="100%" stop-color="#1565c0"/>
  </linearGradient>
</defs>
<rect width="512" height="512" rx="108" fill="url(#bg)"/>
<text x="264" y="266" font-family="Georgia,serif" font-size="310" font-weight="900" font-style="italic" fill="rgba(0,20,80,0.8)" text-anchor="middle" dominant-baseline="central">F</text>
<text x="254" y="256" font-family="Georgia,serif" font-size="310" font-weight="900" font-style="italic" fill="#1565c0" text-anchor="middle" dominant-baseline="central">F</text>
<text x="246" y="248" font-family="Georgia,serif" font-size="310" font-weight="900" font-style="italic" fill="url(#fg)" opacity="0.9" text-anchor="middle" dominant-baseline="central">F</text>
</svg>`);

sharp(svg)
  .resize(1024, 1024)
  .png()
  .toFile("assets/icons/icon_1024.png")
  .then(() => console.log("Icon generated successfully!"))
  .catch(err => console.error("Error:", err.message));