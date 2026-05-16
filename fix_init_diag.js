const fs=require('fs');

// 1. Capture Firebase init error in main.dart and expose it globally
let m=fs.readFileSync('lib/main.dart','utf8');
if(!m.includes('firebaseInitError')){
  m=m.replace(
    'bool _mapsRendererInitialized = false;',
    'bool _mapsRendererInitialized = false;\nString firebaseInitError = \'\';'
  );
  m=m.replace(
    '} on FirebaseException catch (e) {\n    debugPrint(\'Firebase init FirebaseException: \${e.code}\');\n  } catch (e) {\n    debugPrint(\'Firebase init error: \$e\');\n  }',
    '} on FirebaseException catch (e) {\n    firebaseInitError = \'FE:\${e.code}\';\n  } catch (e) {\n    firebaseInitError = \'E:\${e.runtimeType}\';\n  }'
  );
  fs.writeFileSync('lib/main.dart',m,'utf8');
  console.log('main.dart updated:', m.includes('firebaseInitError'));
}

// 2. Show init error in sign-in screen error
let s=fs.readFileSync('lib/screens/sign_in_screen.dart','utf8');
// Add import for main.dart globals
if(!s.includes('import \'../main.dart\'')){
  s=s.replace(
    "import 'package:firebase_core/firebase_core.dart';",
    "import 'package:firebase_core/firebase_core.dart';\nimport '../main.dart' show firebaseInitError;"
  );
}
// Update catch to show init error too
s=s.replace(
  "setState(() => _loginError = 'Apps:' + Firebase.apps.length.toString() + ' ' + e.toString());",
  "setState(() => _loginError = 'Init:' + firebaseInitError + ' Apps:' + Firebase.apps.length.toString() + ' ' + e.toString());"
);
fs.writeFileSync('lib/screens/sign_in_screen.dart',s,'utf8');
console.log('sign_in updated:', s.includes('firebaseInitError'));