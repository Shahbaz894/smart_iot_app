import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../../../motor/data/models/motor_log_response.dart";


class MotorLogApiService {
  final ApiClient apiClient;

  MotorLogApiService(this.apiClient);

  Future<List<MotorLogResponse>> getLogs({
    required String deviceId,
  }) async {
    try {
      final path = ApiEndpoints.motorLogs(deviceId);

      print("MOTOR LOG DEVICE ID: $deviceId");
      print("MOTOR LOG PATH: $path");

      final response = await apiClient.dio.get(path);

      print("MOTOR LOG STATUS: ${response.statusCode}");
      print("MOTOR LOG RESPONSE: ${response.data}");

      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (item) => MotorLogResponse.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      }

      if (data is Map && data["data"] is List) {
        return (data["data"] as List)
            .whereType<Map>()
            .map(
              (item) => MotorLogResponse.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      }

      throw AppException(
        message: "Invalid motor logs response",
      );
    } on DioException catch (e) {
      print("MOTOR LOG ERROR STATUS: ${e.response?.statusCode}");
      print("MOTOR LOG ERROR DATA: ${e.response?.data}");
      print("MOTOR LOG ERROR URL: ${e.requestOptions.uri}");

      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to load motor logs: ${e.toString()}",
      );
    }
  }

  Future<void> deleteLog({
    required String logId,
  }) async {
    try {
      final path = ApiEndpoints.deleteMotorLog(logId);

      print("DELETE MOTOR LOG ID: $logId");
      print("DELETE MOTOR LOG PATH: $path");

      await apiClient.dio.delete(path);
    } on DioException catch (e) {
      print("DELETE MOTOR LOG ERROR STATUS: ${e.response?.statusCode}");
      print("DELETE MOTOR LOG ERROR DATA: ${e.response?.data}");
      print("DELETE MOTOR LOG ERROR URL: ${e.requestOptions.uri}");

      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(
        message: "Failed to delete motor log: ${e.toString()}",
      );
    }
  }

  Future<void> clearLogs({
    required String deviceId,
  }) async {
    try {
      final path = ApiEndpoints.clearMotorLogs(deviceId);

      print("CLEAR MOTOR LOG DEVICE ID: $deviceId");
      print("CLEAR MOTOR LOG PATH: $path");

      await apiClient.dio.delete(path);
    } on DioException catch (e) {
      print("CLEAR MOTOR LOG ERROR STATUS: ${e.response?.statusCode}");
      print("CLEAR MOTOR LOG ERROR DATA: ${e.response?.data}");
      print("CLEAR MOTOR LOG ERROR URL: ${e.requestOptions.uri}");

      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(
        message: "Failed to clear motor logs: ${e.toString()}",
      );
    }
  }
}