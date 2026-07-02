// // import 'package:dio/dio.dart';
// // import 'package:flutter/material.dart';
// // import 'package:smart_iot_app/src/core/constant/storage/auth_storage.dart';
// //
// //
// // class AuthInterceptor extends Interceptor {
// //   // 1. Variable define karein
// //   final AuthStorage authStorage;
// //
// //   // 2. ⚡ FIX: Constructor add kiya jo 1 argument accept karega
// //   AuthInterceptor(this.authStorage);
// //
// //   @override
// //   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
// //     try {
// //       // Direct session storage se check check karein
// //       final session = await authStorage.getSession();
// //       final String? token = session.token;
// //
// //       if (token != null && token.trim().isNotEmpty) {
// //         options.headers["Authorization"] = "Bearer ${token.trim()}";
// //         debugPrint("🚀 INTERCEPTOR: Token injected successfully into ${options.path}");
// //       } else {
// //         debugPrint("⚠️ INTERCEPTOR: Warning! No auth token found in storage for path ${options.path}");
// //       }
// //     } catch (e) {
// //       debugPrint("❌ INTERCEPTOR ERROR: ${e.toString()}");
// //     }
// //
// //     return handler.next(options);
// //   }
// // }
// // class ApiEndpoints {
// //   static const String baseUrl = "http://157.245.55.83";
// //
// //   // Auth
// //   static const String login = "/auth/login";
// //
// //   // Devices
// //   static const String devices = "/devices/";
// //
// //   static String deviceById(String deviceId) {
// //     return "/devices/${Uri.encodeComponent(deviceId)}";
// //   }
// //
// //   // Motor
// //   static String motorStart(String deviceId) {
// //     return "/motor/${Uri.encodeComponent(deviceId)}/start";
// //   }
// //
// //   static String motorRunning(String deviceId) {
// //     return "/motor/running/${Uri.encodeComponent(deviceId)}";
// //   }
// //   static String motorStop(String deviceId) {
// //     return "/motor/${Uri.encodeComponent(deviceId)}/stop";
// //   }
// //
// //   static String motorLogs(String deviceId) {
// //     return "/motor/${Uri.encodeComponent(deviceId)}/logs";
// //   }
// //
// //   static String deleteMotorLog(String logId) {
// //     return "/motor/logs/${Uri.encodeComponent(logId)}";
// //   }
// //
// //   static String clearMotorLogs(String deviceId) {
// //     return "/motor/${Uri.encodeComponent(deviceId)}/logs";
// //   }
// //
// //   // VFD
// //   static String vfdReset(String deviceId) {
// //     return "/vfd/${Uri.encodeComponent(deviceId)}/reset";
// //   }
// //
// //   static String vfdReferenceFrequency(String deviceId) {
// //     return "/vfd/${Uri.encodeComponent(deviceId)}/reference-frequency";
// //   }
// // // Schedule
// // // REMOVED trailing slash to avoid 307 redirect issues with FastAPI POST requests
// //   static const String schedule = "/schedule";
// //
// // // UPDATED to map correctly to your backend's {device_uid} parameter structure
// //   static String scheduleByDevice(String deviceId) {
// //     return "/schedule/${Uri.encodeComponent(deviceId)}";
// //   }
// //
// //   // Telemetry
// //   static String createTelemetry(String deviceId) {
// //     return "/telemetry/${Uri.encodeComponent(deviceId)}";
// //   }
// //
// //   static String latestTelemetry(String deviceId) {
// //     return "/telemetry/${Uri.encodeComponent(deviceId)}/latest";
// //   }
// //
// //   static String telemetryByDevice(String deviceId) {
// //     return "/telemetry/${Uri.encodeComponent(deviceId)}";
// //   }
// //
// //   static String deleteTelemetry(String telemetryId) {
// //     return "/telemetry/record/${Uri.encodeComponent(telemetryId)}";
// //   }
// //
// //   // Khata
// //   /// =======================
// //   /// KHATA
// //   /// =======================
// //
// //   /// Get logged-in user khata entries
// //   static const String khata = "/khata";
// //
// //   /// DO NOT USE
// //   /// /khata/me returns user profile, not entries
// //   static const String khataMe = "/khata";
// //
// //   /// Single entry by id
// //   static String khataById(String entryId) {
// //     return "/khata/${Uri.encodeComponent(entryId)}";
// //   }
// //
// //   /// Add payment to entry
// //   static String khataPayment(String entryId) {
// //     return "/khata/${Uri.encodeComponent(entryId)}/payment";
// //   }
// //
// //
// //
// //   // ───────────────── TIMER ─────────────────
// //
// // // MOTOR TIMER
// // // Corrected: FastAPI expects no deviceId in the URL path here.
// //   // device_id must be sent inside the JSON request body.
// //   static String startMotorTimer() {
// //     return "/motor-timer/start";
// //   }
// //
// //   // Corrected: /stop comes BEFORE the device ID variable
// //   static String stopMotorTimer(String deviceId) {
// //     return "/motor-timer/stop/${Uri.encodeComponent(deviceId)}";
// //   }
// //
// //   // Corrected: /status comes BEFORE the device ID variable
// //   static String getMotorTimer(String deviceId) {
// //     return "/motor-timer/status/${Uri.encodeComponent(deviceId)}";
// //   }
// //   static String motorLatestCommand(String deviceId) {
// //     return "/motor/${Uri.encodeComponent(deviceId)}/latest-command";
// //   }
// //
// // }
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:smart_iot_app/src/core/constant/storage/auth_storage.dart';
//
// class AuthInterceptor extends Interceptor {
//   final AuthStorage authStorage;
//
//   AuthInterceptor(this.authStorage);
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     try {
//       final session = await authStorage.getSession();
//       final String? token = session.token;
//
//       if (token != null && token.trim().isNotEmpty) {
//         options.headers["Authorization"] = "Bearer ${token.trim()}";
//         debugPrint("🚀 INTERCEPTOR: Token injected successfully into ${options.path}");
//       } else {
//         debugPrint("⚠️ INTERCEPTOR: Warning! No auth token found in storage for path ${options.path}");
//       }
//     } catch (e) {
//       debugPrint("❌ INTERCEPTOR ERROR: ${e.toString()}");
//     }
//     return handler.next(options);
//   }
// }
//
// class ApiEndpoints {
//   static const String baseUrl = "http://157.245.55.83";
//
//   // Auth
//   static const String login = "/auth/login";
//
//   // Devices
//   static const String devices = "/devices/";
//
//   static String deviceById(String deviceId) {
//     return "/devices/${Uri.encodeComponent(deviceId)}/";
//   }
//
//   // ── MOTOR (⚡ FIXED: Added explicit trailing slashes for FastAPI POST compatibility) ──
//   static String motorStart(String deviceId) {
//     return "/motor/${Uri.encodeComponent(deviceId)}/start/";
//   }
//
//   static String motorRunning(String deviceId) {
//     return "/motor/running/${Uri.encodeComponent(deviceId)}/";
//   }
//
//   static String motorStop(String deviceId) {
//     return "/motor/${Uri.encodeComponent(deviceId)}/stop/";
//   }
//
//   static String motorLogs(String deviceId) {
//     return "/motor/${Uri.encodeComponent(deviceId)}/logs/";
//   }
//
//   static String deleteMotorLog(String logId) {
//     return "/motor/logs/${Uri.encodeComponent(logId)}/";
//   }
//
//   static String clearMotorLogs(String deviceId) {
//     return "/motor/${Uri.encodeComponent(deviceId)}/logs/";
//   }
//
//   // VFD
//   static String vfdReset(String deviceId) {
//     return "/vfd/${Uri.encodeComponent(deviceId)}/reset/";
//   }
//
//   static String vfdReferenceFrequency(String deviceId) {
//     return "/vfd/${Uri.encodeComponent(deviceId)}/reference-frequency/";
//   }
//
//   // Schedule
//   static const String schedule = "/schedule";
//
//   static String scheduleByDevice(String deviceId) {
//     return "/schedule/${Uri.encodeComponent(deviceId)}/";
//   }
//
//   // Telemetry
//   static String createTelemetry(String deviceId) {
//     return "/telemetry/${Uri.encodeComponent(deviceId)}/";
//   }
//
//   static String latestTelemetry(String deviceId) {
//     return "/telemetry/${Uri.encodeComponent(deviceId)}/latest/";
//   }
//
//   static String telemetryByDevice(String deviceId) {
//     return "/telemetry/${Uri.encodeComponent(deviceId)}/";
//   }
//
//   static String deleteTelemetry(String telemetryId) {
//     return "/telemetry/record/${Uri.encodeComponent(telemetryId)}/";
//   }
//
//   // Khata
//   static const String khata = "/khata";
//   static const String khataMe = "/khata";
//
//   static String khataById(String entryId) {
//     return "/khata/${Uri.encodeComponent(entryId)}/";
//   }
//
//   static String khataPayment(String entryId) {
//     return "/khata/${Uri.encodeComponent(entryId)}/payment/";
//   }
//
//   // ── MOTOR TIMER ──
//   static String startMotorTimer() {
//     return "/motor-timer/start/";
//   }
//
//   static String stopMotorTimer(String deviceId) {
//     return "/motor-timer/stop/${Uri.encodeComponent(deviceId)}/";
//   }
//
//   static String getMotorTimer(String deviceId) {
//     return "/motor-timer/status/${Uri.encodeComponent(deviceId)}/";
//   }
//
//   static String motorLatestCommand(String deviceId) {
//     return "/motor/${Uri.encodeComponent(deviceId)}/latest-command/";
//   }
// }
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/constant/storage/auth_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthStorage authStorage;

  AuthInterceptor(this.authStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final session = await authStorage.getSession();
      final String? token = session.token;

      if (token != null && token.trim().isNotEmpty) {
        options.headers["Authorization"] = "Bearer ${token.trim()}";
        debugPrint("🚀 INTERCEPTOR: Token injected successfully into ${options.path}");
      } else {
        debugPrint("⚠️ INTERCEPTOR: Warning! No auth token found in storage for path ${options.path}");
      }
    } catch (e) {
      debugPrint("❌ INTERCEPTOR ERROR: ${e.toString()}");
    }
    return handler.next(options);
  }
}

class ApiEndpoints {
  static const String baseUrl = "http://157.245.55.83";

  // Auth
  static const String login = "/auth/login";

  // Devices
  static const String devices = "/devices/";

  static String deviceById(String deviceId) {
    return "/devices/${Uri.encodeComponent(deviceId)}";
  }

  // ── MOTOR (⚡ FIXED: NO trailing slash — matches FastAPI @router.post("/{device_id}/start")) ──
  static String motorStart(String deviceId) {
    return "/motor/${Uri.encodeComponent(deviceId)}/start";
  }

  static String motorRunning(String deviceId) {
    return "/motor/running/${Uri.encodeComponent(deviceId)}";
  }

  static String motorStop(String deviceId) {
    return "/motor/${Uri.encodeComponent(deviceId)}/stop";
  }

  static String motorLogs(String deviceId) {
    return "/motor/${Uri.encodeComponent(deviceId)}/logs";
  }

  static String deleteMotorLog(String logId) {
    return "/motor/logs/${Uri.encodeComponent(logId)}";
  }

  static String clearMotorLogs(String deviceId) {
    return "/motor/${Uri.encodeComponent(deviceId)}/logs";
  }

  // VFD
  static String vfdReset(String deviceId) {
    return "/vfd/${Uri.encodeComponent(deviceId)}/reset";
  }

  static String vfdReferenceFrequency(String deviceId) {
    return "/vfd/${Uri.encodeComponent(deviceId)}/reference-frequency";
  }

  // Schedule
  static const String schedule = "/schedule";

  static String scheduleByDevice(String deviceId) {
    return "/schedule/${Uri.encodeComponent(deviceId)}";
  }

  // Telemetry
  static String createTelemetry(String deviceId) {
    return "/telemetry/${Uri.encodeComponent(deviceId)}";
  }

  static String latestTelemetry(String deviceId) {
    return "/telemetry/${Uri.encodeComponent(deviceId)}/latest";
  }

  static String telemetryByDevice(String deviceId) {
    return "/telemetry/${Uri.encodeComponent(deviceId)}";
  }

  static String deleteTelemetry(String telemetryId) {
    return "/telemetry/record/${Uri.encodeComponent(telemetryId)}";
  }

  // Khata
  static const String khata = "/khata";
  static const String khataMe = "/khata";

  static String khataById(String entryId) {
    return "/khata/${Uri.encodeComponent(entryId)}";
  }

  static String khataPayment(String entryId) {
    return "/khata/${Uri.encodeComponent(entryId)}/payment";
  }

  // ── MOTOR TIMER (⚡ FIXED: NO trailing slash — matches FastAPI POST routes) ──
  static String startMotorTimer() {
    return "/motor-timer/start";
  }

  static String stopMotorTimer(String deviceId) {
    return "/motor-timer/stop/${Uri.encodeComponent(deviceId)}";
  }

  static String getMotorTimer(String deviceId) {
    return "/motor-timer/status/${Uri.encodeComponent(deviceId)}";
  }

  static String motorLatestCommand(String deviceId) {
    return "/motor/${Uri.encodeComponent(deviceId)}/latest-command";
  }
}