import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'home_map_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _goToMap(BuildContext context) {
    debugPrint('START_SCREEN: Continue pressed -> going to HomeMapScreen');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeMapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('START_SCREEN: build()');

    final loc = AppLocalizations.of(context);
    final title = loc?.appTitle ?? 'Funparks';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/start_bg.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to $title!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Discover parks, plan your day, share your rides.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build 71',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _goToMap(context),
                        child: const Text('Continue without an account'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _goToMap(context),
                        child: const Text('Sign in'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _goToMap(context),
                        child: const Text('Create an account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
