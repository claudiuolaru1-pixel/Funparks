const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// Replace ReviewsSection with static placeholder in both detail screens
c=c.replace(/ReviewsSection\(\s*parkId: widget\.parkId,\s*itemId: a\.id,\s*\)/g,
  'Text("Reviews coming soon", style: TextStyle(color: Colors.grey))'
);
c=c.replace(/ReviewsSection\(\s*parkId: widget\.parkId,\s*itemId: f\.id,\s*\)/g,
  'Text("Reviews coming soon", style: TextStyle(color: Colors.grey))'
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('ReviewsSection replaced:', (c.match(/ReviewsSection/g)||[]).length, 'remaining');