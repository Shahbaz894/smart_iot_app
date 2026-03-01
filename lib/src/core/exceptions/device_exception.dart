

import 'package:smart_iot_app/src/core/exceptions/app_exception.dart';

enum DeviceErrorType {
  permission,
  connection,
  timeout,
  data,
  unknown,
}

/// One exception to rule all device-related errors
class DeviceException extends AppException {
  final DeviceErrorType type;

  const DeviceException({
    required String message,
    required this.type,
    String? code,
    StackTrace? stackTrace,
  }) : super(
    message: message,
    code: code,
    stackTrace: stackTrace,
  );

  /// Create DeviceException directly from Firebase error codes
  factory DeviceException.fromCode({
    required String? code,
    String? message,
    StackTrace? stackTrace,
  }) {
    switch (code) {
      case 'permission-denied':
        return DeviceException(
          message: 'You do not have permission to access this device.',
          type: DeviceErrorType.permission,
          code: code,
          stackTrace: stackTrace,
        );

      case 'disconnected':
        return DeviceException(
          message: 'Device connection lost.',
          type: DeviceErrorType.connection,
          code: code,
          stackTrace: stackTrace,
        );

      case 'timeout':
        return DeviceException(
          message: 'Device did not respond in time.',
          type: DeviceErrorType.timeout,
          code: code,
          stackTrace: stackTrace,
        );

      default:
        return DeviceException(
          message: message ?? 'Unknown device error occurred.',
          type: DeviceErrorType.unknown,
          code: code,
          stackTrace: stackTrace,
        );
    }
  }
}

