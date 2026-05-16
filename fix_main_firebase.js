const fs=require('fs');
let c=fs.readFileSync('lib/main.dart','utf8');

// Remove the isEmpty check - always call initializeApp, handle duplicate gracefully
c=c.replace(
  /try \{\s*if \(Firebase\.apps\.isEmpty\) \{\s*await Firebase\.initializeApp\(options: DefaultFirebaseOptions\.currentPlatform\);\s*\}\s*\} catch \(e\) \{\s*debugPrint\('Firebase init: \$e'\);\s*\}/,
  `try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    debugPrint('Firebase init FirebaseException: \${e.code}');
  } catch (e) {
    debugPrint('Firebase init error: \$e');
  }`
);

fs.writeFileSync('lib/main.dart',c,'utf8');
const check=c.includes('await Firebase.initializeApp') && !c.includes('apps.isEmpty');
console.log('Fixed:', check);