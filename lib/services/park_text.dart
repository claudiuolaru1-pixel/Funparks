class ParkText {
  /// Picks the best translation from a language map.
  ///
  /// Priority:
  /// 1️⃣ exact language match (fr, es, de…)
  /// 2️⃣ language without region (pt-BR → pt)
  /// 3️⃣ English fallback
  /// 4️⃣ first available value
  /// 5️⃣ empty string
  static String pick(
    Map<String, String> byLang,
    String langCode,
  ) {
    if (byLang.isEmpty) return '';

    final code = langCode.toLowerCase();

    // exact match
    if (_valid(byLang[code])) {
      return byLang[code]!;
    }

    // handle locale with region: pt-BR → pt
    if (code.contains('-')) {
      final base = code.split('-').first;
      if (_valid(byLang[base])) {
        return byLang[base]!;
      }
    }

    // fallback to English
    if (_valid(byLang['en'])) {
      return byLang['en']!;
    }

    // fallback to first available non-empty
    for (final value in byLang.values) {
      if (_valid(value)) return value!;
    }

    return '';
  }

  static bool _valid(String? s) =>
      s != null && s.trim().isNotEmpty;
}