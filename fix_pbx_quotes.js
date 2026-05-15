const fs=require('fs');
let pbx=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');
// Fix: \\" (double backslash + quote) -> \" (single backslash + quote)
// \\\\" in JS = \\" in string, '\\\"' in JS = \" in string
pbx=pbx.replace('/bin/sh \\\\"$SRCROOT/Runner/FunparksPatch.sh\\\\"','/bin/sh \\"$SRCROOT/Runner/FunparksPatch.sh\\"');
fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj',pbx,'utf8');
// Verify
const idx=pbx.indexOf('FunparksPatch.sh');
console.log('Context:', pbx.substring(idx-15,idx+30));