// lib/models/park.dart
class Park {
  final String id;
  final String name;
  final String? city;
  final String country;
  final String type;
  final String? openingHours;
  final Map<String, num> entryPrices;
  final String currency;
  final double lat;
  final double lng;
  final String? thumbnail;
  final String? website;
  final String? ticketsUrl;
  final int? queueTimesId;

  const Park({
    required this.id,
    required this.name,
    this.city,
    required this.country,
    required this.type,
    this.openingHours,
    required this.entryPrices,
    required this.currency,
    required this.lat,
    required this.lng,
    this.thumbnail,
    this.website,
    this.ticketsUrl,
    this.queueTimesId,
  });

  static double _d(dynamic v, double fb) =>
      v is num ? v.toDouble() : double.tryParse('$v') ?? fb;

  factory Park.fromJson(Map<String, dynamic> j) {
    final rawPrices = j['entryPrices'];
    final prices = <String, num>{};
    if (rawPrices is Map) {
      rawPrices.forEach((k, v) {
        if (v is num) prices[k.toString()] = v;
      });
    }
    return Park(
      id: '${j['id'] ?? ''}',
      name: '${j['name'] ?? ''}',
      city: j['city']?.toString(),
      country: '${j['country'] ?? ''}',
      type: '${j['type'] ?? ''}',
      openingHours: j['openingHours']?.toString(),
      entryPrices: prices,
      currency: '${j['currency'] ?? 'EUR'}',
      lat: _d(j['lat'], 0.0),
      lng: _d(j['lng'], 0.0),
      thumbnail: j['thumbnail']?.toString(),
      website: j['website']?.toString(),
      ticketsUrl: j['ticketsUrl']?.toString(),
      queueTimesId: j['queueTimesId'] is int ? j['queueTimesId'] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (city != null) 'city': city,
        'country': country,
        'type': type,
        if (openingHours != null) 'openingHours': openingHours,
        'entryPrices': entryPrices,
        'currency': currency,
        'lat': lat,
        'lng': lng,
        if (thumbnail != null) 'thumbnail': thumbnail,
        if (website != null) 'website': website,
        if (ticketsUrl != null) 'ticketsUrl': ticketsUrl,
        if (queueTimesId != null) 'queueTimesId': queueTimesId,
      };
}