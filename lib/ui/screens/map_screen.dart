import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../models/park.dart';
import '../../screens/park_detail_screen.dart';
import '../../screens/settings_screen.dart';
import '../../services/park_repository.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  bool _loading = true;
  String? _error;

  List<Park> _parks = const [];
  Set<Marker> _markers = const {};

  static const CameraPosition _fallbackStart =
      CameraPosition(target: LatLng(50.0, 8.0), zoom: 4.5);

  @override
  void initState() {
    super.initState();
    _loadParks();
  }

  Future<void> _loadParks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final parks = await ParkRepository.loadLocal();

      final markers = parks.map((p) {
        final subtitle = (p.city == null || p.city!.trim().isEmpty)
            ? p.country
            : '${p.city}, ${p.country}';

        return Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.lat, p.lng),
          infoWindow: InfoWindow(
            title: p.name,
            snippet: subtitle,
          ),
          onTap: () => _showParkSheet(p),
        );
      }).toSet();

      if (!mounted) return;
      setState(() {
        _parks = parks;
        _markers = markers;
        _loading = false;
      });

      if (parks.isNotEmpty) {
        await _zoomToParks(parks);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _parks = const [];
        _markers = const {};
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _zoomToParks(List<Park> parks) async {
    final c = _controller;
    if (c == null) return;

    if (parks.length == 1) {
      final p = parks.first;
      await c.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(p.lat, p.lng), zoom: 12),
        ),
      );
      return;
    }

    double minLat = parks.first.lat, maxLat = parks.first.lat;
    double minLng = parks.first.lng, maxLng = parks.first.lng;

    for (final p in parks) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  ImageProvider _parkImage(Park p) {
    final t = p.thumbnail?.trim();
    if (t == null || t.isEmpty) {
      return const AssetImage('assets/images/start_bg.png');
    }
    if (t.startsWith('http://') || t.startsWith('https://')) {
      return NetworkImage(t);
    }
    return AssetImage(t);
  }

  void _showParkSheet(Park p) {
    final loc = AppLocalizations.of(context)!;

    final subtitle = (p.city == null || p.city!.trim().isEmpty)
        ? p.country
        : '${p.city}, ${p.country}';

    final adult = (p.entryPrices['adult'] ?? 0).toString();
    final child = (p.entryPrices['child'] ?? 0).toString();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 26, backgroundImage: _parkImage(p)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${loc.hours}: ${p.openingHours ?? '—'}'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${loc.entryFrom}: ${p.currency} '
                      '${loc.adult} $adult • ${loc.child} $child',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ParkDetailScreen(park: p)),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(loc.viewPark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle), // ✅ NOT const (updates with language)
        actions: [
          IconButton(
            tooltip: loc.settings,
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Reload parks',
            onPressed: _loadParks,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Zoom to parks',
            onPressed: _parks.isEmpty ? null : () => _zoomToParks(_parks),
            icon: const Icon(Icons.center_focus_strong),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _fallbackStart,
            markers: _markers,
            myLocationButtonEnabled: false,
            onMapCreated: (c) => _controller = c,
          ),

          // Debug overlay
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    if (_loading) ...[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        _error != null
                            ? 'ERROR loading parks: $_error'
                            : 'Parks loaded: ${_parks.length} • Markers: ${_markers.length}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _error != null ? Colors.red : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
