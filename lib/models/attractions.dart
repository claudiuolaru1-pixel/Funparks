// lib/models/attraction.dart

class Attraction {
  final String id;
  final String name;
  final String category;
  final String image;

  // Base (English) fallback
  final String description;

  // ✅ NEW: translations
  final Map<String, dynamic> nameI18n;
  final Map<String, dynamic> descriptionI18n;
  final Map<String, dynamic> factsI18n;

  final bool topPick;

  final int liveWaitMinutes;
  final double rating;

  final int? speedKmh;
  final double? heightM;
  final int? inversions;
  final int? openedYear;
  final int? minHeightCm;

  final double lat;
  final double lng;

  const Attraction({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.description,
    required this.nameI18n,
    required this.descriptionI18n,
    required this.factsI18n,
    required this.topPick,
    required this.liveWaitMinutes,
    required this.rating,
    this.speedKmh,
    this.heightM,
    this.inversions,
    this.openedYear,
    this.minHeightCm,
    required this.lat,
    required this.lng,
  });

  static double _d(dynamic v, double fb) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? fb;

  static double? _nd(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('$v');

  static int _i(dynamic v, int fb) =>
      v is int ? v : int.tryParse('$v') ?? fb;

  static int? _ni(dynamic v) =>
      v is int ? v : int.tryParse('$v');

  static bool _b(dynamic v, bool fb) {
    if (v is bool) return v;
    final s = '$v'.toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return fb;
  }

  static Map<String, dynamic> _m(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : const {};

  factory Attraction.fromJson(
    Map<String, dynamic> j, {
    double parkLat = 41.087,
    double parkLng = 1.157,
  }) {
    return Attraction(
      id: '${j['id']}',
      name: '${j['name']}',
      category: '${j['category']}',
      image: '${j['image']}',
      description: '${j['description'] ?? ''}',

      nameI18n: _m(j['name_i18n']),
      descriptionI18n: _m(j['description_i18n']),
      factsI18n: _m(j['facts_i18n']),

      topPick: _b(j['topPick'], false),
      liveWaitMinutes: _i(j['liveWaitMinutes'], 0),
      rating: _d(j['rating'], 4.3),

      speedKmh: _ni(j['speedKmh']),
      heightM: _nd(j['heightM']),
      inversions: _ni(j['inversions']),
      openedYear: _ni(j['openedYear']),
      minHeightCm: _ni(j['minHeightCm']),

      lat: _d(j['lat'], parkLat),
      lng: _d(j['lng'], parkLng),
    );
  }
}
