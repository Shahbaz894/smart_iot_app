import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/device_state.dart';
import 'package:smart_iot_app/src/features/dashboard/model/device_model.dart';

import '../../../core/exceptions/device_exception.dart';
import '../services/device_fire_base_services.dart';



class DeviceRepository {
  final FirebaseDeviceService _service;
  DeviceRepository(this._service);

  Stream<DeviceState> watchDeviceState() {
    return _service.deviceStream.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return DeviceState(devices: [], motorSpeed: 0.0);

      // Parse the devices map
      final devicesMap = data['devices'] as Map<dynamic, dynamic>? ?? {};

      // Sort keys (0, 1, 2, 3) to keep order consistent
      var sortedKeys = devicesMap.keys.toList()..sort((a, b) => a.toString().compareTo(b.toString()));

      List<IoTDevice> devices = sortedKeys.map((key) {
        return IoTDevice.fromMap(devicesMap[key]);
      }).toList();

      return DeviceState(
        devices: devices,
        motorSpeed: (data['motor_speed'] as num?)?.toDouble() ?? 0.0,
      );
    });
  }

  Future<void> syncWithFirebase(DeviceState state) async {
    // Map the list back to a Map structure for Firebase: {"0": {...}, "1": {...}}
    final Map<String, dynamic> deviceUpdates = {};
    for (int i = 0; i < state.devices.length; i++) {
      deviceUpdates[i.toString()] = state.devices[i].toMap();
    }

    try {
      await _service.updateDeviceData({
        'devices': deviceUpdates,
        'motor_speed': state.motorSpeed,
      });
    } catch (e) {
      throw DeviceException(message: e.toString(), type: DeviceErrorType.data);
    }
  }
}
final deviceRepositoryProvider = Provider((ref) {
  return DeviceRepository(ref.watch(firebaseServiceProvider));
});