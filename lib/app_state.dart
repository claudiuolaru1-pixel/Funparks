import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/my_day_item.dart';

class AppState extends ChangeNotifier {

  // ---------------------------
  // Auth state
  // ---------------------------
  User? _user;
  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  String? get userEmail => _user?.email;

  // ---------------------------
  // Language & currency
  // ---------------------------
  String _languageCode = 'en';
  String _currencyCode = 'EUR';
  String get languageCode => _languageCode;
  String get currencyCode => _currencyCode;
  String get currency => _currencyCode;
  Locale get locale => Locale(_languageCode);
  Future<void> setLocale(Locale l) => setLanguageCode(l.languageCode);
  Future<void> setLanguage(String code) => setLanguageCode(code);
  Future<void> setCurrency(String code) => setCurrencyCode(code);

  Future<void> setLanguageCode(String code) async {
    await _ensureBootLoaded();
    if (code == _languageCode) return;
    _languageCode = code;
    await _prefsSetString(_kLang, code);
    notifyListeners();
  }

  Future<void> setCurrencyCode(String code) async {
    await _ensureBootLoaded();
    if (code == _currencyCode) return;
    _currencyCode = code;
    await _prefsSetString(_kCurrency, code);
    notifyListeners();
  }

  // ---------------------------
  // Favorite parks
  // ---------------------------
  final Set<String> _favoriteParkIds = {};

  Set<String> get favoriteParkIds {
    if (!_bootLoaded) _ensureBootLoaded().then((_) => notifyListeners());
    return _favoriteParkIds;
  }

  bool isParkFavorite(String parkId) => _favoriteParkIds.contains(parkId);

  Future<void> toggleParkFavorite(String parkId) async {
    await _ensureBootLoaded();
    if (_favoriteParkIds.contains(parkId)) {
      _favoriteParkIds.remove(parkId);
    } else {
      _favoriteParkIds.add(parkId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  // ---------------------------
  // Unified My Day
  // ---------------------------
  final List<MyDayItem> _myDayItems = [];
  List<MyDayItem> get myDayItems => List.unmodifiable(_myDayItems);
  int get myDayTotalCount => _myDayItems.length;
  int get myDayTotalMinutes =>
      _myDayItems.fold(0, (sum, i) => sum + i.estimatedMinutes);
  bool isInMyDayUnified(String id) => _myDayItems.any((i) => i.id == id);

  Future<void> addToMyDay(MyDayItem item) async {
    await _ensureBootLoaded();
    await _ensureMyDayLoaded();
    if (!_myDayItems.any((i) => i.id == item.id)) {
      _myDayItems.add(item);
      await _saveMyDayUnified();
      notifyListeners();
    }
  }

  Future<void> removeFromMyDay(String id) async {
    await _ensureBootLoaded();
    await _ensureMyDayLoaded();
    _myDayItems.removeWhere((i) => i.id == id);
    await _saveMyDayUnified();
    notifyListeners();
  }

  Future<void> updateMyDayItemMinutes(String id, int minutes) async {
    await _ensureBootLoaded();
    await _ensureMyDayLoaded();
    final idx = _myDayItems.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _myDayItems[idx].estimatedMinutes = minutes;
      await _saveMyDayUnified();
      notifyListeners();
    }
  }

  void reorderMyDay(List<MyDayItem> newOrder) {
    _myDayItems
      ..clear()
      ..addAll(newOrder);
    _saveMyDayUnified();
    notifyListeners();
  }

  // ---------------------------
  // Attraction notes
  // ---------------------------
  final Map<String, double> _attractionRatings = {};
  final Map<String, String> _attractionComments = {};
  final Map<String, int> _attractionMyWaitMinutes = {};

  double? ratingForAttraction(String id) => _attractionRatings[id];
  String? commentForAttraction(String id) => _attractionComments[id];
  int? myWaitFor(String id) => _attractionMyWaitMinutes[id];

  Future<void> setAttractionRating(String id, double rating) async {
    await ensureLoadedForAttraction(id);
    _attractionRatings[id] = rating;
    await _saveAttractionNotes();
    notifyListeners();
  }

  Future<void> setAttractionComment(String id, String comment) async {
    await ensureLoadedForAttraction(id);
    _attractionComments[id] = comment;
    await _saveAttractionNotes();
    notifyListeners();
  }

  Future<void> setMyWaitMinutes(String id, int? minutes) async {
    await ensureLoadedForAttraction(id);
    if (minutes == null) {
      _attractionMyWaitMinutes.remove(id);
    } else {
      _attractionMyWaitMinutes[id] = minutes;
    }
    await _saveAttractionNotes();
    notifyListeners();
  }

  // ---------------------------
  // Food notes
  // ---------------------------
  final Map<String, double> _foodRatings = {};
  final Map<String, String> _foodComments = {};

  double? ratingForFood(String id) => _foodRatings[id];
  String? commentForFood(String id) => _foodComments[id];

  Future<void> setFoodRating(String id, double rating) async {
    await ensureLoadedForFood(id);
    _foodRatings[id] = rating;
    await _saveFoodNotes();
    notifyListeners();
  }

  Future<void> setFoodComment(String id, String comment) async {
    await ensureLoadedForFood(id);
    _foodComments[id] = comment;
    await _saveFoodNotes();
    notifyListeners();
  }

  // ---------------------------
  // Legacy compatibility stubs
  // ---------------------------
  final Set<String> _myDayAttractionIds = {};
  final Set<String> _myFoodIds = {};
  final Set<String> _plannedHotelIds = {};

  int get myDayCount => _myDayAttractionIds.length;
  int get myFoodCount => _myFoodIds.length;
  bool isInMyDay(String id) => _myDayAttractionIds.contains(id);
  bool isInMyFood(String id) => _myFoodIds.contains(id);
  bool isHotelPlanned(String id) => _plannedHotelIds.contains(id);

  Future<void> toggleMyDayAttraction(String id) async {
    await ensureLoadedForAttraction(id);
    if (_myDayAttractionIds.contains(id)) {
      _myDayAttractionIds.remove(id);
    } else {
      _myDayAttractionIds.add(id);
    }
    notifyListeners();
  }

  Future<void> toggleMyFood(String id) async {
    await ensureLoadedForFood(id);
    if (_myFoodIds.contains(id)) {
      _myFoodIds.remove(id);
    } else {
      _myFoodIds.add(id);
    }
    notifyListeners();
  }

  Future<void> toggleHotelPlanned(String id) async {
    await _ensureBootLoaded();
    if (_plannedHotelIds.contains(id)) {
      _plannedHotelIds.remove(id);
    } else {
      _plannedHotelIds.add(id);
    }
    notifyListeners();
  }

  // ---------------------------
  // Boot / lazy load guards
  // ---------------------------
  bool _bootLoaded = false;
  bool _attractionLoaded = false;
  bool _foodLoaded = false;
  bool _myDayUnifiedLoaded = false;

  Future<void> _ensureBootLoaded() async {
    if (_bootLoaded) return;
    _bootLoaded = true;
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_kLang) ?? _languageCode;
    _currencyCode = prefs.getString(_kCurrency) ?? _currencyCode;
    final fav = prefs.getStringList(_kFavoriteParks) ?? [];
    _favoriteParkIds
      ..clear()
      ..addAll(fav.where((e) => e.trim().isNotEmpty));

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _user = user;
      if (user != null) {
        await _syncFromFirestore(user.uid);
      }
      notifyListeners();
    });
  }

  Future<void> _ensureMyDayLoaded() async {
    if (_myDayUnifiedLoaded) return;
    _myDayUnifiedLoaded = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMyDayUnified);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List;
        _myDayItems
          ..clear()
          ..addAll(decoded
              .map((e) => MyDayItem.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }
  }

  Future<void> ensureLoadedForAttraction(String _) async {
    await _ensureBootLoaded();
    if (_attractionLoaded) return;
    _attractionLoaded = true;
    final prefs = await SharedPreferences.getInstance();
    final notesRaw = prefs.getString(_kAttractionNotes);
    if (notesRaw != null && notesRaw.trim().isNotEmpty) {
      try {
        final decoded = json.decode(notesRaw);
        if (decoded is Map) {
          final r = decoded['ratings'];
          final c = decoded['comments'];
          final w = decoded['waits'];
          if (r is Map)
            _attractionRatings.addAll(
                r.map((k, v) => MapEntry(k.toString(), _toDouble(v))));
          if (c is Map)
            _attractionComments.addAll(c.map(
                (k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
          if (w is Map)
            _attractionMyWaitMinutes.addAll(
                w.map((k, v) => MapEntry(k.toString(), _toInt(v))));
        }
      } catch (_) {}
    }
  }

  Future<void> ensureLoadedForFood(String _) async {
    await _ensureBootLoaded();
    if (_foodLoaded) return;
    _foodLoaded = true;
    final prefs = await SharedPreferences.getInstance();
    final notesRaw = prefs.getString(_kFoodNotes);
    if (notesRaw != null && notesRaw.trim().isNotEmpty) {
      try {
        final decoded = json.decode(notesRaw);
        if (decoded is Map) {
          final r = decoded['ratings'];
          final c = decoded['comments'];
          if (r is Map)
            _foodRatings.addAll(
                r.map((k, v) => MapEntry(k.toString(), _toDouble(v))));
          if (c is Map)
            _foodComments.addAll(c.map(
                (k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
        }
      } catch (_) {}
    }
  }

  // ---------------------------
  // Firestore sync
  // ---------------------------
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Pull all user data from Firestore and overwrite local state.
  Future<void> _syncFromFirestore(String uid) async {
    try {
      final doc = await _userDoc(uid).get();
      if (!doc.exists) {
        // New user — push local data up
        await _pushToFirestore(uid);
        return;
      }
      final data = doc.data() as Map<String, dynamic>;

      // My Day
      final myDayRaw = data['my_day'];
      if (myDayRaw is List) {
        await _ensureMyDayLoaded();
        _myDayItems
          ..clear()
          ..addAll(myDayRaw.map((e) =>
              MyDayItem.fromJson(Map<String, dynamic>.from(e as Map))));
        await _saveMyDayUnified();
      }

      // Favorites
      final favsRaw = data['favorites'];
      if (favsRaw is List) {
        _favoriteParkIds
          ..clear()
          ..addAll(favsRaw.map((e) => e.toString()));
        await _saveFavorites();
      }

      // Attraction notes
      final attrRaw = data['attraction_notes'];
      if (attrRaw is Map) {
        final r = attrRaw['ratings'];
        final c = attrRaw['comments'];
        final w = attrRaw['waits'];
        if (r is Map)
          _attractionRatings.addAll(
              r.map((k, v) => MapEntry(k.toString(), _toDouble(v))));
        if (c is Map)
          _attractionComments.addAll(
              c.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
        if (w is Map)
          _attractionMyWaitMinutes.addAll(
              w.map((k, v) => MapEntry(k.toString(), _toInt(v))));
        await _saveAttractionNotes();
      }

      // Food notes
      final foodRaw = data['food_notes'];
      if (foodRaw is Map) {
        final r = foodRaw['ratings'];
        final c = foodRaw['comments'];
        if (r is Map)
          _foodRatings.addAll(
              r.map((k, v) => MapEntry(k.toString(), _toDouble(v))));
        if (c is Map)
          _foodComments.addAll(
              c.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
        await _saveFoodNotes();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Firestore sync error: $e');
    }
  }

  /// Push all local data up to Firestore.
  Future<void> _pushToFirestore(String uid) async {
    try {
      await _userDoc(uid).set({
        'my_day': _myDayItems.map((i) => i.toJson()).toList(),
        'favorites': _favoriteParkIds.toList(),
        'attraction_notes': {
          'ratings': _attractionRatings,
          'comments': _attractionComments,
          'waits': _attractionMyWaitMinutes,
        },
        'food_notes': {
          'ratings': _foodRatings,
          'comments': _foodComments,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore push error: $e');
    }
  }

  // ---------------------------
  // Save helpers (local + cloud)
  // ---------------------------
  Future<void> _saveMyDayUnified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kMyDayUnified,
        json.encode(_myDayItems.map((i) => i.toJson()).toList()));
    if (isLoggedIn) {
      await _userDoc(_user!.uid).set({
        'my_day': _myDayItems.map((i) => i.toJson()).toList(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _kFavoriteParks, _favoriteParkIds.toList()..sort());
    if (isLoggedIn) {
      await _userDoc(_user!.uid).set({
        'favorites': _favoriteParkIds.toList(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _saveAttractionNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kAttractionNotes,
        json.encode({
          'ratings': _attractionRatings,
          'comments': _attractionComments,
          'waits': _attractionMyWaitMinutes,
        }));
    if (isLoggedIn) {
      await _userDoc(_user!.uid).set({
        'attraction_notes': {
          'ratings': _attractionRatings,
          'comments': _attractionComments,
          'waits': _attractionMyWaitMinutes,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _saveFoodNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kFoodNotes,
        json.encode({
          'ratings': _foodRatings,
          'comments': _foodComments,
        }));
    if (isLoggedIn) {
      await _userDoc(_user!.uid).set({
        'food_notes': {
          'ratings': _foodRatings,
          'comments': _foodComments,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _prefsSetString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // ---------------------------
  // Sign out
  // ---------------------------
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  // ---------------------------
  // Utils
  // ---------------------------
  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  // ---------------------------
  // Pref keys
  // ---------------------------
  static const _kLang = 'pref.languageCode';
  static const _kCurrency = 'pref.currencyCode';
  static const _kAttractionNotes = 'notes.attractions.v1';
  static const _kFoodNotes = 'notes.food.v1';
  static const _kFavoriteParks = 'favorites.parks.v1';
  static const _kMyDayUnified = 'plan.myDay.unified.v1';
}