class SensorData {
  final double waterLevel;
  final double temperature;
  final double humidity;

  SensorData({
    required this.waterLevel,
    required this.temperature,
    required this.humidity,
  });
  factory SensorData.fromMap(Map<dynamic, dynamic>? data) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    if (data == null) {
      return SensorData(
        waterLevel: 0.0,
        temperature: 0.0,
        humidity: 0.0,
      );
    }

    return SensorData(
      waterLevel: parseDouble(data['water_level']),
      temperature: parseDouble(data['temperature']),
      humidity: parseDouble(data['humidity']),
    );
  }

  // This factory will eventually handle Firebase Map data
  factory SensorData.fromMock(double level, double temp, double hum) {
    return SensorData(waterLevel: level, temperature: temp, humidity: hum);
  }
}