import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  String? error;

  Future<void> _signin() async {
    setState(()=>error=null);
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: pass.text);
      if(mounted) Navigator.of(context).pop(true);
    }catch(e){ setState(()=>error='Sign in failed'); }
  }

  Future<void> _reset() async {
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset email sent')));
    }catch(_){}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            if(error!=null) Padding(padding: const EdgeInsets.only(top:8), child: Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 12),
            FilledButton(onPressed: _signin, child: const Text('Sign In')),
            TextButton(onPressed: _reset, child: const Text('Forgot password?'))
          ],
        ),
      ),
    );
  }
}


