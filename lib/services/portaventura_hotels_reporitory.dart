// lib/services/portaventura_hotels_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/hotel.dart';

class PortAventuraHotelsRepository {
  static const String _assetPath = 'assets/data/portaventura_hotels.json';

  static List<Hotel>? _cache;

  static Future<List<Hotel>> loadHotels({
    bool forceReload = false,
    double parkLat = 41.087,
    double parkLng = 1.157,
  }) async {
    if (!forceReload && _cache != null) return _cache!;

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw);

    if (decoded is! List) return <Hotel>[];

    final hotels = decoded
        .whereType<Map>()
        .map((e) => Hotel.fromJson(
              Map<String, dynamic>.from(e),
              parkLat: parkLat,
              parkLng: parkLng,
            ))
        .toList();

    _cache = hotels;
    return hotels;
  }

  static void clearCache() => _cache = null;
}
