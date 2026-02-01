import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'screens/start_screen.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

/// Stores last Flutter error so we can show it even in release builds.
class _LastErrorStore {
  static FlutterErrorDetails? last;
}

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ---- Google Maps Android renderer/platform-view fixes ----
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final platform = GoogleMapsFlutterPlatform.instance;
      if (platform is GoogleMapsFlutterAndroid) {
        // Force legacy renderer (fixes grey/blank map on some devices)
        await platform.initializeWithRenderer(AndroidMapRenderer.legacy);

        // Force hybrid composition (usually most stable with platform views)
        platform.useAndroidViewSurface = true;
      }
    }
    // ---------------------------------------------------------

    // Firebase init
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, st) {
      debugPrint('Firebase initializeApp failed: $e');
      debugPrint('$st');
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      _LastErrorStore.last = details;
      FlutterError.dumpErrorToConsole(details);
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      _LastErrorStore.last = details;
      return _PrettyErrorScreen(details: details);
    };

    runApp(const FunparksApp());
  }, (error, stack) {
    _LastErrorStore.last = FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'runZonedGuarded',
      context: ErrorDescription('Uncaught async error'),
    );
  });
}

class FunparksApp extends StatelessWidget {
  const FunparksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF72C8FF));

    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return FutureBuilder<void>(
            future: appState.ensureInitialized(_deviceLocale(), _defaultCurrency()),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const MaterialApp(home: _BootSplash());
              }

              return MaterialApp(
                title: 'Funparks',
                locale: appState.locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: ThemeData(
                  colorScheme: colorScheme,
                  useMaterial3: true,
                  fontFamily: 'Roboto',
                ),
                home: const StartScreen(),
              );
            },
          );
        },
      ),
    );
  }

  Locale _deviceLocale() {
    final l = ui.PlatformDispatcher.instance.locale;
    return Locale(l.languageCode);
  }

  String _defaultCurrency() {
    final region = ui.PlatformDispatcher.instance.locale.countryCode ?? 'EU';
    if (region == 'GB') return 'GBP';
    if (region == 'US') return 'USD';
    return 'EUR';
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PrettyErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;
  const _PrettyErrorScreen({required this.details});

  @override
  Widget build(BuildContext context) {
    final msg = details.exceptionAsString();
    final stack = details.stack?.toString() ?? '(no stack)';

    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: SingleChildScrollView(
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Funparks Debug Info (Temporary)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The app hit an error. Please copy everything below and send it:',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                      color: const Color(0xFFF7F7F7),
                    ),
                    child: Text(
                      'ERROR:\n$msg\n\nSTACK:\n$stack',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
