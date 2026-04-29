const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');

// Replace Firebase init with try-catch version
const old1='if (Firebase.apps.isEmpty) {\n    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);\n  }';
const old2='await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);';

const newInit=`try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    // Firebase already initialized by native plugin on iOS
    debugPrint('Firebase init: \$e');
  }`;

if(c.includes(old1)){
  c=c.replace(old1, newInit);
  console.log('Fixed try-catch around isEmpty check');
} else if(c.includes(old2)){
  c=c.replace(old2, newInit);
  console.log('Fixed try-catch around direct init');
} else {
  console.log('Pattern not found');
  // Show what we have
  const lines=c.split('\n').filter(l=>l.includes('Firebase'));
  console.log('Firebase lines:',lines);
}
fs.writeFileSync('lib/main.dart',c,'utf8');