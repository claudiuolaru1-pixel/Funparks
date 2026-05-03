const fs=require('fs');
let c=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');
// Replace hardcoded CURRENT_PROJECT_VERSION = 1 with Flutter build number
c=c.replace(/CURRENT_PROJECT_VERSION = 1;/g,'CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";');
// Replace hardcoded MARKETING_VERSION = 1.0 with Flutter version
c=c.replace(/MARKETING_VERSION = 1\.0;/g,'MARKETING_VERSION = "$(FLUTTER_BUILD_NAME)";');
fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj',c,'utf8');
console.log('Fixed Xcode build numbers');