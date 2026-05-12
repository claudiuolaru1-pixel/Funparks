const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');
c=c.replace(
  `      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }`,
  `      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`
);
fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Firebase fix:', c.includes('DefaultFirebaseOptions.currentPlatform') && !c.includes('TargetPlatform.iOS') ? 'YES' : 'NO');