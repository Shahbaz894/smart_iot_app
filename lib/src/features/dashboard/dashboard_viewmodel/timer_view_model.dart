import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/time_state.dart';
import 'package:smart_iot_app/src/features/dashboard/model/time_model.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/automation_repository.dart';
// import 'automation_state.dart';
// import 'timer_device_model.dart';

// class AutomationViewModel extends StateNotifier<AutomationState> {
//   AutomationViewModel() : super(AutomationState());
//
//   // Add a new timer
//   void addTimer(TimerDevice timer) {
//     state = state.copyWith(
//       timers: [...state.timers, timer],
//     );
//     _syncToFirebase();
//   }
//
//   // Toggle the switch (Active/Inactive)
//   void toggleTimer(String id) {
//     state = state.copyWith(
//       timers: [
//         for (final t in state.timers)
//           if (t.id == id)
//             TimerDevice(
//               id: t.id,
//               title: t.title,
//               startTime: t.startTime,
//               stopTime: t.stopTime,
//               espPin: t.espPin,
//               isEnabled: !t.isEnabled,
//             )
//           else
//             t,
//       ],
//     );
//     _syncToFirebase();
//   }
//
//   // Delete a timer
//   void deleteTimer(String id) {
//     state = state.copyWith(
//       timers: state.timers.where((t) => t.id != id).toList(),
//     );
//     _syncToFirebase();
//   }
//
//   // This is where you will eventually call your Firebase Repository
//   void _syncToFirebase() {
//     // print("Syncing ${state.timers.length} timers to Firebase...");
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/automation_repository.dart';
import '../model/time_model.dart';
import '../model/motor_status_model.dart';



class AutomationViewModel extends StateNotifier<AutomationState> {
  final AutomationRepository _repository;

  AutomationViewModel(this._repository)
      : super(
    // Initialize motorStatus with safe default values
    AutomationState(
      motorStatus: MotorStatus(
        inputVoltage: 0.0,
        outputVoltage: 0.0,
        current: 0.0,
        frequency: 0.0,
        running: false,
      ),
    ),
  ) {
    _listenMotorStatus();
  }

  /// ------------------------------
  /// Listen real-time Motor Status from Firebase
  /// ------------------------------
  void _listenMotorStatus() {
    _repository.motorStatusStream.listen((status) {
      // 'status' is already a MotorStatus from the repository stream
      // So we don't need to parse snapshot here
      state = state.copyWith(motorStatus: status);
    });
  }


  /// ------------------------------
  /// Add Timer
  /// ------------------------------
  void addTimer(TimerDevice timer) {
    state = state.copyWith(timers: [...state.timers, timer]);
    _syncToFirebase();
  }

  /// ------------------------------
  /// Toggle Timer
  /// ------------------------------
  void toggleTimer(String id) {
    state = state.copyWith(
      timers: state.timers
          .map((t) => t.id == id ? t.copyWith(isEnabled: !t.isEnabled) : t)
          .toList(),
    );
    _syncToFirebase();
  }

  /// ------------------------------
  /// Delete Timer
  /// ------------------------------
  void deleteTimer(String id) {
    state = state.copyWith(
      timers: state.timers.where((t) => t.id != id).toList(),
    );
    _syncToFirebase();
  }

  /// ------------------------------
  /// Manual Motor Control (only running)
  /// ------------------------------
  Future<void> setManualMode(bool value) async {
    await _repository.updateMotorStatus(running: value);
  }

  /// ------------------------------
  /// Update Motor Status (full update)
  /// ------------------------------
  Future<void> updateMotor({
    double? inputVoltage,
    double? outputVoltage,
    double? current,
    double? frequency,
    bool? running,
  }) async {
    await _repository.updateMotorStatus(
      inputVoltage: inputVoltage,
      outputVoltage: outputVoltage,
      current: current,
      frequency: frequency,
      running: running,
    );
  }

  /// ------------------------------
  /// Sync all timers to Firebase
  /// ------------------------------
  Future<void> _syncToFirebase() async {
    if (state.timers.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true);

      for (final timer in state.timers) {
        await _repository.saveDaySchedule(
          date: DateTime.now(),
          disabled: !timer.isEnabled,
          slots: [
            {'on': timer.startTime, 'off': timer.stopTime}
          ],
        );
      }
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// ------------------------------
  /// Clear all automation
  /// ------------------------------
  Future<void> clearAll() async {
    await _repository.clearAll();
    state = state.copyWith(timers: []);
  }
}


