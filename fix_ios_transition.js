const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');

// Replace iOS transition with standard Cupertino (native iOS slide)
c=c.replace(
  'TargetPlatform.iOS: _FadeScaleTransitionsBuilder(),',
  'TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),'
);

fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Fixed iOS transition to Cupertino');
console.log('Has Cupertino:',c.includes('CupertinoPageTransitionsBuilder'));