// --------------------------------------------------------------------------
// ================= MOTOR STATE =================
import 'package:smart_iot_app/src/features/dashboard/model/motor_model.dart';


class MotorState {
  final MotorModel motor;
  final bool isConnected;
  final bool isLoading;

  const MotorState({
    required this.motor,
    this.isConnected = true,
    this.isLoading = false,
  });

  MotorState copyWith({
    MotorModel? motor,
    bool? isConnected,
    bool? isLoading,
  }) {
    return MotorState(
      motor: motor ?? this.motor,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}