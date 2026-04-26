const fs=require('fs');
let c=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');

// Fix bundle ID
c=c.replace(/com\.funparks\.funparks\.RunnerTests/g,'com.funparks.app.RunnerTests');
c=c.replace(/com\.funparks\.funparks/g,'com.funparks.app');

// Fix code signing to manual
c=c.replace(/CODE_SIGN_STYLE = Automatic;/g,'CODE_SIGN_STYLE = Manual;');

// Fix code sign identity to distribution
c=c.replace(/"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "iPhone Developer";/g,'"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";');

fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj',c,'utf8');
console.log('Fixed bundle ID and code signing');

// Verify
const check=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');
const ids=check.match(/PRODUCT_BUNDLE_IDENTIFIER = [^;]+/g);
console.log('Bundle IDs:',ids);