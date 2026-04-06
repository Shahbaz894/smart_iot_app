
import 'package:smart_iot_app/src/features/dashboard/api_services/automation_api_service.dart';

import '../model/schedule_model.dart';

class MotorAutomationRepository {
  final AutomationApiService api;

  MotorAutomationRepository(this.api);

  Future<List<ScheduleModel>> fetchSchedules(int deviceId) {
    return api.getSchedules(deviceId);
  }
}