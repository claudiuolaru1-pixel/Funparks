import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/park.dart';

class ParkRepository {
  static const String _assetPath = 'assets/data/parks.json';

  static List<Park>? _cache;

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
          .toList();

      _cache = parks;

      debugPrint('ParkRepository: loaded ${parks.length} parks from $_assetPath');
      for (final p in parks) {
        debugPrint('ParkRepository: ${p.id} ${p.name} lat=${p.lat} lng=${p.lng}');
      }

      return parks;
    } catch (e) {
      debugPrint('ParkRepository ERROR loading $_assetPath: $e');
      rethrow;
    }
  }

  static Future<Park?> loadById(String parkId) async {
    final parks = await loadLocal();
    try {
      return parks.firstWhere((p) => p.id == parkId);
    } catch (_) {
      return null;
    }
  }

  static void clearCache() {
    _cache = null;
  }
}
