import 'package:firebase_core/firebase_core.dart';
import '../main.dart' show firebaseInitError;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../ios_auth_helper.dart';

class SignInScreen extends StatefulWidget {
  final bool startOnRegister;
  const SignInScreen({super.key, this.startOnRegister = false});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  late TextEditingController _loginEmailCtrl;
  late TextEditingController _loginPassCtrl;
  bool _loginPassVisible = false;
  String? _loginError;
  bool _loginBusy = false;

  late TextEditingController _regEmailCtrl;
  late TextEditingController _regPassCtrl;
  late TextEditingController _regConfirmCtrl;
  bool _regPassVisible = false;
  String? _regError;
  bool _regBusy = false;

  @override
  void initState() {
    super.initState();
    _loginEmailCtrl = TextEditingController();
    _loginPassCtrl = TextEditingController();
    _regEmailCtrl = TextEditingController();
    _regPassCtrl = TextEditingController();
    _regConfirmCtrl = TextEditingController();
    _tabs = TabController(
        length: 2, vsync: this, initialIndex: widget.startOnRegister ? 1 : 0);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _loginEmailCtrl?.text??''.trim();
    final pass = _loginPassCtrl?.text??'';
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _loginError = 'Please enter email and password.');
      return;
    }
    setState(() { _loginBusy = true; _loginError = null; });
    try {
      if (Platform.isIOS) {
        await IOSAuthHelper.signIn(email, pass);
      } else {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: pass);
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _loginError = _authMessage(e.code));
    } catch (e) {
      setState(() => _loginError = 'Init:' + firebaseInitError + ' Apps:' + Firebase.apps.length.toString() + ' ' + e.toString());
    } finally {
      if (mounted) setState(() => _loginBusy = false);
    }
  }

  Future<void> _register() async {
    final email = _regEmailCtrl?.text??''.trim();
    final pass = _regPassCtrl?.text??'';
    final confirm = _regConfirmCtrl?.text??'';
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _regError = 'Please enter email and password.');
      return;
    }
    if (pass != confirm) {
      setState(() => _regError = 'Passwords do not match.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _regError = 'Password must be at least 6 characters.');
      return;
    }
    setState(() { _regBusy = true; _regError = null; });
    try {
      if (Platform.isIOS) {
        await IOSAuthHelper.register(email, pass);
      } else {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: pass);
      }
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      print('FIREBASE_AUTH_ERROR: ${e.code} - ${e.message}');
      setState(() => _regError = _authMessage(e.code));
    } catch (e) {
      print('GENERAL_ERROR: $e');
      setState(() => _regError = e.toString());
    } finally {
      if (mounted) setState(() => _regBusy = false);
    }
  }
  
  Future<void> _resetPassword() async {
    final email = _loginEmailCtrl?.text??''.trim();
    if (email.isEmpty) {
      setState(() => _loginError = 'Enter your email above first.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email sent.')));
      }
    } catch (_) {}
  }

  String _authMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'invalid-email': return 'Invalid email address.';
      case 'weak-password': return 'Password is too weak.';
      case 'too-many-requests': return 'Too many attempts. Try again later.';
      default: return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withOpacity(0.85),
                  cs.secondary.withOpacity(0.7),
                  Colors.white,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(Icons.attractions, size: 52, color: Colors.white),
                const SizedBox(height: 10),
                const Text('Funparks',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('Your theme park companion',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                const SizedBox(height: 32),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        TabBar(
                          controller: _tabs,
                          labelColor: cs.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: cs.primary,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          tabs: const [Tab(text: 'Log In'), Tab(text: 'Register')],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabs,
                            children: [_loginTab(), _registerTab()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                  child: Text('Continue without account',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _emailField(ctrl: _loginEmailCtrl??TextEditingController(), label: 'Email'),
          const SizedBox(height: 14),
          _passField(ctrl: _loginPassCtrl??TextEditingController(), label: 'Password', visible: _loginPassVisible,
              onToggle: () => setState(() => _loginPassVisible = !_loginPassVisible)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: _resetPassword, child: const Text('Forgot password?')),
          ),
          if (_loginError != null) ...[
            const SizedBox(height: 4),
            _ErrorBox(message: _loginError!),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loginBusy ? null : _login,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _loginBusy
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Log In', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _registerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _emailField(ctrl: _regEmailCtrl??TextEditingController(), label: 'Email'),
          const SizedBox(height: 14),
          _passField(ctrl: _regPassCtrl??TextEditingController(), label: 'Password', visible: _regPassVisible,
              onToggle: () => setState(() => _regPassVisible = !_regPassVisible)),
          const SizedBox(height: 14),
          _passField(ctrl: _regConfirmCtrl??TextEditingController(), label: 'Confirm password', visible: _regPassVisible,
              onToggle: () => setState(() => _regPassVisible = !_regPassVisible)),
          if (_regError != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(message: _regError!),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _regBusy ? null : _register,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _regBusy
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          Text('By registering you agree to our Terms of Service.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _emailField({required TextEditingController ctrl, required String label}) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _passField({required TextEditingController ctrl, required String label,
      required bool visible, required VoidCallback onToggle}) {
    return TextField(
      controller: ctrl,
      obscureText: !visible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
        ],
      ),
    );
  }
}