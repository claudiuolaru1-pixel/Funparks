const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// share_plus 10.x requires ShareParams object
c=c.replace(
  "Share.share('${park.name} - Theme Park Guide\\nDiscover attractions, food, hotels and more on Funparks!')",
  "Share.share(ShareParams(text: '${park.name} - Theme Park Guide\\nDiscover attractions, food, hotels and more on Funparks!'))"
);
c=c.replace(
  "Share.share('${a.name} - Funparks')",
  "Share.share(ShareParams(text: '${a.name} - Funparks'))"
);
c=c.replace(
  "Share.share('${f.name} at ${park.name} - Funparks')",
  "Share.share(ShareParams(text: '${f.name} at ${park.name} - Funparks'))"
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
const lines=c.split('\n').filter(l=>l.includes('Share.share'));
lines.forEach(l=>console.log(l.trim()));