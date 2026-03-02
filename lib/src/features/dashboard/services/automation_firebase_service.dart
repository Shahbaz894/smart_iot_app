import 'package:firebase_database/firebase_database.dart';



import '../model/motor_status_model.dart';


class AutomationFirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final String _basePath = "shahbaz_iot";

  /// ------------------------------
  /// SAVE SCHEDULE FOR A DAY
  /// ------------------------------
  Future<void> saveScheduleForDay(int day, Map<String, dynamic> data) async {
    await _db.ref("$_basePath/schedules/day_$day").set(data);
  }

  /// ------------------------------
  /// DELETE SCHEDULE FOR A DAY
  /// ------------------------------
  Future<void> deleteScheduleForDay(int day) async {
    await _db.ref("$_basePath/schedules/day_$day").remove();
  }

  /// ------------------------------
  /// CLEAR ALL SCHEDULES
  /// ------------------------------
  Future<void> clearAllSchedules() async {
    await _db.ref("$_basePath/schedules").remove();
  }

  /// ------------------------------
  /// LISTEN SCHEDULES
  /// ------------------------------
  Stream<DatabaseEvent> get schedulesStream =>
      _db.ref("$_basePath/schedules").onValue;

  /// ------------------------------
  /// LISTEN MOTOR STATUS
  /// ------------------------------
  Stream<DatabaseEvent> get motorStatusStream =>
      _db.ref("$_basePath/motor_status").onValue;

  /// ------------------------------
  /// GET MOTOR STATUS ONCE
  /// ------------------------------
  Future<MotorStatus> getMotorStatusOnce() async {
    final ref = _db.ref("$_basePath/motor_status");
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.value == null) {
      return MotorStatus(
        inputVoltage: 0,
        outputVoltage: 0,
        current: 0,
        frequency: 0,
        running: false,
      );
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return MotorStatus.fromMap(data);
  }

  /// ------------------------------
  /// SAVE DAY WITH TIME SLOTS
  /// ------------------------------
  Future<void> saveDaySchedule({
    required int day,
    required List<Map<String, dynamic>> slots,
  }) async {
    final Map<String, dynamic> slotMap = {};

    for (int i = 0; i < slots.length; i++) {
      slotMap[i.toString()] = {
        "on": slots[i]['on'],
        "off": slots[i]['off'],
        "pin": slots[i]['pin'],
        "active": true,
      };
    }

    await _db.ref("$_basePath/schedules/day_$day").set({
      "enabled": true,
      "slots": slotMap,
    });
  }

  /// ------------------------------
  /// UPDATE MOTOR STATUS
  /// ------------------------------
  Future<void> updateMotorState({
    required double inputVoltage,
    required double outputVoltage,
    required double current,
    required double frequency,
    required bool running,
  }) async {
    await _db.ref("$_basePath/motor_status").update({
      'input_voltage': inputVoltage,
      'output_voltage': outputVoltage,
      'current': current,
      'frequency': frequency,
      'running': running,
    });
  }

  /// ------------------------------
  /// DELETE DAY SCHEDULE (Optional)
  /// ------------------------------
  Future<void> deleteDaySchedule(int day) async {
    await _db.ref("$_basePath/schedules/day_$day").remove();
  }
}
