import '../model/fault_model.dart';

class FaultState {
  final bool loading;
  final List<FaultModel> faults;
  final String? error;

  FaultState({
    required this.loading,
    required this.faults,
    this.error,
  });

  factory FaultState.initial() {
    return FaultState(
      loading: false,
      faults: [],
      error: null,
    );
  }

  FaultState copyWith({
    bool? loading,
    List<FaultModel>? faults,
    String? error,
  }) {
    return FaultState(
      loading: loading ?? this.loading,
      faults: faults ?? this.faults,
      error: error,
    );
  }
}