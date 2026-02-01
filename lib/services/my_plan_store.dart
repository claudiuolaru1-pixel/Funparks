import 'package:shared_preferences/shared_preferences.dart';

class MyPlanStore {
  static const _kMyDay = 'myday_attraction_ids';
  static const _kMyFood = 'myfood_place_ids';

  static Future<Set<String>> loadMyDay() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_kMyDay) ?? const []).toSet();
  }

  static Future<Set<String>> loadMyFood() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_kMyFood) ?? const []).toSet();
  }

  static Future<void> toggleMyDay(String id) async {
    final p = await SharedPreferences.getInstance();
    final set = (p.getStringList(_kMyDay) ?? const []).toSet();
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await p.setStringList(_kMyDay, set.toList());
  }

  static Future<void> toggleMyFood(String id) async {
    final p = await SharedPreferences.getInstance();
    final set = (p.getStringList(_kMyFood) ?? const []).toSet();
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await p.setStringList(_kMyFood, set.toList());
  }
}
