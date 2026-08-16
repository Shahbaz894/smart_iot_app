// //
// //
// // import "package:flutter_riverpod/flutter_riverpod.dart";
// // import "package:flutter_riverpod/legacy.dart";
// //
// // import "../../../../core/error/app_exception.dart";
// // import "../../data/models/motor_log_response.dart";
// // import "../../data/repositories/motor_repository.dart";
// // import "../state/motor_state.dart";
// //
// // class MotorViewModel extends StateNotifier<MotorState> {
// //   final MotorRepository motorRepository;
// //
// //   MotorViewModel({
// //     required this.motorRepository,
// //   }) : super(const MotorState());
// //
// //   Future<MotorLogResponse?> startMotor({
// //     required String deviceId,
// //     required String customerName,
// //   }) async {
// //     try {
// //       state = state.copyWith(
// //         isLoading: true,
// //         error: null,
// //       );
// //
// //       final log = await motorRepository.start(
// //         deviceId: deviceId,
// //         customerName: customerName,
// //       );
// //
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: null,
// //         motorLog: log,
// //       );
// //
// //       return log;
// //     } on AppException catch (e) {
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: e.message,
// //       );
// //       return null;
// //     } catch (e) {
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: "Failed to start motor: ${e.toString()}",
// //       );
// //       return null;
// //     }
// //   }
// //
// //   Future<MotorLogResponse?> stopMotor({
// //     required String deviceId,
// //     required String customerName,
// //   }) async {
// //     try {
// //       state = state.copyWith(
// //         isLoading: true,
// //         error: null,
// //       );
// //
// //       final log = await motorRepository.stop(
// //         deviceId: deviceId,
// //         customerName: customerName,
// //       );
// //
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: null,
// //         motorLog: log,
// //       );
// //
// //       return log;
// //     } on AppException catch (e) {
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: e.message,
// //       );
// //       return null;
// //     } catch (e) {
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: "Failed to stop motor: ${e.toString()}",
// //       );
// //       return null;
// //     }
// //   }
// // }
//
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:flutter_riverpod/legacy.dart";
//
// import "../../../../core/error/app_exception.dart";
// import "../../data/models/motor_log_response.dart";
// import "../../data/repositories/motor_repository.dart";
// import "../state/motor_state.dart";
//
// class MotorViewModel extends StateNotifier<MotorState> {
//   final MotorRepository motorRepository;
//
//   MotorViewModel({
//     required this.motorRepository,
//   }) : super(const MotorState());
//
//   Future<void> syncMotorCommand({
//     required String deviceId,
//     bool silent = false,
//   }) async {
//     try {
//       state = state.copyWith(
//         isSyncing: true,
//         error: silent ? null : null,
//       );
//
//       final commandStatus = await motorRepository.getLatestCommand(
//         deviceId: deviceId,
//       );
//
//       state = state.copyWith(
//         isSyncing: false,
//         commandStatus: commandStatus,
//         error: null,
//       );
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isSyncing: false,
//         error: silent ? null : e.message,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         isSyncing: false,
//         error: silent ? null : "Failed to sync motor status: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<MotorLogResponse?> startMotor({
//     required String deviceId,
//     required String customerName,
//   }) async {
//     try {
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final log = await motorRepository.start(
//         deviceId: deviceId,
//         customerName: customerName,
//       );
//
//       state = state.copyWith(
//         isLoading: false,
//         error: null,
//         message: "Motor started successfully",
//         motorLog: log,
//         commandStatus: MotorCommandStatus.on,
//       );
//
//       return log;
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//       return null;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to start motor: ${e.toString()}",
//       );
//       return null;
//     }
//   }
//
//   Future<MotorLogResponse?> stopMotor({
//     required String deviceId,
//     required String customerName,
//   }) async {
//     try {
//       state = state.copyWith(
//         isLoading: true,
//         error: null,
//         message: null,
//       );
//
//       final log = await motorRepository.stop(
//         deviceId: deviceId,
//         customerName: customerName,
//       );
//
//       state = state.copyWith(
//         isLoading: false,
//         error: null,
//         message: "Motor stopped successfully",
//         motorLog: log,
//         commandStatus: MotorCommandStatus.off,
//       );
//
//       return log;
//     } on AppException catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.message,
//       );
//       return null;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: "Failed to stop motor: ${e.toString()}",
//       );
//       return null;
//     }
//   }
// }
//
// const Object _keepError = Object();

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/models/motor_log_response.dart";
import "../../data/repositories/motor_repository.dart";
import "../state/motor_state.dart";

class MotorViewModel extends StateNotifier<MotorState> {
  final MotorRepository motorRepository;

  MotorViewModel({
    required this.motorRepository,
  }) : super(const MotorState());

  bool _isNoActiveSessionStop(String message) {
    final text = message.toLowerCase();

    return text.contains("no active database session") ||
        text.contains("no active session") ||
        text.contains("hardware force-stop signal sent successfully");
  }

  bool _isMotorLogDatabaseError(String message) {
    final text = message.toLowerCase();

    return text.contains("database error while creating motor log") ||
        text.contains("creating motor log");
  }

  String _friendlyMotorError(String message) {
    final text = message.toLowerCase();

    if (_isNoActiveSessionStop(message)) {
      return "Stop command sent successfully. No active billing session was open.";
    }

    if (_isMotorLogDatabaseError(message)) {
      return "Motor command reached server, but motor log could not be saved. Please check backend motor log/device mapping.";
    }

    if (text.contains("invalid or expired token") || text.contains("401")) {
      return "Session expired. Please logout and login again.";
    }

    if (text.contains("trigger_type") || text.contains("manual")) {
      return "Invalid motor trigger type. Mobile app must use trigger type app.";
    }

    return message;
  }

  Future<void> syncMotorCommand({
    required String deviceId,
    bool silent = false,
  }) async {
    try {
      state = state.copyWith(
        isSyncing: true,
        error: null,
      );

      final commandStatus = await motorRepository.getLatestCommand(
        deviceId: deviceId,
      );

      state = state.copyWith(
        isSyncing: false,
        commandStatus: commandStatus,
        error: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: silent ? null : _friendlyMotorError(e.message),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: silent ? null : "Failed to sync motor status.",
      );
    }
  }

  Future<MotorLogResponse?> startMotor({
    required String deviceId,
    required String customerName,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final log = await motorRepository.start(
        deviceId: deviceId,
        customerName: customerName,
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        message: "Start command sent successfully",
        motorLog: log,
        commandStatus: MotorCommandStatus.on,
      );

      return log;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _friendlyMotorError(e.message),
        message: null,
      );

      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to start motor.",
        message: null,
      );

      return null;
    }
  }

  Future<MotorLogResponse?> stopMotor({
    required String deviceId,
    required String customerName,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final log = await motorRepository.stop(
        deviceId: deviceId,
        customerName: customerName,
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        message: "Stop command sent successfully",
        motorLog: log,
        commandStatus: MotorCommandStatus.off,
      );

      return log;
    } on AppException catch (e) {
      if (_isNoActiveSessionStop(e.message)) {
        state = state.copyWith(
          isLoading: false,
          error: null,
          message: "Stop command sent. No active billing session was open.",
          commandStatus: MotorCommandStatus.off,
        );

        return null;
      }

      state = state.copyWith(
        isLoading: false,
        error: _friendlyMotorError(e.message),
        message: null,
      );

      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to stop motor.",
        message: null,
      );

      return null;
    }
  }
}