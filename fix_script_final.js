const fs=require('fs');
let pbx=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');

// Replace entire shellScript with a robust version
const oldScript = pbx.match(/A1B2C3D4E5F70001[^}]*shellScript = "([^"]*(\\.[^"]*)*)";/s);
if(!oldScript){console.log('Pattern not found');process.exit(1);}

// New script: handles fresh, broken, and correct states
// grep checks for @try { [FIRApp specifically (not just @try which exists elsewhere in the file)
const newShell = [
  '#!/bin/sh',
  'PLUGIN=$(find \\"$HOME/.pub-cache\\" -path \\"*/firebase_core*/FLTFirebaseCorePlugin.m\\" 2>/dev/null | head -1)',
  'if [ -z \\"$PLUGIN\\" ]; then PLUGIN=$(find \\"$SRCROOT/.symlinks\\" -name \\"FLTFirebaseCorePlugin.m\\" 2>/dev/null | head -1); fi',
  'echo \\"[Funparks] Plugin: $PLUGIN\\"',
  'if [ -n \\"$PLUGIN\\" ]; then',
  '  if grep -q \\"try { \\\\[FIRApp\\" \\"$PLUGIN\\" && ! grep -q \\"@try { \\\\[FIRApp\\" \\"$PLUGIN\\"; then',
  '    echo \\"[Funparks] Fixing broken patch (missing @)...\\"',
  '    sed -i \\"\\\\"\\" \\"s/[^@]try { \\\\[FIRApp/@try { [FIRApp/g\\" \\"$PLUGIN\\" 2>/dev/null || true',
  '  fi',
  '  if ! grep -q \\"@try { \\\\[FIRApp configureWithName\\" \\"$PLUGIN\\"; then',
  '    perl -i -0pe \'s/(\\\\[FIRApp configureWithName:[^\\\\]]+\\\\];)/\\\\@try { $1 } \\\\@catch (NSException *__e) { NSLog(\\\\@\\\\\"[Funparks] FunparksPatch OK: %\\\\@\\\\\", __e.reason); }/g\' \\"$PLUGIN\\"',
  '    echo \\"[Funparks] PATCHED!\\"',
  '  else',
  '    echo \\"[Funparks] Already correctly patched\\"',
  '  fi',
  'fi',
].join('\\n');

// Find and replace the shellScript property
pbx = pbx.replace(
  /shellScript = "(?:[^"\\]|\\.)*";(?=\s*\};\s*\/\* [^*]*3B06AD)/s,
  'shellScript = "' + newShell + '";'
);

// Check if the specific FunparksFirebasePatch shellScript was replaced
if(!pbx.includes('FunparksPatch OK')){
  // Try direct replacement of just the critical part
  pbx = pbx.replace(
    '! grep -q \\"@try\\" \\"$PLUGIN\\"',
    '! grep -q \\"@try { \\\\\\\\[FIRApp configureWithName\\" \\"$PLUGIN\\"'
  );
  console.log('Used fallback fix');
}

fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj',pbx,'utf8');
console.log('Result:', pbx.includes('@try { \\\\[FIRApp configureWithName') ? 'Fixed grep check' : 'Check manually');