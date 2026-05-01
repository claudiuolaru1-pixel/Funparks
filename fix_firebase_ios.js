const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');

// Replace Firebase init with platform-aware version
const oldInit=`  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    // Firebase already initialized by native plugin on iOS
    debugPrint('Firebase init: \$e');
  }`;

const newInit=`  try {
    if (Firebase.apps.isEmpty) {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
    }
  } catch (e) {
    debugPrint('Firebase init: \$e');
  }`;

if(c.includes('Firebase already initialized')){
  c=c.replace(oldInit,newInit);
  console.log('Fixed platform-aware Firebase init');
} else {
  console.log('Pattern not found - showing Firebase lines:');
  c.split('\n').forEach((l,i)=>{if(l.includes('Firebase')||l.includes('try {'))console.log(i+1,l);});
}

fs.writeFileSync('lib/main.dart',c,'utf8');