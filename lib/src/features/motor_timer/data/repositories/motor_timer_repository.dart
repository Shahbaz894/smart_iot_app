import "../services/motor_timer_service.dart";

class MotorTimerRepository {
  final MotorTimerService service;

  MotorTimerRepository({
    required this.service,
  });

  Future<Map<String, dynamic>> startTimer({
    required String deviceId,
    required int durationMinutes,
    String? customerName,
  }) async {
    return await service.startTimer(
      deviceId: deviceId,
      durationMinutes: durationMinutes,
      customerName: customerName,
    );
  }

  Future<Map<String, dynamic>> stopTimer({
    required String deviceId,
  }) async {
    return await service.stopTimer(
      deviceId: deviceId,
    );
  }

  Future<Map<String, dynamic>> getActiveTimer({
    required String deviceId,
  }) async {
    return await service.getActiveTimer(
      deviceId: deviceId,
    );
  }
}