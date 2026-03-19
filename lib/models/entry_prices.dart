class EntryPrices {
  final double adult;
  final double child;

  const EntryPrices({
    required this.adult,
    required this.child,
  });

  factory EntryPrices.fromJson(Map<String, dynamic> json) {
    final adult = json['adult'];
    final child = json['child'];

    if (adult == null || child == null) {
      throw FormatException('EntryPrices requires adult and child.');
    }

    return EntryPrices(
      adult: (adult as num).toDouble(),
      child: (child as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'adult': adult,
        'child': child,
      };
}