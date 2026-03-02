import 'package:firebase_database/firebase_database.dart';

// class MotorRTDBService {
//   final _db = FirebaseDatabase.instance.ref();
//
//   DatabaseReference get _motorRef =>
//       _db.child("shahbaz_iot/motor");
//
//   Stream<Map<String, dynamic>> motorStream() {
//     return _motorRef.onValue.map((event) {
//       final data = event.snapshot.value as Map?;
//       return Map<String, dynamic>.from(data ?? {});
//     });
//   }
//
//   Future<void> updateMotor(Map<String, dynamic> data) async {
//     await _motorRef.update(data);
//   }
// }
import 'package:firebase_database/firebase_database.dart';

class MotorRTDBService {
  final _db = FirebaseDatabase.instance.ref();

  DatabaseReference get _motorRef =>
      _db.child("shahbaz_iot/motor");

  /// 🔥 AUTO INITIALIZE STRUCTURE
  Future<void> initMotorStructure() async {
    final snapshot = await _motorRef.get();

    if (!snapshot.exists || snapshot.value is String) {
      await _motorRef.set({
        "isOn": false,
        "startTime": null,

        "faults": {
          "phaseFault": true,
          "voltageFault": false,
          "tripFault": false,
          "maintenanceRequired": false
        },

        "status": {
          "deviceError": ""
        },

        "electrical": {
          "voltage": {"L1": 0.0, "L2": 0.0, "L3": 0.0},
          "current": {"L1": 0.0, "L2": 0.0, "L3": 0.0},
          "frequency": 0.0,
          "load": 0.0,
          "powerFactor": 0.0
        }
      });
    }
  }

  /// STREAM
  Stream<Map<String, dynamic>> motorStream() {
    return _motorRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      return Map<String, dynamic>.from(data ?? {});
    });
  }

  /// UPDATE
  Future<void> updateMotor(Map<String, dynamic> data) async {
    await _motorRef.update(data);
  }
}