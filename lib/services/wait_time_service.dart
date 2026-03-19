import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WaitTimeReading {
  final int minutes;
  final DateTime? updatedAt;
  final bool? isOpen;
  final bool fromApi;

  const WaitTimeReading({
    required this.minutes,
    this.updatedAt,
    this.isOpen,
    this.fromApi = false,
  });

  int? minutesAgo({DateTime? now}) {
    if (updatedAt == null) return null;
    final n = now ?? DateTime.now();
    final diff = n.difference(updatedAt!);
    return diff.inMinutes < 0 ? 0 : diff.inMinutes;
  }

  bool isFresh({int maxAgeMinutes = 5, DateTime? now}) {
    final ago = minutesAgo(now: now);
    if (ago == null) return false;
    return ago <= maxAgeMinutes;
  }
}

class WaitTimeService {
  final FirebaseFirestore _db;

  WaitTimeService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

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

  /// Load the queue_times_map.json for a park
  Future<Map<String, int>> _loadQueueTimesMap(String parkId) async {
    try {
      final raw = await rootBundle.loadString(
          'assets/data/parks/$parkId/queue_times_map.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  /// Fetch all wait times from Queue-Times API and cache in Firestore
  Future<void> fetchAndCacheQueueTimes({
    required String parkId,
    required int queueTimesId,
  }) async {
    try {
      final map = await _loadQueueTimesMap(parkId);
      if (map.isEmpty) return;

      final url =
          'https://queue-times.com/parks/$queueTimesId/queue_times.json';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final lands = data['lands'] as List? ?? [];

      // Build a map of queueTimesRideId -> {wait_time, is_open}
      final rideData = <int, Map<String, dynamic>>{};
      for (final land in lands) {
        final rides = (land['rides'] as List?) ?? [];
        for (final ride in rides) {
          final id = (ride['id'] as num).toInt();
          rideData[id] = {
            'wait_time': (ride['wait_time'] as num?)?.toInt() ?? 0,
            'is_open': ride['is_open'] as bool? ?? false,
            'last_updated': ride['last_updated'],
          };
        }
      }

      // Write to Firestore for each mapped attraction
      final batch = _db.batch();
      map.forEach((attractionId, queueTimesRideId) {
        final ride = rideData[queueTimesRideId];
        if (ride == null) return;
        final ref = _docRef(parkId: parkId, attractionId: attractionId);
        batch.set(ref, {
          'minutes': ride['wait_time'],
          'isOpen': ride['is_open'],
          'fromApi': true,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
      await batch.commit();
    } catch (e) {
      debugPrint('QueueTimes fetch error: $e');
    }
  }

  /// Submit a user wait time
  Future<void> submitWaitTime({
    required String parkId,
    required String attractionId,
    required int minutes,
    bool insidePark = true,
  }) async {
    if (minutes <= 0) return;
    await _docRef(parkId: parkId, attractionId: attractionId).set({
      'minutes': minutes,
      'isOpen': true,
      'fromApi': false,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<WaitTimeReading?> streamLiveWaitReading({
    required String parkId,
    required String attractionId,
  }) {
    return _docRef(parkId: parkId, attractionId: attractionId)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return _parseReading(data);
    });
  }

  Future<WaitTimeReading?> getLatestWaitReading({
    required String parkId,
    required String attractionId,
  }) async {
    final snap =
        await _docRef(parkId: parkId, attractionId: attractionId).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return _parseReading(data);
  }

  Stream<int?> streamLiveWaitTime({
    required String parkId,
    required String attractionId,
  }) {
    return streamLiveWaitReading(
            parkId: parkId, attractionId: attractionId)
        .map((r) => r?.minutes);
  }

  Future<int?> getLatestWaitTime({
    required String parkId,
    required String attractionId,
  }) async {
    final r = await getLatestWaitReading(
        parkId: parkId, attractionId: attractionId);
    return r?.minutes;
  }

  WaitTimeReading? _parseReading(Map<String, dynamic> data) {
    final rawMinutes = data['minutes'];
    int? minutes;
    if (rawMinutes is int) minutes = rawMinutes;
    if (rawMinutes is num) minutes = rawMinutes.toInt();
    if (minutes == null) return null;

    DateTime? updatedAt;
    final rawUpdated = data['updatedAt'];
    if (rawUpdated is Timestamp) {
      updatedAt = rawUpdated.toDate();
    }

    final isOpen = data['isOpen'] as bool?;
    final fromApi = data['fromApi'] as bool? ?? false;

    return WaitTimeReading(
      minutes: minutes,
      updatedAt: updatedAt,
      isOpen: isOpen,
      fromApi: fromApi,
    );
  }
}