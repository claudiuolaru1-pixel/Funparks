import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
      const Locale('ar'),
    ];

    String localeLabel(Locale l) {
      switch (l.languageCode) {
        case 'en': return 'English';
        case 'es': return 'Espanol';
        case 'fr': return 'Francais';
        case 'de': return 'Deutsch';
        case 'it': return 'Italiano';
        case 'nl': return 'Nederlands';
        case 'pt': return 'Portugues';
        case 'ru': return 'Русский';
        case 'zh': return '中文';
        case 'ar': return 'العربية';
        default: return l.languageCode;
      }
    }

    final current = Locale(app.locale.languageCode);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          if (app.isLoggedIn) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cs.primary,
                    radius: 24,
                    child: Text(
                      (app.userEmail ?? '?')[0].toUpperCase(),
                      style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Logged in as',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        Text(
                          app.userEmail ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log out',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w700)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Log out'),
                    content:
                        const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Log out')),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AppState>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/start');
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              subtitle: const Text('Permanently delete your account and data'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('This will permanently delete your account and all your data. This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  try {
                    await context.read<AppState>().deleteAccount();
                    if (context.mounted) Navigator.of(context).pushReplacementNamed('/start');
                  } catch (_) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please sign in again to delete your account.')));
                  }
                }
              },
            ),
            const Divider(),
          ] else ...[
            ListTile(
              leading: Icon(Icons.login, color: cs.primary),
              title: Text('Log in / Register',
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.w700)),
              subtitle: const Text('Sync your data across devices'),
              onTap: () => Navigator.pushNamed(context, '/signin'),
            ),
            const Divider(),
          ],
          ListTile(
            title: Text(loc.language,
                style: const TextStyle(fontWeight: FontWeight.w800)),
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
                  .map((l) => DropdownMenuItem(
                      value: l, child: Text(localeLabel(l))))
                  .toList(),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(loc.currency,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(app.currency),
            trailing: DropdownButton<String>(
              value:
                  currencies.contains(app.currency) ? app.currency : 'EUR',
              onChanged: (v) async {
                if (v == null) return;
                await context.read<AppState>().setCurrency(v);
              },
              items: currencies
                  .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('funparksfun@gmail.com'),
            onTap: () async {
              final uri = Uri(scheme: 'mailto', path: 'funparksfun@gmail.com', queryParameters: {'subject': 'Funparks App Feedback'});
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w800)),
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Funparks is an independent, unofficial guide app and is not affiliated with, endorsed by, or connected to any of the theme parks, attractions or brands featured. All park names, trademarks and intellectual property belong to their respective owners. Images used are AI-generated illustrations for informational purposes only and do not represent official park media. Disney, Universal, and all other brand names are trademarks of their respective owners.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
