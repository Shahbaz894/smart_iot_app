import "../../../motor/data/models/motor_log_response.dart";
import "../services/motor_log_api_service.dart";

class MotorLogRepository {
  final MotorLogApiService motorLogApiService;

  MotorLogRepository(this.motorLogApiService);

  Future<List<MotorLogResponse>> getLogs({
    required String deviceId,
  }) {
    return motorLogApiService.getLogs(deviceId: deviceId);
  }

  Future<void> deleteLog({
    required String logId,
  }) {
    return motorLogApiService.deleteLog(logId: logId);
  }

  Future<void> clearLogs({
    required String deviceId,
  }) {
    return motorLogApiService.clearLogs(deviceId: deviceId);
  }
}