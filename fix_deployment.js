const fs=require('fs');
let c=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');
c=c.replace(/IPHONEOS_DEPLOYMENT_TARGET = \d+\.\d+;/g,'IPHONEOS_DEPLOYMENT_TARGET = 14.0;');
fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj',c,'utf8');
console.log('Fixed Xcode deployment target to 14.0');
const matches=c.match(/IPHONEOS_DEPLOYMENT_TARGET = [^;]+/g);
console.log('All targets:',matches);