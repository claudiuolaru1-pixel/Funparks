// lib/widgets/featured_parks_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/park_summary.dart';
import 'park_image.dart';

class FeaturedParksBanner extends StatelessWidget {
  final List<ParkSummary> parks;
  final void Function(ParkSummary) onTap;

  const FeaturedParksBanner({
    super.key,
    required this.parks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (parks.isEmpty) return const SizedBox.shrink();
    final featured = parks.take(8).toList();
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Featured Parks',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${parks.length} parks worldwide',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withOpacity(0.45),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // ── Horizontal scroll cards ─────────────────────────────────────
        SizedBox(
          height: 192,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            itemCount: featured.length,
            itemBuilder: (_, i) => _FeaturedCard(
              park: featured[i],
              onTap: () => onTap(featured[i]),
            ),
          ),
        ),

        // ── Section divider ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'All Parks',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final ParkSummary park;
  final VoidCallback onTap;
  const _FeaturedCard({required this.park, required this.onTap});

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _pressed = false;

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'thrill':    return const Color(0xFFD32F2F);
      case 'water':     return const Color(0xFF0277BD);
      case 'safari':    return const Color(0xFF2E7D32);
      case 'family':    return const Color(0xFF6A1B9A);
      default:          return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.park;
    final hasThumb = (p.thumbnail ?? '').isNotEmpty;
    final typeColor = _typeColor(p.type.name);

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
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 95),
        child: Container(
          width: 148,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                hasThumb
                    ? ParkImage(
                        image: p.thumbnail!,
                        fit: BoxFit.cover,
                        cacheWidth: 400,
                      )
                    : Container(
                        color: typeColor.withOpacity(0.65),
                        child: Center(
                          child: Text(
                            p.name.isNotEmpty ? p.name[0] : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                // Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.82),
                      ],
                    ),
                  ),
                ),

                // Type pill — top left
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      p.type.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // Bottom text
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.country,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
