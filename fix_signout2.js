const fs = require("fs");
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

app = app.replace(
  "  Future<void> signOut() async {\n    if (Platform.isIOS) {\n      _iosSignedIn = false;\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.remove('ios_user_uid');\n      await prefs.remove('ios_user_email');\n    } else {\n      await FirebaseAuth.instance.signOut();\n      _user = null;\n    }\n    notifyListeners();\n  }",
  "  Future<void> signOut() async {\n    if (Platform.isIOS) {\n      _iosSignedIn = false;\n      _iosUserEmail = null;\n      _iosGuestChecked = false;\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.remove('ios_user_uid');\n      await prefs.remove('ios_user_email');\n    } else {\n      await FirebaseAuth.instance.signOut();\n      _user = null;\n    }\n    notifyListeners();\n  }"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("signOut fixed:", app.includes("_iosGuestChecked = false;"));