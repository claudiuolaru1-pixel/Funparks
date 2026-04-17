const fs=require('fs');
let code=fs.readFileSync('lib/screens/home_map_screen.dart','utf8');
code=code.replace(/\r\n/g,'\n');
const idx=code.indexOf('itemBuilder: (_, i)');
console.log(JSON.stringify(code.substring(idx,idx+600)));

// Also check food loading in park_detail_screen
let detail=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');
detail=detail.replace(/\r\n/g,'\n');
const fidx=detail.indexOf('food.json');
console.log('\nfood.json reference:');
console.log(JSON.stringify(detail.substring(fidx-100,fidx+200)));