

class ApiEndpoints {
  static const String baseUrl = "http://157.245.55.83";

  // Auth
  static const String login = "/auth/login";

  // Devices
  static const String devices = "/devices/";

  static String deviceById(String deviceId) {
    return "/devices/${Uri.encodeComponent(deviceId)}";
  }

  // Motor
  static String motorStart(String deviceId) {
    return "/motor/${Uri.encodeComponent(deviceId)}/start";
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
// REMOVED trailing slash to avoid 307 redirect issues with FastAPI POST requests
  static const String schedule = "/schedule";

// UPDATED to map correctly to your backend's {device_uid} parameter structure
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
  /// =======================
  /// KHATA
  /// =======================

  /// Get logged-in user khata entries
  static const String khata = "/khata";

  /// DO NOT USE
  /// /khata/me returns user profile, not entries
  static const String khataMe = "/khata";

  /// Single entry by id
  static String khataById(String entryId) {
    return "/khata/${Uri.encodeComponent(entryId)}";
  }

  /// Add payment to entry
  static String khataPayment(String entryId) {
    return "/khata/${Uri.encodeComponent(entryId)}/payment";
  }



  // ───────────────── TIMER ─────────────────

// MOTOR TIMER
// Corrected: FastAPI expects no deviceId in the URL path here.
  // device_id must be sent inside the JSON request body.
  static String startMotorTimer() {
    return "/motor-timer/start";
  }

  // Corrected: /stop comes BEFORE the device ID variable
  static String stopMotorTimer(String deviceId) {
    return "/motor-timer/stop/${Uri.encodeComponent(deviceId)}";
  }

  // Corrected: /status comes BEFORE the device ID variable
  static String getMotorTimer(String deviceId) {
    return "/motor-timer/status/${Uri.encodeComponent(deviceId)}";
  }
  static String motorLatestCommand(String deviceId) {
    return "/motor/${Uri.encodeComponent(deviceId)}/latest-command";
  }

}