const fs=require('fs');
let c=fs.readFileSync('pubspec.yaml','utf8');
// Remove intl line entirely - let Flutter SDK manage it
c=c.replace(/\n  intl: \^0\.\d+\.\d+/,'');
fs.writeFileSync('pubspec.yaml',c,'utf8');
console.log('Removed intl constraint');
console.log(fs.readFileSync('pubspec.yaml','utf8').split('\n').filter(l=>l.includes('intl')));