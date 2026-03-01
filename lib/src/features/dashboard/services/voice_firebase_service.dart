import 'package:firebase_database/firebase_database.dart';
import 'package:smart_iot_app/src/core/exceptions/device_exception.dart';

class VoiceFirebaseService {
  final FirebaseDatabase _database;

  VoiceFirebaseService(this._database);

  final String _root = "shahbaz_iot";

  DatabaseReference _deviceRef(int index) =>
      _database.ref("$_root/devices/$index/is_on");

  DatabaseReference _motorSpeedRef() =>
      _database.ref("$_root/motor_speed");

  /// Turn device ON
  Future<void> turnDeviceOn(int index) async {
    try {
      await _deviceRef(index).set(true);
    } catch (e, stack) {
      throw DeviceException.fromCode(
        code: 'disconnected',
        message: e.toString(),
        stackTrace: stack,
      );
    }
  }

  /// Turn device OFF
  Future<void> turnDeviceOff(int index) async {
    try {
      await _deviceRef(index).set(false);
    } catch (e, stack) {
      throw DeviceException.fromCode(
        code: 'disconnected',
        message: e.toString(),
        stackTrace: stack,
      );
    }
  }

  /// Listen to device state
  Stream<bool> deviceStateStream(int index) {
    return _deviceRef(index).onValue.map((event) {
      final data = event.snapshot.value;
      if (data is bool) return data;
      return false;
    });
  }

  /// Set motor speed
  Future<void> setMotorSpeed(int speed) async {
    await _motorSpeedRef().set(speed);
  }

  DatabaseReference deviceReference(int index) {
    return _database.ref("shahbaz_iot/devices/$index");
  }

}
