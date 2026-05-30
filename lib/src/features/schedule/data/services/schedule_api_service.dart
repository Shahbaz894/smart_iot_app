import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../models/schedule_model.dart";

class ScheduleApiService {
  final ApiClient apiClient;

  ScheduleApiService(this.apiClient);

  Future<ScheduleModel> createSchedule({
    required ScheduleModel schedule,
  }) {
    return createOrUpdateSchedule(schedule: schedule);
  }

  Future<ScheduleModel> updateSchedule({
    required ScheduleModel schedule,
  }) {
    return createOrUpdateSchedule(schedule: schedule);
  }

  Future<ScheduleModel> createOrUpdateSchedule({
    required ScheduleModel schedule,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.schedule,
        data: schedule.toJson(),
      );

      return ScheduleModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to save schedule: ${e.toString()}",
      );
    }
  }

  Future<ScheduleModel> getSchedule({
    required String deviceId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.scheduleByDevice(deviceId),
      );

      return ScheduleModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to fetch schedule: ${e.toString()}",
      );
    }
  }

  Future<void> deleteSchedule({
    required String deviceId,
  }) async {
    try {
      await apiClient.dio.delete(
        ApiEndpoints.scheduleByDevice(deviceId),
      );
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(
        message: "Failed to delete schedule: ${e.toString()}",
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      final inner = data["data"] ?? data["schedule"];

      if (inner is Map<String, dynamic>) {
        return inner;
      }

      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }

      return data;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final inner = map["data"] ?? map["schedule"];

      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }

      return map;
    }

    throw AppException(message: "Invalid schedule response");
  }}