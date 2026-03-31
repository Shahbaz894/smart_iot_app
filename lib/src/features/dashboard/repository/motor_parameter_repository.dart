

import 'package:smart_iot_app/src/features/dashboard/api_services/motor_parametor_api_service.dart';
import 'package:smart_iot_app/src/features/dashboard/model/motor_parameter.dart';

class MotorParameterRepository {
  final MotorParameterApiService apiService;

  MotorParameterRepository({required this.apiService});

  Future<MotorParameter> getMotorParameter(int deviceId) async {
    return await apiService.fetchMotorParameter(deviceId);
  }
}