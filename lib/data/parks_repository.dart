import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/park_summary.dart';
import '../models/park_detail.dart';

class ParksRepository {
  const ParksRepository();

  Future<List<ParkSummary>> loadParkIndex({
    String assetPath = 'assets/data/parks/parks_index.json',
  }) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw FormatException('Park index must be a JSON array.');

    return decoded
        .map((e) => ParkSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ParkDetail> loadParkDetail(String detailAssetPath) async {
    final raw = await rootBundle.loadString(detailAssetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Park detail must be a JSON object.');
    }
    return ParkDetail.fromJson(decoded);
  }
}