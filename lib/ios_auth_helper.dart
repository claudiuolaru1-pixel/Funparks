import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

class IOSAuthHelper {
  static const String _kUid   = 'ios_user_uid';
  static const String _kEmail = 'ios_user_email';

  static Future<String> signIn(String email, String password) async {
    final data = await _post('signInWithPassword', email, password);
    await _save(data);
    return data['localId'] as String;
  }

  static Future<String> register(String email, String password) async {
    final data = await _post('signUp', email, password);
    await _save(data);
    return data['localId'] as String;
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUid);
    await prefs.remove(_kEmail);
  }

  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kUid);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUid);
  }

  static Future<Map<String, dynamic>> _post(
      String endpoint, String email, String pass) async {
    final apiKey = DefaultFirebaseOptions.android.apiKey; // Android key works for REST API
    final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$endpoint?key=$apiKey');
    final res = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'email': email, 'password': pass, 'returnSecureToken': true}));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    final raw = (jsonDecode(res.body)['error']['message'] as String)
        .split(' : ')[0];
    const map = {
      'EMAIL_NOT_FOUND': 'user-not-found',
      'INVALID_LOGIN_CREDENTIALS': 'user-not-found',
      'INVALID_PASSWORD': 'wrong-password',
      'USER_DISABLED': 'user-disabled',
      'EMAIL_EXISTS': 'email-already-in-use',
      'WEAK_PASSWORD': 'weak-password',
      'INVALID_EMAIL': 'invalid-email',
      'TOO_MANY_ATTEMPTS_TRY_LATER': 'too-many-requests',
    };
    throw FirebaseAuthException(code: map[raw] ?? raw.toLowerCase());
  }

  static Future<void> _save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUid,   data['localId'] as String);
    await prefs.setString(_kEmail, data['email']   as String);
  }
}