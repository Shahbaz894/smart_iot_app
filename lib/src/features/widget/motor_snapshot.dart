import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

enum DeviceConnectionStatus {
  noDevice,
  waitingTelemetry,
  connected,
  disconnected,
}

class MotorSnapshot {
  final bool isRunning;
  final bool hasFault;
  final bool hasTelemetryError;
  final int? statusCode;
  final int? faultCode;
  final int? isLive;
  final DeviceConnectionStatus connectionStatus;

  const MotorSnapshot({
    required this.isRunning,
    required this.hasFault,
    required this.hasTelemetryError,
    required this.statusCode,
    required this.faultCode,
    required this.isLive,
    required this.connectionStatus,
  });

  bool get hasDevice => connectionStatus != DeviceConnectionStatus.noDevice;

  factory MotorSnapshot.fromAppState({
    required bool isRunning,
    required bool? syncedRunning,
    required dynamic latest,
    required DeviceConnectionStatus status,
  }) {
    final int? statusCode = _toInt(_readValue(
      latest,
      objectReaders: [
            () => latest?.statusCode,
            () => latest?.status_code,
      ],
      mapKeys: const ["statusCode", "status_code"],
    ));

    final int? faultCode = _toInt(_readValue(
      latest,
      objectReaders: [
            () => latest?.faultCode,
            () => latest?.fault_code,
      ],
      mapKeys: const ["faultCode", "fault_code"],
    ));

    final int? fault = _toInt(_readValue(
      latest,
      objectReaders: [
            () => latest?.fault,
      ],
      mapKeys: const ["fault"],
    ));

    final int? isLive = _toInt(_readValue(
      latest,
      objectReaders: [
            () => latest?.isLive,
            () => latest?.is_live,
      ],
      mapKeys: const ["isLive", "is_live"],
    ));

    final bool hasFault = status == DeviceConnectionStatus.connected &&
        ((fault ?? 0) == 1 || (faultCode ?? 0) > 0 || statusCode == 4);

    final bool effectiveRunning = _resolveMotorRunning(
      fallbackRunning: isRunning,
      syncedRunning: syncedRunning,
      connectionStatus: status,
    );

    debugPrint(
      "🧠 MOTOR SNAPSHOT => "
          "syncedRunning=$syncedRunning "
          "fallbackRunning=$isRunning "
          "effectiveRunning=$effectiveRunning "
          "statusCode=$statusCode "
          "isLive=$isLive "
          "connection=$status",
    );

    return MotorSnapshot(
      isRunning: effectiveRunning,
      hasFault: hasFault,
      hasTelemetryError: status == DeviceConnectionStatus.disconnected,
      statusCode: latest == null ? null : statusCode,
      faultCode: latest == null ? null : faultCode,
      isLive: latest == null ? null : isLive,
      connectionStatus: status,
    );
  }

  static bool _resolveMotorRunning({
    required bool fallbackRunning,
    required bool? syncedRunning,
    required DeviceConnectionStatus connectionStatus,
  }) {
    switch (connectionStatus) {
      case DeviceConnectionStatus.noDevice:
        return false;

      case DeviceConnectionStatus.disconnected:
        return false;

      case DeviceConnectionStatus.waitingTelemetry:
        return syncedRunning ?? fallbackRunning;

      case DeviceConnectionStatus.connected:
      // Important:
      // Do NOT use telemetry status_code here.
      // HomeScreen already calculated safe final state.
        return syncedRunning ?? fallbackRunning;
    }
  }

  static dynamic _readValue(
      dynamic source, {
        required List<dynamic Function()> objectReaders,
        required List<String> mapKeys,
      }) {
    if (source == null) return null;

    if (source is Map) {
      for (final key in mapKeys) {
        if (source.containsKey(key)) return source[key];
      }
    }

    for (final reader in objectReaders) {
      try {
        final value = reader();
        if (value != null) return value;
      } catch (_) {}
    }

    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == "null") return null;

    return int.tryParse(text);
  }

  String get statusName {
    switch (connectionStatus) {
      case DeviceConnectionStatus.noDevice:
        return "Device Not Connected";
      case DeviceConnectionStatus.waitingTelemetry:
        return "Waiting for Telemetry";
      case DeviceConnectionStatus.disconnected:
        return "Device Disconnected";
      case DeviceConnectionStatus.connected:
        break;
    }

    if (hasFault) return "Fault Active";
    return isRunning ? "Running" : "Motor Off";
  }

  String get centerStatusText {
    switch (connectionStatus) {
      case DeviceConnectionStatus.noDevice:
        return "Device not connected";
      case DeviceConnectionStatus.waitingTelemetry:
        return "Waiting for live readings";
      case DeviceConnectionStatus.disconnected:
        return "Device disconnected";
      case DeviceConnectionStatus.connected:
        break;
    }

    if (hasFault) return faultName;
    return isRunning ? "Running" : "Motor Off";
  }

  IconData get bannerIcon {
    switch (connectionStatus) {
      case DeviceConnectionStatus.noDevice:
        return Icons.link_off_rounded;
      case DeviceConnectionStatus.waitingTelemetry:
        return Icons.sync_rounded;
      case DeviceConnectionStatus.disconnected:
        return Icons.wifi_off_rounded;
      case DeviceConnectionStatus.connected:
        break;
    }

    if (hasFault) return Icons.warning_amber_rounded;
    return isRunning
        ? Icons.electric_bolt_rounded
        : Icons.power_settings_new_rounded;
  }

  Color get bannerColor {
    switch (connectionStatus) {
      case DeviceConnectionStatus.noDevice:
        return AppColors.warning;
      case DeviceConnectionStatus.waitingTelemetry:
        return AppColors.primary;
      case DeviceConnectionStatus.disconnected:
        return AppColors.warning;
      case DeviceConnectionStatus.connected:
        break;
    }

    if (hasFault) return AppColors.error;
    return isRunning ? AppColors.green : AppColors.blueDark;
  }

  String get faultName {
    switch (faultCode ?? 0) {
      case 0:
        return "No Fault";
      case 1:
        return "OUT1";
      case 2:
        return "OUT2";
      case 3:
        return "OUT3";
      case 4:
        return "OC1";
      case 5:
        return "OC2";
      case 6:
        return "OC3";
      case 7:
        return "OV1";
      case 8:
        return "OV2";
      case 9:
        return "OV3";
      case 10:
        return "UV";
      case 11:
        return "OL1";
      case 12:
        return "OL2";
      case 13:
        return "SPI";
      case 14:
        return "SPO";
      case 15:
        return "OH1";
      case 16:
        return "OH2";
      case 17:
        return "EF";
      case 18:
        return "CE";
      case 19:
        return "ItE";
      default:
        return "Unknown Fault";
    }
  }

  String get faultDescription {
    switch (faultCode ?? 0) {
      case 0:
        return "Drive operating normally.";
      case 1:
        return "Output phase fault. Check motor cable, output terminal, or missing motor phase.";
      case 2:
        return "Output abnormality. Check motor short circuit or output wiring.";
      case 3:
        return "Output phase imbalance. Check open phase or motor winding damage.";
      case 4:
        return "Acceleration overcurrent. Check acceleration time, heavy load, or jammed motor.";
      case 5:
        return "Deceleration overcurrent. Check deceleration time or high inertia load.";
      case 6:
        return "Constant speed overcurrent. Check mechanical overload or motor current.";
      case 7:
        return "Acceleration overvoltage. DC bus voltage is too high during acceleration.";
      case 8:
        return "Deceleration overvoltage. Check fast deceleration or braking resistor.";
      case 9:
        return "Constant overvoltage. Check supply voltage.";
      case 10:
        return "Under voltage. Check weak supply or loose input cable.";
      case 11:
        return "Motor overload. Current stayed too high for long duration.";
      case 12:
        return "Drive overload. Load may exceed VFD capacity.";
      case 13:
        return "Internal communication fault.";
      case 14:
        return "Output protection triggered.";
      case 15:
        return "Drive overheat. Check cooling fan and ventilation.";
      case 16:
        return "Motor overheat. Motor thermal protection triggered.";
      case 17:
        return "External fault. External safety device triggered.";
      case 18:
        return "Communication error.";
      case 19:
        return "Current detection error.";
      default:
        return "Unknown fault code.";
    }
  }
}