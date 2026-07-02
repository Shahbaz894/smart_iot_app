import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../models/telemetry_model.dart";

class TelemetryApiService {
  final ApiClient apiClient;

  TelemetryApiService(this.apiClient);

  /// Send telemetry through HTTP.
  ///
  /// Backend route:
  /// POST /telemetry/{deviceId}
  ///
  /// Important:
  /// ESP32 should normally send telemetry using MQTT.
  /// Keep this method for testing, fallback, or manual upload only.
  Future<TelemetryModel> sendTelemetry({
    required String deviceId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.createTelemetry(deviceId),
        data: data,
      );

      final responseData = response.data;

      if (responseData is! Map<String, dynamic>) {
        throw AppException(message: "Invalid telemetry create response");
      }

      return TelemetryModel.fromJson(responseData);
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to send telemetry: ${e.toString()}",
      );
    }
  }

  /// Get latest telemetry for one device.
  ///
  /// Backend route:
  /// GET /telemetry/{deviceId}/latest
  Future<TelemetryModel?> getLatestTelemetry({
    required String deviceId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.latestTelemetry(deviceId),
      );

      final data = response.data;

      print("LATEST TELEMETRY DEVICE: $deviceId");
      print("LATEST TELEMETRY RAW: $data");

      if (data == null) return null;

      if (data is List) {
        if (data.isEmpty) return null;

        final item = data.first;

        if (item is Map<String, dynamic>) {
          return TelemetryModel.fromJson(item);
        }

        if (item is Map) {
          return TelemetryModel.fromJson(
            Map<String, dynamic>.from(item),
          );
        }

        return null;
      }

      if (data is Map<String, dynamic>) {
        final inner = data["data"] ?? data["telemetry"] ?? data["latest"];

        if (inner is Map<String, dynamic>) {
          return TelemetryModel.fromJson(inner);
        }

        if (inner is Map) {
          return TelemetryModel.fromJson(
            Map<String, dynamic>.from(inner),
          );
        }

        return TelemetryModel.fromJson(data);
      }

      if (data is Map) {
        return TelemetryModel.fromJson(
          Map<String, dynamic>.from(data),
        );
      }

      return null;
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(
        message: "Failed to fetch latest telemetry: ${e.toString()}",
      );
    }
  }
  /// Get all telemetry records for one device.
  ///
  /// Backend route:
  /// GET /telemetry/{deviceId}
  Future<List<TelemetryModel>> getAllTelemetry({
    required String deviceId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.telemetryByDevice(deviceId),
      );

      final data = response.data;

      if (data is! List) {
        throw AppException(message: "Invalid telemetry list response");
      }

      return data
          .map((item) {
        if (item is! Map<String, dynamic>) {
          throw AppException(message: "Invalid telemetry item response");
        }
        return TelemetryModel.fromJson(item);
      })
          .toList();
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to fetch telemetry: ${e.toString()}",
      );
    }
  }

  /// Delete telemetry record by telemetry id.
  ///
  /// Backend route:
  /// DELETE /telemetry/record/{telemetryId}
  Future<void> deleteTelemetry({
    required String telemetryId,
  }) async {
    try {
      await apiClient.dio.delete(
        ApiEndpoints.deleteTelemetry(telemetryId),
      );
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(
        message: "Failed to delete telemetry: ${e.toString()}",
      );
    }
  }
}