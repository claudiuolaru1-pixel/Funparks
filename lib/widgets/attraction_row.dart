import 'package:flutter/material.dart';

// ✅ Adjust these imports to your project paths:
import '../services/wait_time_service.dart';
import '../l10n/app_localizations.dart';

// These are assumed to already exist in your codebase:
import '../models/attraction.dart';
import '../i18n/i18n_content.dart';
import 'soft_badge.dart';
import 'action_pill.dart';

class AttractionRow extends StatelessWidget {
  final WaitTimeService waitTimeService;
  final String parkId;
  final Attraction attraction;
  final I18nContent i18n;
  final String Function(String) categoryLabel;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const AttractionRow({
    super.key,
    required this.waitTimeService,
    required this.parkId,
    required this.attraction,
    required this.i18n,
    required this.categoryLabel,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final cat = categoryLabel(attraction.category);
    final translatedDesc =
        i18n.tAttractionDesc(context, attraction.id, attraction.description);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          boxShadow: const [
            BoxShadow(blurRadius: 10, offset: Offset(0, 3), color: Colors.black12),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 76,
                height: 76,
                child: Image.asset(
                  attraction.image,
                  fit: BoxFit.cover,
                  cacheWidth: 220,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attraction.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // If you want your inline toggle, swap this Text for _InlineTranslateText
                  Text(
                    translatedDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SoftBadge(
                        icon: Icons.star,
                        text: attraction.rating.toStringAsFixed(1),
                      ),

                      StreamBuilder<WaitTimeReading?>(
                        stream: waitTimeService.streamLiveWaitReading(
                          parkId: parkId,
                          attractionId: attraction.id,
                        ),
                        builder: (_, snap) {
                          // While loading, just show fallback (no "LIVE")
                          if (snap.connectionState == ConnectionState.waiting) {
                            return SoftBadge(
                              icon: Icons.schedule,
                              text: '${attraction.liveWaitMinutes} min',
                            );
                          }

                          final r = snap.data;

                          // ✅ LIVE only if fresh
                          if (r != null && r.isFresh(maxAgeMinutes: 20)) {
                            return SoftBadge(
                              icon: Icons.timer,
                              text: '${r.minutes} min • ${loc.liveWait}',
                            );
                          }

                          // ✅ Not fresh / missing: show fallback + info
                          final fallback = attraction.liveWaitMinutes;
                          final ago = r?.minutesAgo();
                          final suffix = (ago == null)
                              ? _safeNoLiveText(loc)
                              : '${ago}m ago';

                          return SoftBadge(
                            icon: Icons.schedule,
                            text: '$fallback min • $suffix',
                          );
                        },
                      ),

                      if (attraction.topPick)
                        SoftBadge(icon: Icons.star, text: loc.topPick),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            ActionPill(
              attractionId: attraction.id,
              addLabel: loc.addToMyDay,
              removeLabel: loc.removeFromMyDay,
              directionsLabel: loc.directions,
              onDirections: onDirections,
            ),
          ],
        ),
      ),
    );
  }

  String _safeNoLiveText(AppLocalizations loc) {
    // If you don't have loc.noLiveData in your l10n yet,
    // this keeps the build from failing.
    try {
      // ignore: unused_local_variable
      final _ = loc.noLiveData;
      return loc.noLiveData;
    } catch (_) {
      return 'No live data';
    }
  }
}

class InlineTranslateText extends StatefulWidget {
  final String id;
  final String original;
  final String translated;

  const InlineTranslateText({
    super.key,
    required this.id,
    required this.original,
    required this.translated,
  });

  @override
  State<InlineTranslateText> createState() => _InlineTranslateTextState();
}

class _InlineTranslateTextState extends State<InlineTranslateText> {
  bool _showTranslated = false;

  @override
  Widget build(BuildContext context) {
    final txt = _showTranslated ? widget.translated : widget.original;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Text(
            txt,
            key: ValueKey('${widget.id}_$_showTranslated'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() => _showTranslated = !_showTranslated),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              I18nContent.buttonLabel(context, _showTranslated),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
