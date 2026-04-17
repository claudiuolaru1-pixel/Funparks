// lib/widgets/premium_park_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/park_summary.dart';
import 'park_image.dart';

class PremiumParkCard extends StatefulWidget {
  final ParkSummary park;
  final VoidCallback onTap;
  const PremiumParkCard({super.key, required this.park, required this.onTap});

  @override
  State<PremiumParkCard> createState() => _PremiumParkCardState();
}

class _PremiumParkCardState extends State<PremiumParkCard> {
  bool _pressed = false;

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'thrill':    return const Color(0xFFD32F2F);
      case 'water':     return const Color(0xFF0277BD);
      case 'safari':    return const Color(0xFF2E7D32);
      case 'family':    return const Color(0xFF6A1B9A);
      case 'adventure': return const Color(0xFFE65100);
      default:          return const Color(0xFF1565C0);
    }
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'thrill':    return 'THRILL';
      case 'water':     return 'WATER';
      case 'safari':    return 'SAFARI';
      case 'family':    return 'FAMILY';
      case 'adventure': return 'ADVENTURE';
      default:          return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.park;
    final hasThumb = (p.thumbnail ?? '').isNotEmpty;
    final typeColor = _typeColor(p.type.name);
    final price = p.entryPrices.adult;
    final currency = p.currency;
    final location = [p.city, p.country]
        .where((s) => (s ?? '').isNotEmpty)
        .join(', ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.965 : 1.0,
        duration: const Duration(milliseconds: 95),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          height: 158,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_pressed ? 0.08 : 0.20),
                blurRadius: _pressed ? 6 : 16,
                offset: Offset(0, _pressed ? 2 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Hero thumbnail ──────────────────────────────────────
                Hero(
                  tag: 'park_hero_${p.id}',
                  child: hasThumb
                      ? ParkImage(
                          image: p.thumbnail!,
                          fit: BoxFit.cover,
                          cacheWidth: 900,
                        )
                      : Container(
                          color: typeColor.withOpacity(0.65),
                          child: Center(
                            child: Text(
                              p.name.isNotEmpty ? p.name[0] : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                ),

                // ── Cinematic gradient ──────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.40, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.12),
                        Colors.black.withOpacity(0.80),
                      ],
                    ),
                  ),
                ),

                // ── Price badge — top right ─────────────────────────────
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.52),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.28), width: 1),
                    ),
                    child: Text(
                      '$currency ${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),

                // ── Bottom content ──────────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                  blurRadius: 12,
                                  color: Colors.black54,
                                  offset: Offset(0, 1)),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 11),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: typeColor.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _typeLabel(p.type.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
