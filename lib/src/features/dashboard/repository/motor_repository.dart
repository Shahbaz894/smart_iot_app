import 'package:smart_iot_app/src/features/dashboard/model/motor_model.dart';
import 'package:smart_iot_app/src/features/dashboard/services/motor_rtb_services.dart';


class MotorRepository {
  final MotorRTDBService service;

  MotorRepository(this.service);

  Stream<MotorModel> getMotor() {
    return service.motorStream().map(
          (map) => MotorModel.fromMap(map),
    );
  }

  Future<void> toggleMotor(bool isOn) async {
    await service.updateMotor({
      'isOn': isOn,
      'startTime':
      isOn ? DateTime.now().toIso8601String() : null,
    });
  }



}