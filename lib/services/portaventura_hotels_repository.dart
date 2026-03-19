import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/hotel.dart';

class HotelsRepository {
  const HotelsRepository();

  static String _pathForPark(String parkId) =>
      'assets/data/parks/$parkId/hotels.json';

  Future<List<Hotel>> loadHotels({
    required String parkId,
    double parkLat = 0,
    double parkLng = 0,
  }) async {
    final path = _pathForPark(parkId);

    try {
      final raw = await rootBundle.loadString(path);
      if (raw.trim().isEmpty) return <Hotel>[];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Hotel>[];

      return decoded
          .whereType<Map>()
          .map((e) => Hotel.fromJson(
                Map<String, dynamic>.from(e),
                parkLat: parkLat,
                parkLng: parkLng,
              ))
          .toList();
    } catch (e) {
      // Return empty instead of crashing the whole park screen
      return <Hotel>[];
    }
  }
}