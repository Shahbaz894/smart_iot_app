import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/features/logs/data/repositories/motor_log_repository.dart";
import "package:smart_iot_app/src/features/logs/data/services/motor_log_api_service.dart";


import "../../../../auth/ presentation/providers/auth_providers.dart";
import "../state/motor_log_state.dart";
import "../viewmodels/motor_log_viewmodel.dart";

final motorLogApiServiceProvider = Provider<MotorLogApiService>((ref) {
  return MotorLogApiService(
    ref.read(apiClientProvider),
  );
});

final motorLogRepositoryProvider = Provider<MotorLogRepository>((ref) {
  return MotorLogRepository(
    ref.read(motorLogApiServiceProvider),
  );
});

final motorLogViewModelProvider =
StateNotifierProvider<MotorLogViewModel, MotorLogState>((ref) {
  return MotorLogViewModel(
    motorLogRepository: ref.read(motorLogRepositoryProvider),
  );
});