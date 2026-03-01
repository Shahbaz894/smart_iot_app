import 'package:firebase_database/firebase_database.dart';
import 'package:smart_iot_app/src/features/dashboard/services/voice_firebase_service.dart';

import 'package:smart_iot_app/src/core/exceptions/device_exception.dart';


class VoiceRepository {
  final VoiceFirebaseService _service;

  VoiceRepository(this._service);

  /// Turn device ON
  Future<void> turnOn(int index) async {
    try {
      await _service.turnDeviceOn(index);
    } catch (e) {
      throw DeviceException(
        message: e.toString(),
        type: DeviceErrorType.data,
      );
    }
  }

  /// Turn device OFF
  Future<void> turnOff(int index) async {
    try {
      await _service.turnDeviceOff(index);
    } catch (e) {
      throw DeviceException(
        message: e.toString(),
        type: DeviceErrorType.data,
      );
    }
  }

  /// Listen to specific device state
  Stream<bool> listenDeviceState(int index) {
    return _service.deviceStateStream(index);
  }

  /// Set motor speed
  Future<void> setMotorSpeed(int speed) async {
    try {
      await _service.setMotorSpeed(speed);
    } catch (e) {
      throw DeviceException(
        message: e.toString(),
        type: DeviceErrorType.data,
      );
    }
  }

  /// Get full device node reference (for advanced updates)
  DatabaseReference deviceRef(int index) {
    return _service.deviceReference(index);
  }
}

