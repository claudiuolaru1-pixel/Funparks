const fs=require('fs');
let c=fs.readFileSync('lib/screens/sign_in_screen.dart','utf8');

// Add Firebase.apps count to the error message so we can see it
c=c.replace(
  "} catch (e) {\n      setState(() => _loginError = 'Error: ' + e.toString());",
  "} catch (e) {\n      setState(() => _loginError = 'Apps:' + Firebase.apps.length.toString() + ' ' + e.toString());"
);

// Also add Firebase import if not there
if(!c.includes("import 'package:firebase_core/firebase_core.dart';")){
  c="import 'package:firebase_core/firebase_core.dart';\n"+c;
}

fs.writeFileSync('lib/screens/sign_in_screen.dart',c,'utf8');
console.log('Diagnostic added:', c.includes("Apps:"));