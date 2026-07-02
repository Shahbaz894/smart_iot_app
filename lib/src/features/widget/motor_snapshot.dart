import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

enum DeviceConnectionStatus {
  noDevice,
  waitingTelemetry,
  connected,
  disconnected,
}

class MotorSnapshot {
  final String statusLabel;
  final bool isRunning;
  final bool isSyncing;
  final bool hasFault;
  final bool hasTelemetryError;
  final int? statusCode;
  final int? faultCode;
  final int? isLive;
  final DeviceConnectionStatus connectionStatus;
  final String? triggerType;

  const MotorSnapshot({
    required this.isRunning,
    required this.isSyncing,
    required this.hasFault,
    required this.hasTelemetryError,
    required this.statusCode,
    required this.faultCode,
    required this.isLive,
    required this.connectionStatus,
    required this.triggerType,
    required this.statusLabel
  });

  bool get hasDevice => connectionStatus != DeviceConnectionStatus.noDevice;


  factory MotorSnapshot.fromAppState({
    required bool isRunning,
    required bool isSyncing,
    required dynamic latest,
    required DeviceConnectionStatus status,
  }) {
    // ... extraction logic ...
    final int? statusCode = _toInt(_readValue(
      latest,
      objectReaders: [() => latest?.statusCode, () => latest?.status_code],
      mapKeys: const ["statusCode", "status_code"],
    ));

    final String? triggerType = _readValue(
      latest,
      objectReaders: [() => latest?.triggerType],
      mapKeys: const ["triggerType", "trigger_type"],
    );

    // Logic: StatusLabel calculate karein
    String calculatedLabel = "Motor Off";
    if (isRunning) {
      switch (triggerType?.toLowerCase()) {
        case 'physical': calculatedLabel = "Running (Manual)"; break;
        case 'app':      calculatedLabel = "Running (App)"; break;
        case 'timer':    calculatedLabel = "Running (Timer)"; break;
        default:         calculatedLabel = "Running"; break;
      }
    } else if (isSyncing) {
      calculatedLabel = "Syncing...";
    } else {
      calculatedLabel = "Motor Off";
    }

    final int? faultCode = _toInt(_readValue(
      latest,
      objectReaders: [() => latest?.faultCode, () => latest?.fault_code],
      mapKeys: const ["faultCode", "fault_code"],
    ));

    final int? fault = _toInt(_readValue(
      latest,
      objectReaders: [() => latest?.fault],
      mapKeys: const ["fault"],
    ));

    final int? isLive = _toInt(_readValue(
      latest,
      objectReaders: [() => latest?.isLive, () => latest?.is_live],
      mapKeys: const ["isLive", "is_live"],
    ));

    final bool hasFault = status == DeviceConnectionStatus.connected &&
        ((fault ?? 0) == 1 || (faultCode ?? 0) > 0 || statusCode == 4);

    // Return statement (Sirf ek baar statusLabel pass karein!)
    return MotorSnapshot(
      isRunning: isRunning,
      isSyncing: isSyncing,
      hasFault: hasFault,
      hasTelemetryError: status == DeviceConnectionStatus.disconnected,
      statusCode: latest == null ? null : statusCode,
      faultCode: latest == null ? null : faultCode,
      isLive: latest == null ? null : isLive,
      connectionStatus: status,
      triggerType: triggerType,
      statusLabel: calculatedLabel, // ⚡ Duplicate hata diya
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  // ── UI Presentation Getters ───────────────────────────────────────────────

  String get statusName {
    if (isSyncing) return "Syncing...";
    switch (connectionStatus) {
      case DeviceConnectionStatus.noDevice:
        return "Device Not Connected";
      case DeviceConnectionStatus.waitingTelemetry:
        return "Connecting...";
      case DeviceConnectionStatus.disconnected:
        return "Device Offline";
      case DeviceConnectionStatus.connected:
        break;
    }
    if (hasFault) return "Fault Active";
    return isRunning ? "Running" : "Motor Off";
  }

  IconData get bannerIcon {
    if (isSyncing) return Icons.sync_rounded;
    switch (connectionStatus) {
      case DeviceConnectionStatus.noDevice:
        return Icons.link_off_rounded;
      case DeviceConnectionStatus.disconnected:
        return Icons.wifi_off_rounded;
      default:
        break;
    }
    if (hasFault) return Icons.warning_amber_rounded;
    return isRunning
        ? Icons.electric_bolt_rounded
        : Icons.power_settings_new_rounded;
  }

  Color get bannerColor {
    if (isSyncing) return AppColors.primary;
    if (hasFault) return AppColors.error;
    return isRunning ? AppColors.green : AppColors.blueDark;
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

  String get faultName {
    switch (faultCode ?? 0) {
      case 0:
        return "No Fault";
      case 4:
        return "OC1 (Overcurrent)";
      case 5:
        return "OC2 (Overcurrent)";
      case 7:
        return "OV1 (Overvoltage)";
      case 10:
        return "UV (Undervoltage)";
      case 15:
        return "OH1 (Overheat)";
      default:
        return "Fault Code: ${faultCode ?? 'Unknown'}";
    }
  }
}