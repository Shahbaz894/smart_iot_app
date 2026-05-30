class MotorTimerRequest {
  final String deviceId;
  final String? customerName;
  final String startTime;
  final String stopTime;

  MotorTimerRequest({
    required this.deviceId,
    required this.startTime,
    required this.stopTime,
    this.customerName,
  });

  Map<String, dynamic> toJson() {
    return {
      "device_id": deviceId,
      "customer_name": customerName,
      "start_time": startTime,
      "stop_time": stopTime,
    };
  }
}

class MotorTimerResponse {
  final bool success;
  final String message;
  final String? deviceId;
  final String? customerName;
  final String? startedAt;
  final String? stopAt;

  MotorTimerResponse({
    required this.success,
    required this.message,
    this.deviceId,
    this.customerName,
    this.startedAt,
    this.stopAt,
  });

  factory MotorTimerResponse.fromJson(Map<String, dynamic> json) {
    return MotorTimerResponse(
      // Safely maps both clean string keys and nested raw responses
      success: json["success"] ?? (json["device_id"] != null),
      message: json["message"] ?? "Execution successful",
      deviceId: json["device_id"],
      customerName: json["customer_name"],
      startedAt: json["start_time"] ?? json["started_at"],
      stopAt: json["stop_time"] ?? json["stop_at"],
    );
  }
}