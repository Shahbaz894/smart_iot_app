import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/time_state.dart';
import 'package:smart_iot_app/src/features/dashboard/model/time_model.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/automation_repository.dart';

import '../model/motor_status_model.dart';







class AutomationViewModel extends StateNotifier<AutomationState> {
  final AutomationRepository _repository;

  AutomationViewModel(this._repository)
      : super(AutomationState(
    motorStatus: MotorStatus(
      inputVoltage: 0,
      outputVoltage: 0,
      current: 0,
      frequency: 0,
      running: false,
    ),
    schedules: {},
    isLoading: false,
  )) {
    _listenMotorStatus();
    _listenSchedules();
  }

  /// ------------------------------
  /// LISTEN MOTOR STATUS
  /// ------------------------------
  void _listenMotorStatus() {
    _repository.motorStatusStream.listen((motor) {
      state = state.copyWith(motorStatus: motor);
    });
  }

  /// ------------------------------
  /// LISTEN DAY-WISE SCHEDULES
  /// ------------------------------
  void _listenSchedules() {
    _repository.schedulesStream.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final Map<int, List<TimerDevice>> schedules = {};

      data.forEach((dayKey, dayData) {
        final dayInt = int.tryParse(dayKey.toString().replaceAll("day_", "")) ?? 0;
        final slotsMap = dayData['slots'] as Map<dynamic, dynamic>? ?? {};
        final List<TimerDevice> slots = [];

        slotsMap.forEach((slotId, slotData) {
          slots.add(TimerDevice.fromMap(slotId, {
            'title': slotData['title'],
            'day': dayInt,
            'startHour': slotData['on']['hour'],
            'startMinute': slotData['on']['minute'],
            'stopHour': slotData['off']['hour'],
            'stopMinute': slotData['off']['minute'],
            'gpio': slotData['pin'],
            'active': slotData['active'] ?? true,
          }));
        });

        schedules[dayInt] = slots;
      });

      state = state.copyWith(schedules: schedules);
    });
  }

  /// ------------------------------
  /// TURN MOTOR ON/OFF
  /// ------------------------------
  Future<void> setMotorOnOff(bool value) async {
    await _repository.updateMotorStatus(running: value);
    state = state.copyWith(
      motorStatus: state.motorStatus.copyWith(running: value),
    );
  }

  /// ------------------------------
  /// UPDATE MOTOR PARAMETERS
  /// ------------------------------
  Future<void> updateMotor({
    double? inputVoltage,
    double? outputVoltage,
    double? current,
    double? frequency,
  }) async {
    await _repository.updateMotorStatus(
      inputVoltage: inputVoltage,
      outputVoltage: outputVoltage,
      current: current,
      frequency: frequency,
    );
  }

  /// ------------------------------
  /// ADD TIMER (DAY & TIME SLOT)
  /// ------------------------------
  Future<void> addTimer(TimerDevice newTimer) async {
    final schedules = Map<int, List<TimerDevice>>.from(state.schedules);
    final day = newTimer.day; // make sure TimerDevice has int day;

    if (!schedules.containsKey(day)) {
      schedules[day] = [];
    }

    schedules[day]!.add(newTimer);

    // Prepare slots in Firebase format
    final slots = schedules[day]!.map((t) => {
      'on': {'hour': t.startTime.hour, 'minute': t.startTime.minute},
      'off': {'hour': t.stopTime.hour, 'minute': t.stopTime.minute},
      'pin': t.espPin,
      'active': t.isEnabled,
      'title': t.title,
    }).toList();

    // Save to Firebase
    await _repository.saveDaySchedule(day: day, slots: slots);

    state = state.copyWith(schedules: schedules);
  }

  /// ------------------------------
  /// CLEAR ALL SCHEDULES
  /// ------------------------------
  Future<void> clearAll() async {
    state = state.copyWith(isLoading: true);

    await _repository.clearAllSchedules();

    state = state.copyWith(
      schedules: {},
      isLoading: false,
    );
  }

  /// ------------------------------
  /// SET MANUAL MODE (ON/OFF)
  /// ------------------------------
  Future<void> setManualMode(bool val) async {
    await _repository.updateMotorStatus(running: val);

    state = state.copyWith(
      motorStatus: state.motorStatus.copyWith(running: val),
    );
  }
}
