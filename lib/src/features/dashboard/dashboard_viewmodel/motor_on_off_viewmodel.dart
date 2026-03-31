import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/core/exceptions/app_exception.dart';
import 'package:smart_iot_app/src/core/exceptions/app_error.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/motor_on_off_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/motor_on_off_repository.dart';



import 'dart:async';


class MotorOnOffViewModel extends StateNotifier<MotorOnOffState> {
  final MotorOnOffRepository repository;
  Timer? _timer; // Timer for updating live motor time

  MotorOnOffViewModel(this.repository) : super(MotorOnOffState.initial());

  // ---------------------------
  // START MOTOR
  // ---------------------------
  Future<void> startMotor(int deviceId) async {
    if (state.isLoading) return;

    // Optimistic UI update
    final now = DateTime.now();
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      data: state.data?.copyWith(
        isOn: true,
        startTime: now,
        message: "Starting motor...",
      ),
    );

    _startTimer(); // Start updating the live clock

    try {
      final response = await repository.startMotor(deviceId);

      // Use API message, keep local isOn/startTime
      state = state.copyWith(
        isLoading: false,
        data: state.data?.copyWith(
          isOn: true,
          startTime: now,
          message: response.message,
        ),
      );
    } on AppException catch (e) {
      _stopTimer();
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        data: state.data?.copyWith(isOn: false, startTime: null),
      );
    } catch (e) {
      _stopTimer();
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Unexpected error",
        data: state.data?.copyWith(isOn: false, startTime: null),
      );
    }
  }

  // ---------------------------
  // STOP MOTOR
  // ---------------------------
  Future<void> stopMotor(int deviceId) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      data: state.data?.copyWith(
        isOn: false,
        startTime: null,
        message: "Stopping motor...",
      ),
    );

    _stopTimer(); // Stop live clock

    try {
      final response = await repository.stopMotor(deviceId);

      state = state.copyWith(
        isLoading: false,
        data: state.data?.copyWith(
          isOn: false,
          startTime: null,
          message: response.message,
        ),
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
        data: state.data?.copyWith(isOn: true, startTime: DateTime.now()),
      );
      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Unexpected error",
        data: state.data?.copyWith(isOn: true, startTime: DateTime.now()),
      );
      _startTimer();
    }
  }

  // ---------------------------
  // LOCAL TOGGLE (UI ONLY)
  // ---------------------------
  void toggleLocally() {
    final current = state.data;
    if (current == null) return;

    if (!current.isOn) {
      _startTimer();
    } else {
      _stopTimer();
    }

    state = state.copyWith(
      data: current.copyWith(
        isOn: !current.isOn,
        startTime: !current.isOn ? DateTime.now() : null,
      ),
    );
  }

  // ---------------------------
  // TIMER HANDLERS
  // ---------------------------
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state.data;
      if (current != null && current.isOn && current.startTime != null) {
        state = state.copyWith(
          data: current.copyWith(
            startTime: current.startTime!.add(const Duration(seconds: 1)),
          ),
        );
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}