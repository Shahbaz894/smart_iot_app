class SensorState {
  final double waterLevel; // 0.0 to 100.0
  final double temperature;
  final double humidity;
  final List<double> waterHistory; // For the chart

  SensorState({
    this.waterLevel = 0.0,
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.waterHistory = const [],
  });

  SensorState copyWith({
    double? waterLevel,
    double? temperature,
    double? humidity,
    List<double>? waterHistory,
  }) {
    return SensorState(
      waterLevel: waterLevel ?? this.waterLevel,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      waterHistory: waterHistory ?? this.waterHistory,
    );
  }
}