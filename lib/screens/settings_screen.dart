import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();

    const currencies = ['EUR', 'GBP', 'USD'];

    final localeOptions = <Locale>[
      const Locale('en'),
      const Locale('es'),
      const Locale('fr'),
      const Locale('de'),
      const Locale('it'),
      const Locale('nl'),
      const Locale('pt'),
      const Locale('ru'),
      const Locale('zh'),
    ];

    String localeLabel(Locale l) {
      switch (l.languageCode) {
        case 'en':
          return 'English';
        case 'es':
          return 'Español';
        case 'fr':
          return 'Français';
        case 'de':
          return 'Deutsch';
        case 'it':
          return 'Italiano';
        case 'nl':
          return 'Nederlands';
        case 'pt':
          return 'Português';
        case 'ru':
          return 'Русский';
        case 'zh':
          return '中文';
        default:
          return l.languageCode;
      }
    }

    final current = Locale(app.locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ---------- Language ----------
          ListTile(
            title: Text(
              loc.language,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(localeLabel(current)),
            trailing: DropdownButton<Locale>(
              value: localeOptions.firstWhere(
                (x) => x.languageCode == current.languageCode,
                orElse: () => const Locale('en'),
              ),
              onChanged: (v) async {
                if (v == null) return;
                await context.read<AppState>().setLocale(v);
              },
              items: localeOptions
                  .map(
                    (l) => DropdownMenuItem(
                      value: l,
                      child: Text(localeLabel(l)),
                    ),
                  )
                  .toList(),
            ),
          ),

          const Divider(),

          // ---------- Currency ----------
          ListTile(
            title: Text(
              loc.currency,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(app.currency),
            trailing: DropdownButton<String>(
              value: currencies.contains(app.currency) ? app.currency : 'EUR',
              onChanged: (v) async {
                if (v == null) return;
                await context.read<AppState>().setCurrency(v);
              },
              items: currencies
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
