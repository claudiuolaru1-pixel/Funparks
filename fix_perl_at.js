const fs=require('fs');
let pbx=fs.readFileSync('ios/Runner.xcodeproj/project.pbxproj','utf8');

// FIX: @try/@catch without backslash = Perl array interpolation = empty string
// Need \\@try and \\@catch so shell passes \@try to Perl = literal @try
pbx=pbx.replace('/@try { $1 } @catch','/\\\\@try { $1 } \\\\@catch');

// FIX: Search pub-cache first (confirmed location)
pbx=pbx.replace(
  'find \\"$SRCROOT/.symlinks/plugins/firebase_core\\" -name \\"FLTFirebaseCorePlugin.m\\"',
  'find \\"$HOME/.pub-cache\\" -path \\"*/firebase_core*/FLTFirebaseCorePlugin.m\\"'
);

// FIX: grep check - look for @try (correct patch), not just FunparksPatch (also in broken patch)
pbx=pbx.replace('! grep -q FunparksPatch \\"$PLUGIN\\"','! grep -q \\"@try\\" \\"$PLUGIN\\"');

fs.writeFileSync('ios/Runner.xcodeproj/project.pbxproj',pbx,'utf8');
console.log('Fix @try:', pbx.includes('/\\\\@try { $1 } \\\\@catch'));
console.log('Fix path:', pbx.includes('$HOME/.pub-cache'));
console.log('Fix grep:', pbx.includes('grep -q \\"@try\\"'));