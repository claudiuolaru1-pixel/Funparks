const sharp = require("./node_modules/sharp");
const fs = require("fs");

const svg = Buffer.from(`<svg width="1024" height="1024" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
<defs>
  <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%" stop-color="#020818"/>
    <stop offset="40%" stop-color="#051d52"/>
    <stop offset="100%" stop-color="#0d4fa0"/>
  </linearGradient>
  <linearGradient id="fg" x1="0%" y1="0%" x2="0%" y2="100%">
    <stop offset="0%" stop-color="#ffffff"/>
    <stop offset="40%" stop-color="#90caf9"/>
    <stop offset="100%" stop-color="#1565c0"/>
  </linearGradient>
  <linearGradient id="wg" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%" stop-color="#ff9800"/>
    <stop offset="100%" stop-color="#ff5722"/>
  </linearGradient>
  <linearGradient id="tg" x1="0%" y1="0%" x2="100%" y2="0%">
    <stop offset="0%" stop-color="#ff4081"/>
    <stop offset="50%" stop-color="#e040fb"/>
    <stop offset="100%" stop-color="#40c4ff"/>
  </linearGradient>
</defs>
<rect width="512" height="512" rx="108" fill="url(#bg)"/>
<circle cx="60" cy="55" r="2.5" fill="white" opacity="0.7"/>
<circle cx="420" cy="45" r="2.5" fill="white" opacity="0.7"/>
<circle cx="480" cy="180" r="2" fill="white" opacity="0.7"/>
<circle cx="200" cy="40" r="1.5" fill="white" opacity="0.6"/>
<circle cx="470" cy="300" r="2" fill="white" opacity="0.7"/>
<line x1="70" y1="465" x2="70" y2="415" stroke="rgba(255,64,129,0.5)" stroke-width="6" stroke-linecap="round"/>
<line x1="150" y1="465" x2="150" y2="350" stroke="rgba(255,64,129,0.5)" stroke-width="6" stroke-linecap="round"/>
<path d="M 40 415 C 60 415 100 350 150 350 S 200 410 230 390 S 290 310 350 330 S 430 370 475 330" fill="none" stroke="url(#tg)" stroke-width="9" stroke-linecap="round"/>
<path d="M 40 428 C 60 428 100 363 150 363 S 200 423 230 403 S 290 323 350 343 S 430 383 475 343" fill="none" stroke="url(#tg)" stroke-width="6" stroke-linecap="round" opacity="0.7"/>
<rect x="188" y="373" width="48" height="22" rx="8" fill="#ff4081"/>
<circle cx="200" cy="397" r="7" fill="#222"/>
<circle cx="228" cy="397" r="7" fill="#222"/>
<circle cx="204" cy="358" r="7" fill="#ffcc80"/>
<circle cx="220" cy="356" r="7" fill="#ef9a9a"/>
<line x1="204" y1="351" x2="198" y2="342" stroke="#ffcc80" stroke-width="3" stroke-linecap="round"/>
<line x1="220" y1="349" x2="227" y2="340" stroke="#ef9a9a" stroke-width="3" stroke-linecap="round"/>
<line x1="385" y1="265" x2="355" y2="465" stroke="#ff9800" stroke-width="7" stroke-linecap="round" opacity="0.8"/>
<line x1="385" y1="265" x2="415" y2="465" stroke="#ff9800" stroke-width="7" stroke-linecap="round" opacity="0.8"/>
<circle cx="385" cy="200" r="100" fill="none" stroke="url(#wg)" stroke-width="8"/>
<circle cx="385" cy="200" r="65" fill="none" stroke="rgba(255,152,0,0.5)" stroke-width="4"/>
<circle cx="385" cy="200" r="18" fill="#ff9800"/>
<circle cx="385" cy="200" r="8" fill="#fff3e0"/>
<line x1="385" y1="182" x2="385" y2="102" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<line x1="398" y1="185" x2="456" y2="143" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<line x1="403" y1="200" x2="483" y2="200" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<line x1="398" y1="215" x2="456" y2="257" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<line x1="385" y1="218" x2="385" y2="298" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<line x1="372" y1="215" x2="314" y2="257" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<line x1="367" y1="200" x2="287" y2="200" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<line x1="372" y1="185" x2="314" y2="143" stroke="rgba(255,152,0,0.8)" stroke-width="4" stroke-linecap="round"/>
<rect x="375" y="92" width="20" height="16" rx="5" fill="#ff5722"/>
<rect x="446" y="135" width="20" height="16" rx="5" fill="#e040fb"/>
<rect x="473" y="192" width="20" height="16" rx="5" fill="#40c4ff"/>
<rect x="446" y="249" width="20" height="16" rx="5" fill="#69f0ae"/>
<rect x="375" y="290" width="20" height="16" rx="5" fill="#ff9800"/>
<rect x="304" y="249" width="20" height="16" rx="5" fill="#ff4081"/>
<rect x="277" y="192" width="20" height="16" rx="5" fill="#ffeb3b"/>
<rect x="304" y="135" width="20" height="16" rx="5" fill="#7c4dff"/>
<text x="58" y="342" font-family="Georgia,serif" font-size="310" font-weight="900" font-style="italic" fill="rgba(0,20,80,0.8)">F</text>
<text x="48" y="332" font-family="Georgia,serif" font-size="310" font-weight="900" font-style="italic" fill="#1565c0">F</text>
<text x="40" y="324" font-family="Georgia,serif" font-size="310" font-weight="900" font-style="italic" fill="url(#fg)" opacity="0.9">F</text>
<path d="M 418 400 Q 415 368 432 352 Q 450 334 468 352 Q 486 370 483 400 Q 480 425 450 448 Q 420 425 418 400 Z" fill="#69f0ae" opacity="0.95"/>
<circle cx="450" cy="390" r="9" fill="rgba(0,50,30,0.7)"/>
<circle cx="450" cy="390" r="4" fill="white" opacity="0.9"/>
<text x="256" y="492" font-family="Georgia,serif" font-size="36" font-weight="700" font-style="italic" fill="rgba(168,212,255,0.7)" text-anchor="middle" letter-spacing="6">FUNPARKS</text>
</svg>`);

sharp(svg)
  .resize(1024, 1024)
  .png()
  .toFile("assets/icons/icon_1024.png")
  .then(() => console.log("Icon generated successfully!"))
  .catch(err => console.error("Error:", err.message));