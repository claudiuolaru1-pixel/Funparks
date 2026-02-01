// lib/screens/park_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/park.dart';
import '../models/attraction.dart';
import '../models/food_place.dart';
import '../services/portaventura_repository.dart';
import '../services/portaventura_i18n_repository.dart';
import '../services/wait_time_service.dart';
import '../services/i18n_content.dart';
import '../models/hotel.dart';
import '../services/portaventura_hotels_repository.dart';

// ===============================================================
// PREMIUM MICRO-ANIMATIONS / HELPERS (SAFE)
// ===============================================================

class _PressDown extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressDown({required this.child, required this.onTap});

  @override
  State<_PressDown> createState() => _PressDownState();
}

class _PressDownState extends State<_PressDown> {
  bool _down = false;

  void _set(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _down ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class _PremiumAppear extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const _PremiumAppear({
    required this.child,
    this.duration = const Duration(milliseconds: 320),
    this.delay = const Duration(milliseconds: 40),
  });

  @override
  State<_PremiumAppear> createState() => _PremiumAppearState();
}

class _PremiumAppearState extends State<_PremiumAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  late final Animation<double> _scale = Tween<double>(begin: 0.985, end: 1.0)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.86),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
      ),
      child: child,
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.86),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
        boxShadow: const [
          BoxShadow(blurRadius: 10, offset: Offset(0, 3), color: Colors.black12),
        ],
      ),
      child: child,
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  final Widget child;
  const _PremiumBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF72C8FF).withOpacity(0.14),
            Colors.white,
          ],
        ),
      ),
      child: child,
    );
  }
}

// ===============================================================
// LIVE WAIT HELPERS
// ===============================================================

class _LiveWaitText extends StatelessWidget {
  final String parkId;
  final String attractionId;
  final int fallbackMinutes;
  final TextStyle? style;

  const _LiveWaitText({
    required this.parkId,
    required this.attractionId,
    required this.fallbackMinutes,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final service = WaitTimeService();

    return StreamBuilder<WaitTimeReading?>(
      stream: service.streamLiveWaitReading(
        parkId: parkId,
        attractionId: attractionId,
      ),
      builder: (_, snap) {
        final minutes = snap.data?.minutes ?? fallbackMinutes;
        return Text(
          '$minutes min (${loc.liveWait})',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

class _LiveWaitPill extends StatelessWidget {
  final String parkId;
  final String attractionId;
  final int fallbackMinutes;

  const _LiveWaitPill({
    required this.parkId,
    required this.attractionId,
    required this.fallbackMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final service = WaitTimeService();

    return StreamBuilder<WaitTimeReading?>(
      stream: service.streamLiveWaitReading(
        parkId: parkId,
        attractionId: attractionId,
      ),
      builder: (_, snap) {
        final minutes = snap.data?.minutes ?? fallbackMinutes;
        return _SoftBadge(icon: Icons.timer, text: '${minutes}m');
      },
    );
  }
}

// ===============================================================
// SCREEN
// ===============================================================

class ParkDetailScreen extends StatefulWidget {
  final Park park;

  const ParkDetailScreen({
    super.key,
    required this.park,
  });

  @override
  State<ParkDetailScreen> createState() => _ParkDetailScreenState();
}

// ✅ FULL FIXED _ParkDetailScreenState
// Drop this into your park_detail_screen.dart replacing your current _ParkDetailScreenState

class _ParkDetailScreenState extends State<ParkDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  bool _loading = true;
  String? _error;

  List<Attraction> _attractions = const [];
  List<FoodPlace> _food = const [];
  List<Hotel> _hotels = const [];

  I18nContent? _i18n;

  bool get _isPortAventura =>
      widget.park.id.trim().toLowerCase() == 'portaventura';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isPortAventura) {
        final at = await PortAventuraRepository.loadAttractions();
        final food = await PortAventuraRepository.loadFood();
        final hotels = await PortAventuraRepository.loadHotels();
        final i18nRoot = await PortAventuraI18nRepository.load();

        if (!mounted) return;
        setState(() {
          _attractions = at;
          _food = food;
          _hotels = hotels;
          _i18n = I18nContent(i18nRoot);
          _loading = false;
        });
      } else {
        // Non-PortAventura parks: show Overview + Coming Soon tabs
        final i18nRoot = await PortAventuraI18nRepository.load();

        if (!mounted) return;
        setState(() {
          _attractions = const [];
          _food = const [];
          _hotels = const [];
          _i18n = I18nContent(i18nRoot);
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _attractions = const [];
        _food = const [];
        _hotels = const [];
        _i18n = const I18nContent(<String, dynamic>{});
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openMapsDirections(double lat, double lng) async {
    final uri =
        Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps')),
      );
    }
  }

  Future<void> _openWebsite(String url) async {
    final u = url.trim();
    if (u.isEmpty) return;
    final uri = Uri.tryParse(u);
    if (uri == null) return;

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }

  String _categoryLabel(AppLocalizations loc, String category) {
    switch (category.trim().toLowerCase()) {
      case 'thrill':
        return loc.thrill;
      case 'family':
        return loc.family;
      case 'water':
        return loc.water;
      case 'simulator':
        return loc.simulator;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final park = widget.park;

    // Always use a non-null i18n object in UI:
    final i18n = _i18n ?? const I18nContent(<String, dynamic>{});

    return Scaffold(
      appBar: AppBar(
        title: Text(park.name),
        actions: [
          IconButton(
            tooltip: loc.share,
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('${park.name} • Funparks'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: loc.overview),
            Tab(text: loc.attractions),
            Tab(text: loc.foodAndPrices),
            Tab(text: loc.hotels),
          ],
        ),
      ),
      body: _PremiumBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $_error'),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // 1) Overview
                      _OverviewTab(
                        park: park,
                        i18n: i18n,
                        onDirections: () =>
                            _openMapsDirections(park.lat, park.lng),
                        onWebsite: (park.website == null ||
                                park.website!.trim().isEmpty)
                            ? null
                            : () => _openWebsite(park.website!.trim()),
                        showPortAventuraText: _isPortAventura,
                      ),

                      // 2) Attractions
                      _isPortAventura
                          ? _AttractionsTab(
                              parkId: park.id,
                              attractions: _attractions,
                              i18n: i18n,
                              categoryLabel: (c) => _categoryLabel(loc, c),
                              onDirections: (a) =>
                                  _openMapsDirections(a.lat, a.lng),
                            )
                          : _ComingSoonTab(
                              title: loc.attractions,
                              subtitle:
                                  'This park will use the same template as PortAventura.\nWe’ll add attractions here soon.',
                            ),

                      // 3) Food
                      _isPortAventura
                          ? _FoodTab(
                              food: _food,
                              i18n: i18n,
                              onDirections: (f) =>
                                  _openMapsDirections(f.lat, f.lng),
                            )
                          : _ComingSoonTab(
                              title: loc.foodAndPrices,
                              subtitle:
                                  'Food, menus, and prices will appear here soon.',
                            ),

                      // 4) Hotels (NEW signature: hotels + i18n + onDirections)
                      _isPortAventura
                          ? _HotelsTab(
                              hotels: _hotels,
                              i18n: i18n,
                              onDirections: (h) =>
                                  _openMapsDirections(h.lat, h.lng),
                            )
                          : _ComingSoonTab(
                              title: loc.hotels,
                              subtitle: 'Hotels will appear here soon.',
                            ),
                    ],
                  ),
      ),
    );
  }
}


// ===============================================================
// OVERVIEW TAB
// ===============================================================

class _OverviewTab extends StatelessWidget {
  final Park park;
  final I18nContent i18n;
  final VoidCallback onDirections;
  final VoidCallback? onWebsite;

  // When false, we avoid showing PortAventura-specific narrative text.
  final bool showPortAventuraText;

  const _OverviewTab({
    required this.park,
    required this.i18n,
    required this.onDirections,
    required this.onWebsite,
    required this.showPortAventuraText,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final locationText =
        '${(park.city ?? '').trim().isEmpty ? '' : '${park.city}, '}${park.country}';

    final facts = <String>[
      '${loc.hours}: ${park.openingHours ?? '—'}',
      '${loc.entryFrom}: ${park.currency} ${(park.entryPrices['adult'] ?? 0)}',
      '${loc.location}: $locationText',
    ].where((e) => e.trim().isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        if ((park.thumbnail ?? '').trim().isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                park.thumbnail!.trim(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black12),
              ),
            ),
          ),
        if ((park.thumbnail ?? '').trim().isNotEmpty) const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: facts.map((t) => _Chip(text: t)).toList(),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onDirections,
                icon: const Icon(Icons.directions),
                label: Text(loc.directions),
              ),
            ),
            if (onWebsite != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onWebsite,
                  icon: const Icon(Icons.public),
                  label: const Text('Website'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),

        // For PortAventura we keep your rich text blocks + i18n.
        // For other parks we show a clean, generic block.
        if (showPortAventuraText) ...[
          _SectionCard(
            title: loc.overview,
            translatedText: i18n.tOverview(
              context,
              'ov_overview_body',
              'PortAventura Park is one of Europe’s most iconic theme parks.',
            ),
            originalText:
                'PortAventura Park is one of Europe’s most iconic theme parks.',
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: loc.highlights,
            translatedText: i18n.tOverview(
              context,
              'ov_highlights_body',
              'Start with top coasters early. Water rides are best mid-day.',
            ),
            originalText:
                'Start with top coasters early. Water rides are best mid-day.',
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Did you know?',
            translatedText: i18n.tOverview(
              context,
              'ov_did_you_know_body',
              'The park opened in 1995 and is divided into themed worlds inspired by global cultures.',
            ),
            originalText:
                'The park opened in 1995 and is divided into themed worlds inspired by global cultures.',
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Plan like a pro',
            translatedText: i18n.tOverview(
              context,
              'ov_plan_body',
              'Start with the biggest rides in the morning. Save water rides for mid-day.',
            ),
            originalText:
                'Start with the biggest rides in the morning. Save water rides for mid-day.',
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Best photo moments',
            translatedText: i18n.tOverview(
              context,
              'ov_photos_body',
              'Look for viewpoints before sunset for warm golden light.',
            ),
            originalText:
                'Look for viewpoints before sunset for warm golden light.',
          ),
        ] else ...[
          _SectionCard(
            title: loc.overview,
            translatedText:
                'This park is ready as a template.\nWe’ll add full content soon.',
            originalText:
                'This park is ready as a template.\nWe’ll add full content soon.',
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatefulWidget {
  final String title;
  final String originalText;
  final String translatedText;

  const _SectionCard({
    required this.title,
    required this.originalText,
    required this.translatedText,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _showTranslated = false;

  @override
  Widget build(BuildContext context) {
    final textToShow =
        _showTranslated ? widget.translatedText : widget.originalText;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(blurRadius: 10, offset: Offset(0, 3), color: Colors.black12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _showTranslated = !_showTranslated),
                child: Text(I18nContent.buttonLabel(context, _showTranslated)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              textToShow,
              key: ValueKey('${widget.title}_$_showTranslated'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ComingSoonTab({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 42, color: Colors.grey.shade700),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ATTRACTIONS TAB — SAFE
// ===============================================================

enum _AttractionSort { recommended, lowestWait, highestRated }

class _AttractionsTab extends StatefulWidget {
  final String parkId;
  final List<Attraction> attractions;
  final I18nContent i18n;
  final String Function(String category) categoryLabel;
  final Future<void> Function(Attraction a) onDirections;

  const _AttractionsTab({
    required this.parkId,
    required this.attractions,
    required this.i18n,
    required this.categoryLabel,
    required this.onDirections,
  });

  @override
  State<_AttractionsTab> createState() => _AttractionsTabState();
}

class _AttractionsTabState extends State<_AttractionsTab> {
  _AttractionSort _sort = _AttractionSort.recommended;

  List<Attraction> _sorted(List<Attraction> items) {
    final list = [...items];

    if (_sort == _AttractionSort.lowestWait) {
      list.sort((a, b) => a.liveWaitMinutes.compareTo(b.liveWaitMinutes));
      return list;
    }
    if (_sort == _AttractionSort.highestRated) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
      return list;
    }

    list.sort((a, b) {
      final at = a.topPick ? 0 : 1;
      final bt = b.topPick ? 0 : 1;
      if (at != bt) return at.compareTo(bt);

      final r = b.rating.compareTo(a.rating);
      if (r != 0) return r;

      return a.liveWaitMinutes.compareTo(b.liveWaitMinutes);
    });

    return list;
  }

  void _openDetails(Attraction a) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AttractionDetailScreen(
          parkId: widget.parkId,
          attraction: a,
          i18n: widget.i18n,
          onDirections: widget.onDirections,
          categoryLabel: widget.categoryLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final topPicks = widget.attractions.where((a) => a.topPick).toList();
    final list = _sorted(widget.attractions);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      children: [
        Consumer<AppState>(
          builder: (_, app, __) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                icon: Icons.route,
                text: 'Route',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (_) => _MyDayRouteSheet(
                      park: context.read<Park>(), // if you don't have Park in scope, pass it in via widget
                      attractions: widget.attractions,
                    ),
                  );
                },
              ),
              _MiniPill(
                icon: Icons.favorite,
                text: '${loc.addToMyDay}: ${app.myDayCount}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: DropdownButton<_AttractionSort>(
            value: _sort,
            onChanged: (v) => setState(() => _sort = v ?? _sort),
            items: [
              DropdownMenuItem(
                value: _AttractionSort.recommended,
                child: Text(loc.recommended),
              ),
              DropdownMenuItem(
                value: _AttractionSort.lowestWait,
                child: Text(loc.lowestWait),
              ),
              DropdownMenuItem(
                value: _AttractionSort.highestRated,
                child: Text(loc.highestRated),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (topPicks.isNotEmpty) ...[
          Text(
            loc.topPick,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _AttractionTopPickRail(
            parkId: widget.parkId,
            items: topPicks,
            categoryLabel: widget.categoryLabel,
            onOpen: _openDetails,
          ),
          const SizedBox(height: 16),
        ],

        ...list.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AttractionRow(
              parkId: widget.parkId,
              attraction: a,
              i18n: widget.i18n,
              categoryLabel: widget.categoryLabel,
              onTap: () => _openDetails(a),
              onDirections: () => widget.onDirections(a),
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// BASIC UI WIDGETS USED IN DETAIL SCREEN
// ===============================================================

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double initial;
  final ValueChanged<double> onChanged;

  const _StarRow({required this.initial, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filled = initial.round().clamp(1, 5);

    return Row(
      children: List.generate(5, (i) {
        final idx = i + 1;
        final isOn = idx <= filled;
        return IconButton(
          onPressed: () => onChanged(idx.toDouble()),
          icon: Icon(isOn ? Icons.star : Icons.star_border),
        );
      }),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _TextCard({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 3),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...lines.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                t,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// FOOD TAB
// ===============================================================

class _FoodTab extends StatelessWidget {
  final List<FoodPlace> food;
  final I18nContent i18n;
  final Future<void> Function(FoodPlace f) onDirections;

  const _FoodTab({
    required this.food,
    required this.i18n,
    required this.onDirections,
  });

  void _openDetails(BuildContext context, FoodPlace f) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FoodDetailScreen(
          food: f,
          i18n: i18n,
          onDirections: onDirections,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (food.isEmpty) {
      return Center(child: Text(loc.comingSoon));
    }

    final top = food.where((f) => f.topPick).toList();
    final rest = food.where((f) => !f.topPick).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      children: [
        Consumer<AppState>(
          builder: (_, app, __) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                icon: Icons.favorite,
                text: '${loc.addToMyFood}: ${app.myFoodCount}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (top.isNotEmpty) ...[
          Text(
            loc.topPick,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...top.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FoodTopCard(
                food: f,
                i18n: i18n,
                onTap: () => _openDetails(context, f),
                onDirections: () => onDirections(f),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: cs.outlineVariant.withOpacity(0.35)),
          const SizedBox(height: 12),
        ],
        ...rest.map(
          (f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FoodRow(
              food: f,
              i18n: i18n,
              onTap: () => _openDetails(context, f),
              onDirections: () => onDirections(f),
            ),
          ),
        ),
      ],
    );
  }
}

class _FoodTopCard extends StatelessWidget {
  final FoodPlace food;
  final I18nContent i18n;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _FoodTopCard({
    required this.food,
    required this.i18n,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return _PremiumAppear(
      child: _PressDown(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 4),
                color: Colors.black12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        food.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.black12),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.18),
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _GlassPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                loc.topPick,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _FoodActionPill(
                          foodId: food.id,
                          addLabel: loc.addToMyFood,
                          removeLabel: loc.removeFromMyFood,
                          directionsLabel: loc.directions,
                          onDirections: onDirections,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      _SoftBadge(
                        icon: Icons.star,
                        text: food.rating.toStringAsFixed(1),
                      ),
                    ],
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

class _FoodRow extends StatelessWidget {
  final FoodPlace food;
  final I18nContent i18n;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _FoodRow({
    required this.food,
    required this.i18n,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final base =
        food.description.trim().isEmpty ? food.type : food.description.trim();
    final subtitle = i18n.tFoodDesc(context, food.id, base);

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
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 3),
              color: Colors.black12,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                food.image,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 76, height: 76, color: Colors.black12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.type,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  _SoftBadge(
                    icon: Icons.star,
                    text: food.rating.toStringAsFixed(1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _FoodActionPill(
              foodId: food.id,
              addLabel: loc.addToMyFood,
              removeLabel: loc.removeFromMyFood,
              directionsLabel: loc.directions,
              onDirections: onDirections,
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodActionPill extends StatelessWidget {
  final String foodId;
  final String addLabel;
  final String removeLabel;
  final String directionsLabel;
  final VoidCallback onDirections;

  const _FoodActionPill({
    required this.foodId,
    required this.addLabel,
    required this.removeLabel,
    required this.directionsLabel,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillIconButton(
            tooltip: directionsLabel,
            icon: Icons.directions,
            onTap: () async {
              HapticFeedback.selectionClick();
              onDirections();
            },
          ),
          Container(
            width: 34,
            height: 1,
            color: cs.outlineVariant.withOpacity(0.35),
          ),
          Consumer<AppState>(
            builder: (_, app, __) {
              final inMyFood = app.isInMyFood(foodId);

              return _PillIconButton(
                tooltip: inMyFood ? removeLabel : addLabel,
                icon: inMyFood ? Icons.favorite : Icons.favorite_border,
                animate: true,
                onTap: () async {
                  await app.toggleMyFood(foodId);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(inMyFood ? removeLabel : addLabel),
                        duration: const Duration(milliseconds: 850),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// ATTRACTIONS WIDGETS
// ===============================================================

class _AttractionTopPickRail extends StatelessWidget {
  final String parkId;
  final List<Attraction> items;
  final String Function(String) categoryLabel;
  final void Function(Attraction a) onOpen;

  const _AttractionTopPickRail({
    required this.parkId,
    required this.items,
    required this.categoryLabel,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final a = items[i];
          return SizedBox(
            width: 280,
            child: _AttractionTopCard(
              parkId: parkId,
              attraction: a,
              categoryLabel: categoryLabel,
              onTap: () => onOpen(a),
            ),
          );
        },
      ),
    );
  }
}

class _AttractionTopCard extends StatelessWidget {
  final String parkId;
  final Attraction attraction;
  final String Function(String) categoryLabel;
  final VoidCallback onTap;

  const _AttractionTopCard({
    required this.parkId,
    required this.attraction,
    required this.categoryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 3),
                color: Colors.black12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 110,
                  child: Image.asset(
                    attraction.image,
                    fit: BoxFit.cover,
                    cacheWidth: 900,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.black12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attraction.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SoftBadge(
                            icon: Icons.star,
                            text: attraction.rating.toStringAsFixed(1),
                          ),
                          _SoftBadge(
                            icon: Icons.category,
                            text: categoryLabel(attraction.category),
                          ),
                          _SoftBadge(
                            icon: Icons.star,
                            text: loc.topPick,
                          ),
                        ],
                      ),
                    ],
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

class _AttractionRow extends StatelessWidget {
  final String parkId;
  final Attraction attraction;
  final I18nContent i18n;
  final String Function(String) categoryLabel;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _AttractionRow({
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
    final service = WaitTimeService();

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
                      _SoftBadge(
                        icon: Icons.star,
                        text: attraction.rating.toStringAsFixed(1),
                      ),
                      StreamBuilder<WaitTimeReading?>(
                        stream: service.streamLiveWaitReading(
                          parkId: parkId,
                          attractionId: attraction.id,
                        ),
                        builder: (_, snap) {
                          final minutes =
                              snap.data?.minutes ?? attraction.liveWaitMinutes;
                          return _SoftBadge(
                            icon: Icons.timer,
                            text: '$minutes min • ${loc.liveWait}',
                          );
                        },
                      ),
                      if (attraction.topPick)
                        _SoftBadge(icon: Icons.star, text: loc.topPick),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            _ActionPill(
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
}

// ===============================================================
// ATTRACTION DETAIL SCREEN
// ===============================================================

class _AttractionDetailScreen extends StatefulWidget {
  final String parkId;
  final Attraction attraction;
  final I18nContent i18n;
  final Future<void> Function(Attraction a) onDirections;
  final String Function(String category) categoryLabel;

  const _AttractionDetailScreen({
    required this.parkId,
    required this.attraction,
    required this.i18n,
    required this.onDirections,
    required this.categoryLabel,
  });

  @override
  State<_AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<_AttractionDetailScreen> {
  final _commentCtrl = TextEditingController();
  final _myWaitCtrl = TextEditingController();
  double _rating = 4.5;
  bool _showDescTranslated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = context.read<AppState>();

      try {
        await app.ensureLoadedForAttraction(widget.attraction.id);
      } catch (_) {}

      final r = app.ratingForAttraction(widget.attraction.id) ??
          widget.attraction.rating;
      final c = app.commentForAttraction(widget.attraction.id) ?? '';
      final myWait = app.myWaitFor(widget.attraction.id);

      if (!mounted) return;
      setState(() {
        _rating = r;
        _commentCtrl.text = c;
        _myWaitCtrl.text = myWait?.toString() ?? '';
      });
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _myWaitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final a = widget.attraction;

    final descTranslated =
        widget.i18n.tAttractionDesc(context, a.id, a.description);
    final cat = widget.categoryLabel(a.category);
    final service = WaitTimeService();

    final factLines = <String>[
      if (a.speedKmh != null) 'Speed: ${a.speedKmh} km/h',
      if (a.heightM != null) 'Height: ${a.heightM!.toStringAsFixed(0)} m',
      if (a.inversions != null) 'Inversions: ${a.inversions}',
      if (a.openedYear != null) 'Opened: ${a.openedYear}',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(a.name),
        actions: [
          IconButton(
            tooltip: loc.share,
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('${a.name} • Funparks'),
          ),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              a.image,
              fit: BoxFit.cover,
              cacheWidth: 1200,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Container(color: Colors.black12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showDescTranslated ? descTranslated : a.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(
                        () => _showDescTranslated = !_showDescTranslated),
                    child: Text(
                        I18nContent.buttonLabel(context, _showDescTranslated)),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(icon: Icons.category, text: cat),
                    StreamBuilder<WaitTimeReading?>(
                      stream: service.streamLiveWaitReading(
                        parkId: widget.parkId,
                        attractionId: a.id,
                      ),
                      builder: (_, snap) {
                        final minutes = snap.data?.minutes ?? a.liveWaitMinutes;
                        return _Pill(
                          icon: Icons.timer,
                          text: '$minutes min (${loc.liveWait})',
                        );
                      },
                    ),
                    Consumer<AppState>(
                      builder: (_, app, __) {
                        final myWait = app.myWaitFor(a.id);
                        return _Pill(
                          icon: Icons.edit,
                          text: myWait == null
                              ? loc.setMyWait
                              : '${loc.setMyWait}: $myWait',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _TextCard(title: 'Facts', lines: factLines),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => widget.onDirections(a),
                        icon: const Icon(Icons.directions),
                        label: Text(loc.directions),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<AppState>(
                        builder: (_, app, __) {
                          final inMyDay = app.isInMyDay(a.id);
                          return FilledButton.icon(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await app.toggleMyDayAttraction(a.id);
                            },
                            icon: Icon(inMyDay
                                ? Icons.favorite
                                : Icons.favorite_border),
                            label: Text(inMyDay
                                ? loc.removeFromMyDay
                                : loc.addToMyDay),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(loc.yourRating,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _StarRow(
                  initial: _rating,
                  onChanged: (v) => setState(() => _rating = v),
                ),
                const SizedBox(height: 18),
                Text(loc.yourComment,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: loc.commentHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(loc.myWaitTimeOptional,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _myWaitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: loc.minutesHint,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final app = context.read<AppState>();
                      await app.setAttractionRating(a.id, _rating);
                      await app.setAttractionComment(
                          a.id, _commentCtrl.text.trim());

                      final wait = int.tryParse(_myWaitCtrl.text.trim());
                      await app.setMyWaitMinutes(a.id, wait);

                      if (wait != null && wait > 0) {
                        await service.submitWaitTime(
                          parkId: widget.parkId,
                          attractionId: a.id,
                          minutes: wait,
                        );
                      }

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.saved)));
                    },
                    child: Text(loc.save),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// SHARED SMALL WIDGETS (used by Attractions + Food + LiveWait)
// ===============================================================

class _PillIconButton extends StatefulWidget {
  final String tooltip;
  final IconData icon;
  final Future<void> Function() onTap;
  final bool animate;

  const _PillIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.animate = false,
  });

  @override
  State<_PillIconButton> createState() => _PillIconButtonState();
}

class _PillIconButtonState extends State<_PillIconButton> {
  bool _pressed = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isHeart =
        widget.icon == Icons.favorite || widget.icon == Icons.favorite_border;

    final scale = widget.animate ? (_pressed ? 0.93 : 1.0) : 1.0;
    final opacity = widget.animate ? (_pressed ? 0.92 : 1.0) : 1.0;

    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _busy
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  if (widget.animate) {
                    HapticFeedback.lightImpact();
                    setState(() => _pressed = true);
                    await Future.delayed(const Duration(milliseconds: 70));
                    if (mounted) setState(() => _pressed = false);
                  } else {
                    HapticFeedback.selectionClick();
                  }
                  await widget.onTap();
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
        onTapDown: (_) {
          if (!widget.animate) return;
          setState(() => _pressed = true);
        },
        onTapCancel: () {
          if (!widget.animate) return;
          setState(() => _pressed = false);
        },
        onTapUp: (_) {
          if (!widget.animate) return;
          setState(() => _pressed = false);
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          scale: scale,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            opacity: opacity,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                widget.icon,
                size: 20,
                color: isHeart ? cs.primary : cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SoftBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String attractionId;
  final String addLabel;
  final String removeLabel;
  final String directionsLabel;
  final VoidCallback onDirections;

  const _ActionPill({
    required this.attractionId,
    required this.addLabel,
    required this.removeLabel,
    required this.directionsLabel,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillIconButton(
            tooltip: directionsLabel,
            icon: Icons.directions,
            onTap: () async {
              HapticFeedback.selectionClick();
              onDirections();
            },
          ),
          Container(
            width: 34,
            height: 1,
            color: cs.outlineVariant.withOpacity(0.35),
          ),
          Consumer<AppState>(
            builder: (_, app, __) {
              final inMyDay = app.isInMyDay(attractionId);
              return _PillIconButton(
                tooltip: inMyDay ? removeLabel : addLabel,
                icon: inMyDay ? Icons.favorite : Icons.favorite_border,
                animate: true,
                onTap: () async {
                  await app.toggleMyDayAttraction(attractionId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(inMyDay ? removeLabel : addLabel),
                        duration: const Duration(milliseconds: 850),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MyDayRouteSheet extends StatelessWidget {
  final Park park;
  final List<Attraction> attractions;

  const _MyDayRouteSheet({
    required this.park,
    required this.attractions,
  });

  List<Attraction> _selectedInOrder(AppState app) {
    final selected = attractions.where((a) => app.isInMyDay(a.id)).toList();
    if (selected.length <= 2) return selected;

    // Greedy nearest-neighbor route:
    final remaining = [...selected];
    final ordered = <Attraction>[];

    // Start at park center (or you could start at first selected)
    double curLat = park.lat;
    double curLng = park.lng;

    while (remaining.isNotEmpty) {
      remaining.sort((a, b) {
        final da = _dist(curLat, curLng, a.lat, a.lng);
        final db = _dist(curLat, curLng, b.lat, b.lng);
        return da.compareTo(db);
      });
      final next = remaining.removeAt(0);
      ordered.add(next);
      curLat = next.lat;
      curLng = next.lng;
    }

    return ordered;
  }

  static double _dist(double aLat, double aLng, double bLat, double bLng) {
    final dx = (aLat - bLat);
    final dy = (aLng - bLng);
    return (dx * dx) + (dy * dy); // squared distance (fast + good enough)
  }

  Uri _googleMapsRouteUri(List<Attraction> ordered) {
    if (ordered.isEmpty) {
      return Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${park.lat},${park.lng}');
    }
    final origin = '${park.lat},${park.lng}';
    final destination = '${ordered.last.lat},${ordered.last.lng}';

    // Waypoints are everything except the last
    final waypoints = ordered.length <= 1
        ? ''
        : ordered
            .sublist(0, ordered.length - 1)
            .map((a) => '${a.lat},${a.lng}')
            .join('|');

    final qp = <String, String>{
      'api': '1',
      'origin': origin,
      'destination': destination,
      if (waypoints.isNotEmpty) 'waypoints': waypoints,
      'travelmode': 'walking',
    };

    return Uri.https('www.google.com', '/maps/dir/', qp);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Consumer<AppState>(
      builder: (_, app, __) {
        final ordered = _selectedInOrder(app);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Day Route',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (ordered.isEmpty)
                Text(
                  'Add attractions to My Day to build a route.',
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: ordered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final a = ordered[i];
                      return ListTile(
                        title: Text(a.name),
                        subtitle: Text('${a.category} • ${a.liveWaitMinutes} min'),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: ordered.isEmpty
                      ? null
                      : () async {
                          final uri = _googleMapsRouteUri(ordered);
                          // use your existing launcher style if you want
                          // ignore: use_build_context_synchronously
                          final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open Maps')),
                            );
                          }
                        },
                  icon: const Icon(Icons.route),
                  label: Text(loc.directions),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ===============================================================
// FOOD DETAIL
// ===============================================================

class _FoodDetailScreen extends StatefulWidget {
  final FoodPlace food;
  final I18nContent i18n;
  final Future<void> Function(FoodPlace f) onDirections;

  const _FoodDetailScreen({
    required this.food,
    required this.i18n,
    required this.onDirections,
  });

  @override
  State<_FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<_FoodDetailScreen> {
  final _commentCtrl = TextEditingController();
  double _rating = 4.4;

  bool _showDescTranslated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = context.read<AppState>();
      await app.ensureLoadedForFood(widget.food.id);

      if (!mounted) return;
      setState(() {
        _rating = app.ratingForFood(widget.food.id) ?? widget.food.rating;
        _commentCtrl.text = app.commentForFood(widget.food.id) ?? '';
      });
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final f = widget.food;

    final baseDesc = f.description.isEmpty ? f.type : f.description;
    final descTranslated = widget.i18n.tFoodDesc(context, f.id, baseDesc);

    return Scaffold(
      appBar: AppBar(
        title: Text(f.name),
        actions: [
          IconButton(
            tooltip: loc.share,
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('${f.name} • Funparks'),
          ),
        ],
      ),
      body: _PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  f.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, offset: Offset(0, 3), color: Colors.black12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_showDescTranslated ? descTranslated : baseDesc),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _showDescTranslated = !_showDescTranslated),
                      child: Text(I18nContent.buttonLabel(context, _showDescTranslated)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.onDirections(f),
                    icon: const Icon(Icons.directions),
                    label: Text(loc.directions),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<AppState>(
                    builder: (_, app, __) {
                      final inPlan = app.isInMyFood(f.id);
                      return FilledButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await app.toggleMyFood(f.id);
                        },
                        icon: Icon(inPlan ? Icons.favorite : Icons.favorite_border),
                        label: Text(inPlan ? loc.removeFromMyFood : loc.addToMyFood),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              loc.menuAndPrices,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            ...f.items.map(
              (it) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.surface,
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.30)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.name,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            if (it.description.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  it.description,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        it.price.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(loc.yourRating, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _StarRow(initial: _rating, onChanged: (v) => setState(() => _rating = v)),
            const SizedBox(height: 18),
            Text(loc.yourComment, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: loc.commentHintFood,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final app = context.read<AppState>();
                  await app.setFoodRating(f.id, _rating);
                  await app.setFoodComment(f.id, _commentCtrl.text.trim());

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.saved)),
                  );
                },
                child: Text(loc.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// HOTELS TAB + HOTEL DETAIL
// ===============================================================

class _HotelsTab extends StatelessWidget {
  final List<Hotel> hotels;
  final String currency;
  final Future<void> Function(Hotel h) onDirections;

  const _HotelsTab({
    required this.hotels,
    required this.currency,
    required this.onDirections,
  });

  void _openDetails(BuildContext context, Hotel h) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _HotelDetailScreen(
          hotel: h,
          currency: currency,
          onDirections: onDirections,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (hotels.isEmpty) {
      return const Center(child: Text('Coming soon'));
    }

    final top = hotels.where((h) => h.topPick).toList();
    final rest = hotels.where((h) => !h.topPick).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      children: [
        Consumer<AppState>(
          builder: (_, app, __) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                icon: Icons.hotel,
                text: 'Add to My Stay: ${app.myStayCount}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (top.isNotEmpty) ...[
          Text(
            'Top Pick',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...top.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HotelTopCard(
                hotel: h,
                currency: currency,
                onTap: () => _openDetails(context, h),
                onDirections: () => onDirections(h),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: cs.outlineVariant.withOpacity(0.35)),
          const SizedBox(height: 12),
        ],

        ...rest.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HotelRow(
              hotel: h,
              currency: currency,
              onTap: () => _openDetails(context, h),
              onDirections: () => onDirections(h),
            ),
          ),
        ),
      ],
    );
  }
}

class _HotelTopCard extends StatelessWidget {
  final Hotel hotel;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _HotelTopCard({
    required this.hotel,
    required this.currency,
    required this.onTap,
    required this.onDirections,
  });

  String _fromPriceText() {
    if (hotel.rooms.isEmpty) return '—';
    final min = hotel.rooms
        .map((r) => r.pricePerNight)
        .reduce((a, b) => a < b ? a : b);
    return '$currency ${min.toStringAsFixed(0)}/night';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _PremiumAppear(
      child: _PressDown(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            boxShadow: const [
              BoxShadow(blurRadius: 14, offset: Offset(0, 4), color: Colors.black12),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        hotel.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.04),
                              Colors.black.withOpacity(0.16),
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _GlassPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Top Pick',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _HotelActionPill(
                          hotelId: hotel.id,
                          onDirections: onDirections,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      _SoftBadge(icon: Icons.star, text: hotel.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _SoftBadge(icon: Icons.payments, text: _fromPriceText()),
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

class _HotelRow extends StatelessWidget {
  final Hotel hotel;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _HotelRow({
    required this.hotel,
    required this.currency,
    required this.onTap,
    required this.onDirections,
  });

  String _fromPriceText() {
    if (hotel.rooms.isEmpty) return '—';
    final min = hotel.rooms
        .map((r) => r.pricePerNight)
        .reduce((a, b) => a < b ? a : b);
    return '$currency ${min.toStringAsFixed(0)}/night';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                hotel.image,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 76, height: 76, color: Colors.black12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hotel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SoftBadge(icon: Icons.star, text: hotel.rating.toStringAsFixed(1)),
                      _SoftBadge(icon: Icons.payments, text: _fromPriceText()),
                      if (hotel.topPick) const _SoftBadge(icon: Icons.star, text: 'Top Pick'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _HotelActionPill(
              hotelId: hotel.id,
              onDirections: onDirections,
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelActionPill extends StatelessWidget {
  final String hotelId;
  final VoidCallback onDirections;

  const _HotelActionPill({
    required this.hotelId,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillIconButton(
            tooltip: 'Directions',
            icon: Icons.directions,
            onTap: () async {
              HapticFeedback.selectionClick();
              onDirections();
            },
          ),
          Container(
            width: 34,
            height: 1,
            color: cs.outlineVariant.withOpacity(0.35),
          ),
          Consumer<AppState>(
            builder: (_, app, __) {
              final inMyStay = app.isInMyStay(hotelId);

              return _PillIconButton(
                tooltip: inMyStay ? 'Remove from My Stay' : 'Add to My Stay',
                icon: inMyStay ? Icons.favorite : Icons.favorite_border,
                animate: true,
                onTap: () async {
                  await app.toggleMyStay(hotelId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(inMyStay ? 'Removed from My Stay' : 'Added to My Stay'),
                        duration: const Duration(milliseconds: 850),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  final String currency;
  final Future<void> Function(Hotel h) onDirections;

  const _HotelDetailScreen({
    required this.hotel,
    required this.currency,
    required this.onDirections,
  });

  @override
  State<_HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<_HotelDetailScreen> {
  final _commentCtrl = TextEditingController();
  double _rating = 4.5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final app = context.read<AppState>();
      await app.ensureLoadedForHotel(widget.hotel.id);

      if (!mounted) return;
      setState(() {
        _rating = app.ratingForHotel(widget.hotel.id) ?? widget.hotel.rating;
        _commentCtrl.text = app.commentForHotel(widget.hotel.id) ?? '';
      });
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.hotel;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(h.name),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('${h.name} • Funparks'),
          ),
        ],
      ),
      body: _PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  h.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, offset: Offset(0, 3), color: Colors.black12),
                ],
              ),
              child: Text(h.description),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.onDirections(h),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Consumer<AppState>(
                    builder: (_, app, __) {
                      final inStay = app.isInMyStay(h.id);
                      return FilledButton.icon(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          await app.toggleMyStay(h.id);
                        },
                        icon: Icon(inStay ? Icons.favorite : Icons.favorite_border),
                        label: Text(inStay ? 'Remove from My Stay' : 'Add to My Stay'),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'Rooms & prices',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            if (h.rooms.isEmpty)
              Text('No room data yet', style: TextStyle(color: Colors.grey.shade700))
            else
              ...h.rooms.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.surface,
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.30)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text(r.description, style: TextStyle(color: Colors.grey.shade700)),
                              const SizedBox(height: 8),
                              _SoftBadge(
                                icon: r.breakfastIncluded ? Icons.free_breakfast : Icons.no_food,
                                text: r.breakfastIncluded ? 'Breakfast included' : 'No breakfast',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.currency} ${r.pricePerNight.toStringAsFixed(0)}/night',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 18),
            Text('Your rating', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _StarRow(initial: _rating, onChanged: (v) => setState(() => _rating = v)),

            const SizedBox(height: 18),
            Text('Your comment', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final app = context.read<AppState>();
                  await app.setHotelRating(h.id, _rating);
                  await app.setHotelComment(h.id, _commentCtrl.text.trim());

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')),
                  );
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// HOTELS TAB (Recommended / Lowest price / Highest rated) + My Stay
// ===============================================================

enum _HotelSort { recommended, lowestPrice, highestRated }

class _HotelsTab extends StatefulWidget {
  final List<Hotel> hotels;
  final String currency;
  final Future<void> Function(Hotel h) onDirections;
  final Future<void> Function(String url)? onWebsite;

  const _HotelsTab({
    required this.hotels,
    required this.currency,
    required this.onDirections,
    this.onWebsite,
  });

  @override
  State<_HotelsTab> createState() => _HotelsTabState();
}

class _HotelsTabState extends State<_HotelsTab> {
  _HotelSort _sort = _HotelSort.recommended;

  List<Hotel> _sorted(List<Hotel> items) {
    final list = [...items];

    if (_sort == _HotelSort.lowestPrice) {
      list.sort((a, b) {
        final ap = a.lowestNightPrice ?? double.infinity;
        final bp = b.lowestNightPrice ?? double.infinity;
        final c = ap.compareTo(bp);
        if (c != 0) return c;
        return b.rating.compareTo(a.rating);
      });
      return list;
    }

    if (_sort == _HotelSort.highestRated) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
      return list;
    }

    // recommended: topPick first, then rating desc, then lowest price asc
    list.sort((a, b) {
      final at = a.topPick ? 0 : 1;
      final bt = b.topPick ? 0 : 1;
      if (at != bt) return at.compareTo(bt);

      final r = b.rating.compareTo(a.rating);
      if (r != 0) return r;

      final ap = a.lowestNightPrice ?? double.infinity;
      final bp = b.lowestNightPrice ?? double.infinity;
      return ap.compareTo(bp);
    });

    return list;
  }

  void _openDetails(Hotel h) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _HotelDetailScreen(
          hotel: h,
          currency: widget.currency,
          onDirections: widget.onDirections,
          onWebsite: widget.onWebsite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (widget.hotels.isEmpty) {
      return Center(child: Text(loc.comingSoon));
    }

    final list = _sorted(widget.hotels);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      children: [
        Consumer<AppState>(
          builder: (_, app, __) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                icon: Icons.hotel,
                text: '${loc.addToMyStay}: ${app.myStayCount}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: DropdownButton<_HotelSort>(
            value: _sort,
            onChanged: (v) => setState(() => _sort = v ?? _sort),
            items: [
              DropdownMenuItem(
                value: _HotelSort.recommended,
                child: Text(loc.recommended),
              ),
              DropdownMenuItem(
                value: _HotelSort.lowestPrice,
                child: Text(loc.lowestPrice),
              ),
              DropdownMenuItem(
                value: _HotelSort.highestRated,
                child: Text(loc.highestRated),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        ...list.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _openDetails(h),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surface,
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 3),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        h.image,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(width: 76, height: 76, color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            h.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _SoftBadge(
                                icon: Icons.star,
                                text: h.rating.toStringAsFixed(1),
                              ),
                              if (h.lowestNightPrice != null)
                                _SoftBadge(
                                  icon: Icons.payments,
                                  text:
                                      '${widget.currency} ${h.lowestNightPrice!.toStringAsFixed(0)} / ${loc.night}',
                                ),
                              if (h.topPick)
                                _SoftBadge(icon: Icons.star, text: loc.topPick),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    _HotelActionPill(
                      hotelId: h.id,
                      addLabel: loc.addToMyStay,
                      removeLabel: loc.removeFromMyStay,
                      directionsLabel: loc.directions,
                      onDirections: () => widget.onDirections(h),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),
        Container(height: 1, color: cs.outlineVariant.withOpacity(0.35)),
        const SizedBox(height: 12),
        Text(
          loc.tapCardForDetails,
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _HotelActionPill extends StatelessWidget {
  final String hotelId;
  final String addLabel;
  final String removeLabel;
  final String directionsLabel;
  final VoidCallback onDirections;

  const _HotelActionPill({
    required this.hotelId,
    required this.addLabel,
    required this.removeLabel,
    required this.directionsLabel,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillIconButton(
            tooltip: directionsLabel,
            icon: Icons.directions,
            onTap: () async {
              HapticFeedback.selectionClick();
              onDirections();
            },
          ),
          Container(
            width: 34,
            height: 1,
            color: cs.outlineVariant.withOpacity(0.35),
          ),
          Consumer<AppState>(
            builder: (_, app, __) {
              final inMyStay = app.isInMyStay(hotelId);
              return _PillIconButton(
                tooltip: inMyStay ? removeLabel : addLabel,
                icon: inMyStay ? Icons.favorite : Icons.favorite_border,
                animate: true,
                onTap: () async {
                  await app.toggleMyStay(hotelId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(inMyStay ? removeLabel : addLabel),
                        duration: const Duration(milliseconds: 850),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// HOTEL DETAIL SCREEN
// ===============================================================

class _HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;
  final String currency;
  final Future<void> Function(Hotel h) onDirections;
  final Future<void> Function(String url)? onWebsite;

  const _HotelDetailScreen({
    required this.hotel,
    required this.currency,
    required this.onDirections,
    this.onWebsite,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
        actions: [
          IconButton(
            tooltip: loc.share,
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('${hotel.name} • Funparks'),
          ),
        ],
      ),
      body: _PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  hotel.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surface,
                border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, 3),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.description),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Pill(icon: Icons.star, text: hotel.rating.toStringAsFixed(1)),
                      if (hotel.lowestNightPrice != null)
                        _Pill(
                          icon: Icons.payments,
                          text:
                              '$currency ${hotel.lowestNightPrice!.toStringAsFixed(0)} / ${loc.night}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => onDirections(hotel),
                          icon: const Icon(Icons.directions),
                          label: Text(loc.directions),
                        ),
                      ),
                      if (hotel.website != null &&
                          hotel.website!.trim().isNotEmpty &&
                          onWebsite != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => onWebsite!(hotel.website!.trim()),
                            icon: const Icon(Icons.public),
                            label: Text(loc.website),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Text(
              loc.rooms,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            ...hotel.rooms.map((r) {
              final bf = r.breakfastIncluded
                  ? loc.breakfastIncluded
                  : loc.breakfastNotIncluded;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: cs.surface,
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.30)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                            if (r.description.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  r.description,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              bf,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$currency ${r.pricePerNight.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// HOTELS TAB + HOTEL DETAIL (i18n + sorting + Add to My Stay)
// ===============================================================

enum _HotelSort { recommended, lowestPrice, highestRated }

class _HotelsTab extends StatefulWidget {
  final List<Hotel> hotels;
  final I18nContent i18n;
  final Future<void> Function(Hotel h) onDirections;

  const _HotelsTab({
    required this.hotels,
    required this.i18n,
    required this.onDirections,
  });

  @override
  State<_HotelsTab> createState() => _HotelsTabState();
}

class _HotelsTabState extends State<_HotelsTab> {
  _HotelSort _sort = _HotelSort.recommended;

  void _openDetails(BuildContext context, Hotel h) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _HotelDetailScreen(
          hotel: h,
          i18n: widget.i18n,
          onDirections: widget.onDirections,
        ),
      ),
    );
  }

  double? _startingPrice(Hotel h) => h.lowestNightPrice;

  List<Hotel> _sorted(List<Hotel> items) {
    final list = [...items];

    if (_sort == _HotelSort.lowestPrice) {
      list.sort((a, b) {
        final ap = a.lowestNightPrice;
        final bp = b.lowestNightPrice;
        if (ap == null && bp == null) return 0;
        if (ap == null) return 1;
        if (bp == null) return -1;
        return ap.compareTo(bp);
      });
      return list;
    }

    if (_sort == _HotelSort.highestRated) {
      list.sort((a, b) => b.rating.compareTo(a.rating));
      return list;
    }

    // recommended: TopPick first, then rating desc, then lowest price asc (null last)
    list.sort((a, b) {
      final at = a.topPick ? 0 : 1;
      final bt = b.topPick ? 0 : 1;
      if (at != bt) return at.compareTo(bt);

      final r = b.rating.compareTo(a.rating);
      if (r != 0) return r;

      final ap = a.lowestNightPrice;
      final bp = b.lowestNightPrice;
      if (ap == null && bp == null) return 0;
      if (ap == null) return 1;
      if (bp == null) return -1;
      return ap.compareTo(bp);
    });

    return list;
  }

  String _priceBadge(AppLocalizations loc, double? price) {
    if (price == null) return loc.price;
    return '€ ${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (widget.hotels.isEmpty) {
      return Center(child: Text(loc.comingSoon));
    }

    final list = _sorted(widget.hotels);
    final top = list.where((h) => h.topPick).toList();
    final rest = list.where((h) => !h.topPick).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      children: [
        // My Stay count + Sort
        Consumer<AppState>(
          builder: (_, app, __) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniPill(
                icon: Icons.favorite,
                text: '${loc.addToMyStay}: ${app.myStayCount}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: DropdownButton<_HotelSort>(
            value: _sort,
            onChanged: (v) => setState(() => _sort = v ?? _sort),
            items: [
              DropdownMenuItem(
                value: _HotelSort.recommended,
                child: Text(loc.recommended),
              ),
              DropdownMenuItem(
                value: _HotelSort.lowestPrice,
                child: Text(loc.lowestPrice),
              ),
              DropdownMenuItem(
                value: _HotelSort.highestRated,
                child: Text(loc.highestRated),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (top.isNotEmpty) ...[
          Text(
            loc.topPick,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...top.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HotelTopCard(
                hotel: h,
                i18n: widget.i18n,
                startPrice: _startingPrice(h),
                priceBadgeText: _priceBadge(loc, _startingPrice(h)),
                onTap: () => _openDetails(context, h),
                onDirections: () => widget.onDirections(h),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: cs.outlineVariant.withOpacity(0.35)),
          const SizedBox(height: 12),
        ],

        ...rest.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HotelRow(
              hotel: h,
              i18n: widget.i18n,
              startPrice: _startingPrice(h),
              priceBadgeText: _priceBadge(loc, _startingPrice(h)),
              onTap: () => _openDetails(context, h),
              onDirections: () => widget.onDirections(h),
            ),
          ),
        ),
      ],
    );
  }
}

class _HotelTopCard extends StatelessWidget {
  final Hotel hotel;
  final I18nContent i18n;
  final double? startPrice;
  final String priceBadgeText;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _HotelTopCard({
    required this.hotel,
    required this.i18n,
    required this.startPrice,
    required this.priceBadgeText,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final translatedDesc = i18n.tHotelDesc(context, hotel.id, hotel.description);
    final cs = Theme.of(context).colorScheme;

    return _PremiumAppear(
      child: _PressDown(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            boxShadow: const [
              BoxShadow(blurRadius: 14, offset: Offset(0, 4), color: Colors.black12),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        hotel.image,
                        fit: BoxFit.cover,
                        cacheWidth: 1200,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.18),
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: _GlassPill(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                loc.topPick,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _HotelActionPill(
                          hotelId: hotel.id,
                          addLabel: loc.addToMyStay,
                          removeLabel: loc.removeFromMyStay,
                          directionsLabel: loc.directions,
                          websiteLabel: loc.website,
                          websiteUrl: hotel.website,
                          onDirections: onDirections,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hotel.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          _SoftBadge(icon: Icons.star, text: hotel.rating.toStringAsFixed(1)),
                          const SizedBox(width: 8),
                          _SoftBadge(icon: Icons.euro, text: priceBadgeText),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translatedDesc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
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

class _HotelRow extends StatelessWidget {
  final Hotel hotel;
  final I18nContent i18n;
  final double? startPrice;
  final String priceBadgeText;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  const _HotelRow({
    required this.hotel,
    required this.i18n,
    required this.startPrice,
    required this.priceBadgeText,
    required this.onTap,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final translatedDesc = i18n.tHotelDesc(context, hotel.id, hotel.description);

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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                hotel.image,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                cacheWidth: 240,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) =>
                    Container(width: 76, height: 76, color: Colors.black12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
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
                      _SoftBadge(icon: Icons.star, text: hotel.rating.toStringAsFixed(1)),
                      _SoftBadge(icon: Icons.euro, text: priceBadgeText),
                      if (hotel.rooms.isNotEmpty)
                        _SoftBadge(icon: Icons.hotel, text: '${hotel.rooms.length} ${loc.rooms}'),
                      if (hotel.topPick) _SoftBadge(icon: Icons.star, text: loc.topPick),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _HotelActionPill(
              hotelId: hotel.id,
              addLabel: loc.addToMyStay,
              removeLabel: loc.removeFromMyStay,
              directionsLabel: loc.directions,
              websiteLabel: loc.website,
              websiteUrl: hotel.website,
              onDirections: onDirections,
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelActionPill extends StatelessWidget {
  final String hotelId;

  final String addLabel;
  final String removeLabel;

  final String directionsLabel;

  final String websiteLabel;
  final String? websiteUrl;

  final VoidCallback onDirections;

  const _HotelActionPill({
    required this.hotelId,
    required this.addLabel,
    required this.removeLabel,
    required this.directionsLabel,
    required this.websiteLabel,
    required this.websiteUrl,
    required this.onDirections,
  });

  Future<void> _openWebsite(BuildContext context) async {
    final url = (websiteUrl ?? '').trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(websiteLabel)),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid website URL')),
      );
      return;
    }

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surfaceContainerHighest,
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillIconButton(
            tooltip: directionsLabel,
            icon: Icons.directions,
            onTap: () async {
              HapticFeedback.selectionClick();
              onDirections();
            },
          ),
          Container(width: 34, height: 1, color: cs.outlineVariant.withOpacity(0.35)),
          _PillIconButton(
            tooltip: websiteLabel,
            icon: Icons.public,
            onTap: () async {
              HapticFeedback.selectionClick();
              await _openWebsite(context);
            },
          ),
          Container(width: 34, height: 1, color: cs.outlineVariant.withOpacity(0.35)),
          Consumer<AppState>(
            builder: (_, app, __) {
              final inStay = app.isInMyStay(hotelId);
              return _PillIconButton(
                tooltip: inStay ? removeLabel : addLabel,
                icon: inStay ? Icons.favorite : Icons.favorite_border,
                animate: true,
                onTap: () async {
                  await app.toggleMyStay(hotelId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(inStay ? removeLabel : addLabel),
                        duration: const Duration(milliseconds: 850),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// HOTEL DETAIL SCREEN (i18n + My Stay + room-level i18n)
// ===============================================================

class _HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;
  final I18nContent i18n;
  final Future<void> Function(Hotel h) onDirections;

  const _HotelDetailScreen({
    required this.hotel,
    required this.i18n,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final translatedDesc = i18n.tHotelDesc(context, hotel.id, hotel.description);
    final start = hotel.lowestNightPrice;

    final facts = <String>[
      '${loc.rating}: ${hotel.rating.toStringAsFixed(1)}',
      if (start != null) '${loc.fromPrice}: € ${start.toStringAsFixed(0)}',
      if (hotel.rooms.isNotEmpty) '${loc.rooms}: ${hotel.rooms.length}',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(hotel.name),
        actions: [
          IconButton(
            tooltip: loc.share,
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('${hotel.name} • Funparks'),
          ),
          Consumer<AppState>(
            builder: (_, app, __) {
              final inStay = app.isInMyStay(hotel.id);
              return IconButton(
                tooltip: inStay ? loc.removeFromMyStay : loc.addToMyStay,
                icon: Icon(inStay ? Icons.favorite : Icons.favorite_border),
                onPressed: () async => app.toggleMyStay(hotel.id),
              );
            },
          ),
          if ((hotel.website ?? '').trim().isNotEmpty)
            IconButton(
              tooltip: loc.website,
              icon: const Icon(Icons.public),
              onPressed: () async {
                final uri = Uri.tryParse(hotel.website!.trim());
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
      body: _PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  hotel.image,
                  fit: BoxFit.cover,
                  cacheWidth: 1400,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Container(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _GlassCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translatedDesc, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: facts.map((t) => _Chip(text: t)).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => onDirections(hotel),
                        icon: const Icon(Icons.directions),
                        label: Text(loc.directions),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              loc.rooms,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),

            if (hotel.rooms.isEmpty)
              Text(loc.comingSoon, style: TextStyle(color: Colors.grey.shade700))
            else
              ...hotel.rooms.map((r) {
                // ✅ Room-level i18n
                final roomName = i18n.tHotelRoomName(context, hotel.id, r.key, r.name);
                final roomDesc = i18n.tHotelRoomDesc(context, hotel.id, r.key, r.description);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: cs.surface,
                      border: Border.all(color: cs.outlineVariant.withOpacity(0.30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(roomName, style: const TextStyle(fontWeight: FontWeight.w900)),
                        if (roomDesc.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(roomDesc, style: TextStyle(color: Colors.grey.shade700)),
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _SoftBadge(
                              icon: Icons.euro,
                              text: '€ ${r.pricePerNight.toStringAsFixed(0)} / ${loc.night}',
                            ),
                            _SoftBadge(
                              icon: r.breakfastIncluded
                                  ? Icons.free_breakfast
                                  : Icons.no_food,
                              text: r.breakfastIncluded
                                  ? loc.breakfastIncluded
                                  : loc.breakfastNotIncluded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
