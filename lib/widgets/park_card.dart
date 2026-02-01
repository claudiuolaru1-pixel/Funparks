import 'package:flutter/material.dart';
import '../models/park.dart';

class ParkCard extends StatelessWidget {
  final Park park;
  final VoidCallback onView;

  const ParkCard({super.key, required this.park, required this.onView});

  String get iconEmoji {
    switch (park.type) {
      case 'thrill':
        return '🎢';
      case 'water':
        return '🌊';
      case 'fantasy':
        return '🏰';
      case 'safari':
        return '🐘';
      case 'tech':
        return '🤖';
      default:
        return '🎡';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(iconEmoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(park.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(park.country, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text('From ${park.currency} ${park.entryPrices['adult']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onView,
              style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}


