const Object _unset = Object();

class MotorTimerState {
  final bool isLoading;
  final bool isRunning;
  final bool isStopping;

  final int selectedHours;
  final int selectedMinutes;

  final int totalSeconds;
  final int remainingSeconds;

  final String? deviceId;
  final String? customerName;

  final DateTime? startedAt;
  final DateTime? expectedStopAt;

  final String? error;
  final String? message;

  const MotorTimerState({
    this.isLoading = false,
    this.isRunning = false,
    this.isStopping = false,
    this.selectedHours = 0,
    this.selectedMinutes = 30,
    this.totalSeconds = 1800,
    this.remainingSeconds = 0,
    this.deviceId,
    this.customerName,
    this.startedAt,
    this.expectedStopAt,
    this.error,
    this.message,
  });

  int get selectedTotalMinutes {
    return (selectedHours * 60) + selectedMinutes;
  }

  bool get hasValidDuration {
    return selectedTotalMinutes > 0;
  }

  double get completionProgress {
    if (totalSeconds <= 0) return 0;

    final completed = totalSeconds - remainingSeconds;
    final value = completed / totalSeconds;

    return value.clamp(0.0, 1.0);
  }

  String get remainingText {
    final seconds = remainingSeconds <= 0 ? 0 : remainingSeconds;

    final h = (seconds ~/ 3600).toString().padLeft(2, "0");
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
    final s = (seconds % 60).toString().padLeft(2, "0");

    return "$h:$m:$s";
  }

  String get selectedDurationText {
    final h = selectedHours;
    final m = selectedMinutes;

    if (h > 0 && m > 0) {
      return "$h hr $m min";
    }

    if (h > 0) {
      return "$h hr";
    }

    return "$m min";
  }

  MotorTimerState copyWith({
    bool? isLoading,
    bool? isRunning,
    bool? isStopping,
    int? selectedHours,
    int? selectedMinutes,
    int? totalSeconds,
    int? remainingSeconds,
    Object? deviceId = _unset,
    Object? customerName = _unset,
    Object? startedAt = _unset,
    Object? expectedStopAt = _unset,
    Object? error = _unset,
    Object? message = _unset,
  }) {
    return MotorTimerState(
      isLoading: isLoading ?? this.isLoading,
      isRunning: isRunning ?? this.isRunning,
      isStopping: isStopping ?? this.isStopping,
      selectedHours: selectedHours ?? this.selectedHours,
      selectedMinutes: selectedMinutes ?? this.selectedMinutes,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      deviceId: deviceId == _unset ? this.deviceId : deviceId as String?,
      customerName: customerName == _unset
          ? this.customerName
          : customerName as String?,
      startedAt: startedAt == _unset ? this.startedAt : startedAt as DateTime?,
      expectedStopAt: expectedStopAt == _unset
          ? this.expectedStopAt
          : expectedStopAt as DateTime?,
      error: error == _unset ? this.error : error as String?,
      message: message == _unset ? this.message : message as String?,
    );
  }
}