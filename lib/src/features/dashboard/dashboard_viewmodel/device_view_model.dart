import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/device_state.dart';
import 'package:smart_iot_app/src/features/dashboard/model/device_model.dart';

import '../repository/device_repository.dart';





// class DeviceViewModel extends StateNotifier<DeviceState> {
//   final DeviceRepository _repository;
//
//   DeviceViewModel(this._repository)
//       : super(DeviceState(
//     // INITIALIZE with 4 default devices so the buttons work immediately
//     devices: [
//       IoTDevice(name: "Light", isOn: false, pin: 12),
//       IoTDevice(name: "Fan", isOn: false, pin: 14),
//       IoTDevice(name: "Pump", isOn: false, pin: 27),
//       IoTDevice(name: "Heater", isOn: false, pin: 26),
//     ],
//     motorSpeed: 0.0,
//   )) {
//     _initFirebaseListener();
//   }
//
//   void _initFirebaseListener() {
//     _repository.watchDeviceState().listen((newState) {
//       if (newState.devices.isNotEmpty) {
//         state = newState;
//       }
//     }, onError: (error) {
//       // CHANGE THIS: Don't use error.message, just print the error object
//
//     });
//   }
//
//   Future<void> toggleDevice(int index) async {
//     // This will now pass because we initialized with 4 devices!
//     if (index >= state.devices.length) return;
//
//     final updatedDevices = List<IoTDevice>.from(state.devices);
//     updatedDevices[index] = updatedDevices[index].copyWith(
//       isOn: !updatedDevices[index].isOn,
//     );
//
//     state = state.copyWith(devices: updatedDevices);
//
//     try {
//       await _repository.syncWithFirebase(state);
//     } catch (e) {
//
//     }
//   }
//
//   Future<void> updateDeviceName(int index, String newName) async {
//     if (index >= state.devices.length) return;
//
//     // Create a deep copy of the list
//     final List<IoTDevice> updatedDevices = state.devices.map((device) =>
//     device == state.devices[index]
//         ? device.copyWith(name: newName)
//         : device
//     ).toList();
//
//     // Update local state first (Optimistic UI)
//     state = state.copyWith(devices: updatedDevices);
//
//     try {
//       // Send to Firebase
//       await _repository.syncWithFirebase(state);
//     } catch (e) {
//       debugPrint("Failed to update name: $e");
//       // Optional: add logic here to revert state if sync fails
//     }
//   }
//
// // ... rest of your motor speed and emergency stop methods
//   Future<void> setMotorSpeed(double value) async {
//     // 1. Update local state immediately so the slider moves smoothly
//     state = state.copyWith(motorSpeed: value);
//
//     try {
//       // 2. Sync to Firebase
//       await _repository.syncWithFirebase(state);
//     } catch (e) {
//
//     }
//   }
// }
class DeviceViewModel extends StateNotifier<DeviceState> {
  final DeviceRepository _repository;

  DeviceViewModel(this._repository)
      : super(DeviceState(
    devices: [
      IoTDevice(name: "Light", isOn: false, pin: 12),
      IoTDevice(name: "Fan", isOn: false, pin: 14),
      IoTDevice(name: "Pump", isOn: false, pin: 27),
      IoTDevice(name: "Heater", isOn: false, pin: 26),
    ],
    motorSpeed: 0.0,
  )) {
    _initFirebaseListener();
  }

  void _initFirebaseListener() {
    _repository.watchDeviceState().listen((newState) {
      if (newState.devices.isNotEmpty) {
        state = newState;
      }
    }, onError: (error) {
      debugPrint("Listener Error: $error");
    });
  }

  // --- DEVICE ACTIONS ---

  Future<void> toggleDevice(int index) async {
    if (index >= state.devices.length) return;

    final updatedDevices = List<IoTDevice>.from(state.devices);
    updatedDevices[index] = updatedDevices[index].copyWith(
      isOn: !updatedDevices[index].isOn,
    );

    state = state.copyWith(devices: updatedDevices);
    await _repository.syncWithFirebase(state);
  }

  Future<void> updateDeviceName(int index, String newName) async {
    if (index >= state.devices.length) return;

    final updatedDevices = List<IoTDevice>.from(state.devices);
    // This updates the name while PRESERVING the pin and isOn status
    updatedDevices[index] = updatedDevices[index].copyWith(name: newName);

    state = state.copyWith(devices: updatedDevices);
    await _repository.syncWithFirebase(state);
  }

  // --- MOTOR & EMERGENCY ---

  Future<void> setMotorSpeed(double value) async {
    state = state.copyWith(motorSpeed: value);
    await _repository.syncWithFirebase(state);
  }

  // FIXED: Re-added the missing method
  Future<void> triggerEmergencyStop() async {
    // Set all switches to false but KEEP their names and pins
    final stoppedDevices = state.devices.map((device) =>
        device.copyWith(isOn: false)
    ).toList();

    state = state.copyWith(
      devices: stoppedDevices,
      motorSpeed: 0.0,
    );

    await _repository.syncWithFirebase(state);
  }
}

final deviceViewModelProvider = StateNotifierProvider<DeviceViewModel, DeviceState>((ref) {
  final repo = ref.watch(deviceRepositoryProvider);
  return DeviceViewModel(repo);
});

