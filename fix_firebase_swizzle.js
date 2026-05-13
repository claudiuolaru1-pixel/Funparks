const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');
c=c.replace(
  /try \{[\s\S]*?if \(Firebase\.apps\.isEmpty\)[\s\S]*?\} catch \(e\) \{\s*debugPrint\('Firebase init.*?\);\s*\}/,
  `try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint('Firebase init: \$e');
  }`
);
fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Fixed:', !c.includes('TargetPlatform.iOS') ? 'YES' : 'NO');