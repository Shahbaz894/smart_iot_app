// // import "../models/motor_log_response.dart";
// // import "../services/motor_api_service.dart";
// //
// // class MotorRepository {
// //   final MotorApiService motorApiService;
// //
// //   MotorRepository(this.motorApiService);
// //
// //   Future<MotorLogResponse> start({
// //     required String deviceId,
// //     required String customerName,
// //   }) {
// //     return motorApiService.startMotor(
// //       deviceId: deviceId,
// //       customerName: customerName,
// //     );
// //   }
// //
// //   Future<MotorLogResponse> stop({
// //     required String deviceId,
// //     required String customerName,
// //   }) {
// //     return motorApiService.stopMotor(
// //       deviceId: deviceId,
// //       customerName: customerName,
// //     );
// //   }
// // }
//
// import "../../presentation/state/motor_state.dart";
// import "../models/motor_log_response.dart";
// import "../services/motor_api_service.dart";
//
// class MotorRepository {
//   final MotorApiService motorApiService;
//
//   MotorRepository(this.motorApiService);
//
//   Future<MotorCommandStatus> getLatestCommand({
//     required String deviceId,
//   }) {
//     return motorApiService.getLatestCommand(deviceId: deviceId);
//   }
//
//   Future<MotorLogResponse> start({
//     required String deviceId,
//     required String customerName,
//   }) {
//     return motorApiService.startMotor(
//       deviceId: deviceId,
//       customerName: customerName,
//     );
//   }
//
//   Future<MotorLogResponse> stop({
//     required String deviceId,
//     required String customerName,
//   }) {
//     return motorApiService.stopMotor(
//       deviceId: deviceId,
//       customerName: customerName,
//     );
//   }
// }
import "../../presentation/state/motor_state.dart";
import "../models/motor_log_response.dart";
import "../services/motor_api_service.dart";

class MotorRepository {
  final MotorApiService motorApiService;

  MotorRepository(this.motorApiService);

  Future<MotorCommandStatus> getLatestCommand({
    required String deviceId,
  }) {
    return motorApiService.getLatestCommand(
      deviceId: deviceId.trim(),
    );
  }

  Future<MotorLogResponse> start({
    required String deviceId,
    required String customerName,
  }) {
    return motorApiService.startMotor(
      deviceId: deviceId.trim(),
      customerName: customerName,
    );
  }

  Future<MotorLogResponse> stop({
    required String deviceId,
    required String customerName,
  }) {
    return motorApiService.stopMotor(
      deviceId: deviceId.trim(),
      customerName: customerName,
    );
  }
}