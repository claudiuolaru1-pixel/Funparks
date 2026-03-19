import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/attraction.dart';
import '../models/food_place.dart';
import '../models/hotel.dart';

class ParkAssetsRepository {
  const ParkAssetsRepository();

  static String _base(String parkId) => 'assets/data/parks/$parkId';

  Future<List<Attraction>> loadAttractions({
    required String parkId,
    required double parkLat,
    required double parkLng,
  }) {
    return _loadList(
      '${_base(parkId)}/attractions.json',
      (json) => Attraction.fromJson(
        json,
        parkLat: parkLat,
        parkLng: parkLng,
      ),
    );
  }

  Future<List<FoodPlace>> loadFood({
    required String parkId,
    required double parkLat,
    required double parkLng,
  }) {
    return _loadList(
      '${_base(parkId)}/food.json',
      (json) => FoodPlace.fromJson(
        json,
        parkLat: parkLat,
        parkLng: parkLng,
      ),
    );
  }

  Future<List<Hotel>> loadHotels({
    required String parkId,
    required double parkLat,
    required double parkLng,
  }) {
    return _loadList(
      '${_base(parkId)}/hotels.json',
      (json) => Hotel.fromJson(
        json,
        parkLat: parkLat,
        parkLng: parkLng,
      ),
    );
  }

  // ------------------------------------------------------------
  // INTERNAL GENERIC LOADER (supports List OR {key:[...]} formats)
  // ------------------------------------------------------------
  Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson, {
    String? fallbackKey,
  }) async {
    try {
      final raw = await rootBundle.loadString(assetPath);

      if (raw.trim().isEmpty) return <T>[];

      final decoded = jsonDecode(raw);

      List list;

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && fallbackKey != null) {
        final value = decoded[fallbackKey];
        if (value is List) {
          list = value;
        } else {
          return <T>[];
        }
      } else {
        return <T>[];
      }

      return list
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      // Return empty instead of crashing screens
      return <T>[];
    }
  }
}