const fs = require('fs');
let code = fs.readFileSync('lib/screens/park_detail_screen.dart', 'utf8');
code = code.replace(/\r\n/g, '\n');

// Find all onTap occurrences
let idx = 0;
while (true) {
  idx = code.indexOf('onTap:', idx + 1);
  if (idx === -1) break;
  console.log('--- onTap at', idx, '---');
  console.log(JSON.stringify(code.substring(idx, idx + 200)));
}