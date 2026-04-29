const fs=require('fs');
let c=fs.readFileSync('ios/Runner/Info.plist','utf8');
if(!c.includes('FirebaseAppDelegateProxyEnabled')){
  c=c.replace('</dict>\n</plist>',
    '\t<key>FirebaseAppDelegateProxyEnabled</key>\n\t<false/>\n</dict>\n</plist>');
  fs.writeFileSync('ios/Runner/Info.plist',c,'utf8');
  console.log('Added FirebaseAppDelegateProxyEnabled=false');
}