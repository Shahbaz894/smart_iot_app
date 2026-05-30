import "../../data/models/schedule_model.dart";

const Object _unset = Object();

class ScheduleState {
  final bool isLoading;
  final ScheduleModel? schedule;
  final String? error;
  final String? message;

  const ScheduleState({
    this.isLoading = false,
    this.schedule,
    this.error,
    this.message,
  });

  ScheduleState copyWith({
    bool? isLoading,
    Object? schedule = _unset,
    Object? error = _unset,
    Object? message = _unset,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      schedule: schedule == _unset ? this.schedule : schedule as ScheduleModel?,
      error: error == _unset ? this.error : error as String?,
      message: message == _unset ? this.message : message as String?,
    );
  }
}