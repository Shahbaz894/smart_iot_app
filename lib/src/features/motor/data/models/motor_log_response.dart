class MotorLogResponse {
  final String? id;
  final String? deviceId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String? triggerType;
  final String? customerName;
  final String? status;

  const MotorLogResponse({
    this.id,
    this.deviceId,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    this.triggerType,
    this.customerName,
    this.status,
  });

  double get runHours {
    if (durationMinutes != null && durationMinutes! > 0) {
      return durationMinutes! / 60.0;
    }

    if (startTime != null && endTime != null) {
      final minutes = endTime!.difference(startTime!).inMinutes;

      if (minutes > 0) {
        return minutes / 60.0;
      }
    }

    return 0;
  }

  factory MotorLogResponse.fromJson(Map<String, dynamic> json) {
    return MotorLogResponse(
      id: json["id"]?.toString() ?? json["log_id"]?.toString(),
      deviceId: json["device_id"]?.toString() ?? json["deviceId"]?.toString(),
      startTime: _parseDate(json["start_time"] ?? json["startTime"]),
      endTime: _parseDate(json["end_time"] ?? json["endTime"]),
      durationMinutes: _parseInt(
        json["duration_minutes"] ?? json["durationMinutes"],
      ),
      triggerType: json["trigger_type"]?.toString() ??
          json["triggerType"]?.toString(),
      customerName: json["customer_name"]?.toString() ??
          json["customerName"]?.toString(),
      status: json["status"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "device_id": deviceId,
      "start_time": startTime?.toIso8601String(),
      "end_time": endTime?.toIso8601String(),
      "duration_minutes": durationMinutes,
      "trigger_type": triggerType,
      "customer_name": customerName,
      "status": status,
      "run_hours": runHours,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();

    if (text.isEmpty) return null;

    return DateTime.tryParse(text);
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }
}