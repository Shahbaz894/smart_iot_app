import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
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

      return data.map((item) {
        if (item is! Map<String, dynamic>) {
          throw AppException(message: "Invalid device item format");
        }

        return DeviceModel.fromJson(item);
      }).toList();
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

  /// ✅ Fetch latest telemetry for device.
  ///
  /// This is needed for DeviceScreen online/offline status.
  ///
  /// is_live == 1 => Device Online
  /// is_live == 0 => Device Offline
  Future<Map<String, dynamic>?> getLatestTelemetryByDeviceId(
      String deviceId,
      ) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) {
      return null;
    }

    // ✅ Try common backend routes safely.
    // Keep the first route that matches your backend.
    final possiblePaths = <String>[
      "/telemetry/$safeDeviceId/latest",
      "/telemetry/latest/$safeDeviceId",
      "/telemetry/latest?device_id=$safeDeviceId",
    ];

    DioException? lastDioError;

    for (final path in possiblePaths) {
      try {
        debugPrint("📡 DEVICE LATEST TELEMETRY PATH: $path");

        final response = await apiClient.dio.get(path);

        final data = response.data;

        final parsed = _extractTelemetryMap(data);

        if (parsed != null) {
          debugPrint(
            "✅ DEVICE LATEST TELEMETRY OK => $safeDeviceId | is_live=${parsed["is_live"] ?? parsed["isLive"]}",
          );

          return parsed;
        }
      } on DioException catch (e) {
        lastDioError = e;

        debugPrint(
          "⚠️ Latest telemetry failed on $path => ${e.response?.statusCode} ${e.message}",
        );

        continue;
      } catch (e) {
        debugPrint("⚠️ Latest telemetry parse failed on $path => $e");

        continue;
      }
    }

    if (lastDioError != null) {
      debugPrint(
        "❌ All latest telemetry paths failed for $safeDeviceId: ${lastDioError.message}",
      );
    }

    return null;
  }

  Map<String, dynamic>? _extractTelemetryMap(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      if (data["data"] is Map) {
        return Map<String, dynamic>.from(data["data"]);
      }

      if (data["payload"] is Map) {
        return Map<String, dynamic>.from(data["payload"]);
      }

      if (data["telemetry"] is Map) {
        return Map<String, dynamic>.from(data["telemetry"]);
      }

      return data;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map["data"] is Map) {
        return Map<String, dynamic>.from(map["data"]);
      }

      if (map["payload"] is Map) {
        return Map<String, dynamic>.from(map["payload"]);
      }

      if (map["telemetry"] is Map) {
        return Map<String, dynamic>.from(map["telemetry"]);
      }

      return map;
    }

    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }

    return null;
  }

  /// Create a new device for a user.
  ///
  /// Backend route:
  /// POST /devices/?user_id={userId}
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