import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/motor_automation_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/motor_automation_repository.dart';


class MotorAutomationViewModel extends StateNotifier<MotorAutomationState> {
  final MotorAutomationRepository repository;

  MotorAutomationViewModel(this.repository) : super(MotorAutomationState.initial());

  Future<void> loadSchedules(int deviceId) async {
    state = state.copyWith(isLoading: true);

    try {
      final schedules = await repository.fetchSchedules(deviceId);

      state = state.copyWith(
        isLoading: false,
        schedules: schedules,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}