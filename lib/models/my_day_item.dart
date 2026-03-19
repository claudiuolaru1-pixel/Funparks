// lib/models/my_day_item.dart
enum MyDayItemType { attraction, restaurant, hotel }

class MyDayItem {
  final String id;
  final String name;
  final MyDayItemType type;
  int estimatedMinutes;

  MyDayItem({
    required this.id,
    required this.name,
    required this.type,
    required this.estimatedMinutes,
  });

  static int defaultMinutes(MyDayItemType t) {
    switch (t) {
      case MyDayItemType.attraction: return 45;
      case MyDayItemType.restaurant: return 60;
      case MyDayItemType.hotel: return 30;
    }
  }

  static MyDayItemType typeFromString(String s) {
    switch (s) {
      case 'restaurant': return MyDayItemType.restaurant;
      case 'hotel': return MyDayItemType.hotel;
      default: return MyDayItemType.attraction;
    }
  }

  static String typeToString(MyDayItemType t) {
    switch (t) {
      case MyDayItemType.attraction: return 'attraction';
      case MyDayItemType.restaurant: return 'restaurant';
      case MyDayItemType.hotel: return 'hotel';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': typeToString(type),
    'estimatedMinutes': estimatedMinutes,
  };

  factory MyDayItem.fromJson(Map<String, dynamic> j) => MyDayItem(
    id: j['id'] as String,
    name: j['name'] as String,
    type: typeFromString(j['type'] as String? ?? 'attraction'),
    estimatedMinutes: j['estimatedMinutes'] as int? ?? 45,
  );
}