import "package:flutter/cupertino.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/repositories/telemetry_repository.dart";
import "../state/telemetry_state.dart";

class TelemetryViewModel extends StateNotifier<TelemetryState> {
  final TelemetryRepository telemetryRepository;

  bool _latestRequestRunning = false;

  TelemetryViewModel({
    required this.telemetryRepository,
  }) : super(const TelemetryState());

  Future<void> loadLatest(
      String deviceId, {
        bool showLoading = true,
      }) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) return;

    if (_latestRequestRunning) return;
    _latestRequestRunning = true;

    final oldLatest = state.latest;
    final isSilentRefresh = showLoading == false;

    try {
      // Only show full loading on first load when no previous data exists.
      if (showLoading && oldLatest == null) {
        state = state.copyWith(
          isLoading: true,
          isRefreshing: false,
          clearError: true,
        );
      }

      // IMPORTANT:
      // For auto refresh, do NOT set isRefreshing=true.
      // This keeps the UI stable and prevents black flash / refresh indicator.
      final latest = await telemetryRepository.getLatest(
        deviceId: safeDeviceId,
      );

      // If API returns null during refresh, keep old data on screen.
      final newLatest = latest ?? oldLatest;

      // If data did not change and this was silent refresh, do not notify UI.
      if (isSilentRefresh && newLatest == oldLatest) {
        return;
      }

      state = state.copyWith(
        latest: newLatest,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      );

      debugPrint("Telemetry updated: ${newLatest?.timestamp}");
    } on AppException catch (e) {
      if (isSilentRefresh) {
        // Silent refresh should not disturb UI.
        // Keep old values and let screen decide whether to count failure.
        rethrow;
      }

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.message,
      );
    } catch (_) {
      if (isSilentRefresh) {
        rethrow;
      }

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: "Failed to load telemetry",
      );
    } finally {
      _latestRequestRunning = false;
    }
  }

  Future<void> loadAll(String deviceId) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) return;

    try {
      state = state.copyWith(
        isLoading: true,
        clearError: true,
      );

      final records = await telemetryRepository.getAll(
        deviceId: safeDeviceId,
      );

      state = state.copyWith(
        isLoading: false,
        records: records,
        clearError: true,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to load telemetry records",
      );
    }
  }
}