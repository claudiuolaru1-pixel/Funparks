const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');
c=c.replace(
  `  try {
    // Skip Firebase on iOS - double-init crash with FlutterFire plugin auto-config.
    // Auth not available on iOS in this version; all park/affiliate data works.
    if (!Platform.isIOS && !Platform.isMacOS && Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint('Firebase init: \$e');
  }`,
  `  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint('Firebase init: \$e');
  }`
);
fs.writeFileSync('lib/main.dart',c,'utf8');
console.log('Firebase re-enabled:', !c.includes('Skip Firebase on iOS') ? 'YES' : 'NO');