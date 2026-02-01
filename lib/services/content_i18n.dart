// lib/services/content_i18n.dart
import 'package:flutter/widgets.dart';

class ContentI18n {
  static String _lang(BuildContext c) =>
      Localizations.localeOf(c).languageCode;

  static String text(
    BuildContext c,
    Map<String, dynamic> map,
    String fallback,
  ) {
    final l = _lang(c);
    if (map[l] is String) return map[l];
    if (map['en'] is String) return map['en'];
    return fallback;
  }

  static List<String> list(
    BuildContext c,
    Map<String, dynamic> map,
    List<String> fallback,
  ) {
    final l = _lang(c);
    if (map[l] is List) return List<String>.from(map[l]);
    if (map['en'] is List) return List<String>.from(map['en']);
    return fallback;
  }
}
