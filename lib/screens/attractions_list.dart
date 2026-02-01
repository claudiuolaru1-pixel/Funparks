import 'package:flutter/material.dart';

// ✅ adjust these imports to your project structure:
import '../services/wait_time_service.dart';
import '../widgets/attraction_row.dart';
import '../models/attraction.dart';
import '../i18n/i18n_content.dart';

class AttractionsListScreen extends StatelessWidget {
  final String parkId;
  final List<Attraction> attractions;
  final I18nContent i18n;
  final String Function(String) categoryLabel;

  const AttractionsListScreen({
    super.key,
    required this.parkId,
    required this.attractions,
    required this.i18n,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final waitTimeService = WaitTimeService(); // ✅ create once here

    return ListView.builder(
      itemCount: attractions.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, i) {
        final a = attractions[i];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AttractionRow(
            waitTimeService: waitTimeService,
            parkId: parkId,
            attraction: a,
            i18n: i18n,
            categoryLabel: categoryLabel,
            onTap: () {
              // your existing behavior
            },
            onDirections: () {
              // your existing behavior
            },
          ),
        );
      },
    );
  }
}
