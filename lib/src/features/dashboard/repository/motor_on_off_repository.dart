import 'package:smart_iot_app/src/features/dashboard/api_services/motor_api_services.dart';

import '../model/motor_on_off_model.dart';

class MotorOnOffRepository {
  final MotorApiService service;

  MotorOnOffRepository(this.service);

  Future<MotorOnOffModel> startMotor(int deviceId) {
    return service.sendCommand(
      deviceId: deviceId,
      command: "start",
    );
  }

  Future<MotorOnOffModel> stopMotor(int deviceId) {
    return service.sendCommand(
      deviceId: deviceId,
      command: "stop",
    );
  }
}