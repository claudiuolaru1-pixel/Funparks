const fs=require('fs');
let c=fs.readFileSync('ios/Runner/Info.plist','utf8');
if(!c.includes('ITSAppUsesNonExemptEncryption')){
  c=c.replace('</dict>\n</plist>',
    '\t<key>ITSAppUsesNonExemptEncryption</key>\n\t<false/>\n</dict>\n</plist>');
  fs.writeFileSync('ios/Runner/Info.plist',c,'utf8');
  console.log('Added ITSAppUsesNonExemptEncryption=false');
} else {
  console.log('Already present');
}