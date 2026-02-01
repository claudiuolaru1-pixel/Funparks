// lib/models/attraction.dart

class Attraction {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category; // thrill, family, water, simulator
  final bool topPick;

  // Optional map coords (if missing in JSON, we use park center)
  final double lat;
  final double lng;

  // Optional “live” values (you can replace later with real API)
  final int liveWaitMinutes;
  final double rating;

  // ✅ NEW premium facts (optional)
  final int? speedKmh;
  final int? heightM;
  final int? inversions;
  final int? openedYear;

  Attraction({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.category,
    required this.topPick,
    required this.lat,
    required this.lng,
    required this.liveWaitMinutes,
    required this.rating,
    this.speedKmh,
    this.heightM,
    this.inversions,
    this.openedYear,
  });

  static double _parseDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  static int _parseInt(dynamic v, int fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? fallback;
  }

  static int? _parseIntNullable(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool _parseBool(dynamic v, bool fallback) {
    if (v == null) return fallback;
    if (v is bool) return v;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  factory Attraction.fromJson(
    Map<String, dynamic> j, {
    // PortAventura center fallback
    double parkLat = 41.087,
    double parkLng = 1.157,
  }) {
    // If JSON lacks coordinates, use the park center.
    final lat = _parseDouble(j['lat'], parkLat);
    final lng = _parseDouble(j['lng'], parkLng);

    // Optional values; safe fallbacks
    final wait = _parseInt(j['liveWaitMinutes'], 25);
    final rating = _parseDouble(j['rating'], 4.6);

    return Attraction(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? 'Unnamed').toString(),
      description: (j['description'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      category: (j['category'] ?? 'family').toString(),
      topPick: _parseBool(j['topPick'], false),
      lat: lat,
      lng: lng,
      liveWaitMinutes: wait,
      rating: rating,

      // ✅ premium facts (optional)
      speedKmh: _parseIntNullable(j['speedKmh']),
      heightM: _parseIntNullable(j['heightM']),
      inversions: _parseIntNullable(j['inversions']),
      openedYear: _parseIntNullable(j['openedYear']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'category': category,
        'topPick': topPick,
        'lat': lat,
        'lng': lng,
        'liveWaitMinutes': liveWaitMinutes,
        'rating': rating,
        'speedKmh': speedKmh,
        'heightM': heightM,
        'inversions': inversions,
        'openedYear': openedYear,
      };
}
