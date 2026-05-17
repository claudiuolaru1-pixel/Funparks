const fs = require("fs");

// 1. Clean main.dart
let m = fs.readFileSync("lib/main.dart", "utf8").replace(/\r\n/g, "\n");
m = m.replace("String firebaseInitError = '';\n\n", "");
m = m.replace("  } on FirebaseException catch (e) {\n    firebaseInitError = 'FE:\${e.code}';\n  } catch (e) {\n    firebaseInitError = e.toString().length > 120 ? e.toString().substring(0,120) : e.toString();\n  }", "  } catch (_) {}");
fs.writeFileSync("lib/main.dart", m, "utf8");
console.log("main cleaned:", !m.includes("firebaseInitError"));

// 2. Clean sign_in_screen.dart
let si = fs.readFileSync("lib/screens/sign_in_screen.dart", "utf8").replace(/\r\n/g, "\n");
si = si.replace("import '../main.dart' show firebaseInitError;\n", "");
si = si.replace(
  "      setState(() => _loginError = 'FAE:' + e.code + ' ' + (e.message ?? ''));",
  "      setState(() => _loginError = _authMessage(e.code));"
);
si = si.replace(
  "      setState(() => _loginError = 'Init:' + firebaseInitError + ' Apps:' + Firebase.apps.length.toString() + ' ' + e.toString());",
  "      setState(() => _loginError = 'Something went wrong. Please try again.');"
);
// Remove unused Firebase import if no longer needed
if (!si.includes("Firebase.") && si.includes("import 'package:firebase_core/firebase_core.dart';")) {
  si = si.replace("import 'package:firebase_core/firebase_core.dart';\n", "");
}
fs.writeFileSync("lib/screens/sign_in_screen.dart", si, "utf8");
console.log("sign_in cleaned:", !si.includes("firebaseInitError"));
console.log("FAE removed:", !si.includes("FAE:"));