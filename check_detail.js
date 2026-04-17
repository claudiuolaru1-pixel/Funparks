const fs = require('fs');
let code = fs.readFileSync('lib/screens/park_detail_screen.dart', 'utf8');
code = code.replace(/\r\n/g, '\n');
// Find onTap patterns near navigation
const idx = code.indexOf('onTap:');
console.log('First onTap at:', idx);
console.log(JSON.stringify(code.substring(idx, idx + 200)));
const idx2 = code.indexOf('Navigator.push');
console.log('\nFirst Navigator.push at:', idx2);
console.log(JSON.stringify(code.substring(idx2 - 30, idx2 + 150)));