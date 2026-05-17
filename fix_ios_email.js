const fs = require("fs");
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

// 1. Add _iosUserEmail field next to _iosSignedIn
app = app.replace(
  "  bool _iosSignedIn = false;\n  bool _iosGuestChecked = false;",
  "  bool _iosSignedIn = false;\n  bool _iosGuestChecked = false;\n  String? _iosUserEmail;"
);

// 2. Load email from SharedPreferences when iOS user is found
app = app.replace(
  "      if (_iu != null && _iu.isNotEmpty) {\n        _iosSignedIn = true;\n        await _syncFromFirestore(_iu);\n        notifyListeners();\n      }",
  "      if (_iu != null && _iu.isNotEmpty) {\n        _iosSignedIn = true;\n        _iosUserEmail = _ip.getString('ios_user_email');\n        await _syncFromFirestore(_iu);\n        notifyListeners();\n      }"
);

// 3. Update userEmail getter to use _iosUserEmail on iOS
app = app.replace(
  "  String? get userEmail => _user?.email;",
  "  String? get userEmail => _user?.email ?? (Platform.isIOS ? _iosUserEmail : null);"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("_iosUserEmail field:", app.includes("String? _iosUserEmail;"));
console.log("email loaded:", app.includes("_iosUserEmail = _ip.getString('ios_user_email')"));
console.log("getter updated:", app.includes("_user?.email ?? (Platform.isIOS ? _iosUserEmail : null)"));