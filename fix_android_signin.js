const fs = require("fs");

// 1. Add onAndroidSignIn to app_state.dart
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");
app = app.replace(
  "  void onIOSSignIn(String uid, String email) {",
  "  void onAndroidSignIn(dynamic user) {\n    _user = user;\n    notifyListeners();\n  }\n\n  void onIOSSignIn(String uid, String email) {"
);
fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("onAndroidSignIn added:", app.includes("onAndroidSignIn"));

// 2. Call it from sign_in_screen after Android login
let si = fs.readFileSync("lib/screens/sign_in_screen.dart", "utf8").replace(/\r\n/g, "\n");
si = si.replace(
  "        await FirebaseAuth.instance\n            .signInWithEmailAndPassword(email: email, password: pass);",
  "        await FirebaseAuth.instance\n            .signInWithEmailAndPassword(email: email, password: pass);\n        final u = FirebaseAuth.instance.currentUser;\n        if (mounted && u != null) Provider.of<AppState>(context, listen: false).onAndroidSignIn(u);"
);
fs.writeFileSync("lib/screens/sign_in_screen.dart", si, "utf8");
console.log("Android signin updated:", si.includes("onAndroidSignIn(u)"));