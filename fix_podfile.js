const fs=require('fs');

// Fix Podfile - set minimum iOS to 14.0
let podfile=fs.readFileSync('ios/Podfile','utf8');
console.log('Current Podfile start:',podfile.substring(0,200));

// Replace or add platform line
if(podfile.includes("platform :ios,")){
  podfile=podfile.replace(/platform :ios, '[^']+'/,"platform :ios, '14.0'");
  console.log('Updated platform version');
} else {
  podfile="platform :ios, '14.0'\n"+podfile;
  console.log('Added platform line');
}

fs.writeFileSync('ios/Podfile',podfile,'utf8');
console.log('Fixed Podfile');
console.log(fs.readFileSync('ios/Podfile','utf8').substring(0,100));