const fs=require('fs');
let c=fs.readFileSync('ios/Runner/Info.plist','utf8');
if(!c.includes('FIREBASE_AUTO_INIT_ENABLED')){
  c=c.replace('</dict>\n</plist>',
    '\t<key>FIREBASE_AUTO_INIT_ENABLED</key>\n\t<false/>\n</dict>\n</plist>');
  fs.writeFileSync('ios/Runner/Info.plist',c,'utf8');
  console.log('Disabled Firebase auto init');
}
// Also remove FirebaseAppDelegateProxyEnabled if it causes issues
console.log('Info.plist tail:');
console.log(fs.readFileSync('ios/Runner/Info.plist','utf8').split('\n').slice(-8).join('\n'));