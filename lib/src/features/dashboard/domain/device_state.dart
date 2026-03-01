// class DeviceState {
//   final List<bool> deviceSwitches;
//   final double motorSpeed;
//
//   DeviceState({
//     required this.deviceSwitches,
//     required this.motorSpeed,
//   });
//
//   DeviceState copyWith({
//     List<bool>? deviceSwitches,
//     double? motorSpeed,
//   }) {
//     return DeviceState(
//       deviceSwitches: deviceSwitches ?? this.deviceSwitches,
//       motorSpeed: motorSpeed ?? this.motorSpeed,
//     );
//   }
// }
// Updated main state

import 'package:smart_iot_app/src/features/dashboard/model/device_model.dart';


class DeviceState {
  final List<IoTDevice> devices;
  final double motorSpeed;

  DeviceState({required this.devices, required this.motorSpeed});

  DeviceState copyWith({List<IoTDevice>? devices, double? motorSpeed}) {
    return DeviceState(
      devices: devices ?? this.devices,
      motorSpeed: motorSpeed ?? this.motorSpeed,
    );
  }
}