const fs = require("fs");

// 1. Create lib/ios_auth_helper.dart
const helper = [
"import 'dart:convert';",
"import 'package:firebase_auth/firebase_auth.dart';",
"import 'package:http/http.dart' as http;",
"import 'package:shared_preferences/shared_preferences.dart';",
"import 'firebase_options.dart';",
"",
"class IOSAuthHelper {",
"  static const String _kUid   = 'ios_user_uid';",
"  static const String _kEmail = 'ios_user_email';",
"",
"  static Future<String> signIn(String email, String password) async {",
"    final data = await _post('signInWithPassword', email, password);",
"    await _save(data);",
"    return data['localId'] as String;",
"  }",
"",
"  static Future<String> register(String email, String password) async {",
"    final data = await _post('signUp', email, password);",
"    await _save(data);",
"    return data['localId'] as String;",
"  }",
"",
"  static Future<void> signOut() async {",
"    final prefs = await SharedPreferences.getInstance();",
"    await prefs.remove(_kUid);",
"    await prefs.remove(_kEmail);",
"  }",
"",
"  static Future<bool> isSignedIn() async {",
"    final prefs = await SharedPreferences.getInstance();",
"    return prefs.containsKey(_kUid);",
"  }",
"",
"  static Future<String?> getUid() async {",
"    final prefs = await SharedPreferences.getInstance();",
"    return prefs.getString(_kUid);",
"  }",
"",
"  static Future<Map<String, dynamic>> _post(",
"      String endpoint, String email, String pass) async {",
"    final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;",
"    final uri = Uri.parse(",
"        'https://identitytoolkit.googleapis.com/v1/accounts:$endpoint?key=$apiKey');",
"    final res = await http.post(uri,",
"        headers: {'Content-Type': 'application/json'},",
"        body: jsonEncode(",
"            {'email': email, 'password': pass, 'returnSecureToken': true}));",
"    if (res.statusCode == 200) {",
"      return jsonDecode(res.body) as Map<String, dynamic>;",
"    }",
"    final raw = (jsonDecode(res.body)['error']['message'] as String)",
"        .split(' : ')[0];",
"    const map = {",
"      'EMAIL_NOT_FOUND': 'user-not-found',",
"      'INVALID_LOGIN_CREDENTIALS': 'user-not-found',",
"      'INVALID_PASSWORD': 'wrong-password',",
"      'USER_DISABLED': 'user-disabled',",
"      'EMAIL_EXISTS': 'email-already-in-use',",
"      'WEAK_PASSWORD': 'weak-password',",
"      'INVALID_EMAIL': 'invalid-email',",
"      'TOO_MANY_ATTEMPTS_TRY_LATER': 'too-many-requests',",
"    };",
"    throw FirebaseAuthException(code: map[raw] ?? raw.toLowerCase());",
"  }",
"",
"  static Future<void> _save(Map<String, dynamic> data) async {",
"    final prefs = await SharedPreferences.getInstance();",
"    await prefs.setString(_kUid,   data['localId'] as String);",
"    await prefs.setString(_kEmail, data['email']   as String);",
"  }",
"}",
].join("\n");
fs.writeFileSync("lib/ios_auth_helper.dart", helper, "utf8");
console.log("1. ios_auth_helper created:", helper.includes("signInWithPassword"));

// 2. Patch app_state.dart
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

app = app.replace(
  "import 'dart:convert';",
  "import 'dart:convert';\nimport 'dart:io';"
);
app = app.replace(
  "  bool get isLoggedIn => _user != null;",
  "  bool _iosSignedIn = false;\n  bool get isLoggedIn => _user != null || _iosSignedIn;"
);
app = app.replace(
  "  Future<void> _ensureBootLoaded() async {\n    if (_bootLoaded) return;\n    _bootLoaded = true;",
  "  Future<void> _ensureBootLoaded() async {\n    if (Platform.isIOS && !_iosSignedIn) {\n      final _ip = await SharedPreferences.getInstance();\n      final _iu = _ip.getString('ios_user_uid');\n      if (_iu != null && _iu.isNotEmpty) {\n        _iosSignedIn = true;\n        await _syncFromFirestore(_iu);\n        notifyListeners();\n      }\n    }\n    if (_bootLoaded) return;\n    _bootLoaded = true;"
);
app = app.replace(
  "    // Listen to auth state changes\n    FirebaseAuth.instance.authStateChanges().listen((user) async {\n      _user = user;\n      if (user != null) {\n        await _syncFromFirestore(user.uid);\n      }\n      notifyListeners();\n    });",
  "    // Listen to auth state changes\n    if (!Platform.isIOS) {\n      FirebaseAuth.instance.authStateChanges().listen((user) async {\n        _user = user;\n        if (user != null) {\n          await _syncFromFirestore(user.uid);\n        }\n        notifyListeners();\n      });\n    }"
);
app = app.replace(
  "  Future<void> signOut() async {\n    await FirebaseAuth.instance.signOut();\n  }",
  "  Future<void> signOut() async {\n    if (Platform.isIOS) {\n      _iosSignedIn = false;\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.remove('ios_user_uid');\n      await prefs.remove('ios_user_email');\n      notifyListeners();\n    } else {\n      await FirebaseAuth.instance.signOut();\n    }\n  }"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("2. app_state dart:io:", app.includes("import 'dart:io'"));
console.log("   _iosSignedIn:", app.includes("_iosSignedIn"));
console.log("   boot iOS check:", app.includes("_ip.getString"));
console.log("   authState wrapped:", app.includes("if (!Platform.isIOS)"));
console.log("   signOut patched:", app.includes("prefs.remove('ios_user_uid')"));

// 3. Patch sign_in_screen.dart
let si = fs.readFileSync("lib/screens/sign_in_screen.dart", "utf8").replace(/\r\n/g, "\n");

si = si.replace(
  "import 'package:firebase_auth/firebase_auth.dart';",
  "import 'package:firebase_auth/firebase_auth.dart';\nimport 'dart:io';\nimport '../ios_auth_helper.dart';"
);
si = si.replace(
  "      await FirebaseAuth.instance\n          .signInWithEmailAndPassword(email: email, password: pass);",
  "      if (Platform.isIOS) {\n        await IOSAuthHelper.signIn(email, pass);\n      } else {\n        await FirebaseAuth.instance\n            .signInWithEmailAndPassword(email: email, password: pass);\n      }"
);
si = si.replace(
  "      await FirebaseAuth.instance\n          .createUserWithEmailAndPassword(email: email, password: pass);",
  "      if (Platform.isIOS) {\n        await IOSAuthHelper.register(email, pass);\n      } else {\n        await FirebaseAuth.instance\n            .createUserWithEmailAndPassword(email: email, password: pass);\n      }"
);

fs.writeFileSync("lib/screens/sign_in_screen.dart", si, "utf8");
console.log("3. sign_in ios import:", si.includes("ios_auth_helper.dart"));
console.log("   login iOS:", si.includes("IOSAuthHelper.signIn"));
console.log("   register iOS:", si.includes("IOSAuthHelper.register"));