import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";



import "../../../auth/ presentation/providers/auth_providers.dart";
import "../state/telemetry_state.dart";
import "../viewmodels/telemetry_viewmodel.dart";

final telemetryViewModelProvider =
StateNotifierProvider<TelemetryViewModel, TelemetryState>((ref) {
  return TelemetryViewModel(
    telemetryRepository: ref.read(telemetryRepositoryProvider),
  );
});
