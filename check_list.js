const fs = require('fs');
let code = fs.readFileSync('lib/screens/home_map_screen.dart', 'utf8');
code = code.replace(/\r\n/g, '\n');
const idx = code.indexOf('AnimationLimiter');
if (idx === -1) { console.log('No AnimationLimiter found'); }
else { console.log('Found at', idx); console.log(JSON.stringify(code.substring(idx, idx + 400))); }