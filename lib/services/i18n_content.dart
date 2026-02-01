// lib/services/i18n_content.dart
import 'package:flutter/widgets.dart';

class I18nContent {
  final Map<String, dynamic> root;
  const I18nContent(this.root);

  String _lang(BuildContext context) =>
      Localizations.localeOf(context).languageCode;

  // -------------------- Overview --------------------
  String tOverview(BuildContext context, String key, String fallbackEn) {
    final l = _lang(context);
    final ov = root['overview'];
    if (ov is! Map) return fallbackEn;
    final entry = ov[key];
    if (entry is! Map) return fallbackEn;
    return (entry[l] ?? entry['en'] ?? fallbackEn).toString();
  }

  // -------------------- Attractions --------------------
  String tAttractionDesc(
      BuildContext context, String attractionId, String fallbackEn) {
    final l = _lang(context);
    final at = root['attractions'];
    if (at is! Map) return fallbackEn;
    final obj = at[attractionId];
    if (obj is! Map) return fallbackEn;
    final desc = obj['desc'];
    if (desc is! Map) return fallbackEn;
    return (desc[l] ?? desc['en'] ?? fallbackEn).toString();
  }

  // -------------------- Food --------------------
  String tFoodDesc(BuildContext context, String foodId, String fallbackEn) {
    final l = _lang(context);
    final fd = root['food'];
    if (fd is! Map) return fallbackEn;
    final obj = fd[foodId];
    if (obj is! Map) return fallbackEn;
    final desc = obj['desc'];
    if (desc is! Map) return fallbackEn;
    return (desc[l] ?? desc['en'] ?? fallbackEn).toString();
  }

  // -------------------- Hotels --------------------
  String tHotelDesc(BuildContext context, String hotelId, String fallbackEn) {
    final l = _lang(context);
    final ht = root['hotels'];
    if (ht is! Map) return fallbackEn;
    final obj = ht[hotelId];
    if (obj is! Map) return fallbackEn;
    final desc = obj['desc'];
    if (desc is! Map) return fallbackEn;
    return (desc[l] ?? desc['en'] ?? fallbackEn).toString();
  }

  /// Optional: room-level name translation
  /// roomKey example: "standard_room", "superior_room"
  String tHotelRoomName(
    BuildContext context,
    String hotelId,
    String roomKey,
    String fallbackEn,
  ) {
    final l = _lang(context);
    final ht = root['hotels'];
    if (ht is! Map) return fallbackEn;
    final obj = ht[hotelId];
    if (obj is! Map) return fallbackEn;
    final rooms = obj['rooms'];
    if (rooms is! Map) return fallbackEn;
    final roomObj = rooms[roomKey];
    if (roomObj is! Map) return fallbackEn;
    final name = roomObj['name'];
    if (name is! Map) return fallbackEn;
    return (name[l] ?? name['en'] ?? fallbackEn).toString();
  }

  /// Optional: room-level description translation
  String tHotelRoomDesc(
    BuildContext context,
    String hotelId,
    String roomKey,
    String fallbackEn,
  ) {
    final l = _lang(context);
    final ht = root['hotels'];
    if (ht is! Map) return fallbackEn;
    final obj = ht[hotelId];
    if (obj is! Map) return fallbackEn;
    final rooms = obj['rooms'];
    if (rooms is! Map) return fallbackEn;
    final roomObj = rooms[roomKey];
    if (roomObj is! Map) return fallbackEn;
    final desc = roomObj['desc'];
    if (desc is! Map) return fallbackEn;
    return (desc[l] ?? desc['en'] ?? fallbackEn).toString();
  }

  // -------------------- Translate button --------------------
  static String buttonLabel(BuildContext context, bool showingTranslated) {
    final l = Localizations.localeOf(context).languageCode;
    String pick(Map<String, String> m, String fb) => m[l] ?? fb;

    final translate = pick({
      'en': 'Translate',
      'fr': 'Traduire',
      'es': 'Traducir',
      'de': 'Übersetzen',
      'it': 'Traduci',
      'nl': 'Vertalen',
      'pt': 'Traduzir',
      'ru': 'Перевести',
      'zh': '翻译',
    }, 'Translate');

    final original = pick({
      'en': 'Original',
      'fr': 'Original',
      'es': 'Original',
      'de': 'Original',
      'it': 'Originale',
      'nl': 'Origineel',
      'pt': 'Original',
      'ru': 'Оригинал',
      'zh': '原文',
    }, 'Original');

    return showingTranslated ? original : translate;
  }
}
