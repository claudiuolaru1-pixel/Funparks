import 'entry_prices.dart';

enum ParkType { theme, water, zoo, resort, other }

ParkType parkTypeFromJson(dynamic value) {
  final s = (value ?? '').toString().toLowerCase().trim();
  switch (s) {
    case 'theme':
      return ParkType.theme;
    case 'water':
      return ParkType.water;
    case 'zoo':
      return ParkType.zoo;
    case 'resort':
      return ParkType.resort;
    default:
      return ParkType.other;
  }
}

class ParkSummary {
  final String id;
  final String name;
  final String city;
  final String country;
  final ParkType type;
  final String openingHours;
  final EntryPrices entryPrices;
  final String currency;
  final double lat;
  final double lng;
  final String thumbnail;
  final String website;
  final String detailAsset;
  final String? ticketsUrl;

  const ParkSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.type,
    required this.openingHours,
    required this.entryPrices,
    required this.currency,
    required this.lat,
    required this.lng,
    required this.thumbnail,
    required this.website,
    this.detailAsset = "",
    this.ticketsUrl,
  });

  factory ParkSummary.fromJson(Map<String, dynamic> json) {
    String reqString(String key) {
      final v = json[key];
      if (v == null || v.toString().trim().isEmpty) {
        throw FormatException('ParkSummary missing "$key".');
      }
      return v.toString();
    }

    num reqNum(String key) {
      final v = json[key];
      if (v == null) throw FormatException('ParkSummary missing "$key".');
      if (v is num) return v;
      return num.parse(v.toString());
    }

    final entry = json['entryPrices'];
    if (entry is! Map<String, dynamic>) {
      throw FormatException('ParkSummary.entryPrices must be an object.');
    }

    return ParkSummary(
      id: reqString('id'),
      name: reqString('name'),
      city: reqString('city'),
      country: reqString('country'),
      type: parkTypeFromJson(json['type']),
      openingHours: reqString('openingHours'),
      entryPrices: EntryPrices.fromJson(entry),
      currency: reqString('currency'),
      lat: (reqNum('lat')).toDouble(),
      lng: (reqNum('lng')).toDouble(),
      thumbnail: reqString('thumbnail'),
      website: reqString('website'),
      detailAsset: json['detailAsset']?.toString() ?? '',
      ticketsUrl: json['ticketsUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'country': country,
        'type': type.name,
        'openingHours': openingHours,
        'entryPrices': entryPrices.toJson(),
        'currency': currency,
        'lat': lat,
        'lng': lng,
        'thumbnail': thumbnail,
        'website': website,
        'detailAsset': detailAsset,
        if (ticketsUrl != null) 'ticketsUrl': ticketsUrl,
      };
}