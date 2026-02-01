// lib/services/live_wait_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'wait_time_service.dart';

class LiveWaitRepository {
  LiveWaitRepository({WaitTimeService? service}) : _service = service ?? WaitTimeService();

  final WaitTimeService _service;

  /// Stream latest live wait.
  /// Returns null if Firebase isn't ready or data doesn't exist.
  Stream<int?> streamLiveWait({
    required String parkId,
    required String attractionId,
  }) async* {
    try {
      yield* _service.streamLiveWaitTime(
        parkId: parkId,
        attractionId: attractionId,
      );
    } catch (e) {
      debugPrint('LiveWaitRepository.streamLiveWait error: $e');
      yield null;
    }
  }

  /// One-shot fetch
  Future<int?> getLatestWait({
    required String parkId,
    required String attractionId,
  }) async {
    try {
      return await _service.getLatestWaitTime(
        parkId: parkId,
        attractionId: attractionId,
      );
    } catch (e) {
      debugPrint('LiveWaitRepository.getLatestWait error: $e');
      return null;
    }
  }

  /// Submit a wait time (Premium crowd-sourced)
  Future<void> submitWait({
    required String parkId,
    required String attractionId,
    required int minutes,
  }) async {
    try {
      await _service.submitWaitTime(
        parkId: parkId,
        attractionId: attractionId,
        minutes: minutes,
        insidePark: true,
      );
    } catch (e) {
      debugPrint('LiveWaitRepository.submitWait error: $e');
    }
  }
}
