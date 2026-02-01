// lib/services/portaventura_i18n_repository.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class PortAventuraI18nRepository {
  static const String _assetPath = 'assets/data/portaventura_i18n.json';

  static Future<Map<String, dynamic>> load() async {
    final raw = await rootBundle.loadString(_assetPath);

    final decoded = json.decode(raw);

    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);

    // If JSON is not a Map, return empty (but it means file structure is wrong)
    return <String, dynamic>{};
  }
}
