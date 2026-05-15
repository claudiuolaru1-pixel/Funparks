const fs=require('fs');
let pbx=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');

// Fix the shellScript - escape @ in Perl replacement
const oldPerl = `perl -i -0pe 's/(\\\\[FIRApp configureWithName:[^\\\\]]+\\\\];)/@try { $1 } @catch (NSException *__e) { NSLog(@"[Funparks] FunparksPatch: Firebase dup ignored: %@", __e.reason); }/g'`;
const newPerl = `perl -i -0pe 's/(\\\\[FIRApp configureWithName:[^\\\\]]+\\\\];)/\\\\@try { $1 } \\\\@catch (NSException *__e) { NSLog(\\\\@"[Funparks] FunparksPatch: Firebase dup ignored: %\\\\@", __e.reason); }/g'`;

// Also update the search path - we now know the exact pub cache location
const oldSearch = 'PLUGIN=$(find "$SRCROOT/.symlinks/plugins/firebase_core" -name "FLTFirebaseCorePlugin.m" 2>/dev/null | head -1)\\nif [ -z "$PLUGIN" ]; then PLUGIN=$(find "$HOME/.pub-cache" -path "*/firebase_core*/FLTFirebaseCorePlugin.m" 2>/dev/null | head -1); fi';
const newSearch = 'PLUGIN=$(find "$HOME/.pub-cache" -path "*/firebase_core*/FLTFirebaseCorePlugin.m" 2>/dev/null | head -1)\\nif [ -z "$PLUGIN" ]; then PLUGIN=$(find "$SRCROOT/.symlinks" -name "FLTFirebaseCorePlugin.m" 2>/dev/null | head -1); fi';

pbx = pbx.replace(oldPerl, newPerl);
pbx = pbx.replace(oldSearch, newSearch);
fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj', pbx, 'utf8');
console.log('Perl @ fixed:', pbx.includes('\\\\@try') ? 'YES' : 'NO');