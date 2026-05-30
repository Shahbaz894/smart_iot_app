class MotorTimerRequest {
  final int durationMinutes;
  final String? customerName;

  MotorTimerRequest({
    required this.durationMinutes,
    this.customerName,
  });

  Map<String, dynamic> toJson() {
    return {
      "duration_minutes": durationMinutes,
      "customer_name": customerName,
    };
  }
}