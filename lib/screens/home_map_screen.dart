// lib/screens/home_map_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/park.dart';
import '../services/park_repository.dart';
import 'park_detail_screen.dart';
import 'settings_screen.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  bool _loading = true;
  String? _error;

  List<Park> _parks = const [];
  Set<Marker> _markers = const {};

  static const CameraPosition _fallback = CameraPosition(
    target: LatLng(48.8566, 2.3522), // Paris
    zoom: 5.5,
  );

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

      if (!mounted) return;

      final markers = parks
          .where((p) => p.lat != 0.0 && p.lng != 0.0)
          .map(
            (p) => Marker(
              markerId: MarkerId(p.id),
              position: LatLng(p.lat, p.lng),
              infoWindow: InfoWindow(
                title: p.name,
                snippet: (p.city ?? '').trim().isNotEmpty
                    ? '${p.city}, ${p.country}'
                    : p.country,
                onTap: () => _openPark(p),
              ),
              onTap: () => _openParkSheet(p),
            ),
          )
          .toSet();

      setState(() {
        _parks = parks;
        _markers = markers;
        _loading = false;
      });

      final target = _pickInitialPark(parks);
      if (target != null) {
        final c = await _controller.future;
        await c.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(target.lat, target.lng),
              zoom: 11.0,
            ),
          ),
        );
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

  Park? _pickInitialPark(List<Park> parks) {
    if (parks.isEmpty) return null;

    for (final p in parks) {
      if (p.id.toLowerCase().contains('portaventura')) return p;
      if (p.name.toLowerCase().contains('portaventura')) return p;
    }

    return parks.firstWhere(
      (p) => p.lat != 0.0 && p.lng != 0.0,
      orElse: () => parks.first,
    );
  }

  void _openPark(Park park) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ParkDetailScreen(park: park)),
    );
  }

  Future<void> _openMapsDirections(Park park) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${park.lat},${park.lng}',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Maps')),
      );
    }
  }

  void _openParkSheet(Park park) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        final loc = AppLocalizations.of(context)!;
        final app = context.watch<AppState>();

        final locationLine = (park.city ?? '').trim().isNotEmpty
            ? '${park.city}, ${park.country}'
            : park.country;

        // Prefer app currency if you want global currency override:
        final currency = app.currency; // (instead of park.currency)

        final adult = park.entryPrices['adult'];
        final fromPrice = adult != null ? '$currency ${adult.toString()}' : '—';

        final hasHours = (park.openingHours ?? '').trim().isNotEmpty;
        final hasImage = (park.image ?? '').trim().isNotEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Image.asset(
                        park.image!.trim(),
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        cacheWidth: 160,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(Icons.park),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(Icons.park),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          park.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          locationLine,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniChip(icon: Icons.category, text: park.type),
                  _MiniChip(icon: Icons.payments, text: '${loc.entryFrom} $fromPrice'),
                  if (hasHours)
                    _MiniChip(
                      icon: Icons.schedule,
                      text: park.openingHours!.trim(),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: Text(loc.directions),
                      onPressed: () async {
                        Navigator.pop(context);
                        await _openMapsDirections(park);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.info_outline),
                      label: Text(loc.viewPark), // or "Open park" if you add it to arb
                      onPressed: () {
                        Navigator.pop(context);
                        _openPark(park);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: const Text('Center'),
                  onPressed: () async {
                    final c = await _controller.future;
                    await c.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(park.lat, park.lng),
                          zoom: 14.5,
                        ),
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _fallback,
              markers: _markers,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (c) {
                if (!_controller.isCompleted) _controller.complete(c);
              },
            ),

            // ✅ Top bar (Settings)
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: Row(
                children: [
                  Expanded(
                    child: _TopStatusPill(
                      text: _loading
                          ? 'Loading parks…'
                          : _error != null
                              ? 'Error loading parks. Check assets/data/parks.json and pubspec.yaml.'
                              : 'Funparks',
                      isError: _error != null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.black.withOpacity(0.68),
                    child: IconButton(
                      tooltip: loc.settings,
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            if (!_loading && _parks.isNotEmpty)
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton(
                  heroTag: 'center_first_park',
                  onPressed: () async {
                    final p = _pickInitialPark(_parks);
                    if (p == null) return;
                    final c = await _controller.future;
                    await c.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(p.lat, p.lng),
                          zoom: 11.0,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.public),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopStatusPill extends StatelessWidget {
  final String text;
  final bool isError;
  const _TopStatusPill({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      color: isError ? Colors.red.withOpacity(0.92) : Colors.black.withOpacity(0.68),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.public,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniChip({required this.icon, required this.text});

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
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}
