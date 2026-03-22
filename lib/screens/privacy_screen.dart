import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text('Last updated: March 2026', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 20),
            _section('About Funparks',
              'Funparks is an independent, unofficial theme park guide app developed and operated by an individual developer. This Privacy Policy explains how Funparks handles information when you use the app.'),
            _section('Information We Collect',
              'Funparks collects minimal information necessary to provide its services:\n\n'
              '• App preferences (language, currency) stored locally on your device\n'
              '• My Day and My Food selections stored locally on your device\n'
              '• AI Assistant queries are sent to our secure Firebase Cloud Function, which calls the Anthropic API to generate responses. Queries are not stored or logged by us.\n'
              '• Firebase services (Authentication, Firestore, Storage) may collect anonymous usage data as described in Google Firebase\'s Privacy Policy.'),
            _section('How We Use Information',
              'We use collected information solely to provide app functionality:\n\n'
              '• Your preferences are used to personalise your experience\n'
              '• AI queries are processed only to generate your requested response\n'
              '• We do not sell, share or monetise any user data\n'
              '• We do not display advertising'),
            _section('Third Party Services',
              'Funparks uses the following third-party services:\n\n'
              '• Google Firebase (Authentication, Firestore, Cloud Storage, Cloud Functions) — subject to Google\'s Privacy Policy\n'
              '• Anthropic Claude API — AI responses are processed by Anthropic subject to their Privacy Policy\n'
              '• Google Maps — map functionality subject to Google\'s Privacy Policy'),
            _section('Children\'s Privacy',
              'Funparks is a theme park guide app suitable for all ages. We do not knowingly collect personal information from children under 13. The app does not require account creation to use its core features.'),
            _section('Data Storage',
              'Your app preferences and saved items are stored locally on your device. No personal data is transmitted to our servers except AI Assistant queries, which are processed in real-time and not stored.'),
            _section('Your Rights',
              'You can clear all locally stored app data at any time by uninstalling the app or clearing app data in your device settings. For any privacy-related questions or requests, please contact us.'),
            _section('Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify users of significant changes through the app. Continued use of Funparks after changes constitutes acceptance of the updated policy.'),
            _section('Contact',
              'For any questions about this Privacy Policy or your data, please contact us:'),
            GestureDetector(
              onTap: () async {
                final uri = Uri(scheme: 'mailto', path: 'funparksfun@gmail.com', query: 'subject=Funparks Privacy Enquiry');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
              child: const Text(
                'funparksfun@gmail.com',
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 15),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}