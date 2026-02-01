// lib/models/park.dart
class Park {
  final String id;
  final String name;
  final String country;
  final String type;
  final String? openingHours;
  final Map<String, num> entryPrices;
  final String currency;
  final double lat;
  final double lng;
  final String? website;

  // Optional UI fields
  final String? city;
  final String? thumbnail; // asset path or image URL

  Park({
    required this.id,
    required this.name,
    required this.country,
    required this.type,
    required this.openingHours,
    required this.entryPrices,
    required this.currency,
    required this.lat,
    required this.lng,
    this.website,
    this.city,
    this.thumbnail,
  });

  factory Park.fromJson(Map<String, dynamic> j) {
    // entryPrices can be absent or not a map
    final prices = j['entryPrices'];
    Map<String, num> parsedPrices;
    if (prices is Map) {
      parsedPrices = Map<String, num>.from(
        prices.map((k, v) => MapEntry(k.toString(), (v as num))),
      );
    } else {
      parsedPrices = const {'adult': 0, 'child': 0};
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return Park(
      id: (j['id'] ?? j['parkId'] ?? j['uid'] ?? '').toString(),
      name: (j['name'] ?? 'Unnamed Park').toString(),
      country: (j['country'] ?? '').toString(),
      type: (j['type'] ?? 'theme').toString(),
      openingHours: j['openingHours']?.toString(),
      entryPrices: parsedPrices,
      currency: (j['currency'] ?? 'EUR').toString(),
      lat: parseDouble(j['lat']),
      lng: parseDouble(j['lng']),
      website: j['website']?.toString(),
      city: (j['city'] ?? j['town'] ?? j['locality'])?.toString(),
      thumbnail: (j['thumbnail'] ?? j['image'] ?? j['imageUrl'] ?? j['thumbnailUrl'])?.toString(),
    );
  }
}
