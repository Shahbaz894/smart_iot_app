import "../../data/models/motor_log_response.dart";

const Object _unset = Object();

enum MotorCommandStatus {
  on,
  off,
  unknown,
}

extension MotorCommandStatusX on MotorCommandStatus {
  String get value {
    switch (this) {
      case MotorCommandStatus.on:
        return "on";
      case MotorCommandStatus.off:
        return "off";
      case MotorCommandStatus.unknown:
        return "unknown";
    }
  }

  static MotorCommandStatus fromValue(dynamic value) {
    final text = value?.toString().trim().toLowerCase();

    if (text == "on" ||
        text == "running" ||
        text == "true" ||
        text == "1") {
      return MotorCommandStatus.on;
    }

    if (text == "off" ||
        text == "stopped" ||
        text == "false" ||
        text == "0") {
      return MotorCommandStatus.off;
    }

    return MotorCommandStatus.unknown;
  }
}

class MotorState {
  /// Used only when user manually taps ON/OFF button.
  /// This can show loader on MotorButton.
  final bool isLoading;

  /// Used only for background database sync.
  /// This must NOT show any loader on UI.
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

  bool get isMotorStatusKnown => commandStatus != MotorCommandStatus.unknown;

  /// Use this only for button loader.
  bool get showButtonLoader => isLoading;

  /// Never use isSyncing for MotorButton loading.
  bool get isBackgroundSyncing => isSyncing;

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