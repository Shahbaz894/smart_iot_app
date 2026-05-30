// // import "package:dio/dio.dart";
// // import "package:smart_iot_app/src/core/constant/api_endpoints.dart";
// //
// // import "../../../../core/error/app_exception.dart";
// // import "../../../../core/network/api_client.dart";
// // import "../models/motor_log_response.dart";
// //
// // class MotorApiService {
// //   final ApiClient apiClient;
// //
// //   MotorApiService(this.apiClient);
// //
// //   /// Start motor.
// //   ///
// //   /// Backend route:
// //   /// POST /motor/{deviceId}/start
// //   ///
// //   /// Backend then sends MQTT command to ESP32:
// //   /// topic: vfd/{device_uid}/command or tubewell/{device_uid}/motor
// //   /// payload: {"command": "ON"}
// //   Future<MotorLogResponse> startMotor({
// //     required String deviceId,
// //     required String customerName,
// //     String triggerType = "manual",
// //   }) async {
// //     try {
// //       final response = await apiClient.dio.post(
// //         ApiEndpoints.motorStart(deviceId),
// //         data: {
// //           "trigger_type": triggerType,
// //           "customer_name": customerName,
// //         },
// //       );
// //
// //       final data = response.data;
// //
// //       if (data is! Map<String, dynamic>) {
// //         throw AppException(message: "Invalid motor start response");
// //       }
// //
// //       return MotorLogResponse.fromJson(data);
// //     } on DioException catch (e) {
// //       throw apiClient.handleError(e);
// //     } on AppException {
// //       rethrow;
// //     } catch (e) {
// //       throw AppException(
// //         message: "Failed to start motor: ${e.toString()}",
// //       );
// //     }
// //   }
// //
// //   /// Stop motor.
// //   ///
// //   /// Backend route:
// //   /// POST /motor/{deviceId}/stop
// //   ///
// //   /// Backend then sends MQTT command to ESP32:
// //   /// payload: {"command": "OFF"}
// //   Future<MotorLogResponse> stopMotor({
// //     required String deviceId,
// //     required String customerName,
// //   }) async {
// //     try {
// //       final response = await apiClient.dio.post(
// //         ApiEndpoints.motorStop(deviceId),
// //         data: {
// //           "customer_name": customerName,
// //         },
// //       );
// //
// //       final data = response.data;
// //
// //       if (data is! Map<String, dynamic>) {
// //         throw AppException(message: "Invalid motor stop response");
// //       }
// //
// //       return MotorLogResponse.fromJson(data);
// //     } on DioException catch (e) {
// //       throw apiClient.handleError(e);
// //     } on AppException {
// //       rethrow;
// //     } catch (e) {
// //       throw AppException(
// //         message: "Failed to stop motor: ${e.toString()}",
// //       );
// //     }
// //   }
// // }
// import "package:dio/dio.dart";
// import "package:smart_iot_app/src/core/constant/api_endpoints.dart";
//
// import "../../../../core/error/app_exception.dart";
// import "../../../../core/network/api_client.dart";
// import "../../presentation/state/motor_state.dart";
// import "../models/motor_log_response.dart";
//
// class MotorApiService {
//   final ApiClient apiClient;
//
//   MotorApiService(this.apiClient);
//
//   Future<MotorCommandStatus> getLatestCommand({
//     required String deviceId,
//   }) async {
//     try {
//       final response = await apiClient.dio.get(
//         ApiEndpoints.motorLatestCommand(deviceId),
//       );
//
//       final data = response.data;
//
//       if (data is! Map<String, dynamic>) {
//         throw AppException(message: "Invalid motor command response");
//       }
//
//       final rawCommand = data["command"] ??
//           data["motor_command"] ??
//           data["status"] ??
//           data["motor_status"] ??
//           data["state"];
//
//       final command = rawCommand?.toString().trim().toUpperCase();
//
//       if (command == "ON" ||
//           command == "START" ||
//           command == "STARTED" ||
//           command == "RUNNING" ||
//           command == "1" ||
//           data["is_on"] == true ||
//           data["is_running"] == true) {
//         return MotorCommandStatus.on;
//       }
//
//       if (command == "OFF" ||
//           command == "STOP" ||
//           command == "STOPPED" ||
//           command == "0" ||
//           data["is_on"] == false ||
//           data["is_running"] == false) {
//         return MotorCommandStatus.off;
//       }
//
//       return MotorCommandStatus.unknown;
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } on AppException {
//       rethrow;
//     } catch (e) {
//       throw AppException(
//         message: "Failed to sync motor command: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<MotorLogResponse> startMotor({
//     required String deviceId,
//     required String customerName,
//     String triggerType = "manual",
//   }) async {
//     try {
//       final response = await apiClient.dio.post(
//         ApiEndpoints.motorStart(deviceId),
//         data: {
//           "trigger_type": triggerType,
//           "customer_name": customerName,
//         },
//       );
//
//       final data = response.data;
//
//       if (data is! Map<String, dynamic>) {
//         throw AppException(message: "Invalid motor start response");
//       }
//
//       return MotorLogResponse.fromJson(data);
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } on AppException {
//       rethrow;
//     } catch (e) {
//       throw AppException(
//         message: "Failed to start motor: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<MotorLogResponse> stopMotor({
//     required String deviceId,
//     required String customerName,
//   }) async {
//     try {
//       final response = await apiClient.dio.post(
//         ApiEndpoints.motorStop(deviceId),
//         data: {
//           "customer_name": customerName,
//         },
//       );
//
//       final data = response.data;
//
//       if (data is! Map<String, dynamic>) {
//         throw AppException(message: "Invalid motor stop response");
//       }
//
//       return MotorLogResponse.fromJson(data);
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } on AppException {
//       rethrow;
//     } catch (e) {
//       throw AppException(
//         message: "Failed to stop motor: ${e.toString()}",
//       );
//     }
//   }
// }

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:smart_iot_app/src/core/constant/api_endpoints.dart";

import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../../presentation/state/motor_state.dart";
import "../models/motor_log_response.dart";

class MotorApiService {
  final ApiClient apiClient;

  MotorApiService(this.apiClient);

  Future<MotorCommandStatus> getLatestCommand({
    required String deviceId,
  }) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) {
      return MotorCommandStatus.unknown;
    }

    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.motorLatestCommand(safeDeviceId),

        // Prevent stale cached GET response on emulator/proxy.
        queryParameters: {
          "_t": DateTime.now().millisecondsSinceEpoch,
        },
      );

      final data = response.data;

      debugPrint("🟢 MOTOR LATEST COMMAND RAW: $data");

      final status = _parseMotorCommandStatus(data);

      debugPrint("🟢 MOTOR LATEST COMMAND PARSED: $status");

      return status;
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(
        message: "Failed to sync motor command: ${e.toString()}",
      );
    }
  }

  MotorCommandStatus _parseMotorCommandStatus(dynamic data) {
    if (data == null) return MotorCommandStatus.unknown;

    if (data is bool) {
      return data ? MotorCommandStatus.on : MotorCommandStatus.off;
    }

    if (data is num) {
      if (data == 1) return MotorCommandStatus.on;
      if (data == 0) return MotorCommandStatus.off;
      return MotorCommandStatus.unknown;
    }

    if (data is String) {
      return _parseCommandText(data);
    }

    if (data is List) {
      if (data.isEmpty) return MotorCommandStatus.unknown;

      // Usually latest endpoint returns latest item first.
      for (final item in data) {
        final status = _parseMotorCommandStatus(item);
        if (status != MotorCommandStatus.unknown) {
          return status;
        }
      }

      return MotorCommandStatus.unknown;
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      // Direct boolean flags.
      final directBoolKeys = [
        "is_on",
        "isOn",
        "is_running",
        "isRunning",
        "running",
        "motor_on",
        "motorOn",
      ];

      for (final key in directBoolKeys) {
        if (map.containsKey(key)) {
          final status = _parseMotorCommandStatus(map[key]);
          if (status != MotorCommandStatus.unknown) {
            return status;
          }
        }
      }

      // Direct command/status fields.
      final directCommandKeys = [
        "command",
        "motor_command",
        "motorCommand",
        "command_status",
        "commandStatus",
        "status",
        "motor_status",
        "motorStatus",
        "state",
        "action",
        "type",
        "name",
      ];

      for (final key in directCommandKeys) {
        if (map.containsKey(key)) {
          final status = _parseMotorCommandStatus(map[key]);
          if (status != MotorCommandStatus.unknown) {
            return status;
          }
        }
      }

      // Motor log style:
      // started_at exists and stopped_at/end_time is null => ON.
      // stopped_at/end_time exists => OFF.
      final stoppedValue =
          map["stopped_at"] ??
              map["stoppedAt"] ??
              map["stop_time"] ??
              map["stopTime"] ??
              map["end_time"] ??
              map["endTime"] ??
              map["ended_at"] ??
              map["endedAt"];

      final startedValue =
          map["started_at"] ??
              map["startedAt"] ??
              map["start_time"] ??
              map["startTime"];

      if (stoppedValue != null &&
          stoppedValue.toString().trim().isNotEmpty &&
          stoppedValue.toString().trim().toLowerCase() != "null") {
        return MotorCommandStatus.off;
      }

      if (startedValue != null &&
          startedValue.toString().trim().isNotEmpty &&
          startedValue.toString().trim().toLowerCase() != "null") {
        return MotorCommandStatus.on;
      }

      // Wrapped backend responses.
      final nestedKeys = [
        "data",
        "latest",
        "latestCommand",
        "latest_command",
        "motor",
        "motorLog",
        "motor_log",
        "log",
        "record",
        "result",
        "payload",
      ];

      for (final key in nestedKeys) {
        if (map.containsKey(key)) {
          final status = _parseMotorCommandStatus(map[key]);
          if (status != MotorCommandStatus.unknown) {
            return status;
          }
        }
      }

      return MotorCommandStatus.unknown;
    }

    return MotorCommandStatus.unknown;
  }

  MotorCommandStatus _parseCommandText(String value) {
    final text = value.trim().toLowerCase();

    if (text.isEmpty || text == "null") {
      return MotorCommandStatus.unknown;
    }

    if (text == "on" ||
        text == "start" ||
        text == "started" ||
        text == "running" ||
        text == "run" ||
        text == "true" ||
        text == "1") {
      return MotorCommandStatus.on;
    }

    if (text == "off" ||
        text == "stop" ||
        text == "stopped" ||
        text == "not_running" ||
        text == "false" ||
        text == "0") {
      return MotorCommandStatus.off;
    }

    return MotorCommandStatus.unknown;
  }

  Future<MotorLogResponse> startMotor({
    required String deviceId,
    required String customerName,
    String triggerType = "manual",
  }) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) {
      throw AppException(message: "Device ID is required");
    }

    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.motorStart(safeDeviceId),
        data: {
          "trigger_type": triggerType,
          "customer_name": customerName,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw AppException(message: "Invalid motor start response");
      }

      return MotorLogResponse.fromJson(data);
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to start motor: ${e.toString()}",
      );
    }
  }

  Future<MotorLogResponse> stopMotor({
    required String deviceId,
    required String customerName,
  }) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) {
      throw AppException(message: "Device ID is required");
    }

    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.motorStop(safeDeviceId),
        data: {
          "customer_name": customerName,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw AppException(message: "Invalid motor stop response");
      }

      return MotorLogResponse.fromJson(data);
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to stop motor: ${e.toString()}",
      );
    }
  }
}