import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  // ---------- Locale ----------
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool _languageManuallySet = false;
  bool get languageManuallySet => _languageManuallySet;

  // ---------- Currency ----------
  String _currency = 'EUR';
  String get currency => _currency;

  // ---------- Init ----------
  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void>? _initFuture;

  /// Call this from main.dart using FutureBuilder.
  /// Runs only once (safe to call multiple times).
  Future<void> ensureInitialized(Locale deviceLocale, String defaultCurrency) {
    _initFuture ??= _loadFromPrefs(deviceLocale, defaultCurrency);
    return _initFuture!;
  }

  Future<void> _loadFromPrefs(Locale deviceLocale, String defaultCurrency) async {
    final prefs = await SharedPreferences.getInstance();

    final savedLang = prefs.getString('locale_lang');
    final lang = (savedLang == null || savedLang.trim().isEmpty)
        ? deviceLocale.languageCode
        : savedLang.trim();

    _locale = Locale(lang);

    _currency = prefs.getString('currency') ?? defaultCurrency;
    _languageManuallySet = prefs.getBool('language_manual') ?? false;
    _myStay = (prefs.getStringList('my_stay') ?? []).toSet();

    // Restore lists
    _myDay = (prefs.getStringList('my_day') ?? []).toSet();
    _myFood = (prefs.getStringList('my_food') ?? []).toSet();
    _myStay = (prefs.getStringList('my_stay') ?? []).toSet();

    _initialized = true;
    notifyListeners();
  }

  // Keep compatibility if older code still calls this:
  Future<void> loadFromDevice(Locale deviceLocale, String defaultCurrency) async {
    await ensureInitialized(deviceLocale, defaultCurrency);
  }

  Future<void> setLocale(Locale l) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(l.languageCode);
    _languageManuallySet = true;
    await prefs.setString('locale_lang', _locale.languageCode);
    await prefs.setBool('language_manual', true);
    notifyListeners();
  }

  Future<void> setLocaleSilently(Locale l) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(l.languageCode);
    await prefs.setString('locale_lang', _locale.languageCode);
    notifyListeners();
  }

  Future<void> setCurrency(String cur) async {
    final prefs = await SharedPreferences.getInstance();
    _currency = cur;
    await prefs.setString('currency', cur);
    notifyListeners();
  }

  // -------------------- My Day (Attractions) --------------------
  Set<String> _myDay = {};
  bool isInMyDay(String id) => _myDay.contains(id);

  int get myDayCount => _myDay.length;

  Future<void> toggleMyDayAttraction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (_myDay.contains(id)) {
      _myDay.remove(id);
    } else {
      _myDay.add(id);
    }
    await prefs.setStringList('my_day', _myDay.toList());
    notifyListeners();
  }

  // -------------------- My Food --------------------
  Set<String> _myFood = {};
  bool isInMyFood(String id) => _myFood.contains(id);

  int get myFoodCount => _myFood.length;

  Future<void> toggleMyFood(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (_myFood.contains(id)) {
      _myFood.remove(id);
    } else {
      _myFood.add(id);
    }
    await prefs.setStringList('my_food', _myFood.toList());
    notifyListeners();
  }

    // -------------------- My Stay (Hotels) --------------------
    Set<String> _myStay = {};
    bool isInMyStay(String id) => _myStay.contains(id);
    int get myStayCount => _myStay.length;

    Future<void> toggleMyStay(String id) async {
      final prefs = await SharedPreferences.getInstance();
      if (_myStay.contains(id)) {
        _myStay.remove(id);
      } else {
        _myStay.add(id);
      }
      await prefs.setStringList('my_stay', _myStay.toList());
      notifyListeners();
    }

  // -------------------- Ratings / Comments (Attractions) --------------------
  final Map<String, double> _attrRatings = {};
  final Map<String, String> _attrComments = {};

  double? ratingForAttraction(String id) => _attrRatings[id];
  String? commentForAttraction(String id) => _attrComments[id];

  Future<void> setAttractionRating(String id, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    _attrRatings[id] = rating;
    await prefs.setDouble('attr_rating_$id', rating);
    notifyListeners();
  }

  Future<void> setAttractionComment(String id, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    _attrComments[id] = comment;
    await prefs.setString('attr_comment_$id', comment);
    notifyListeners();
  }

  // -------------------- Ratings / Comments (Food) --------------------
  final Map<String, double> _foodRatings = {};
  final Map<String, String> _foodComments = {};

  double? ratingForFood(String id) => _foodRatings[id];
  String? commentForFood(String id) => _foodComments[id];

  Future<void> setFoodRating(String id, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    _foodRatings[id] = rating;
    await prefs.setDouble('food_rating_$id', rating);
    notifyListeners();
  }

  Future<void> setFoodComment(String id, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    _foodComments[id] = comment;
    await prefs.setString('food_comment_$id', comment);
    notifyListeners();
  }

  // -------------------- Ratings / Comments (Hotels) --------------------
  final Map<String, double> _hotelRatings = {};
  final Map<String, String> _hotelComments = {};

  double? ratingForHotel(String id) => _hotelRatings[id];
  String? commentForHotel(String id) => _hotelComments[id];

  Future<void> setHotelRating(String id, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    _hotelRatings[id] = rating;
    await prefs.setDouble('hotel_rating_$id', rating);
    notifyListeners();
  }

  Future<void> setHotelComment(String id, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    _hotelComments[id] = comment;
    await prefs.setString('hotel_comment_$id', comment);
    notifyListeners();
  }

  // -------------------- My Wait Minutes --------------------
  final Map<String, int?> _myWait = {};
  int? myWaitFor(String attractionId) => _myWait[attractionId];

  Future<void> setMyWaitMinutes(String attractionId, int? minutes) async {
    final prefs = await SharedPreferences.getInstance();
    _myWait[attractionId] = minutes;
    if (minutes == null) {
      await prefs.remove('my_wait_$attractionId');
    } else {
      await prefs.setInt('my_wait_$attractionId', minutes);
    }
    notifyListeners();
  }

  // -------------------- Lazy load per item --------------------
  Future<void> ensureLoadedForAttraction(String id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!_attrRatings.containsKey(id)) {
      final v = prefs.getDouble('attr_rating_$id');
      if (v != null) _attrRatings[id] = v;
    }

    if (!_attrComments.containsKey(id)) {
      final v = prefs.getString('attr_comment_$id');
      if (v != null) _attrComments[id] = v;
    }

    if (!_myWait.containsKey(id)) {
      _myWait[id] = prefs.getInt('my_wait_$id');
    }
  }

  Future<void> ensureLoadedForFood(String id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!_foodRatings.containsKey(id)) {
      final v = prefs.getDouble('food_rating_$id');
      if (v != null) _foodRatings[id] = v;
    }

    if (!_foodComments.containsKey(id)) {
      final v = prefs.getString('food_comment_$id');
      if (v != null) _foodComments[id] = v;
    }
  }

  Future<void> ensureLoadedForHotel(String id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!_hotelRatings.containsKey(id)) {
      final v = prefs.getDouble('hotel_rating_$id');
      if (v != null) _hotelRatings[id] = v;
    }

    if (!_hotelComments.containsKey(id)) {
      final v = prefs.getString('hotel_comment_$id');
      if (v != null) _hotelComments[id] = v;
    }
  }
}
