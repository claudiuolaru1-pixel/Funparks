const fs=require('fs');
let pbx=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');

// Check if already added
if(pbx.includes('FIRAppPatch.m')){console.log('Already added');process.exit(0);}

// Add PBXBuildFile entry
const buildFileUUID='A1B2C3D4E5F60001';
const fileRefUUID='A1B2C3D4E5F60002';
const buildFileEntry=`\t\t${buildFileUUID} /* FIRAppPatch.m in Sources */ = {isa = PBXBuildFile; fileRef = ${fileRefUUID} /* FIRAppPatch.m */; };\n`;
pbx=pbx.replace('/* Begin PBXBuildFile section */',`/* Begin PBXBuildFile section */\n${buildFileEntry}`);

// Add PBXFileReference entry
const fileRefEntry=`\t\t${fileRefUUID} /* FIRAppPatch.m */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.c.objc; path = FIRAppPatch.m; sourceTree = "<group>"; };\n`;
pbx=pbx.replace('/* Begin PBXFileReference section */',`/* Begin PBXFileReference section */\n${fileRefEntry}`);

// Add to Runner group (find the Runner group that contains AppDelegate.swift)
pbx=pbx.replace(/AppDelegate\.swift \*\/,\n(\s*)/,`AppDelegate.swift */,\n$1${fileRefUUID} /* FIRAppPatch.m */,\n$1`);

// Add to Sources build phase
pbx=pbx.replace(/main\.m in Sources \*\/,\n(\s*)/,`main.m in Sources */,\n$1${buildFileUUID} /* FIRAppPatch.m in Sources */,\n$1`);

fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj',pbx,'utf8');
console.log('Added FIRAppPatch.m to project');
console.log('Verify:', pbx.includes('FIRAppPatch.m') ? 'YES' : 'NO');