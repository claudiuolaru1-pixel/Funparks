const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Revert to simple Share.share(text) - works in share_plus 10.x
c=c.replace(
  "Share.share(ShareParams(text: '${park.name} - Theme Park Guide\\nDiscover attractions, food, hotels and more on Funparks!'))",
  "Share.share('${park.name} - Theme Park Guide\\nDiscover attractions, food, hotels and more on Funparks!')"
);
c=c.replace(
  "Share.share(ShareParams(text: '${a.name} - Funparks'))",
  "Share.share('${a.name} - Funparks')"
);
// Fix food share - park not accessible in _FoodDetailScreenState, use only f.name
c=c.replace(
  "Share.share(ShareParams(text: '${f.name} at ${park.name} - Funparks'))",
  "Share.share('${f.name} - Funparks')"
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
const lines=c.split('\n').filter(l=>l.includes('Share.share'));
lines.forEach(l=>console.log(l.trim()));