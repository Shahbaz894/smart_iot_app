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
//     String triggerType = "app",
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
import "package:smart_iot_app/src/core/constant/api_endpoints.dart";

import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../../presentation/state/motor_state.dart";
import "../models/motor_log_response.dart";

class MotorApiService {
  final ApiClient apiClient;

  MotorApiService(this.apiClient);

  String _safeTriggerType(String? triggerType) {
    final value = triggerType?.trim().toLowerCase();

    if (value == "physical") return "physical";
    if (value == "schedule") return "schedule";
    if (value == "time") return "time";
    if (value == "app") return "app";

    // Old app used "manual". Backend does not accept manual.
    // Mobile button should be treated as app.
    if (value == "manual") return "app";

    return "app";
  }

  Future<MotorCommandStatus> getLatestCommand({
    required String deviceId,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.motorLatestCommand(deviceId),
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw AppException(message: "Invalid motor command response");
      }

      final rawCommand = data["command"] ??
          data["motor_command"] ??
          data["status"] ??
          data["motor_status"] ??
          data["state"];

      final command = rawCommand?.toString().trim().toUpperCase();

      if (command == "ON" ||
          command == "START" ||
          command == "STARTED" ||
          command == "RUNNING" ||
          command == "1" ||
          data["is_on"] == true ||
          data["is_running"] == true) {
        return MotorCommandStatus.on;
      }

      if (command == "OFF" ||
          command == "STOP" ||
          command == "STOPPED" ||
          command == "0" ||
          data["is_on"] == false ||
          data["is_running"] == false) {
        return MotorCommandStatus.off;
      }

      return MotorCommandStatus.unknown;
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to sync motor command: ${e.toString()}",
      );
    }
  }

  Future<MotorLogResponse> startMotor({
    required String deviceId,
    required String customerName,
    String triggerType = "app",
  }) async {
    try {
      final safeTriggerType = _safeTriggerType(triggerType);

      final response = await apiClient.dio.post(
        ApiEndpoints.motorStart(deviceId),
        data: {
          "trigger_type": safeTriggerType,
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
    String triggerType = "app",
  }) async {
    try {
      final safeTriggerType = _safeTriggerType(triggerType);

      final response = await apiClient.dio.post(
        ApiEndpoints.motorStop(deviceId),
        data: {
          "trigger_type": safeTriggerType,
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