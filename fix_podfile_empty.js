const fs=require('fs');
let c=fs.readFileSync('ios/Podfile','utf8');
c=c.replace(
  /return @\{@"APP_LANGUAGE": \[NSNull null\], @"APP_VERIFICATION_DISABLED": @\(NO\)\}; \/\/ FunparksAuthPatch/,
  'return @{}; // FunparksAuthPatch'
);
fs.writeFileSync('ios/Podfile',c,'utf8');
console.log('Fixed:', c.includes('return @{}; // FunparksAuthPatch'));