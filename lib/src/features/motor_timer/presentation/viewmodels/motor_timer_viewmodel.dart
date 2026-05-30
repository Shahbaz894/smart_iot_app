import "dart:async";

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";

import "../../data/repositories/motor_timer_repository.dart";

import "../state/motor_timer_state.dart";

class MotorTimerViewModel extends StateNotifier<MotorTimerState> {
  final MotorTimerRepository repository;

  Timer? _ticker;

  bool _autoStopInProgress = false;

  MotorTimerViewModel({
    required this.repository,
  }) : super(const MotorTimerState());

  // =========================================================
  // DURATION
  // =========================================================

  void setDuration({
    required int hours,
    required int minutes,
  }) {
    if (state.isRunning) {
      state = state.copyWith(
        error: "Timer already running",
      );
      return;
    }

    final totalMinutes = ((hours * 60) + minutes).clamp(0, 24 * 60);

    state = state.copyWith(
      selectedHours: totalMinutes ~/ 60,
      selectedMinutes: totalMinutes % 60,
      totalSeconds: totalMinutes * 60,
      remainingSeconds: 0,
      error: null,
    );
  }

  void addMinutes(int minutes) {
    final next =
    (state.selectedTotalMinutes + minutes).clamp(0, 24 * 60);

    setDuration(
      hours: next ~/ 60,
      minutes: next % 60,
    );
  }

  void setQuickDuration(int totalMinutes) {
    final value = totalMinutes.clamp(1, 24 * 60);

    setDuration(
      hours: value ~/ 60,
      minutes: value % 60,
    );
  }

  // =========================================================
  // START TIMER
  // =========================================================

  Future<void> startTimer({
    required String deviceId,
    String? customerName,
  }) async {
    try {
      final cleanDeviceId = deviceId.trim();

      if (cleanDeviceId.isEmpty) {
        throw AppException(
          message: "Device ID missing",
        );
      }

      if (state.isRunning) {
        throw AppException(
          message: "Timer already running",
        );
      }

      if (!state.hasValidDuration) {
        throw AppException(
          message: "Please select timer duration",
        );
      }

      final durationMinutes = state.selectedTotalMinutes;

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final response = await repository.startTimer(
        deviceId: cleanDeviceId,
        durationMinutes: durationMinutes,
        customerName: customerName,
      );

      final totalSeconds = durationMinutes * 60;

      final now = DateTime.now();

      final stopAt = now.add(
        Duration(seconds: totalSeconds),
      );

      _ticker?.cancel();

      _autoStopInProgress = false;

      state = state.copyWith(
        isLoading: false,
        isRunning: true,
        isStopping: false,
        deviceId: cleanDeviceId,
        customerName: customerName,
        totalSeconds: totalSeconds,
        remainingSeconds: totalSeconds,
        startedAt: now,
        expectedStopAt: stopAt,
        error: null,
        message: response["message"] ?? "Timer started",
      );

      _startTicker();
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // =========================================================
  // TICKER
  // =========================================================

  void _startTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        final stopAt = state.expectedStopAt;

        if (stopAt == null || !state.isRunning) {
          return;
        }

        final remaining =
            stopAt.difference(DateTime.now()).inSeconds;

        if (remaining <= 0) {
          state = state.copyWith(
            remainingSeconds: 0,
          );

          if (!_autoStopInProgress) {
            _autoStopInProgress = true;

            stopNow();
          }

          return;
        }

        state = state.copyWith(
          remainingSeconds: remaining,
        );
      },
    );
  }

  // =========================================================
  // STOP
  // =========================================================

  Future<void> stopNow() async {
    try {
      final deviceId = state.deviceId;

      if (deviceId == null) {
        throw AppException(
          message: "No active timer",
        );
      }

      state = state.copyWith(
        isStopping: true,
        isLoading: true,
      );

      await repository.stopTimer(
        deviceId: deviceId,
      );

      _ticker?.cancel();

      _autoStopInProgress = false;

      state = state.copyWith(
        isLoading: false,
        isStopping: false,
        isRunning: false,
        remainingSeconds: 0,
        deviceId: null,
        customerName: null,
        startedAt: null,
        expectedStopAt: null,
        message: "Motor stopped",
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isStopping: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isStopping: false,
        error: e.toString(),
      );
    }
  }

  // =========================================================
  // RESET
  // =========================================================

  void resetSelection() {
    if (state.isRunning) {
      state = state.copyWith(
        error: "Stop timer first",
      );

      return;
    }

    state = const MotorTimerState();
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}