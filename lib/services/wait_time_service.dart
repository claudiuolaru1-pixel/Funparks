import 'package:cloud_firestore/cloud_firestore.dart';

/// Premium wait time reading (live + metadata)
class WaitTimeReading {
  final int minutes;
  final DateTime? updatedAt;
  final bool? insidePark;

  const WaitTimeReading({
    required this.minutes,
    this.updatedAt,
    this.insidePark,
  });

  int? minutesAgo({DateTime? now}) {
    if (updatedAt == null) return null;
    final n = now ?? DateTime.now();
    final diff = n.difference(updatedAt!);
    return diff.inMinutes < 0 ? 0 : diff.inMinutes;
  }

  bool isFresh({int maxAgeMinutes = 20, DateTime? now}) {
    final ago = minutesAgo(now: now);
    if (ago == null) return false;
    return ago <= maxAgeMinutes;
  }
}

class WaitTimeService {
  final FirebaseFirestore _db;

  WaitTimeService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  /// parks/{parkId}/wait_times/{attractionId}
  DocumentReference<Map<String, dynamic>> _docRef({
    required String parkId,
    required String attractionId,
  }) {
    return _db
        .collection('parks')
        .doc(parkId)
        .collection('wait_times')
        .doc(attractionId);
  }

  /// Submit a wait time (updates the "latest" doc).
  Future<void> submitWaitTime({
    required String parkId,
    required String attractionId,
    required int minutes,
    bool insidePark = true,
  }) async {
    // Keep your original rule:
    // - If you want to allow "0 min", change this to: if (minutes < 0) return;
    if (minutes <= 0) return;

    final ref = _docRef(parkId: parkId, attractionId: attractionId);

    await ref.set(
      {
        'minutes': minutes,
        'insidePark': insidePark,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ---------------------------
  // BASIC methods (minutes only)
  // ---------------------------

  Future<int?> getLatestWaitTime({
    required String parkId,
    required String attractionId,
  }) async {
    final reading = await getLatestWaitReading(
      parkId: parkId,
      attractionId: attractionId,
    );
    return reading?.minutes;
  }

  Stream<int?> streamLiveWaitTime({
    required String parkId,
    required String attractionId,
  }) {
    return streamLiveWaitReading(
      parkId: parkId,
      attractionId: attractionId,
    ).map((r) => r?.minutes);
  }

  // ---------------------------
  // PREMIUM methods (minutes + updatedAt + insidePark)
  // ---------------------------

  Future<WaitTimeReading?> getLatestWaitReading({
    required String parkId,
    required String attractionId,
  }) async {
    final snap = await _docRef(
      parkId: parkId,
      attractionId: attractionId,
    ).get();

    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;

    return _parseReading(data);
  }

  Stream<WaitTimeReading?> streamLiveWaitReading({
    required String parkId,
    required String attractionId,
  }) {
    return _docRef(
      parkId: parkId,
      attractionId: attractionId,
    ).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return _parseReading(data);
    });
  }

  WaitTimeReading? _parseReading(Map<String, dynamic> data) {
    final rawMinutes = data['minutes'];
    int? minutes;

    if (rawMinutes is int) minutes = rawMinutes;
    if (rawMinutes is num) minutes = rawMinutes.toInt();

    if (minutes == null || minutes <= 0) return null;

    DateTime? updatedAt;
    final rawUpdated = data['updatedAt'];
    if (rawUpdated is Timestamp) {
      updatedAt = rawUpdated.toDate();
    } else if (rawUpdated is DateTime) {
      updatedAt = rawUpdated;
    }

    bool? insidePark;
    final rawInside = data['insidePark'];
    if (rawInside is bool) insidePark = rawInside;

    return WaitTimeReading(
      minutes: minutes,
      updatedAt: updatedAt,
      insidePark: insidePark,
    );
  }
}
