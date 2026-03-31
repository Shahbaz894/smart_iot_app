import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/fault_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/fault_repository.dart';

class FaultViewModel extends StateNotifier<FaultState> {
  final FaultRepository repository;

  FaultViewModel(this.repository) : super(FaultState.initial());

  Future<void> loadFaults(int deviceId) async {
    state = state.copyWith(loading: true);

    try {
      final faults = await repository.getFaultHistory(deviceId);

      state = state.copyWith(
        loading: false,
        faults: faults,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }
}