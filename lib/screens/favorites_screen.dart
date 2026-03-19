// lib/screens/favorites_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/park.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Park>> _parksFuture;

  @override
  void initState() {
    super.initState();
    _parksFuture = _loadParks();
  }

  Future<List<Park>> _loadParks() async {
    final raw = await rootBundle.loadString('assets/data/parks.json');
    final decoded = jsonDecode(raw);

    final List<dynamic> list = decoded is List
        ? decoded
        : (decoded is Map && decoded['parks'] is List)
            ? decoded['parks'] as List
            : <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => Park.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final favorites = context.watch<AppState>().favoriteParkIds;

    String safe(String Function() getter, String fallback) {
      try {
        return getter();
      } catch (_) {
        return fallback;
      }
    }

    final title = safe(() => loc.favoritesTitle, 'Favorites');
    final emptyText = safe(() => loc.noFavoritesYet, 'No favorites yet');
    final removeText =
        safe(() => loc.removeFromFavorites, 'Remove from favorites');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Park>>(
        future: _parksFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Error: ${snap.error}'),
              ),
            );
          }

          final parks = snap.data ?? <Park>[];
          final favParks = parks.where((p) => favorites.contains(p.id)).toList();

          if (favParks.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(emptyText),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(12),
            itemCount: favParks.length,
            separatorBuilder: (_, __) => SizedBox(height: 10),
            itemBuilder: (context, i) {
              final park = favParks[i];

              return Material(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/park', arguments: park),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.park, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                park.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 4),
                              Text(
                                park.id,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: removeText,
                          onPressed: () => context
                              .read<AppState>()
                              .toggleParkFavorite(park.id),
                          icon: Icon(Icons.favorite),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
