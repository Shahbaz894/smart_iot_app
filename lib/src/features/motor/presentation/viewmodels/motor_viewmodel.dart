// // import "package:flutter/foundation.dart";
// // import "package:flutter_riverpod/flutter_riverpod.dart";
// // import "package:flutter_riverpod/legacy.dart";
// // import "package:smart_iot_app/src/features/motor/data/repositories/motor_repository.dart";
// //
// // import "package:smart_iot_app/src/mqtt/mqtt_stream_service.dart";
// //
// // import "../../../../core/error/app_exception.dart";
// // import "../../data/models/motor_log_response.dart";
// //
// // import "../state/motor_state.dart";
// //
// // class MotorViewModel extends StateNotifier<MotorState> {
// //   final MotorRepository motorRepository;
// //
// //   final MqttStreamService mqttStreamService;
// //
// //   MotorViewModel({
// //     required this.motorRepository,
// //     required this.mqttStreamService,
// //   }) : super(const MotorState());
// //
// //   /// 🛰️ START LIVE MQTT SYNC LOCK (Isay screen loading par call karein)
// //   // void listenToLiveHardwareSync(String deviceId) {
// //   //   final safeDeviceId = deviceId.trim();
// //   //
// //   //   if (safeDeviceId.isEmpty) return;
// //   //
// //   //   mqttStreamService.initMqttSession(safeDeviceId);
// //   //
// //   //   mqttStreamService.liveStatus.addListener(() {
// //   //     final newStatus = mqttStreamService.liveStatus.value;
// //   //
// //   //     debugPrint(
// //   //       "📡 MQTT STATUS RECEIVED => $newStatus",
// //   //     );
// //   //
// //   //     if (newStatus == MotorCommandStatus.unknown) {
// //   //       return;
// //   //     }
// //   //
// //   //     if (state.commandStatus == newStatus) {
// //   //       return;
// //   //     }
// //   //
// //   //     state = state.copyWith(
// //   //       commandStatus: newStatus,
// //   //     );
// //   //
// //   //     debugPrint(
// //   //       "⚡ UI UPDATED FROM MQTT => $newStatus",
// //   //     );
// //   //   });
// //   // }
// //   void listenToLiveHardwareSync(String deviceId) {
// //     final safeDeviceId = deviceId.trim();
// //     if (safeDeviceId.isEmpty) return;
// //
// //     mqttStreamService.initMqttSession(safeDeviceId);
// //
// //     mqttStreamService.liveStatus.addListener(() {
// //       final newStatus = mqttStreamService.liveStatus.value;
// //
// //       // Sirf tab update karein agar status change hua hai
// //       if (state.commandStatus != newStatus) {
// //         debugPrint("📡 HARDWARE SYNC DETECTED => $newStatus");
// //
// //         // Update state
// //         state = state.copyWith(commandStatus: newStatus);
// //
// //         // Agar motor ON hui hai (physical ya app se), toh naya active log fetch karein
// //         if (newStatus == MotorCommandStatus.on) {
// //           fetchActiveLog(safeDeviceId);
// //         }
// //       }
// //     });
// //   }
// //   Future<void> fetchActiveLog(String deviceId) async {
// //     try {
// //       // Repository mein ek naya method add karein: getRunningMotor(deviceId)
// //       final activeLog = await motorRepository.getRunningMotor(deviceId);
// //
// //       if (activeLog != null) {
// //         state = state.copyWith(
// //           motorLog: activeLog,
// //           commandStatus: MotorCommandStatus.on,
// //         );
// //       }
// //     } catch (e) {
// //       debugPrint("❌ Error fetching active log: $e");
// //     }
// //   }
// //
// //   /// 🟢 START MOTOR BUTTON ACTION
// //   Future<MotorLogResponse?> startMotor({
// //     required String deviceId,
// //     required String customerName,
// //   }) async {
// //     final safeDeviceId = deviceId.trim();
// //     if (safeDeviceId.isEmpty) return null;
// //     if (state.isLoading) return null;
// //
// //     try {
// //       state = state.copyWith(isLoading: true, error: null, message: null);
// //
// //       // Secure FastAPI Gateway call
// //       final log = await motorRepository.start(
// //         deviceId: safeDeviceId,
// //         customerName: customerName,
// //       );
// //
// //       // UI update immediately to show responsiveness
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: null,
// //         message: "Motor started successfully",
// //         motorLog: log,
// //         commandStatus: MotorCommandStatus.on,
// //       );
// //
// //       return log;
// //     } on AppException catch (e) {
// //       state = state.copyWith(isLoading: false, error: e.message);
// //       return null;
// //     } catch (e) {
// //       state = state.copyWith(isLoading: false, error: "Failed to start motor: ${e.toString()}");
// //       return null;
// //     }
// //   }
// //
// //   /// 🔴 STOP MOTOR BUTTON ACTION
// //   // Future<MotorLogResponse?> stopMotor({
// //   //   required String deviceId,
// //   //   required String customerName,
// //   // }) async {
// //   //   final safeDeviceId = deviceId.trim();
// //   //   if (safeDeviceId.isEmpty) return null;
// //   //   if (state.isLoading) return null;
// //   //
// //   //   try {
// //   //     state = state.copyWith(isLoading: true, error: null, message: null);
// //   //
// //   //     // Secure FastAPI Gateway call
// //   //     final log = await motorRepository.stop(
// //   //       deviceId: safeDeviceId,
// //   //       customerName: customerName,
// //   //     );
// //   //
// //   //     state = state.copyWith(
// //   //       isLoading: false,
// //   //       error: null,
// //   //       message: "Motor stopped successfully",
// //   //       motorLog: log,
// //   //       commandStatus: MotorCommandStatus.off,
// //   //     );
// //   //
// //   //     return log;
// //   //   } on AppException catch (e) {
// //   //     // 🚀 HARDWARE SAFE BYPASS ZONE: Even if DB session log row gives 404 error,
// //   //     // we forcefully update UI to OFF to ensure safe manual alignment.
// //   //     state = state.copyWith(
// //   //       isLoading: false,
// //   //       commandStatus: MotorCommandStatus.off,
// //   //       error: e.message,
// //   //     );
// //   //     return null;
// //   //   } catch (e) {
// //   //     state = state.copyWith(isLoading: false, error: "Failed to stop motor: ${e.toString()}");
// //   //     return null;
// //   //   }
// //   // }
// //   Future<MotorLogResponse> stopMotor({
// //     required String deviceId,
// //     required String customerName,
// //   }) async {
// //     final safeDeviceId = deviceId.trim();
// //
// //     if (safeDeviceId.isEmpty) {
// //       throw AppException(message: "Device ID missing");
// //     }
// //
// //     state = state.copyWith(
// //       isLoading: true,
// //       error: null,
// //       message: null,
// //     );
// //
// //     try {
// //       final log = await motorRepository.stop(
// //         deviceId: safeDeviceId,
// //         customerName: customerName,
// //       );
// //
// //       debugPrint("STOP LOG RESPONSE => ${log.toJson()}");
// //
// //       state = state.copyWith(
// //         isLoading: false,
// //         motorLog: log,
// //         commandStatus: MotorCommandStatus.off,
// //         message: "Motor stopped",
// //       );
// //
// //       return log;
// //     } catch (e) {
// //       state = state.copyWith(
// //         isLoading: false,
// //         error: e.toString(),
// //       );
// //
// //       rethrow;
// //     }
// //   }
// //
// //
// //
// //   Future<void> loadInitialMotorState({
// //     required String deviceId,
// //   }) async {
// //     final safeDeviceId = deviceId.trim();
// //
// //     if (safeDeviceId.isEmpty) return;
// //
// //     try {
// //       debugPrint(
// //         "🔄 LOADING INITIAL MOTOR STATE => $safeDeviceId",
// //       );
// //
// //       final status = await motorRepository.getLatestCommand(
// //         deviceId: safeDeviceId,
// //       );
// //
// //       debugPrint(
// //         "✅ INITIAL MOTOR STATE => $status",
// //       );
// //
// //       state = state.copyWith(
// //         commandStatus: status,
// //         error: null,
// //       );
// //     } catch (e) {
// //       debugPrint(
// //         "❌ INITIAL MOTOR STATE FAILED => $e",
// //       );
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     mqttStreamService.closeSession();
// //     super.dispose();
// //   }
// // }
// import "dart:async";
//
// import "package:flutter/foundation.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:flutter_riverpod/legacy.dart";
// import "package:smart_iot_app/src/features/motor/data/repositories/motor_repository.dart";
//
// import "package:smart_iot_app/src/mqtt/mqtt_stream_service.dart";
//
// import "../../../../core/error/app_exception.dart";
// import "../../data/models/motor_log_response.dart";
//
// import "../state/motor_state.dart";
//
// class MotorViewModel extends StateNotifier<MotorState> {
//   final MotorRepository motorRepository;
//
//   final MqttStreamService mqttStreamService;
//
//   MotorViewModel({
//     required this.motorRepository,
//     required this.mqttStreamService,
//   }) : super(const MotorState());
//
//   /// 🛰️ START LIVE MQTT SYNC LOCK (Isay screen loading par call karein)
//   void listenToLiveHardwareSync(String deviceId) {
//     final safeDeviceId = deviceId.trim();
//     if (safeDeviceId.isEmpty) return;
//
//     mqttStreamService.initMqttSession(safeDeviceId);
//
//     mqttStreamService.liveStatus.addListener(() {
//       final newStatus = mqttStreamService.liveStatus.value;
//
//       // Sirf tab update karein agar status change hua hai
//       if (state.commandStatus != newStatus) {
//         debugPrint("📡 HARDWARE SYNC DETECTED => $newStatus");
//
//         // Update state
//         state = state.copyWith(commandStatus: newStatus);
//
//         // Agar motor ON hui hai (physical ya app se), toh naya active log fetch karein
//         if (newStatus == MotorCommandStatus.on) {
//           fetchActiveLog(safeDeviceId);
//         }
//       }
//     });
//   }
//
//   Future<void> fetchActiveLog(String deviceId) async {
//     try {
//       // Repository mein ek naya method add karein: getRunningMotor(deviceId)
//       final activeLog = await motorRepository.getRunningMotor(deviceId);
//
//       if (activeLog != null) {
//         state = state.copyWith(
//           motorLog: activeLog,
//           commandStatus: MotorCommandStatus.on,
//         );
//       }
//     } catch (e) {
//       debugPrint("❌ Error fetching active log: $e");
//     }
//   }
//
//   /// 🟢 START MOTOR BUTTON ACTION
//   Future<MotorLogResponse?> startMotor({
//     required String deviceId,
//     required String customerName,
//   }) async {
//     final safeDeviceId = deviceId.trim();
//     if (safeDeviceId.isEmpty) return null;
//     if (state.isLoading) return null;
//
//     try {
//       state = state.copyWith(isLoading: true, error: null, message: null);
//
//       // Secure FastAPI Gateway call
//       final log = await motorRepository.start(
//         deviceId: safeDeviceId,
//         customerName: customerName,
//       );
//
//       // UI update immediately to show responsiveness
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
//       state = state.copyWith(isLoading: false, error: e.message);
//       return null;
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: "Failed to start motor: ${e.toString()}");
//       return null;
//     }
//   }
//
//   /// 🔴 STOP MOTOR BUTTON ACTION
//   Future<MotorLogResponse> stopMotor({
//     required String deviceId,
//     required String customerName,
//   }) async {
//     final safeDeviceId = deviceId.trim();
//
//     if (safeDeviceId.isEmpty) {
//       throw AppException(message: "Device ID missing");
//     }
//
//     state = state.copyWith(
//       isLoading: true,
//       error: null,
//       message: null,
//     );
//
//     try {
//       final log = await motorRepository.stop(
//         deviceId: safeDeviceId,
//         customerName: customerName,
//       );
//
//       debugPrint("STOP LOG RESPONSE => ${log.toJson()}");
//
//       state = state.copyWith(
//         isLoading: false,
//         motorLog: log,
//         commandStatus: MotorCommandStatus.off,
//         message: "Motor stopped",
//       );
//
//       return log;
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//
//       rethrow;
//     }
//   }
//
//   /// 🔄 SYNC MOTOR COMMAND FROM BACKEND
//   ///
//   /// Used by HomeScreen for:
//   ///  - initial load (silent: true via Future.microtask)
//   ///  - RefreshIndicator (silent: false, so user sees spinner)
//   ///  - periodic 5s timer (silent: true, background polling)
//   ///
//   /// [silent] = true  -> doesn't toggle global `isLoading`, so the
//   ///                      MotorCommandButton does NOT show its
//   ///                      CircularProgressIndicator during background polls.
//   /// [silent] = false -> toggles `isLoading` normally (manual refresh).
//   Future<void> syncMotorCommand({
//     required String deviceId,
//     bool silent = false,
//   }) async {
//     final safeDeviceId = deviceId.trim();
//     if (safeDeviceId.isEmpty) return;
//
//     // Don't interfere with an in-flight manual start/stop command.
//     if (state.isLoading && !silent) return;
//
//     try {
//       if (!silent) {
//         state = state.copyWith(isLoading: true);
//       }
//
//       final status = await motorRepository.getLatestCommand(
//         deviceId: safeDeviceId,
//       );
//
//       if (status == MotorCommandStatus.unknown) {
//         if (!silent) {
//           state = state.copyWith(isLoading: false);
//         }
//         return;
//       }
//
//       if (state.commandStatus != status) {
//         debugPrint("🔄 MOTOR COMMAND SYNCED => $status");
//       }
//
//       state = state.copyWith(
//         commandStatus: status,
//         isLoading: false,
//         error: null,
//       );
//
//       // If motor turned ON (by app or physical button), fetch active log
//       // so the Khata session / running log info stays accurate.
//       if (status == MotorCommandStatus.on) {
//         unawaited(fetchActiveLog(safeDeviceId));
//       }
//     } catch (e) {
//       debugPrint("❌ SYNC MOTOR COMMAND FAILED => $e");
//       if (!silent) {
//         state = state.copyWith(isLoading: false);
//       }
//     }
//   }
//
//   Future<void> loadInitialMotorState({
//     required String deviceId,
//   }) async {
//     final safeDeviceId = deviceId.trim();
//
//     if (safeDeviceId.isEmpty) return;
//
//     try {
//       debugPrint(
//         "🔄 LOADING INITIAL MOTOR STATE => $safeDeviceId",
//       );
//
//       final status = await motorRepository.getLatestCommand(
//         deviceId: safeDeviceId,
//       );
//
//       debugPrint(
//         "✅ INITIAL MOTOR STATE => $status",
//       );
//
//       state = state.copyWith(
//         commandStatus: status,
//         error: null,
//       );
//     } catch (e) {
//       debugPrint(
//         "❌ INITIAL MOTOR STATE FAILED => $e",
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     mqttStreamService.closeSession();
//     super.dispose();
//   }
// }
import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/features/motor/data/repositories/motor_repository.dart";

import "package:smart_iot_app/src/mqtt/mqtt_stream_service.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/models/motor_log_response.dart";

import "../state/motor_state.dart";

class MotorViewModel extends StateNotifier<MotorState> {
  final MotorRepository motorRepository;
  final MqttStreamService mqttStreamService;

  MotorViewModel({
    required this.motorRepository,
    required this.mqttStreamService,
  }) : super(const MotorState());

  /// 🛰️ START LIVE MQTT SYNC LOCK (Isay screen loading par call karein)
  void listenToLiveHardwareSync(String deviceId) {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return;

    mqttStreamService.initMqttSession(safeDeviceId);

    mqttStreamService.liveStatus.addListener(() {
      final newStatus = mqttStreamService.liveStatus.value;

      // Sirf tab update karein agar status change hua hai
      if (state.commandStatus != newStatus) {
        debugPrint("📡 HARDWARE SYNC DETECTED => $newStatus");

        // Update state
        state = state.copyWith(commandStatus: newStatus);

        // Agar motor ON hui hai (physical ya app se), toh naya active log fetch karein
        if (newStatus == MotorCommandStatus.on) {
          fetchActiveLog(safeDeviceId);
        }
      }
    });
  }

  Future<void> fetchActiveLog(String deviceId) async {
    try {
      // Repository mein ek naya method add karein: getRunningMotor(deviceId)
      final activeLog = await motorRepository.getRunningMotor(deviceId);

      if (activeLog != null) {
        state = state.copyWith(
          motorLog: activeLog,
          commandStatus: MotorCommandStatus.on,
        );
      }
    } catch (e) {
      debugPrint("❌ Error fetching active log: $e");
    }
  }

  /// 🟢 START MOTOR BUTTON ACTION
  // Future<MotorLogResponse?> startMotor({
  //   required String deviceId,
  //   required String customerName,
  // }) async {
  //   final safeDeviceId = deviceId.trim();
  //   if (safeDeviceId.isEmpty) return null;
  //
  //   // ⚡ FIX: "if (state.isLoading) return null;" KO YAHAN SE REMOVE KAR DIYA HAI.
  //   // Ab user ka click hamesha API execute karega!
  //
  //   try {
  //     state = state.copyWith(isLoading: true, error: null, message: null);
  //
  //     // Secure FastAPI Gateway call
  //     final log = await motorRepository.start(
  //       deviceId: safeDeviceId,
  //       customerName: customerName,
  //     );
  //
  //     // UI update immediately to show responsiveness
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: null,
  //       message: "Motor started successfully",
  //       motorLog: log,
  //       commandStatus: MotorCommandStatus.on,
  //     );
  //
  //     return log;
  //   } on AppException catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.message);
  //     return null;
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: "Failed to start motor: ${e.toString()}");
  //     return null;
  //   }
  // }
  //
  // /// 🔴 STOP MOTOR BUTTON ACTION
  // Future<MotorLogResponse> stopMotor({
  //   required String deviceId,
  //   required String customerName,
  // }) async {
  //   final safeDeviceId = deviceId.trim();
  //
  //   if (safeDeviceId.isEmpty) {
  //     throw AppException(message: "Device ID missing");
  //   }
  //
  //   state = state.copyWith(
  //     isLoading: true,
  //     error: null,
  //     message: null,
  //   );
  //
  //   try {
  //     final log = await motorRepository.stop(
  //       deviceId: safeDeviceId,
  //       customerName: customerName,
  //     );
  //
  //     debugPrint("STOP LOG RESPONSE => ${log.toJson()}");
  //
  //     state = state.copyWith(
  //       isLoading: false,
  //       motorLog: log,
  //       commandStatus: MotorCommandStatus.off,
  //       message: "Motor stopped",
  //     );
  //
  //     return log;
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: e.toString(),
  //     );
  //
  //     rethrow;
  //   }
  // }
  /// 🟢 START MOTOR BUTTON ACTION
  Future<MotorLogResponse?> startMotor({
    required String deviceId,
    required String customerName,
  }) async {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return null;

    try {
      state = state.copyWith(isLoading: true, error: null, message: null);

      debugPrint("🌍 API REQUEST JAA RAHI HAI => START MOTOR ($safeDeviceId)");

      // Secure FastAPI Gateway call
      final log = await motorRepository.start(
        deviceId: safeDeviceId,
        customerName: customerName,
      );

      debugPrint("✅ API SUCCESS! MOTOR STARTED. LOG ID: ${log.id}");

      state = state.copyWith(
        isLoading: false,
        error: null,
        message: "Motor started successfully",
        motorLog: log,
        commandStatus: MotorCommandStatus.on,
      );

      return log;
    } catch (e, stackTrace) {
      // 🚨 YAHAN ASAL ERROR PAKDA JAYEGA!
      debugPrint("🔥🔥🔥 API CALL CRASHED (START): ${e.toString()}");
      debugPrint("🔥🔥🔥 STACK TRACE: $stackTrace");

      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// 🔴 STOP MOTOR BUTTON ACTION
  Future<MotorLogResponse?> stopMotor({
    required String deviceId,
    required String customerName,
  }) async {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return null;

    try {
      state = state.copyWith(isLoading: true, error: null, message: null);

      debugPrint("🌍 API REQUEST JAA RAHI HAI => STOP MOTOR ($safeDeviceId)");

      final log = await motorRepository.stop(
        deviceId: safeDeviceId,
        customerName: customerName,
      );

      debugPrint("✅ API SUCCESS! MOTOR STOPPED. LOG ID: ${log.id}");

      state = state.copyWith(
        isLoading: false,
        motorLog: log,
        commandStatus: MotorCommandStatus.off,
        message: "Motor stopped",
      );

      return log;
    } catch (e, stackTrace) {
      // 🚨 YAHAN ASAL ERROR PAKDA JAYEGA!
      debugPrint("🔥🔥🔥 API CALL CRASHED (STOP): ${e.toString()}");
      debugPrint("🔥🔥🔥 STACK TRACE: $stackTrace");

      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// 🔄 SYNC MOTOR COMMAND FROM BACKEND
  Future<void> syncMotorCommand({
    required String deviceId,
    bool silent = false,
  }) async {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return;

    // Don't interfere with an in-flight manual start/stop command.
    if (state.isLoading && !silent) return;

    try {
      if (!silent) {
        state = state.copyWith(isLoading: true);
      }

      final status = await motorRepository.getLatestCommand(
        deviceId: safeDeviceId,
      );

      if (status == MotorCommandStatus.unknown) {
        if (!silent) {
          state = state.copyWith(isLoading: false);
        }
        return;
      }

      if (state.commandStatus != status) {
        debugPrint("🔄 MOTOR COMMAND SYNCED => $status");
      }

      state = state.copyWith(
        commandStatus: status,
        isLoading: false,
        error: null,
      );

      if (status == MotorCommandStatus.on) {
        unawaited(fetchActiveLog(safeDeviceId));
      }
    } catch (e) {
      debugPrint("❌ SYNC MOTOR COMMAND FAILED => $e");
      if (!silent) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> loadInitialMotorState({
    required String deviceId,
  }) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) return;

    try {
      debugPrint(
        "🔄 LOADING INITIAL MOTOR STATE => $safeDeviceId",
      );

      final status = await motorRepository.getLatestCommand(
        deviceId: safeDeviceId,
      );

      debugPrint(
        "✅ INITIAL MOTOR STATE => $status",
      );

      state = state.copyWith(
        commandStatus: status,
        error: null,
      );
    } catch (e) {
      debugPrint(
        "❌ INITIAL MOTOR STATE FAILED => $e",
      );
    }
  }

  @override
  void dispose() {
    mqttStreamService.closeSession();
    super.dispose();
  }
}