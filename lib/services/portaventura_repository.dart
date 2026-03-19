// lib/services/portaventura_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/attraction.dart';
import '../models/food_place.dart';
import '../models/hotel.dart';

class PortAventuraRepository {
  // Central park fallback coordinates
  static const double _parkLat = 41.087;
  static const double _parkLng = 1.157;

  static const String _basePath = 'assets/data/parks/portaventura';

  // ------------------------------------------------------------
  // ATTRACTIONS
  // ------------------------------------------------------------
  static Future<List<Attraction>> loadAttractions() async {
    return _loadList(
      '$_basePath/attractions.json',
      (json) => Attraction.fromJson(
        json,
        parkLat: _parkLat,
        parkLng: _parkLng,
      ),
      fallbackKey: 'attractions',
    );
  }

  // ------------------------------------------------------------
  // FOOD
  // ------------------------------------------------------------
  static Future<List<FoodPlace>> loadFood() async {
    return _loadList(
      '$_basePath/food.json',
      (json) => FoodPlace.fromJson(
        json,
        parkLat: _parkLat,
        parkLng: _parkLng,
      ),
      fallbackKey: 'food',
    );
  }

  // ------------------------------------------------------------
  // HOTELS
  // ------------------------------------------------------------
  static Future<List<Hotel>> loadHotels() async {
    return _loadList(
      '$_basePath/hotels.json',
      (json) => Hotel.fromJson(
        json,
        parkLat: _parkLat,
        parkLng: _parkLng,
      ),
      fallbackKey: 'hotels',
    );
  }

  // ------------------------------------------------------------
  // INTERNAL GENERIC LOADER
  // ------------------------------------------------------------
  static Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic>) fromJson, {
    String? fallbackKey,
  }) async {
    try {
      final raw = await rootBundle.loadString(assetPath);

      if (raw.trim().isEmpty) {
        throw Exception('Asset is empty: $assetPath');
      }

      final decoded = jsonDecode(raw);

      List list;

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && fallbackKey != null) {
        final value = decoded[fallbackKey];
        if (value is List) {
          list = value;
        } else {
          throw Exception(
            'Expected key "$fallbackKey" to contain a List in $assetPath',
          );
        }
      } else {
        throw Exception(
          'Unsupported JSON format in $assetPath (expected List or Map)',
        );
      }

      return list
          .whereType<Map>()
          .map(
            (e) => fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(growable: false);
    } catch (e) {
      throw Exception(
        'PortAventuraRepository failed to load "$assetPath": $e',
      );
    }
  }
}
