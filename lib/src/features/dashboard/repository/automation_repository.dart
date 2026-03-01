import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_iot_app/src/features/dashboard/services/automation_firebase_service.dart';



import '../model/motor_status_model.dart';

class AutomationRepository {
  final AutomationFirebaseService _service;

  AutomationRepository(this._service);

  /// Save one full day schedule
  Future<void> saveDaySchedule({
    required DateTime date,
    required bool disabled,
    required List<Map<String, TimeOfDay>> slots,
  }) async {
    final dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    Map<String, dynamic> data = {
      "disabled": disabled,
    };

    if (!disabled) {
      Map<String, dynamic> slotMap = {};

      for (int i = 0; i < slots.length; i++) {
        slotMap["slot${i + 1}"] = {
          "startHour": slots[i]['on']!.hour,
          "startMinute": slots[i]['on']!.minute,
          "stopHour": slots[i]['off']!.hour,
          "stopMinute": slots[i]['off']!.minute,
        };
      }

      data["slots"] = slotMap;
    }

    await _service.saveScheduleForDate(dateKey, data);
  }

  /// Delete one day schedule
  Future<void> deleteDaySchedule(DateTime date) async {
    final dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    await _service.deleteScheduleForDate(dateKey);
  }

  /// Clear all schedules
  Future<void> clearAll() async {
    await _service.clearAllAutomation();
  }

  /// Listen full automation
  Stream<DatabaseEvent> get automationStream => _service.automationStream;

  /// Listen motor status
  // Stream<DatabaseEvent> get motorStatusStream => _service.motorStatusStream;

  /// Manual motor control (update all parameters or just running)
  // Future<void> updateMotorStatus({
  //   double? inputVoltage,
  //   double? outputVoltage,
  //   double? current,
  //   double? frequency,
  //   bool? running,
  // }) async {
  //   // Fetch current motor status first to avoid overwriting nulls
  //   final event = await _service.motorStatusStream.first;
  //   final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
  //
  //   await _service.updateMotorState(
  //     inputVoltage: inputVoltage ?? (data['input_voltage']?.toDouble() ?? 0.0),
  //     outputVoltage: outputVoltage ?? (data['output_voltage']?.toDouble() ?? 0.0),
  //     current: current ?? (data['current']?.toDouble() ?? 0.0),
  //     frequency: frequency ?? (data['frequency']?.toDouble() ?? 0.0),
  //     running: running ?? (data['running'] ?? false),
  //   );
  // }

  Stream<MotorStatus> get motorStatusStream =>
      _service.motorStatusStream.map((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        // MotorStatus.fromMap handles null internally
        return MotorStatus.fromMap(data);
      });

  Future<void> updateMotorStatus({
    double? inputVoltage,
    double? outputVoltage,
    double? current,
    double? frequency,
    bool? running,
  }) async {
    // Fetch current data safely
    final event = await _service.motorStatusStream.first;
    final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

    await _service.updateMotorState(
      inputVoltage: inputVoltage ?? (data['input_voltage']?.toDouble() ?? 0.0),
      outputVoltage: outputVoltage ?? (data['output_voltage']?.toDouble() ?? 0.0),
      current: current ?? (data['current']?.toDouble() ?? 0.0),
      frequency: frequency ?? (data['frequency']?.toDouble() ?? 0.0),
      running: running ?? (data['running'] ?? false),
    );
  }
}
