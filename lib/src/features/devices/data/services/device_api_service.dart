import "package:dio/dio.dart";
import "package:smart_iot_app/src/core/constant/api_endpoints.dart";

import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../models/device_model.dart";

class DeviceApiService {
  final ApiClient apiClient;

  DeviceApiService(this.apiClient);

  /// Fetch all devices that belong to one user.
  ///
  /// Backend route:
  /// GET /devices/?user_id={userId}
  Future<List<DeviceModel>> getDevicesByUserId(String userId) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.devices,
        queryParameters: {
          "user_id": userId,
        },
      );

      final data = response.data;

      if (data is! List) {
        throw AppException(message: "Invalid devices response format");
      }

      return data
          .map((item) {
        if (item is! Map<String, dynamic>) {
          throw AppException(message: "Invalid device item format");
        }
        return DeviceModel.fromJson(item);
      })
          .toList();
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to fetch devices: ${e.toString()}",
      );
    }
  }

  /// Create a new device for a user.
  ///
  /// Backend route:
  /// POST /devices/?user_id={userId}
  ///
  /// MQTT note:
  /// This only creates the device in PostgreSQL.
  /// MQTT communication starts later through motor, VFD, and telemetry flows.
  Future<DeviceModel> createDevice({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.devices,
        queryParameters: {
          "user_id": userId,
        },
        data: data,
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw AppException(message: "Invalid create device response");
      }

      return DeviceModel.fromJson(responseData);
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to create device: ${e.toString()}",
      );
    }
  }

  /// Update an existing device.
  ///
  /// Backend route:
  /// PUT /devices/{deviceId}?user_id={userId}
  Future<DeviceModel> updateDevice({
    required String userId,
    required String deviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.dio.put(
        ApiEndpoints.deviceById(deviceId),
        queryParameters: {
          "user_id": userId,
        },
        data: data,
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw AppException(message: "Invalid update device response");
      }

      return DeviceModel.fromJson(responseData);
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to update device: ${e.toString()}",
      );
    }
  }
}