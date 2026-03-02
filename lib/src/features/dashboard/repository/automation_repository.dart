


import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_iot_app/src/features/dashboard/services/automation_firebase_service.dart';
import '../model/motor_model.dart';

import '../services/automation_firebase_service.dart';
import '../model/motor_status_model.dart';



class AutomationRepository {
  final AutomationFirebaseService _service;

  AutomationRepository(this._service);

  /// ------------------------------
  /// Motor Status Stream (Realtime)
  /// ------------------------------
  Stream<MotorStatus> get motorStatusStream =>
      _service.motorStatusStream.map((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
        return MotorStatus.fromMap(data);
      });

  /// ------------------------------
  /// Schedules Stream (Realtime)
  /// ------------------------------
  Stream<DatabaseEvent> get schedulesStream => _service.schedulesStream;

  /// ------------------------------
  /// Get Motor Status Once
  /// ------------------------------
  Future<MotorStatus> getMotorStatusOnce() async {
    return await _service.getMotorStatusOnce();
  }

  /// ------------------------------
  /// Update Motor Status (Partial Update)
  /// ------------------------------
  Future<void> updateMotorStatus({
    double? inputVoltage,
    double? outputVoltage,
    double? current,
    double? frequency,
    bool? running,
  }) async {
    final currentStatus = await _service.getMotorStatusOnce();

    await _service.updateMotorState(
      inputVoltage: inputVoltage ?? currentStatus.inputVoltage,
      outputVoltage: outputVoltage ?? currentStatus.outputVoltage,
      current: current ?? currentStatus.current,
      frequency: frequency ?? currentStatus.frequency,
      running: running ?? currentStatus.running,
    );
  }

  // =========================================================
  // ================== SCHEDULING SYSTEM ====================
  // =========================================================

  /// ------------------------------
  /// Save schedule for ONE DAY with multiple slots
  /// day = 1..31
  /// slots format from UI:
  /// [
  ///   { "on": {"hour": 8, "minute": 0}, "off": {"hour": 12, "minute": 0}, "pin": 12 },
  ///   { "on": {"hour": 13, "minute": 0}, "off": {"hour": 16, "minute": 0}, "pin": 12 }
  /// ]
  /// ------------------------------
  Future<void> saveDaySchedule({
    required int day,
    required List<Map<String, dynamic>> slots,
  }) async {
    await _service.saveDaySchedule(day: day, slots: slots);
  }

  /// ------------------------------
  /// Save multiple days (bulk sync)
  /// ------------------------------
  Future<void> saveMultipleDays({
    required Set<int> days,
    required List<Map<String, dynamic>> slots,
  }) async {
    for (final day in days) {
      await _service.saveDaySchedule(day: day, slots: slots);
    }
  }

  /// ------------------------------
  /// Delete schedule for one day
  /// ------------------------------
  Future<void> deleteDaySchedule(int day) async {
    await _service.deleteDaySchedule(day);
  }

  /// ------------------------------
  /// Clear ALL schedules
  /// ------------------------------
  Future<void> clearAllSchedules() async {
    await _service.clearAllSchedules();
  }
}