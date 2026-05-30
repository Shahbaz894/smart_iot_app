import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";

import "../../../auth/ presentation/providers/auth_providers.dart";


import "../../data/repositories/motor_timer_repository.dart";
import "../../data/services/motor_timer_service.dart";

import "../state/motor_timer_state.dart";
import "../viewmodels/motor_timer_viewmodel.dart";

final motorTimerServiceProvider = Provider<MotorTimerService>((ref) {
  return MotorTimerService(
    apiClient: ref.read(apiClientProvider),
  );
});

final motorTimerRepositoryProvider = Provider<MotorTimerRepository>((ref) {
  return MotorTimerRepository(
    service: ref.read(motorTimerServiceProvider),
  );
});

final motorTimerViewModelProvider =
StateNotifierProvider<MotorTimerViewModel, MotorTimerState>((ref) {
  return MotorTimerViewModel(
    repository: ref.read(motorTimerRepositoryProvider),
  );
});