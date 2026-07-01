const sharp = require("./node_modules/sharp");

const svg = Buffer.from(`<svg width="1080" height="1080" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#020818"/>
      <stop offset="50%" stop-color="#051d52"/>
      <stop offset="100%" stop-color="#0d4fa0"/>
    </linearGradient>
    <linearGradient id="accent" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#FF6B2B"/>
      <stop offset="50%" stop-color="#f43f5e"/>
      <stop offset="100%" stop-color="#a855f7"/>
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <rect width="1080" height="1080" fill="url(#bg)"/>
  <circle cx="200" cy="200" r="300" fill="rgba(255,107,43,0.08)"/>
  <circle cx="900" cy="800" r="250" fill="rgba(168,85,247,0.08)"/>
  <circle cx="950" cy="150" r="200" fill="rgba(6,182,212,0.06)"/>
  <rect x="0" y="0" width="1080" height="1080" fill="url(#bg)" opacity="0.3"/>
  <circle cx="540" cy="380" r="180" fill="rgba(255,255,255,0.03)" stroke="rgba(255,255,255,0.06)" stroke-width="1"/>
  <circle cx="540" cy="380" r="130" fill="rgba(255,255,255,0.03)" stroke="rgba(255,255,255,0.06)" stroke-width="1"/>
  <line x1="540" y1="200" x2="540" y2="560" stroke="rgba(255,152,0,0.5)" stroke-width="3"/>
  <line x1="360" y1="380" x2="720" y2="380" stroke="rgba(255,152,0,0.5)" stroke-width="3"/>
  <line x1="413" y1="253" x2="667" y2="507" stroke="rgba(255,152,0,0.4)" stroke-width="2"/>
  <line x1="667" y1="253" x2="413" y2="507" stroke="rgba(255,152,0,0.4)" stroke-width="2"/>
  <circle cx="540" cy="380" r="24" fill="#FF9800"/>
  <circle cx="540" cy="380" r="12" fill="#FFF3E0"/>
  <rect x="525" y="192" width="30" height="22" rx="6" fill="#FF5722"/>
  <rect x="525" y="544" width="30" height="22" rx="6" fill="#FF9800"/>
  <rect x="352" y="369" width="30" height="22" rx="6" fill="#a855f7"/>
  <rect x="698" y="369" width="30" height="22" rx="6" fill="#06b6d4"/>
  <rect x="405" y="245" width="30" height="22" rx="6" fill="#f43f5e"/>
  <rect x="645" y="245" width="30" height="22" rx="6" fill="#10b981"/>
  <rect x="405" y="495" width="30" height="22" rx="6" fill="#ffeb3b"/>
  <rect x="645" y="495" width="30" height="22" rx="6" fill="#e040fb"/>
  <rect x="140" y="580" width="800" height="6" rx="3" fill="url(#accent)" opacity="0.9"/>
  <text x="540" y="680" font-family="Georgia,serif" font-size="96" font-weight="900" font-style="italic" text-anchor="middle" fill="white" filter="url(#glow)">funparks</text>
  <text x="540" y="760" font-family="Georgia,serif" font-size="32" font-weight="400" text-anchor="middle" fill="rgba(255,255,255,0.6)" letter-spacing="8">THEME PARK GUIDE</text>
  <rect x="140" y="800" width="800" height="1" fill="rgba(255,255,255,0.1)"/>
  <text x="540" y="860" font-family="Georgia,serif" font-size="28" text-anchor="middle" fill="rgba(255,255,255,0.4)" letter-spacing="4">funparks.app</text>
  <circle cx="200" cy="950" r="8" fill="#FF6B2B" opacity="0.6"/>
  <circle cx="230" cy="950" r="5" fill="#f43f5e" opacity="0.5"/>
  <circle cx="850" cy="950" r="8" fill="#a855f7" opacity="0.6"/>
  <circle cx="880" cy="950" r="5" fill="#06b6d4" opacity="0.5"/>
</svg>`);

sharp(svg)
  .resize(1080, 1080)
  .jpeg({ quality: 95 })
  .toFile("C:/Users/claud/OneDrive/Desktop/funparks-website/public/screenshots/funparks_social.jpg")
  .then(() => console.log("Social image created!"))
  .catch(e => console.error(e.message));