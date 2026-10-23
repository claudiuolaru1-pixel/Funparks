// lib/models/closure_status.dart
//
// Optional "is this still open?" information for a park or an attraction.
// It is read from the extra fields that were added to the JSON data files:
//
//   status            open | limited_days | seasonal_closed |
//                     temporarily_closed | permanently_closed | notice
//   statusNote        short English explanation
//   statusFrom        first day the status applies (YYYY-MM-DD)
//   statusUntil       last day the status applies (YYYY-MM-DD)
//   statusAsOf        day the information was checked
//   statusSource      where it came from
//   statusConfidence  High | Med | Low
//   seasonNote        English text about winter / Christmas / season dates
//   closures          [{from, until, note}] windows when a park is closed
//
// Nothing here removes or hides an item. It only adds a label.

enum ClosureKind {
  permanentlyClosed,
  temporarilyClosed,
  seasonalClosed,
  limitedDays,
  scheduledClosure, // a closure that starts soon
  notice, // unconfirmed / check before visiting
}

class ClosureWindow {
  final DateTime from;
  final DateTime? until;
  final String? note;

  const ClosureWindow({required this.from, this.until, this.note});

  /// A window without an end date ("reopening date not announced yet") stops
  /// counting after this day, so a stale entry can never keep a park marked
  /// as closed for good. Every park reopens before this date.
  static final DateTime openEndedLimit = DateTime(2027, 5, 31);

  bool contains(DateTime today) {
    if (today.isBefore(from)) return false;
    final u = until ?? openEndedLimit;
    if (today.isAfter(u)) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
        'from': ClosureStatus.fmt(from),
        if (until != null) 'until': ClosureStatus.fmt(until!),
        if (note != null) 'note': note,
      };
}

class ClosureStatus {
  final String status;
  final String? note;
  final DateTime? from;
  final DateTime? until;
  final String? asOf;
  final String? source;
  final String? confidence;
  final String? seasonNote;
  final List<ClosureWindow> closures;

  const ClosureStatus({
    required this.status,
    this.note,
    this.from,
    this.until,
    this.asOf,
    this.source,
    this.confidence,
    this.seasonNote,
    this.closures = const [],
  });

  static String fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    final p = v.toString().split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  static String? _s(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// Returns null when the JSON object carries no status information at all.
  static ClosureStatus? tryParse(Map<String, dynamic> j) {
    final status = _s(j['status']);
    final seasonNote = _s(j['seasonNote']);
    final rawClosures = j['closures'];
    final closures = <ClosureWindow>[];
    if (rawClosures is List) {
      for (final c in rawClosures) {
        if (c is Map) {
          final f = _date(c['from']);
          if (f == null) continue;
          closures.add(ClosureWindow(
            from: f,
            until: _date(c['until']),
            note: _s(c['note']),
          ));
        }
      }
    }
    if (status == null && seasonNote == null && closures.isEmpty) return null;
    return ClosureStatus(
      status: status ?? 'open',
      note: _s(j['statusNote']),
      from: _date(j['statusFrom']),
      until: _date(j['statusUntil']),
      asOf: _s(j['statusAsOf']),
      source: _s(j['statusSource']),
      confidence: _s(j['statusConfidence']),
      seasonNote: seasonNote,
      closures: closures,
    );
  }

  /// Keeps the fields when an object is written back with toJson().
  Map<String, dynamic> toJson() => {
        'status': status,
        if (note != null) 'statusNote': note,
        if (from != null) 'statusFrom': fmt(from!),
        if (until != null) 'statusUntil': fmt(until!),
        if (asOf != null) 'statusAsOf': asOf,
        if (source != null) 'statusSource': source,
        if (confidence != null) 'statusConfidence': confidence,
        if (seasonNote != null) 'seasonNote': seasonNote,
        if (closures.isNotEmpty)
          'closures': closures.map((c) => c.toJson()).toList(),
      };

  static DateTime _day(DateTime now) => DateTime(now.year, now.month, now.day);

  bool _inRange(DateTime today) {
    final f = from;
    final u = until;
    if (f != null && today.isBefore(f)) return false;
    if (u != null && today.isAfter(u)) return false;
    return true;
  }

  /// How many days ahead a scheduled closure is announced.
  static const int announceDays = 45;

  /// The label that applies on [now], or null when nothing needs to be shown.
  ClosureKind? kindAt(DateTime now) {
    final today = _day(now);

    if (status == 'permanently_closed') return ClosureKind.permanentlyClosed;

    // A closure window of a park (for example Tivoli between Halloween and Christmas).
    for (final w in closures) {
      if (w.contains(today)) return ClosureKind.seasonalClosed;
    }

    if (_inRange(today)) {
      switch (status) {
        case 'temporarily_closed':
          return ClosureKind.temporarilyClosed;
        case 'seasonal_closed':
          return ClosureKind.seasonalClosed;
        case 'limited_days':
          return ClosureKind.limitedDays;
        case 'notice':
          return ClosureKind.notice;
      }
    }

    // Closure that has not started yet but is close.
    final soon = upcomingWindowAt(now);
    if (soon != null) return ClosureKind.scheduledClosure;
    return null;
  }

  /// First and last day to print for the current label.
  /// For an active window of a park this is the window; otherwise from/until.
  ClosureWindow? windowAt(DateTime now) {
    final today = _day(now);
    for (final w in closures) {
      if (w.contains(today)) return w;
    }
    if (_inRange(today) && (from != null || until != null)) {
      final f = from ?? today;
      return ClosureWindow(from: f, until: until);
    }
    return upcomingWindowAt(now);
  }

  /// A closure that begins within [announceDays] days.
  ClosureWindow? upcomingWindowAt(DateTime now) {
    final today = _day(now);
    final limit = today.add(const Duration(days: announceDays));
    for (final w in closures) {
      if (w.from.isAfter(today) && !w.from.isAfter(limit)) return w;
    }
    final f = from;
    if (status == 'temporarily_closed' &&
        f != null &&
        f.isAfter(today) &&
        !f.isAfter(limit)) {
      return ClosureWindow(from: f, until: until);
    }
    return null;
  }

  /// True when the item is closed right now (used to dim the card).
  bool isClosedAt(DateTime now) {
    final k = kindAt(now);
    return k == ClosureKind.permanentlyClosed ||
        k == ClosureKind.temporarilyClosed ||
        k == ClosureKind.seasonalClosed;
  }

  /// English note while it is still relevant.
  String? noteAt(DateTime now) {
    final today = _day(now);
    for (final w in closures) {
      if (w.contains(today) && w.note != null) return w.note;
    }
    if (note == null) return null;
    if (status == 'permanently_closed') return note;
    if (_inRange(today)) return note;
    return null;
  }
}
