import "../../data/models/motor_log_response.dart";

const Object _unset = Object();

enum MotorCommandStatus {
  on,
  off,
  unknown,
}

class MotorState {
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? message;
  final MotorLogResponse? motorLog;
  final MotorCommandStatus commandStatus;

  const MotorState({
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.message,
    this.motorLog,
    this.commandStatus = MotorCommandStatus.unknown,
  });

  bool get isMotorOn => commandStatus == MotorCommandStatus.on;
  bool get isMotorOff => commandStatus == MotorCommandStatus.off;

  MotorState copyWith({
    bool? isLoading,
    bool? isSyncing,
    Object? error = _unset,
    Object? message = _unset,
    Object? motorLog = _unset,
    MotorCommandStatus? commandStatus,
  }) {
    return MotorState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error == _unset ? this.error : error as String?,
      message: message == _unset ? this.message : message as String?,
      motorLog: motorLog == _unset
          ? this.motorLog
          : motorLog as MotorLogResponse?,
      commandStatus: commandStatus ?? this.commandStatus,
    );
  }
}