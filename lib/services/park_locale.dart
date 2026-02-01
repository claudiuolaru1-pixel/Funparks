import 'package:flutter/material.dart';

class ParkLocale {
  static Locale? localeForCountry(String? countryRaw) {
    final c = (countryRaw ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    if (c.isEmpty) return null;

    bool any(List<String> keys) => keys.any((k) => c == k || c.contains(k));

    if (any(['spain', 'españa', 'espana'])) return const Locale('es');
    if (any(['france'])) return const Locale('fr');
    if (any(['germany', 'deutschland'])) return const Locale('de');
    if (any(['italy', 'italia'])) return const Locale('it');
    if (any(['netherlands', 'nederland'])) return const Locale('nl');
    if (any(['russia', 'россия'])) return const Locale('ru');
    if (any(['portugal'])) return const Locale('pt');
    if (any(['china', 'chinese', '中文', '汉语', '中國', '中国', 'cn', 'zh'])) {
      return const Locale('zh');
    }


    // Chinese (covers common English + Chinese names)
    if (any([
      'china', '中国', '中华人民共和国',
      'hong kong', '香港',
      'taiwan', '台湾',
      'macau', '澳门'
    ])) {
      return const Locale('zh');
    }

    return null;
  }
}
