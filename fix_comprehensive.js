const fs=require('fs');
let c=fs.readFileSync('lib/screens/park_detail_screen.dart','utf8');

// FIX 1: Restore full _AttractionRow build method (currently minimal)
c=c.replace(
`  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Text(attraction.name, style: const TextStyle(color: Colors.black)),
    );
  }
}

class _ActionPill`,
`  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final lookup = _I18nLookup(i18n);
    final cat = categoryLabel(attraction.category);
    final baseEn = attraction.description.trim().isEmpty
        ? attraction.category
        : attraction.description.trim();
    final pair = lookup.pairDescFromSection(context,
        section: 'attractions', id: attraction.id, fallbackEn: baseEn);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: const [
            BoxShadow(blurRadius: 10, offset: Offset(0, 3), color: Colors.black12)
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
                child: ParkImage(image: attraction.image, fit: BoxFit.cover, cacheWidth: 220),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(attraction.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(cat,
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(pair.translated,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _SoftBadge(
                        icon: Icons.star,
                        text: attraction.rating.toStringAsFixed(1)),
                    _SoftBadge(icon: Icons.timer, text: '\${attraction.liveWaitMinutes} min'),
                    if (attraction.topPick)
                      _SoftBadge(icon: Icons.star, text: loc.topPick),
                    if ((attraction.minHeightCm ?? 0) > 0)
                      _SoftBadge(icon: Icons.height, text: '\${attraction.minHeightCm} cm+'),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _ActionPill(
              attractionId: attraction.id,
              attractionName: attraction.name,
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
}

class _ActionPill`
);

// FIX 2: Remove WaitTimeService from detail screen build
c=c.replace(
  '    final cat = widget.categoryLabel(a.category);\n    final service = WaitTimeService();\n\n    final factLines',
  '    final cat = widget.categoryLabel(a.category);\n\n    final factLines'
);

// FIX 3: Replace StreamBuilder in detail screen with static pill
c=c.replace(
`                  StreamBuilder<WaitTimeReading?>(
                    stream: service.streamLiveWaitReading(
                        parkId: widget.parkId,
                        attractionId: a.id),
                    builder: (_, snap) {
                      final minutes =
                          snap.data?.minutes ?? a.liveWaitMinutes;
                      return _Pill(
                          icon: Icons.timer,
                          text:
                              '\$minutes min (\${loc.liveWait})');
                    },
                  ),`,
  `                  _Pill(icon: Icons.timer, text: '\${a.liveWaitMinutes} min (\${loc.liveWait})'),`
);

// FIX 4: Remove _PremiumAppear from _FoodTopCard
c=c.replace(
`    return _PremiumAppear(
      child: _PressDown(
        onTap: onTap,`,
  `    return _PressDown(
      onTap: onTap,`
);
// Remove extra closing ) from _PremiumAppear
c=c.replace(
`        ),
      ),
    );
  }
}

class _FoodRow`,
`        ),
    );
  }
}

class _FoodRow`
);

// FIX 5: Fix _AttractionTopCard - replace InkWell with GestureDetector and remove RepaintBoundary
c=c.replace(
`    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: RepaintBoundary(
        child: Container(`,
  `    return GestureDetector(
      onTap: onTap,
      child: Container(`
);
// Remove RepaintBoundary closing
c=c.replace(
`          ),
        ),
      ),
    );
  }
}

class _AttractionRow`,
`          ),
      ),
    );
  }
}

class _AttractionRow`
);

fs.writeFileSync('lib/screens/park_detail_screen.dart',c,'utf8');
console.log('Fix 1 AttractionRow restored:', c.includes('GestureDetector(\n      onTap: onTap,\n      child: Container(\n        padding') ? 'YES' : 'NO');
console.log('Fix 2 WaitTimeService removed:', !c.includes('final service = WaitTimeService();\n\n    final factLines') ? 'YES' : 'NO');
console.log('Fix 3 StreamBuilder removed:', !c.includes('service.streamLiveWaitReading(\n                        parkId: widget.parkId') ? 'YES' : 'NO');
console.log('Fix 4 PremiumAppear removed:', !c.includes('return _PremiumAppear(') ? 'YES' : 'NO');
console.log('Fix 5 RepaintBoundary removed:', !c.includes('RepaintBoundary') ? 'YES' : 'NO');