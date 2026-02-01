// lib/models/food_place.dart

class FoodItem {
  final String name;
  final String description;
  final double price;

  FoodItem({
    required this.name,
    required this.description,
    required this.price,
  });

  factory FoodItem.fromJson(Map<String, dynamic> j) {
    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return FoodItem(
      name: (j['name'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      price: parseDouble(j['price']),
    );
  }
}

class FoodPlace {
  final String id;
  final String name;
  final String type;
  final String image;

  // Optional map coords (if missing -> park center)
  final double lat;
  final double lng;

  // Optional user-facing defaults
  final double rating;
  final String description;

  // ✅ NEW
  final bool topPick;

  final List<FoodItem> items;

  FoodPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.lat,
    required this.lng,
    required this.rating,
    required this.description,
    required this.topPick,
    required this.items,
  });

  static double _parseDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static bool _parseBool(dynamic v, bool fallback) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  factory FoodPlace.fromJson(
    Map<String, dynamic> j, {
    double parkLat = 41.087,
    double parkLng = 1.157,
  }) {
    final lat = _parseDouble(j['lat'], parkLat);
    final lng = _parseDouble(j['lng'], parkLng);
    final rating = _parseDouble(j['rating'], 4.4);
    final topPick = _parseBool(j['topPick'], false);

    final itemsRaw = j['items'];
    final items = (itemsRaw is List)
        ? itemsRaw
            .whereType<Map>()
            .map((e) => FoodItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <FoodItem>[];

    return FoodPlace(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      lat: lat,
      lng: lng,
      rating: rating,
      description: (j['description'] ?? j['type'] ?? '').toString(),
      topPick: topPick,
      items: items,
    );
  }
}
