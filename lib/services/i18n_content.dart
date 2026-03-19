import 'package:flutter/widgets.dart';

class I18nContent {
  final Map<String, dynamic> root;
  const I18nContent(this.root);

  String _lang(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase();

  String _pickText({
    required BuildContext context,
    required Map<String, dynamic> map,
    required String fallback,
  }) {
    final l = _lang(context);
    final v = map[l] ?? map['en'];
    if (v is String && v.trim().isNotEmpty) return v;
    return fallback;
  }

  Map<String, dynamic>? _asMap(dynamic v) => v is Map<String, dynamic>
      ? v
      : (v is Map ? Map<String, dynamic>.from(v) : null);

  // -------------------- Overview --------------------
  String tOverview(BuildContext context, String key, String fallbackEn) {
    final ov = _asMap(root['overview']);
    if (ov == null) return fallbackEn;

    final entry = _asMap(ov[key]);
    if (entry == null) return fallbackEn;

    return _pickText(context: context, map: entry, fallback: fallbackEn);
  }

  // -------------------- Attractions --------------------
  String tAttractionDesc(BuildContext context, String attractionId, String fallbackEn) {
    final at = _asMap(root['attractions']);
    if (at == null) return fallbackEn;

    final obj = _asMap(at[attractionId]);
    if (obj == null) return fallbackEn;

    final desc = _asMap(obj['desc']);
    if (desc == null) return fallbackEn;

    return _pickText(context: context, map: desc, fallback: fallbackEn);
  }

  // -------------------- Food --------------------
  String tFoodDesc(BuildContext context, String foodId, String fallbackEn) {
    final fd = _asMap(root['food']);
    if (fd == null) return fallbackEn;

    final obj = _asMap(fd[foodId]);
    if (obj == null) return fallbackEn;

    final desc = _asMap(obj['desc']);
    if (desc == null) return fallbackEn;

    return _pickText(context: context, map: desc, fallback: fallbackEn);
  }

  // -------------------- Hotels --------------------
  String tHotelDesc(BuildContext context, String hotelId, String fallbackEn) {
    final ht = _asMap(root['hotels']);
    if (ht == null) return fallbackEn;

    final obj = _asMap(ht[hotelId]);
    if (obj == null) return fallbackEn;

    final desc = _asMap(obj['desc']);
    if (desc == null) return fallbackEn;

    return _pickText(context: context, map: desc, fallback: fallbackEn);
  }

  // -------------------- Hotel rooms --------------------
  String tHotelRoomName(
    BuildContext context,
    String hotelId,
    String roomKey,
    String fallbackEn,
  ) {
    final ht = _asMap(root['hotels']);
    if (ht == null) return fallbackEn;

    final obj = _asMap(ht[hotelId]);
    if (obj == null) return fallbackEn;

    final rooms = _asMap(obj['rooms']);
    if (rooms == null) return fallbackEn;

    final roomObj = _asMap(rooms[roomKey]);
    if (roomObj == null) return fallbackEn;

    final name = _asMap(roomObj['name']);
    if (name == null) return fallbackEn;

    return _pickText(context: context, map: name, fallback: fallbackEn);
  }

  String tHotelRoomDesc(
    BuildContext context,
    String hotelId,
    String roomKey,
    String fallbackEn,
  ) {
    final ht = _asMap(root['hotels']);
    if (ht == null) return fallbackEn;

    final obj = _asMap(ht[hotelId]);
    if (obj == null) return fallbackEn;

    final rooms = _asMap(obj['rooms']);
    if (rooms == null) return fallbackEn;

    final roomObj = _asMap(rooms[roomKey]);
    if (roomObj == null) return fallbackEn;

    final desc = _asMap(roomObj['desc']);
    if (desc == null) return fallbackEn;

    return _pickText(context: context, map: desc, fallback: fallbackEn);
  }

  // -------------------- Translate button label --------------------
  static String buttonLabel(BuildContext context, bool showingTranslated) {
    final l = Localizations.localeOf(context).languageCode.toLowerCase();
    String pick(Map<String, String> m, String fb) => m[l] ?? m['en'] ?? fb;

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