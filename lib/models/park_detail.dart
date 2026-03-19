class ParkTimeNeeded {
  final int recommendedDays;
  final int minimumHours;

  const ParkTimeNeeded({
    required this.recommendedDays,
    required this.minimumHours,
  });

  factory ParkTimeNeeded.fromJson(Map<String, dynamic> json) {
    final rd = json['recommendedDays'];
    final mh = json['minimumHours'];
    if (rd == null || mh == null) {
      throw FormatException('timeNeeded requires recommendedDays and minimumHours.');
    }
    return ParkTimeNeeded(
      recommendedDays: (rd as num).toInt(),
      minimumHours: (mh as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'recommendedDays': recommendedDays,
        'minimumHours': minimumHours,
      };
}

class ParkZone {
  final String id;
  final String name;

  const ParkZone({required this.id, required this.name});

  factory ParkZone.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    final name = json['name']?.toString().trim();
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      throw FormatException('Zone requires id and name.');
    }
    return ParkZone(id: id, name: name);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ParkRide {
  final String id;
  final String name;
  final String zoneId;
  final String category; // coaster, dark_ride, water, kids, show, etc.
  final int thrill; // 1..5
  final bool familyFriendly;
  final int? minHeightCm;
  final int? durationMin;
  final List<String> tags;
  final String shortDescription;
  final List<String> tips;
  final String? thumbnail;

  const ParkRide({
    required this.id,
    required this.name,
    required this.zoneId,
    required this.category,
    required this.thrill,
    required this.familyFriendly,
    required this.minHeightCm,
    required this.durationMin,
    required this.tags,
    required this.shortDescription,
    required this.tips,
    required this.thumbnail,
  });

  factory ParkRide.fromJson(Map<String, dynamic> json) {
    String reqString(String key) {
      final v = json[key];
      if (v == null || v.toString().trim().isEmpty) {
        throw FormatException('Ride missing "$key".');
      }
      return v.toString();
    }

    int reqInt(String key) {
      final v = json[key];
      if (v == null) throw FormatException('Ride missing "$key".');
      return (v as num).toInt();
    }

    int? optInt(String key) {
      final v = json[key];
      if (v == null) return null;
      return (v as num).toInt();
    }

    final tagsRaw = json['tags'];
    final tipsRaw = json['tips'];

    return ParkRide(
      id: reqString('id'),
      name: reqString('name'),
      zoneId: reqString('zoneId'),
      category: reqString('category'),
      thrill: reqInt('thrill'),
      familyFriendly: (json['familyFriendly'] as bool?) ?? false,
      minHeightCm: optInt('minHeightCm'),
      durationMin: optInt('durationMin'),
      tags: (tagsRaw is List) ? tagsRaw.map((e) => e.toString()).toList() : const [],
      shortDescription: reqString('shortDescription'),
      tips: (tipsRaw is List) ? tipsRaw.map((e) => e.toString()).toList() : const [],
      thumbnail: json['thumbnail']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'zoneId': zoneId,
        'category': category,
        'thrill': thrill,
        'familyFriendly': familyFriendly,
        'minHeightCm': minHeightCm,
        'durationMin': durationMin,
        'tags': tags,
        'shortDescription': shortDescription,
        'tips': tips,
        'thumbnail': thumbnail,
      };
}

class ParkTips {
  final List<String> firstTimer;
  final List<String> crowdStrategy;
  final List<String> withKids;
  final List<String> rainyDay;

  const ParkTips({
    required this.firstTimer,
    required this.crowdStrategy,
    required this.withKids,
    required this.rainyDay,
  });

  factory ParkTips.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) {
      final v = json[key];
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    return ParkTips(
      firstTimer: list('firstTimer'),
      crowdStrategy: list('crowdStrategy'),
      withKids: list('withKids'),
      rainyDay: list('rainyDay'),
    );
  }

  Map<String, dynamic> toJson() => {
        'firstTimer': firstTimer,
        'crowdStrategy': crowdStrategy,
        'withKids': withKids,
        'rainyDay': rainyDay,
      };
}

class ParkPractical {
  final List<String> bestMonths;
  final List<String> transport;
  final List<String> accessibilityNotes;

  const ParkPractical({
    required this.bestMonths,
    required this.transport,
    required this.accessibilityNotes,
  });

  factory ParkPractical.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) {
      final v = json[key];
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    return ParkPractical(
      bestMonths: list('bestMonths'),
      transport: list('transport'),
      accessibilityNotes: list('accessibilityNotes'),
    );
  }

  Map<String, dynamic> toJson() => {
        'bestMonths': bestMonths,
        'transport': transport,
        'accessibilityNotes': accessibilityNotes,
      };
}

class ParkDetail {
  final String id;
  final String lastUpdated; // ISO date string
  final String tagline;
  final String description;
  final ParkTimeNeeded timeNeeded;
  final List<ParkZone> zones;
  final List<ParkRide> rides;
  final ParkTips tips;
  final ParkPractical practical;

  const ParkDetail({
    required this.id,
    required this.lastUpdated,
    required this.tagline,
    required this.description,
    required this.timeNeeded,
    required this.zones,
    required this.rides,
    required this.tips,
    required this.practical,
  });

  factory ParkDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    if (id == null || id.isEmpty) throw FormatException('ParkDetail missing "id".');

    final timeNeededRaw = json['timeNeeded'];
    final zonesRaw = json['zones'];
    final ridesRaw = json['rides'];
    final tipsRaw = json['tips'];
    final practicalRaw = json['practical'];

    if (timeNeededRaw is! Map<String, dynamic>) throw FormatException('timeNeeded must be an object.');
    if (zonesRaw is! List) throw FormatException('zones must be a list.');
    if (ridesRaw is! List) throw FormatException('rides must be a list.');
    if (tipsRaw is! Map<String, dynamic>) throw FormatException('tips must be an object.');
    if (practicalRaw is! Map<String, dynamic>) throw FormatException('practical must be an object.');

    return ParkDetail(
      id: id,
      lastUpdated: (json['lastUpdated'] ?? '').toString(),
      tagline: (json['tagline'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      timeNeeded: ParkTimeNeeded.fromJson(timeNeededRaw),
      zones: zonesRaw.map((e) => ParkZone.fromJson(e as Map<String, dynamic>)).toList(),
      rides: ridesRaw.map((e) => ParkRide.fromJson(e as Map<String, dynamic>)).toList(),
      tips: ParkTips.fromJson(tipsRaw),
      practical: ParkPractical.fromJson(practicalRaw),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lastUpdated': lastUpdated,
        'tagline': tagline,
        'description': description,
        'timeNeeded': timeNeeded.toJson(),
        'zones': zones.map((z) => z.toJson()).toList(),
        'rides': rides.map((r) => r.toJson()).toList(),
        'tips': tips.toJson(),
        'practical': practical.toJson(),
      };
}