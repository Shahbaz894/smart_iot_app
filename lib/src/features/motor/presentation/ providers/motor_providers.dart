import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/features/dashboard/repository/motor_repository.dart";


import "../../../auth/ presentation/providers/auth_providers.dart";
import "../state/motor_state.dart";
import "../viewmodels/motor_viewmodel.dart";

final motorViewModelProvider =
StateNotifierProvider<MotorViewModel, MotorState>((ref) {
  return MotorViewModel(
    motorRepository: ref.read(motorRepositoryProvider),
  );
});