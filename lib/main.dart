import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'models/park.dart';
import 'screens/start_screen.dart';
import 'screens/home_map_screen.dart';
import 'screens/park_detail_screen.dart';
import 'screens/my_day_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/sign_in_screen.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';

bool _mapsRendererInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (!_mapsRendererInitialized &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android) {
    final platform = GoogleMapsFlutterPlatform.instance;
    if (platform is GoogleMapsFlutterAndroid) {
      await platform.initializeWithRenderer(AndroidMapRenderer.legacy);
      platform.useAndroidViewSurface = true;
      _mapsRendererInitialized = true;
    }
  }
  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: const FunparksApp(),
    ),
  );
}

class FunparksApp extends StatelessWidget {
  const FunparksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: appState.locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          initialRoute: '/start',
          routes: {
            '/start': (_) => const StartScreen(),
            '/home': (_) => const HomeMapScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/privacy': (_) => const PrivacyScreen(),
            '/my_day': (_) => const MyDayScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/signin') {
              final arg = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => SignInScreen(
                  startOnRegister: arg == 'register',
                ),
              );
            }
            if (settings.name == '/park') {
              final arg = settings.arguments;
              if (arg is Park) {
                return MaterialPageRoute(
                  builder: (_) => ParkDetailScreen(park: arg),
                );
              }
              return MaterialPageRoute(
                builder: (_) => const _RouteErrorScreen(
                  message: 'Missing/invalid Park argument for /park route.',
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  final String message;
  const _RouteErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message),
        ),
      ),
    );
  }
}