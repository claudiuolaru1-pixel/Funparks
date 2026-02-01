// lib/services/portaventura_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/attraction.dart';
import '../models/food_place.dart';
import '../models/hotel.dart';

class PortAventuraRepository {
  static const double _parkLat = 41.087;
  static const double _parkLng = 1.157;

  static Future<List<Attraction>> loadAttractions() async {
    final raw =
        await rootBundle.loadString('assets/data/portaventura_attractions.json');
    final decoded = json.decode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => Attraction.fromJson(
              Map<String, dynamic>.from(e),
              parkLat: _parkLat,
              parkLng: _parkLng,
            ))
        .toList();
  }

  static Future<List<FoodPlace>> loadFood() async {
    final raw = await rootBundle.loadString('assets/data/portaventura_food.json');
    final decoded = json.decode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => FoodPlace.fromJson(
              Map<String, dynamic>.from(e),
              parkLat: _parkLat,
              parkLng: _parkLng,
            ))
        .toList();
  }

  // ✅ NEW: Hotels (note your path!)
  static Future<List<Hotel>> loadHotels() async {
    final raw =
        await rootBundle.loadString('assets/data/portaventura_hotels.json');
    final decoded = json.decode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map>()
        .map((e) => Hotel.fromJson(
              Map<String, dynamic>.from(e),
              parkLat: _parkLat,
              parkLng: _parkLng,
            ))
        .toList();
  }
}
