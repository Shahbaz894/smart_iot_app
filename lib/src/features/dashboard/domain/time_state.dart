import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/features/dashboard/model/motor_status_model.dart';
import 'package:smart_iot_app/src/features/dashboard/model/time_model.dart';




// class AutomationState {
//   final List<TimerDevice> timers;
//   final bool isLoading;
//
//   // Add motorStatus field
//   final MotorStatus motorStatus;
//
//   AutomationState({
//     this.timers = const [],
//     this.isLoading = false,
//     MotorStatus? motorStatus,
//   }) : motorStatus = motorStatus ??
//       MotorStatus(
//         inputVoltage: 0.0,
//         outputVoltage: 0.0,
//         current: 0.0,
//         frequency: 0.0,
//         running: false,
//       );
//
//   AutomationState copyWith({
//     List<TimerDevice>? timers,
//     bool? isLoading,
//     MotorStatus? motorStatus,
//   }) {
//     return AutomationState(
//       timers: timers ?? this.timers,
//       isLoading: isLoading ?? this.isLoading,
//       motorStatus: motorStatus ?? this.motorStatus,
//     );
//   }
// }
// class AutomationState {
//   final MotorStatus motorStatus;
//   final bool isLoading;
//
//   AutomationState({required this.motorStatus, this.isLoading = false});
//
//   AutomationState copyWith({MotorStatus? motorStatus, bool? isLoading}) {
//     return AutomationState(
//       motorStatus: motorStatus ?? this.motorStatus,
//       isLoading: isLoading ?? this.isLoading,
//     );
//   }
// }
import 'package:flutter/foundation.dart';


class AutomationState {
  final MotorStatus motorStatus;
  final Map<int, List<TimerDevice>> schedules; // day-wise schedules
  final bool isLoading;

  AutomationState({
    required this.motorStatus,
    this.schedules = const {},
    this.isLoading = false,
  });

  AutomationState copyWith({
    MotorStatus? motorStatus,
    Map<int, List<TimerDevice>>? schedules,
    bool? isLoading,
  }) {
    return AutomationState(
      motorStatus: motorStatus ?? this.motorStatus,
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}