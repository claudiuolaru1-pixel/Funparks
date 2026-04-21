import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/parks_repository.dart';
import '../models/park.dart';
import '../l10n/app_localizations.dart';
import '../models/park_summary.dart';
import '../widgets/park_image.dart';
import '../widgets/shimmer_park_list.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  static const CameraPosition _initial = CameraPosition(
    target: LatLng(48.8566, 2.3522),
    zoom: 4.5,
  );

  final _repo = ParksRepository();
  final _searchCtrl = TextEditingController();

  GoogleMapController? _controller;
  final Set<Marker> _allMarkers = {};

  bool _loading = true;
  String? _error;

  List<ParkSummary> _allParks = const [];
  List<ParkSummary> _filtered = const [];

  String _searchQuery = '';
  String? _selectedCountry;
  String? _selectedType;

  List<String> get _countries {
    final set = <String>{};
    for (final p in _allParks) {
      if (p.country.trim().isNotEmpty) set.add(p.country.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> get _types {
    final set = <String>{};
    for (final p in _allParks) {
      final t = p.type.name.trim();
      if (t.isNotEmpty) set.add(t);
    }
    final list = set.toList()..sort();
    return list;
  }

  @override
  void initState() {
    super.initState();
    _loadParksAndMarkers();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
        _applyFilters();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    _filtered = _allParks.where((p) {
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery) ||
          p.country.toLowerCase().contains(_searchQuery) ||
          (p.city ?? '').toLowerCase().contains(_searchQuery);
      final matchCountry =
          _selectedCountry == null || p.country.trim() == _selectedCountry;
      final matchType =
          _selectedType == null || p.type.name.trim() == _selectedType;
      return matchSearch && matchCountry && matchType;
    }).toList();
    _updateMarkers();
  }

  void _updateMarkers() {
    final filteredIds = _filtered.map((p) => p.id).toSet();
    final visibleMarkers = _allMarkers
        .where((m) => filteredIds.contains(m.markerId.value))
        .toSet();
    // We rebuild markers set so the map updates
    _markers
      ..clear()
      ..addAll(visibleMarkers);
  }

  final Set<Marker> _markers = {};

  Future<void> _loadParksAndMarkers() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final parks = await _repo.loadParkIndex(
        assetPath: 'assets/data/parks/parks_index.json',
      );

      final markers = <Marker>{};

      for (final park in parks) {
        markers.add(
          Marker(
            markerId: MarkerId(park.id),
            position: LatLng(park.lat, park.lng),
            infoWindow: InfoWindow(title: park.name),
            onTap: () {
              if (!mounted) return;
              _playPlop();
              _openPark(park);
            },
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _allParks = parks;
        _filtered = parks;
        _allMarkers
          ..clear()
          ..addAll(markers);
        _markers
          ..clear()
          ..addAll(markers);
        _loading = false;
      });

      if (markers.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        _fitAllMarkers();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _playPlop() async {
    try {
      final p = AudioPlayer();
      await p.play(AssetSource('sounds/water_drop.mp3'));
    } catch (_) {}
  }

  void _openPark(ParkSummary park) {
    Navigator.of(context).pushNamed('/park', arguments: Park(
      id: park.id,
      name: park.name,
      city: park.city,
      country: park.country,
      type: park.type.name,
      openingHours: park.openingHours,
      entryPrices: {'adult': park.entryPrices.adult, 'child': park.entryPrices.child},
      currency: park.currency,
      lat: park.lat,
      lng: park.lng,
      thumbnail: park.thumbnail,
      website: park.website,
      ticketsUrl: park.ticketsUrl,
    ));
  }

  Future<void> _fitAllMarkers() async {
    final c = _controller;
    if (c == null || _markers.isEmpty) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final m in _markers) {
      final lat = m.position.latitude;
      final lng = m.position.longitude;
      minLat = (minLat == null) ? lat : (lat < minLat ? lat : minLat);
      maxLat = (maxLat == null) ? lat : (lat > maxLat ? lat : maxLat);
      minLng = (minLng == null) ? lng : (lng < minLng ? lng : minLng);
      maxLng = (maxLng == null) ? lng : (lng > maxLng ? lng : maxLng);
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    } catch (_) {}
  }

  Future<void> _fitFilteredMarkers() async {
    final c = _controller;
    if (c == null || _markers.isEmpty) return;

    double? minLat, maxLat, minLng, maxLng;
    for (final m in _markers) {
      final lat = m.position.latitude;
      final lng = m.position.longitude;
      minLat = (minLat == null) ? lat : (lat < minLat ? lat : minLat);
      maxLat = (maxLat == null) ? lat : (lat > maxLat ? lat : maxLat);
      minLng = (minLng == null) ? lng : (lng < minLng ? lng : minLng);
      maxLng = (maxLng == null) ? lng : (lng > maxLng ? lng : maxLng);
    }

    if (minLat == null) return;

    if (minLat == maxLat && minLng == maxLng) {
      await c.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(minLat!, minLng!), 12));
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );

    try {
      await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
    } catch (_) {}
  }

  void _clearFilters() {
    _searchCtrl.clear();
    setState(() {
      _searchQuery = '';
      _selectedCountry = null;
      _selectedType = null;
      _filtered = _allParks;
      _markers
        ..clear()
        ..addAll(_allMarkers);
    });
    _fitAllMarkers();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCountry != null ||
      _selectedType != null;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Clear filters',
            ),
          IconButton(
            onPressed: _loadParksAndMarkers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search + filter bar ──
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search parks…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                // Filter chips row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Country filter
                      PopupMenuButton<String?>(
                        tooltip: 'Filter by country',
                        onSelected: (v) {
                          setState(() {
                            _selectedCountry = v;
                            _applyFilters();
                          });
                          _fitFilteredMarkers();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: null, child: Text('All countries')),
                          ..._countries.map((c) =>
                              PopupMenuItem(value: c, child: Text(c))),
                        ],
                        child: _FilterChip(
                          label: _selectedCountry ?? 'Country',
                          active: _selectedCountry != null,
                          icon: Icons.public,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Type filter
                      PopupMenuButton<String?>(
                        tooltip: 'Filter by type',
                        onSelected: (v) {
                          setState(() {
                            _selectedType = v;
                            _applyFilters();
                          });
                          _fitFilteredMarkers();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: null, child: Text('All types')),
                          ..._types.map((t) =>
                              PopupMenuItem(value: t, child: Text(t))),
                        ],
                        child: _FilterChip(
                          label: _selectedType ?? 'Type',
                          active: _selectedType != null,
                          icon: Icons.category,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Results count
                      if (!_loading)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: cs.surfaceContainerHighest,
                          ),
                          child: Text(
                            '${_filtered.length} park${_filtered.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Map ──
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initial,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (c) {
                    _controller = c;
                    if (_markers.isNotEmpty) _fitAllMarkers();
                  },
                ),
                if (_loading)
                  const Center(child: CircularProgressIndicator()),
                if (_error != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Material(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Error: $_error',
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Parks list ──
          if (_loading)
            Expanded(flex: 2, child: const ShimmerParkList()),
          if (!_loading && _filtered.isNotEmpty)
            Expanded(
              flex: 2,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (_, i) {
                  final p = _filtered[i];
                  return ListTile(
                    leading: Hero(
                      tag: 'park_hero_${p.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (p.thumbnail ?? '').isNotEmpty
                            ? ParkImage(image: p.thumbnail!, width: 56, height: 56, fit: BoxFit.cover)
                            : Container(
                                width: 56, height: 56,
                                color: cs.primaryContainer,
                                child: Center(child: Text(
                                  p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                                  style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w900),
                                )),
                              ),
                      ),
                    ),
                    title: Text(p.name,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                        [p.city, p.country]
                            .where((s) => (s ?? '').isNotEmpty)
                            .join(', '),
                        style: TextStyle(color: Colors.grey.shade600)),
                    trailing: Text(p.type.name,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.primary,
                            fontWeight: FontWeight.w700)),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _playPlop();
                      _controller?.animateCamera(
                          CameraUpdate.newLatLngZoom(
                              LatLng(p.lat, p.lng), 12));
                      _openPark(p);
                        },
                      );
                    },
                  ),
                ),
          if (!_loading && _filtered.isEmpty && _hasActiveFilters)
            const Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 42, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No parks match your filters',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active ? cs.primary : cs.surfaceContainerHighest,
        border: active
            ? null
            : Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: active ? cs.onPrimary : cs.onSurface),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? cs.onPrimary : cs.onSurface)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down,
              size: 16, color: active ? cs.onPrimary : cs.onSurface),
        ],
      ),
    );
  }
}