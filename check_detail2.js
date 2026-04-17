const fs = require('fs');
let code = fs.readFileSync('lib/screens/park_detail_screen.dart', 'utf8');
code = code.replace(/\r\n/g, '\n');
// Find all onPressed near navigation
let idx = 0;
let count = 0;
while (count < 5) {
  idx = code.indexOf('onPressed:', idx + 1);
  if (idx === -1) break;
  const snippet = code.substring(idx, idx + 180);
  if (snippet.includes('push') || snippet.includes('Detail')) {
    console.log('--- at', idx, '---');
    console.log(JSON.stringify(snippet));
  }
  count++;
}
// Also search for GestureDetector near attraction
const gIdx = code.indexOf('AttractionCard');
console.log('\nAttractionCard at:', gIdx);
if (gIdx !== -1) console.log(JSON.stringify(code.substring(gIdx, gIdx + 300)));