class ParkText {
  static String pick(Map<String, String> byLang, String langCode) {
    if (byLang.containsKey(langCode) && byLang[langCode]!.trim().isNotEmpty) {
      return byLang[langCode]!;
    }
    if (byLang.containsKey('en') && byLang['en']!.trim().isNotEmpty) {
      return byLang['en']!;
    }
    if (byLang.isNotEmpty) {
      return byLang.values.first;
    }
    return '';
  }
}
