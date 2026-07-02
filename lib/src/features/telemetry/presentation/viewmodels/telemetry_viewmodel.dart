import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/repositories/telemetry_repository.dart";
import "../../data/models/telemetry_model.dart";
import "../state/telemetry_state.dart";

class TelemetryViewModel extends StateNotifier<TelemetryState> {
  final TelemetryRepository telemetryRepository;


  // Polling State
  Timer? _pollingTimer;
  String? _activeDeviceId;
  bool _latestRequestRunning = false;

  TelemetryViewModel({required this.telemetryRepository}) : super(const TelemetryState());

  // ============================================================================
  // POLLING-BASED LIVE UPDATES
  // ============================================================================

  /// Call this when the Dashboard opens to start the polling loop.
  void startLiveStream(String deviceId) {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return;

    _activeDeviceId = safeDeviceId;

    // Initial fetch
    _pollTelemetry();

    // Setup interval (3 seconds is standard industry practice for IoT status)
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollTelemetry());
  }

  // Future<void> _pollTelemetry() async {
  //   if (_activeDeviceId == null || _latestRequestRunning) {
  //     return;
  //   }
  //
  //   _latestRequestRunning = true;
  //
  //   try {
  //     final latest = await telemetryRepository.getLatest(
  //       deviceId: _activeDeviceId!,
  //     );
  //
  //     if (latest == null) {
  //       return;
  //     }
  //
  //     debugPrint(
  //       "LIVE TELEMETRY => "
  //           "status=${latest.statusCode} "
  //           "live=${latest.isLive} "
  //           "current=${latest.current}",
  //     );
  //
  //     state = state.copyWith(
  //       latest: latest,
  //       isLoading: false,
  //       clearError: true,
  //     );
  //   } catch (e, stackTrace) {
  //     debugPrint(
  //       "Polling telemetry failed: $e",
  //     );
  //
  //     debugPrintStack(
  //       stackTrace: stackTrace,
  //     );
  //   } finally {
  //     _latestRequestRunning = false;
  //   }
  // }

  // ============================================================================
  // EXISTING METHODS (Preserved)
  // ============================================================================
  // TelemetryViewModel mein update karein:
  Future<void> _pollTelemetry() async {
    if (_activeDeviceId == null || _latestRequestRunning) return;
    _latestRequestRunning = true;
    try {
      final latest = await telemetryRepository.getLatest(deviceId: _activeDeviceId!);

      // Yahan Debug karein
      if (latest == null) {
        debugPrint("⚠️ POLLING WARNING: Backend returned null for device $_activeDeviceId");
        return;
      }

      state = state.copyWith(latest: latest, isLoading: false, clearError: true);
    } catch (e) {
      debugPrint("❌ POLLING ERROR: $e");
    } finally {
      _latestRequestRunning = false;
    }
  }

  Future<void> loadLatest(String deviceId, {bool showLoading = true}) async {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return;


    try {
      if (showLoading && state.latest == null) {
        state = state.copyWith(isLoading: true, clearError: true);
      }
      final latest = await telemetryRepository.getLatest(deviceId: safeDeviceId);

      if (latest != null) {
        state = state.copyWith(latest: latest, isLoading: false, clearError: true);
      }
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadAll(String deviceId) async {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final records = await telemetryRepository.getAll(deviceId: safeDeviceId);
      state = state.copyWith(isLoading: false, records: records, clearError: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to load history");
    }
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  void closeStream() {
    _activeDeviceId = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    closeStream();
    super.dispose();
  }
}