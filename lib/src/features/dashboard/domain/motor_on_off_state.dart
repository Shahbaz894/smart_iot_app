import 'package:smart_iot_app/src/features/dashboard/domain/MotorOnOffStateData.dart';

import '../model/motor_on_off_model.dart';

class MotorOnOffState {
  final MotorOnOffStateData data;
  final bool isLoading;
  final String? errorMessage;

  const MotorOnOffState({
    required this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  factory MotorOnOffState.initial() => MotorOnOffState(
    data: const MotorOnOffStateData(
      isOn: false,
      startTime: null,
      message: "",
    ),
  );

  MotorOnOffState copyWith({
    MotorOnOffStateData? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MotorOnOffState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}