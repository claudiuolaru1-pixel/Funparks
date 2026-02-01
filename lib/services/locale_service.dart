import 'package:flutter/widgets.dart';

class LocaleService {
  /// Returns the suggested locale for a park country.
  /// You can expand this mapping anytime.
  static Locale? localeForCountry(String country) {
    final c = country.trim().toLowerCase();

    // Spain / Mexico / etc.
    if (c == 'spain' || c == 'españa' || c == 'espana') return const Locale('es');

    // France
    if (c == 'france') return const Locale('fr');

    // Netherlands
    if (c == 'netherlands' || c == 'holland') return const Locale('nl');

    // Germany
    if (c == 'germany' || c == 'deutschland') return const Locale('de');

    // Italy
    if (c == 'italy' || c == 'italia') return const Locale('it');

    // Portugal / Brazil (neutral Portuguese you asked for)
    if (c == 'portugal' || c == 'brazil') return const Locale('pt');

    // Russia
    if (c == 'russia') return const Locale('ru');

    // China (simplified)
    if (c == 'china') return const Locale('zh');

    return null; // unknown → don't auto switch
  }
}
