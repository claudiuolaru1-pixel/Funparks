const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');
c=c.replace(
  /try \{[\s\S]*?Firebase already configured[\s\S]*?\} catch \(e\) \{[\s\S]*?debugPrint\('Firebase init.*?\);\s*\}/,
  `try {
    if (Firebase.apps.isEmpty) {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
    }
  } catch (e) {
    debugPrint('Firebase init: \$e');
  }`
);
fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Reverted:', c.includes('TargetPlatform.iOS') ? 'YES' : 'NO');