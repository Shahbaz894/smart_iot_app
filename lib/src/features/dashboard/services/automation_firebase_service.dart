import 'package:firebase_database/firebase_database.dart';

class AutomationFirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  final String _basePath = "shahbaz_iot";

  /// ------------------------------
  /// SAVE SCHEDULE FOR A DATE
  /// ------------------------------
  Future<void> saveScheduleForDate(
      String dateKey,
      Map<String, dynamic> data,
      ) async {
    await _db.ref("$_basePath/automation/$dateKey").set(data);
  }

  /// ------------------------------
  /// DELETE SCHEDULE FOR A DATE
  /// ------------------------------
  Future<void> deleteScheduleForDate(String dateKey) async {
    await _db.ref("$_basePath/automation/$dateKey").remove();
  }

  /// ------------------------------
  /// CLEAR ALL AUTOMATION
  /// ------------------------------
  Future<void> clearAllAutomation() async {
    await _db.ref("$_basePath/automation").remove();
  }

  /// ------------------------------
  /// LISTEN AUTOMATION
  /// ------------------------------
  Stream<DatabaseEvent> get automationStream =>
      _db.ref("$_basePath/automation").onValue;

  /// ------------------------------
  /// LISTEN MOTOR STATUS
  /// ------------------------------
  Stream<DatabaseEvent> get motorStatusStream =>
      _db.ref("$_basePath/motor_status").onValue;

  /// ------------------------------
  /// UPDATE MOTOR STATUS (Optional manual control)
  /// ------------------------------
  // Future<void> updateMotorState(bool running) async {
  //   await _db.ref("$_basePath/motor_status/running").set(running);
  // }


  // tream<DatabaseEvent> get motorStatusStream =>
  //     _db.ref("$_basePath/motor_status").onValue;

  /// ------------------------------
  /// UPDATE MOTOR STATUS (All parameters)
  /// ------------------------------
  Future<void> updateMotorState({
    required double inputVoltage,
    required double outputVoltage,
    required double current,
    required double frequency,
    required bool running,
  }) async {
    await _db.ref("$_basePath/motor_status").set({
      'input_voltage': inputVoltage,
      'output_voltage': outputVoltage,
      'current': current,
      'frequency': frequency,
      'running': running,
    });
  }

}
