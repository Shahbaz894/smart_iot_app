import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";


import "../../../auth/ presentation/providers/auth_providers.dart";
import "../../data/repositories/schedule_repository.dart";
import "../../data/services/schedule_api_service.dart";
import "../state/schedule_state.dart";
import "../viewmodels/schedule_viewmodel.dart";

final scheduleApiServiceProvider = Provider<ScheduleApiService>((ref) {
  return ScheduleApiService(
    ref.read(apiClientProvider),
  );
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(
    ref.read(scheduleApiServiceProvider),
  );
});

final scheduleViewModelProvider =
StateNotifierProvider<ScheduleViewModel, ScheduleState>((ref) {
  return ScheduleViewModel(
    scheduleRepository: ref.read(scheduleRepositoryProvider),
  );
});