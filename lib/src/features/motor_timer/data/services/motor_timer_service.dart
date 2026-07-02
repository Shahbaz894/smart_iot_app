import "package:dio/dio.dart";

import "../../../../core/network/api_client.dart";
import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";

class MotorTimerService {
  final ApiClient apiClient;

  MotorTimerService({
    required this.apiClient,
  });

  // =========================================================
  // START TIMER (FIXED: SATISFIES SQLALCHEMY NULLABLE=FALSE)
  // =========================================================

  // Future<Map<String, dynamic>> startTimer({
  //   required String deviceId,
  //   required int durationMinutes,
  //   String? customerName,
  // }) async {
  //   try {
  //     final DateTime now = DateTime.now().toUtc();
  //     final DateTime stopTime = now.add(Duration(minutes: durationMinutes));
  //
  //     // Helper function to remove microseconds for cleaner database casting
  //     String formatToCleanIso(DateTime dt) {
  //       return "${dt.year.toString().padLeft(4, '0')}-"
  //           "${dt.month.toString().padLeft(2, '0')}-"
  //           "${dt.day.toString().padLeft(2, '0')}T"
  //           "${dt.hour.toString().padLeft(2, '0')}:"
  //           "${dt.minute.toString().padLeft(2, '0')}:"
  //           "${dt.second.toString().padLeft(2, '0')}Z";
  //     }
  //
  //     final Map<String, dynamic> requestPayload = {
  //       "device_id": deviceId,
  //       "customer_name": (customerName == null || customerName.trim().isEmpty)
  //           ? "Manual Timer Run"
  //           : customerName.trim(),
  //       "start_time": formatToCleanIso(now),
  //       "stop_time": formatToCleanIso(stopTime),
  //       // 🔥 FIX: Added to satisfy the nullable=False constraint in database
  //       "duration_minutes": durationMinutes,
  //     };
  //
  //     final response = await apiClient.dio.post(
  //       ApiEndpoints.startMotorTimer(),
  //       data: requestPayload,
  //     );
  //
  //     return response.data;
  //   } on DioException catch (e) {
  //     throw apiClient.handleError(e);
  //   } catch (e) {
  //     throw AppException(
  //       message: "Failed to start timer: ${e.toString()}",
  //     );
  //   }
  // }
  //
  // // =========================================================
  // // STOP TIMER
  // // =========================================================
  // Future<Map<String, dynamic>> stopTimer({required String deviceId}) async {
  //   try {
  //     final response = await apiClient.dio.post(ApiEndpoints.stopMotorTimer(deviceId));
  //     return response.data;
  //   } on DioException catch (e) { throw apiClient.handleError(e); }
  //   catch (e) { throw AppException(message: "Failed to stop timer: ${e.toString()}"); }
  // }

  // =========================================================
  // GET ACTIVE TIMER
  // =========================================================
  Future<Map<String, dynamic>> startTimer({
    required String deviceId,
    required int durationMinutes,
    String? customerName,
  }) async {
    try {
      final DateTime now = DateTime.now().toUtc();
      final DateTime stopTime = now.add(Duration(minutes: durationMinutes));

      // Helper function to remove microseconds for cleaner database casting
      String formatToCleanIso(DateTime dt) {
        return "${dt.year.toString().padLeft(4, '0')}-"
            "${dt.month.toString().padLeft(2, '0')}-"
            "${dt.day.toString().padLeft(2, '0')}T"
            "${dt.hour.toString().padLeft(2, '0')}:"
            "${dt.minute.toString().padLeft(2, '0')}:"
            "${dt.second.toString().padLeft(2, '0')}Z";
      }

      final Map<String, dynamic> requestPayload = {
        "device_id": deviceId,
        "customer_name": (customerName == null || customerName.trim().isEmpty)
            ? "Manual Timer Run"
            : customerName.trim(),
        "start_time": formatToCleanIso(now),
        "stop_time": formatToCleanIso(stopTime),
        "duration_minutes": durationMinutes,
        // 🔥 THE FIX: Yahan 'timer' explicitly bhej rahe hain FastAPI validation ke liye
        "trigger_type": "timer",
      };

      final response = await apiClient.dio.post(
        ApiEndpoints.startMotorTimer(),
        data: requestPayload,
      );

      return response.data;
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(
        message: "Failed to start timer: ${e.toString()}",
      );
    }
  }

  // =========================================================
  // STOP TIMER
  // =========================================================
  Future<Map<String, dynamic>> stopTimer({required String deviceId}) async {
    try {
      final response = await apiClient.dio.post(ApiEndpoints.stopMotorTimer(deviceId));
      return response.data;
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(message: "Failed to stop timer: ${e.toString()}");
    }
  }

  // =========================================================
  // GET ACTIVE TIMER
  // =========================================================
  Future<Map<String, dynamic>> getActiveTimer({required String deviceId}) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.getMotorTimer(deviceId));
      return response.data;
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(message: "Failed to get timer: ${e.toString()}");
    }
  }
  //
  // Future<Map<String, dynamic>> getActiveTimer({required String deviceId}) async {
  //   try {
  //     final response = await apiClient.dio.get(ApiEndpoints.getMotorTimer(deviceId));
  //     return response.data;
  //   } on DioException catch (e) { throw apiClient.handleError(e); }
  //   catch (e) { throw AppException(message: "Failed to get timer: ${e.toString()}"); }
  // }
}