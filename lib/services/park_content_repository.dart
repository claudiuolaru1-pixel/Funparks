import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/attraction.dart';
import '../models/food_place.dart';

class ParkContentRepository {
  static String _base(String parkId) => 'assets/data/parks/$parkId';

  // Cache per park
  static final Map<String, List<Attraction>> _attractionsCache = {};
  static final Map<String, List<FoodPlace>> _foodCache = {};
  static final Map<String, Map<String, dynamic>> _overviewCache = {};

  static Future<List<Attraction>> loadAttractions(String parkId,
      {bool forceReload = false}) async {
    if (!forceReload && _attractionsCache.containsKey(parkId)) {
      return _attractionsCache[parkId]!;
    }

    final path = '${_base(parkId)}/attractions.json';
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = json.decode(raw);

      if (decoded is! List) {
        debugPrint('ParkContentRepository: $path is not a JSON list.');
        _attractionsCache[parkId] = <Attraction>[];
        return _attractionsCache[parkId]!;
      }

      final items = decoded
          .whereType<Map>()
          .map((e) => Attraction.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      _attractionsCache[parkId] = items;
      debugPrint('ParkContentRepository: loaded ${items.length} attractions for $parkId');
      return items;
    } catch (e) {
      debugPrint('ParkContentRepository ERROR loading $path: $e');
      rethrow;
    }
  }

  static Future<List<FoodPlace>> loadFood(
    String parkId, {
    bool forceReload = false,
    double parkLat = 0,
    double parkLng = 0,
  }) async {
    if (!forceReload && _foodCache.containsKey(parkId)) {
      return _foodCache[parkId]!;
    }

    final path = '${_base(parkId)}/food.json';
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = json.decode(raw);

      if (decoded is! List) {
        debugPrint('ParkContentRepository: $path is not a JSON list.');
        _foodCache[parkId] = <FoodPlace>[];
        return _foodCache[parkId]!;
      }

      final items = decoded.whereType<Map>().map((e) {
        return FoodPlace.fromJson(
          Map<String, dynamic>.from(e),
          parkLat: parkLat,
          parkLng: parkLng,
        );
      }).toList();

      _foodCache[parkId] = items;
      debugPrint('ParkContentRepository: loaded ${items.length} food places for $parkId');
      return items;
    } catch (e) {
      debugPrint('ParkContentRepository ERROR loading $path: $e');
      rethrow;
    }
  }

  /// overview.json format is a JSON object (map), not a list.
  static Future<Map<String, dynamic>> loadOverview(
    String parkId, {
    bool forceReload = false,
  }) async {
    if (!forceReload && _overviewCache.containsKey(parkId)) {
      return _overviewCache[parkId]!;
    }

    final path = '${_base(parkId)}/overview.json';
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = json.decode(raw);

      if (decoded is! Map) {
        debugPrint('ParkContentRepository: $path is not a JSON object.');
        _overviewCache[parkId] = <String, dynamic>{};
        return _overviewCache[parkId]!;
      }

      final m = Map<String, dynamic>.from(decoded);
      _overviewCache[parkId] = m;
      debugPrint('ParkContentRepository: loaded overview for $parkId');
      return m;
    } catch (e) {
      debugPrint('ParkContentRepository ERROR loading $path: $e');
      rethrow;
    }
  }

  static void clearCache({String? parkId}) {
    if (parkId == null) {
      _attractionsCache.clear();
      _foodCache.clear();
      _overviewCache.clear();
      return;
    }
    _attractionsCache.remove(parkId);
    _foodCache.remove(parkId);
    _overviewCache.remove(parkId);
  }
}
