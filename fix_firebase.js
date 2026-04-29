const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');

// Replace Firebase.initializeApp with safe version that checks first
c=c.replace(
  'await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);',
  `if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }`
);

fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Fixed Firebase initialization');
console.log(fs.readFileSync('lib/main.dart','utf8').split('\n').filter(l=>l.includes('Firebase')));