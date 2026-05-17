const fs = require("fs");
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

// 1. Move _ensureMyDayLoaded AFTER auth listener setup (fix Android)
app = app.replace(
  "    if (_bootLoaded) return;\n    _bootLoaded = true;\n    await _ensureMyDayLoaded();",
  "    if (_bootLoaded) return;\n    _bootLoaded = true;"
);
app = app.replace(
  "    // Listen to auth state changes\n    if (!Platform.isIOS) {",
  "    await _ensureMyDayLoaded();\n\n    // Listen to auth state changes\n    if (!Platform.isIOS) {"
);

// 2. Fix signOut to reset iOS state properly
app = app.replace(
  "    if (Platform.isIOS) {\n      _iosSignedIn = false;\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.remove('ios_user_uid');\n      await prefs.remove('ios_user_email');\n      notifyListeners();",
  "    if (Platform.isIOS) {\n      _iosSignedIn = false;\n      _iosUserEmail = null;\n      _iosGuestChecked = false;\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.remove('ios_user_uid');\n      await prefs.remove('ios_user_email');\n      notifyListeners();"
);

// 3. Add onIOSSignIn method after signOut
app = app.replace(
  "  Future<void> _syncFromFirestore",
  "  void onIOSSignIn(String uid, String email) {\n    _iosSignedIn = true;\n    _iosUserEmail = email;\n    _iosGuestChecked = true;\n    notifyListeners();\n  }\n\n  Future<void> _syncFromFirestore"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("myDay moved after auth:", app.includes("await _ensureMyDayLoaded();\n\n    // Listen to auth"));
console.log("signOut reset:", app.includes("_iosGuestChecked = false;\n      final prefs"));
console.log("onIOSSignIn added:", app.includes("void onIOSSignIn(String uid, String email)"));