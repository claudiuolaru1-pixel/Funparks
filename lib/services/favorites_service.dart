import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static const _key = 'favorite_parks';
  final Set<String> _ids = {};

  bool _loaded = false;

  bool get loaded => _loaded;

  bool isFavorite(String parkId) => _ids.contains(parkId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    _ids
      ..clear()
      ..addAll(list);
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String parkId) async {
    if (_ids.contains(parkId)) {
      _ids.remove(parkId);
    } else {
      _ids.add(parkId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
    notifyListeners();
  }
}
