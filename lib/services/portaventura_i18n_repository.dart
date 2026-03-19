// lib/services/portaventura_i18n_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class PortAventuraI18nRepository {
  // ✅ correct path
  static const String _assetPath = 'assets/i18n/portaventura.json';

  static Future<Map<String, dynamic>> load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);

      if (raw.trim().isEmpty) {
        throw Exception('Asset is empty: $_assetPath');
      }

      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);

      throw Exception('Expected a JSON object (Map) in $_assetPath');
    } catch (e) {
      throw Exception(
        'PortAventuraI18nRepository.load failed: Unable to load asset: "$_assetPath". $e',
      );
    }
  }
}
