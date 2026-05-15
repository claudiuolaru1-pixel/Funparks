const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Fix park share - replace corrupted text with clean share message
c=c.replace(
  /Share\.share\('\$\{park\.name\} [^']+'\)/,
  "Share.share('\${park.name} - Theme Park Guide\\nDiscover attractions, food, hotels and more on Funparks!')"
);

// Fix food share - replace corrupted text with clean share message  
c=c.replace(
  /Share\.share\('\$\{f\.name\} [^']+'\)/,
  "Share.share('\${f.name} at \${park.name} - Funparks')"
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');

// Verify
const lines = c.split('\n').filter(l=>l.includes('Share.share'));
lines.forEach(l=>console.log('Share line:',l.trim()));