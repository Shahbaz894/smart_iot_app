// ----------------------
// MotorOnOffStateData
// ----------------------
class MotorOnOffStateData {
  final bool isOn;
  final DateTime? startTime;
  final String message;

  const MotorOnOffStateData({
    required this.isOn,
    this.startTime,
    required this.message,
  });

  MotorOnOffStateData copyWith({
    bool? isOn,
    DateTime? startTime,
    String? message,
  }) {
    return MotorOnOffStateData(
      isOn: isOn ?? this.isOn,
      startTime: startTime ?? this.startTime,
      message: message ?? this.message,
    );
  }
}