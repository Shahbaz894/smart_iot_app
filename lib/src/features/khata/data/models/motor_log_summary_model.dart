class MotorLogSummaryModel {
  final String id;
  final String deviceId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String? triggerType;
  final String? customerName;
  final String? status;

  const MotorLogSummaryModel({
    required this.id,
    required this.deviceId,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    this.triggerType,
    this.customerName,
    this.status,
  });

  double get runHours {
    if (durationMinutes != null && durationMinutes! > 0) {
      return durationMinutes! / 60;
    }

    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!).inMinutes / 60;
    }

    return 0;
  }

  factory MotorLogSummaryModel.fromJson(Map<String, dynamic> json) {
    return MotorLogSummaryModel(
      id: json["id"]?.toString() ?? "",
      deviceId: json["device_id"]?.toString() ?? "",
      startTime: json["start_time"] == null
          ? null
          : DateTime.tryParse(json["start_time"].toString()),
      endTime: json["end_time"] == null
          ? null
          : DateTime.tryParse(json["end_time"].toString()),
      durationMinutes: int.tryParse(
        json["duration_minutes"]?.toString() ?? "",
      ),
      triggerType: json["trigger_type"]?.toString(),
      customerName: json["customer_name"]?.toString(),
      status: json["status"]?.toString(),
    );
  }
}