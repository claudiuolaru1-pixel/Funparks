import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class ActiveWaitAlert {
  final String parkId;
  final String attractionId;
  final String attractionName;
  final int thresholdMinutes;
  final bool fired;

  const ActiveWaitAlert({
    required this.parkId,
    required this.attractionId,
    required this.attractionName,
    required this.thresholdMinutes,
    required this.fired,
  });

  factory ActiveWaitAlert.fromMap(Map<String, dynamic> map) {
    return ActiveWaitAlert(
      parkId: map['parkId'] as String? ?? '',
      attractionId: map['attractionId'] as String? ?? '',
      attractionName: map['attractionName'] as String? ?? '',
      thresholdMinutes: (map['thresholdMinutes'] as num?)?.toInt() ?? 0,
      fired: map['fired'] as bool? ?? false,
    );
  }
}

class WaitAlertService {
  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;

  WaitAlertService({FirebaseFirestore? db, FirebaseMessaging? messaging})
      : _db = db ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Request notification permission from the OS. Call this once,
  /// e.g. the first time a user taps a bell icon.
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Set (or replace) the user's single active wait alert.
  /// Returns false if the user isn't signed in or on an unsupported platform.
  Future<bool> setAlert({
    required String parkId,
    required String attractionId,
    required String attractionName,
    required int thresholdMinutes,
  }) async {
    if (Platform.isIOS) return false; // Firestore not available on iOS 26
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final granted = await requestPermission();
    if (!granted) return false;

    final token = await _messaging.getToken();
    if (token == null) return false;

    try {
      await _userDoc(user.uid).set({
        'activeWaitAlert': {
          'parkId': parkId,
          'attractionId': attractionId,
          'attractionName': attractionName,
          'thresholdMinutes': thresholdMinutes,
          'fcmToken': token,
          'fired': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('WaitAlertService.setAlert error: $e');
      return false;
    }
  }

  /// Clear the user's active alert (e.g. they cancel it manually).
  Future<void> clearAlert() async {
    if (Platform.isIOS) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _userDoc(user.uid).update({
        'activeWaitAlert': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('WaitAlertService.clearAlert error: $e');
    }
  }

  /// Stream the current user's active alert, or null if none/not signed in.
  Stream<ActiveWaitAlert?> streamActiveAlert() {
    final user = FirebaseAuth.instance.currentUser;
    if (Platform.isIOS || user == null) {
      return Stream.value(null);
    }
    return _userDoc(user.uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      final raw = data['activeWaitAlert'];
      if (raw == null) return null;
      return ActiveWaitAlert.fromMap(Map<String, dynamic>.from(raw as Map));
    });
  }

  /// Convenience check: is there an active (not-yet-fired) alert for this
  /// specific attraction?
  Stream<bool> isAlertActiveFor({
    required String parkId,
    required String attractionId,
  }) {
    return streamActiveAlert().map((alert) {
      if (alert == null || alert.fired) return false;
      return alert.parkId == parkId && alert.attractionId == attractionId;
    });
  }
}