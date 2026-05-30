import 'package:smart_iot_app/src/features/motor/data/models/motor_log_response.dart';



const Object _unset = Object();

class MotorLogState {
  final bool isLoading;
  final List<MotorLogResponse> logs;
  final String? error;
  final String? message;

  const MotorLogState({
    this.isLoading = false,
    this.logs = const [],
    this.error,
    this.message,
  });

  MotorLogState copyWith({
    bool? isLoading,
    List<MotorLogResponse>? logs,
    Object? error = _unset,
    Object? message = _unset,
  }) {
    return MotorLogState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      error: error == _unset ? this.error : error as String?,
      message: message == _unset ? this.message : message as String?,
    );
  }
}