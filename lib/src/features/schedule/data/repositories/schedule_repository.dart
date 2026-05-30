import "../models/schedule_model.dart";
import "../services/schedule_api_service.dart";

class ScheduleRepository {
  final ScheduleApiService scheduleApiService;

  ScheduleRepository(this.scheduleApiService);

  Future<ScheduleModel> createSchedule({
    required ScheduleModel schedule,
  }) {
    return scheduleApiService.createSchedule(schedule: schedule);
  }

  Future<ScheduleModel> updateSchedule({
    required ScheduleModel schedule,
  }) {
    return scheduleApiService.updateSchedule(schedule: schedule);
  }

  Future<ScheduleModel> saveSchedule({
    required ScheduleModel schedule,
  }) {
    return scheduleApiService.createOrUpdateSchedule(schedule: schedule);
  }

  Future<ScheduleModel> getSchedule({
    required String deviceId,
  }) {
    return scheduleApiService.getSchedule(deviceId: deviceId);
  }

  Future<void> deleteSchedule({
    required String deviceId,
  }) {
    return scheduleApiService.deleteSchedule(deviceId: deviceId);
  }
}