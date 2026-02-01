// lib/models/hotel.dart

class HotelRoom {
  /// ✅ used for i18n lookup, e.g. "standard_room", "superior_room"
  final String key;

  final String name;
  final String description;
  final double pricePerNight;
  final bool breakfastIncluded;

  HotelRoom({
    required this.key,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.breakfastIncluded,
  });

  static double _d(dynamic v, double fb) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? fb;

  static bool _b(dynamic v, bool fb) {
    if (v is bool) return v;
    final s = '$v'.trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fb;
  }

  factory HotelRoom.fromJson(Map<String, dynamic> j) {
    return HotelRoom(
      key: (j['key'] ?? '').toString(), // ✅ NEW
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      pricePerNight: _d(j['pricePerNight'], 0.0),
      breakfastIncluded: _b(j['breakfastIncluded'], false),
    );
  }
}

class Hotel {
  final String id;
  final String name;
  final String description;
  final String image;
  final double lat;
  final double lng;
  final double rating;
  final bool topPick;
  final String? website;
  final List<HotelRoom> rooms;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.topPick,
    required this.website,
    required this.rooms,
  });

  static double _d(dynamic v, double fb) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? fb;

  static bool _b(dynamic v, bool fb) {
    if (v is bool) return v;
    final s = '$v'.trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fb;
  }

  factory Hotel.fromJson(
    Map<String, dynamic> j, {
    double parkLat = 41.087,
    double parkLng = 1.157,
  }) {
    final roomsRaw = j['rooms'];
    final rooms = (roomsRaw is List)
        ? roomsRaw
            .whereType<Map>()
            .map((e) => HotelRoom.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <HotelRoom>[];

    return Hotel(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      lat: _d(j['lat'], parkLat),
      lng: _d(j['lng'], parkLng),
      rating: _d(j['rating'], 4.4),
      topPick: _b(j['topPick'], false),
      website: (j['website'] ?? '').toString().trim().isEmpty
          ? null
          : (j['website'] ?? '').toString().trim(),
      rooms: rooms,
    );
  }

  /// Used for "Lowest price" sorting (ignores invalid/0 prices).
  double? get lowestNightPrice {
    final prices = rooms.map((r) => r.pricePerNight).where((p) => p > 0).toList();
    if (prices.isEmpty) return null;
    prices.sort();
    return prices.first;
  }
}
