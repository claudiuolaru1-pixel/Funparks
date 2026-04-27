// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ↓↓↓ KEEP THESE EXACTLY AS GENERATED ↓↓↓
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: '...',
    appId: '...',
    messagingSenderId: '...',
    projectId: '...',
    authDomain: '...',
    storageBucket: '...',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9YP3eakiCzrJYT7-H6Hjtwcj2Jf0PCN8',
    appId: '1:50958281106:android:a85bbfba720a39872e794b',
    messagingSenderId: '50958281106',
    projectId: 'funparks-779c6',
    storageBucket: 'funparks-779c6.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: '...',
    appId: '...',
    messagingSenderId: '...',
    projectId: '...',
    storageBucket: '...',
    iosBundleId: '...',
  );

  // etc...
}