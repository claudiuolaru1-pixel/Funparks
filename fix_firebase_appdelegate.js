const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');
c=c.replace(
  `  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint('Firebase init: $e');
  }`,
  `  try {
    if (Firebase.apps.isEmpty) {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        // Firebase already configured in AppDelegate.swift - skip native init
      } else {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
    }
  } catch (e) {
    debugPrint('Firebase init: \$e');
  }`
);
fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Fixed:', c.includes('Firebase already configured in AppDelegate') ? 'YES' : 'NO');