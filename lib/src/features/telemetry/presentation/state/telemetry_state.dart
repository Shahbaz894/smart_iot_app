import "../../data/models/telemetry_model.dart";

class TelemetryState {
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final TelemetryModel? latest;
  final List<TelemetryModel> records;

  const TelemetryState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.latest,
    this.records = const [],
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TelemetryState &&
        other.isLoading == isLoading &&
        other.isRefreshing == isRefreshing &&
        other.error == error &&
        other.latest == latest;  // uses TelemetryModel.== above
  }

  @override
  int get hashCode => Object.hash(isLoading, isRefreshing, error, latest);

  TelemetryState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    TelemetryModel? latest,
    List<TelemetryModel>? records,
  }) {
    return TelemetryState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      latest: latest ?? this.latest,
      records: records ?? this.records,
    );
  }
}