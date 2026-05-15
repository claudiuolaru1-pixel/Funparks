const fs = require('fs');
let pbx = fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj', 'utf8');

if (pbx.includes('FunparksFirebasePatch')) { console.log('Already added'); process.exit(0); }

const scriptUUID = 'A1B2C3D4E5F70001';

// Shell script that finds and patches FLTFirebaseCorePlugin.m before compilation
const script = [
  '#!/bin/sh',
  'PLUGIN=$(find "$SRCROOT/.symlinks/plugins/firebase_core" -name "FLTFirebaseCorePlugin.m" 2>/dev/null | head -1)',
  'if [ -z "$PLUGIN" ]; then PLUGIN=$(find "$HOME/.pub-cache" -path "*/firebase_core*/FLTFirebaseCorePlugin.m" 2>/dev/null | head -1); fi',
  'echo "[Funparks] Plugin file: $PLUGIN"',
  'if [ -n "$PLUGIN" ] && ! grep -q FunparksPatch "$PLUGIN"; then',
  ' perl -i -0pe \'s/(\\[FIRApp configureWithName:[^\\]]+\\];)/@try { $1 } @catch (NSException *__e) { NSLog(@\\"[Funparks] FunparksPatch: Firebase dup ignored: %@\\", __e.reason); }/g\' "$PLUGIN"',
  ' echo "[Funparks] FunparksPatch: PATCHED!"',
  'else',
  ' echo "[Funparks] FunparksPatch: skipped (file=$PLUGIN)"',
  'fi',
].join('\\n');

const escapedScript = script.replace(/\\/g, '\\\\').replace(/"/g, '\\"');

const buildPhaseBlock = `\t\t${scriptUUID} /* FunparksFirebasePatch */ = {\n\t\t\tisa = PBXShellScriptBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = (\n\t\t\t);\n\t\t\tinputFileListPaths = (\n\t\t\t);\n\t\t\tinputPaths = (\n\t\t\t);\n\t\t\tname = FunparksFirebasePatch;\n\t\t\toutputFileListPaths = (\n\t\t\t);\n\t\t\toutputPaths = (\n\t\t\t);\n\t\t\trunOnlyForDeploymentPostprocessing = 0;\n\t\t\tshellPath = /bin/sh;\n\t\t\tshellScript = "${escapedScript}";\n\t\t};\n`;

// Add the build phase definition
if (pbx.includes('/* Begin PBXShellScriptBuildPhase section */')) {
  pbx = pbx.replace('/* Begin PBXShellScriptBuildPhase section */', 
    '/* Begin PBXShellScriptBuildPhase section */\n' + buildPhaseBlock);
} else {
  // Add the entire section before PBXSourcesBuildPhase
  pbx = pbx.replace('/* Begin PBXSourcesBuildPhase section */',
    '/* Begin PBXShellScriptBuildPhase section */\n' + buildPhaseBlock + '\t\t/* End PBXShellScriptBuildPhase section */\n\n\t\t/* Begin PBXSourcesBuildPhase section */');
}

// Add to Runner target buildPhases BEFORE Sources
const sourcesMatch = pbx.match(/([A-F0-9]{24}) \/\* Sources \*\/,/);
if (sourcesMatch) {
  pbx = pbx.replace(sourcesMatch[0],
    `${scriptUUID} /* FunparksFirebasePatch */,\n\t\t\t\t${sourcesMatch[0]}`);
  console.log('Inserted before Sources phase');
} else {
  console.log('WARNING: Sources phase not found, appending');
}

fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj', pbx, 'utf8');
console.log('Run Script added:', pbx.includes('FunparksFirebasePatch'));