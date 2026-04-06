import '../model/schedule_model.dart';

class MotorAutomationState {
  final bool isLoading;
  final List<ScheduleModel> schedules;
  final String? error;

  MotorAutomationState({
    required this.isLoading,
    required this.schedules,
    this.error,
  });

  factory MotorAutomationState.initial() {
    return MotorAutomationState(
      isLoading: false,
      schedules: [],
      error: null,
    );
  }

  MotorAutomationState copyWith({
    bool? isLoading,
    List<ScheduleModel>? schedules,
    String? error,
  }) {
    return MotorAutomationState(
      isLoading: isLoading ?? this.isLoading,
      schedules: schedules ?? this.schedules,
      error: error,
    );
  }
}