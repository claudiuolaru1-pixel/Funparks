const fs = require('fs');
const raw = fs.readFileSync('lib/screens/home_map_screen.dart');
const hasCRLF = raw.includes('\r\n') || Buffer.from(raw).indexOf(13) !== -1;
console.log('Has CRLF:', hasCRLF);
const text = raw.toString('utf8');
const idx = text.indexOf('CircleAvatar');
console.log('CircleAvatar found at:', idx);
if (idx !== -1) {
  const snippet = text.substring(idx - 200, idx + 100);
  console.log('RAW bytes around it:');
  for (let i = 0; i < snippet.length; i++) {
    const c = snippet.charCodeAt(i);
    if (c === 13) process.stdout.write('[CR]');
    else if (c === 10) process.stdout.write('[LF]\n');
    else process.stdout.write(snippet[i]);
  }
}