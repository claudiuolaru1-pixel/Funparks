const fs=require('fs');
let c=fs.readFileSync('ios/Podfile','utf8');

// Replace the @{} return with correct typed constants for firebase_auth 6.x
c=c.replace(
  'return @{}; // FunparksAuthPatch',
  'return @{@"APP_VERIFICATION_DISABLED_FOR_TESTING": @(NO), @"APP_LANGUAGE_CODE": [NSNull null], @"TENANT_ID": [NSNull null]}; // FunparksAuthPatch'
);

fs.writeFileSync('ios/Podfile',c,'utf8');
console.log('Fixed:', c.includes('APP_VERIFICATION_DISABLED_FOR_TESTING'));