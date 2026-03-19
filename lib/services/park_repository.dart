import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/park.dart';

class ParkRepository {
  static const String _assetPath = 'assets/data/parks.json';

  /// In-memory cache
  static List<Park>? _cache;

  /// Fast lookup cache (id → park)
  static final Map<String, Park> _byId = {};

  /// Load parks from local assets
  static Future<List<Park>> loadLocal({bool forceReload = false}) async {
    if (!forceReload && _cache != null) return _cache!;

    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = json.decode(raw);

      if (decoded is! List) {
        debugPrint('ParkRepository: $_assetPath is not a JSON list.');
        _cache = <Park>[];
        return _cache!;
      }

      final parks = decoded
          .whereType<Map>()
          .map((e) => Park.fromJson(Map<String, dynamic>.from(e)))
          .where((p) => p.id.isNotEmpty)
          .toList();

      _cache = parks;

      // build lookup map
      _byId
        ..clear()
        ..addEntries(parks.map((p) => MapEntry(p.id, p)));

      if (kDebugMode) {
        debugPrint('ParkRepository: loaded ${parks.length} parks');
        for (final p in parks) {
          debugPrint('• ${p.id} → ${p.name}');
        }
      }

      return parks;
    } catch (e) {
      debugPrint('ParkRepository ERROR loading $_assetPath: $e');
      _cache = <Park>[];
      return _cache!;
    }
  }

  /// Get park by ID (fast lookup)
  static Future<Park?> loadById(String parkId) async {
    if (_byId.containsKey(parkId)) return _byId[parkId];

    final parks = await loadLocal();
    for (final p in parks) {
      if (p.id == parkId) return p;
    }
    return null;
  }

  /// Clear cache (useful when refreshing data)
  static void clearCache() {
    _cache = null;
    _byId.clear();
  }
}