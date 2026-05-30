import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/features/logs/data/repositories/motor_log_repository.dart";

import "../../../../../core/error/app_exception.dart";

import "../state/motor_log_state.dart";

class MotorLogViewModel extends StateNotifier<MotorLogState> {
  final MotorLogRepository motorLogRepository;

  MotorLogViewModel({
    required this.motorLogRepository,
  }) : super(const MotorLogState());

  Future<void> loadLogs(String deviceId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final logs = await motorLogRepository.getLogs(deviceId: deviceId);

      state = state.copyWith(
        isLoading: false,
        logs: logs,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to load motor logs: ${e.toString()}",
      );
    }
  }

  Future<void> deleteLog(String logId) async {
    try {
      if (logId.trim().isEmpty) {
        state = state.copyWith(
          error: "Motor log ID missing",
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      await motorLogRepository.deleteLog(logId: logId);

      final logs = state.logs.where((log) => log.id != logId).toList();

      state = state.copyWith(
        isLoading: false,
        logs: logs,
        message: "Motor log deleted",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to delete motor log: ${e.toString()}",
      );
    }
  }

  Future<void> clearLogs(String deviceId) async {
    try {
      if (deviceId.trim().isEmpty) {
        state = state.copyWith(
          error: "Device ID missing",
          message: null,
        );
        return;
      }

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      await motorLogRepository.clearLogs(deviceId: deviceId);

      state = state.copyWith(
        isLoading: false,
        logs: [],
        message: "All motor logs cleared",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to clear motor logs: ${e.toString()}",
      );
    }
  }
}