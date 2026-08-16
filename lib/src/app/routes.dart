import "package:flutter/material.dart";
import "package:smart_iot_app/src/features/auth/%20presentation/views/login_screen.dart";
import "package:smart_iot_app/src/features/devices/presentation/%20views/device_screen.dart";
import "package:smart_iot_app/src/features/home/presentation/views/home_screen.dart";
import "package:smart_iot_app/src/features/khata/presentation/views/%20khata_screen.dart";
import "package:smart_iot_app/src/features/logs/data/presentation/views/motor_log_screen.dart";
import "package:smart_iot_app/src/features/motor_timer/presentation/views/motor_timer_screen.dart";


import "package:flutter/material.dart";
import "package:smart_iot_app/src/features/schedule/presentation/views/schedule_screen.dart";
import "package:smart_iot_app/src/features/telemetry/presentation/views/telemetry_screen.dart";



import "package:flutter/material.dart";

import "package:smart_iot_app/src/features/home/presentation/views/home_screen.dart";

import "package:smart_iot_app/src/features/logs/data/presentation/views/motor_log_screen.dart";
import "package:smart_iot_app/src/features/motor_timer/presentation/views/motor_timer_screen.dart";
import "package:smart_iot_app/src/features/schedule/presentation/views/schedule_screen.dart";
import "package:smart_iot_app/src/features/telemetry/presentation/views/telemetry_screen.dart";
import "package:smart_iot_app/src/splash_screen.dart";


class AppRoutes {
  static const String splash = "/";

  static const String login = "/login";
  static const String devices = "/devices";
  static const String home = "/home";

  static const String schedule = "/schedule";
  static const String khata = "/khata";
  static const String telemetry = "/telemetry";
  static const String motorTimer = "/motor-timer";
  static const String systemLogs = "/system-logs";

  static String _deviceIdFromArgs(RouteSettings settings) {
    final args = settings.arguments;

    if (args is Map) {
      return args["deviceId"]?.toString() ?? "";
    }

    return "";
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case devices:
        return MaterialPageRoute(
          builder: (_) => const DeviceScreen(),
        );

      case home:
        final deviceId = _deviceIdFromArgs(settings);

        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            deviceId: deviceId,
          ),
        );

      case schedule:
        final deviceId = _deviceIdFromArgs(settings);

        return MaterialPageRoute(
          builder: (_) => ScheduleScreen(
            deviceId: deviceId,
          ),
        );

      case khata:
        final deviceId = _deviceIdFromArgs(settings);

        return MaterialPageRoute(
          builder: (_) => KhataScreen(
            deviceId: deviceId,
          ),
        );

      case telemetry:
        final deviceId = _deviceIdFromArgs(settings);

        return MaterialPageRoute(
          builder: (_) => TelemetryScreen(
            deviceId: deviceId,
          ),
        );

      case motorTimer:
        final deviceId = _deviceIdFromArgs(settings);

        return MaterialPageRoute(
          builder: (_) => MotorTimerScreen(
            deviceId: deviceId,
          ),
        );

      case systemLogs:
        final deviceId = _deviceIdFromArgs(settings);

        return MaterialPageRoute(
          builder: (_) => MotorLogScreen(
            deviceId: deviceId,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}