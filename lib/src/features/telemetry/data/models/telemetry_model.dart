class TelemetryModel {
  final String? id;
  final String? deviceId;
  final int? isLive;

  final double? voltage;
  final double? current;
  final double? freq;
  final double? power;
  final double? powerPercent;
  final double? torquePercent;
  final double? motorSpeed;
  final double? dcbus;
  final double? energyIn;

  final int? fault;
  final int? faultCode;
  final int? statusCode;

  final int? timestamp;
  final DateTime? createdAt;

  final double? referenceFreq;

  const TelemetryModel({
    this.id,
    this.deviceId,
    this.isLive,
    this.voltage,
    this.current,
    this.freq,
    this.power,
    this.powerPercent,
    this.torquePercent,
    this.motorSpeed,
    this.dcbus,
    this.energyIn,
    this.fault,
    this.faultCode,
    this.statusCode,
    this.timestamp,
    this.createdAt,
    this.referenceFreq,
  });

  TelemetryModel copyWith({
    String? id,
    String? deviceId,
    int? isLive,
    double? voltage,
    double? current,
    double? freq,
    double? power,
    double? powerPercent,
    double? torquePercent,
    double? motorSpeed,
    double? dcbus,
    double? energyIn,
    int? fault,
    int? faultCode,
    int? statusCode,
    int? timestamp,
    DateTime? createdAt,
    double? referenceFreq,
  }) {
    return TelemetryModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      isLive: isLive ?? this.isLive,
      voltage: voltage ?? this.voltage,
      current: current ?? this.current,
      freq: freq ?? this.freq,
      power: power ?? this.power,
      powerPercent: powerPercent ?? this.powerPercent,
      torquePercent: torquePercent ?? this.torquePercent,
      motorSpeed: motorSpeed ?? this.motorSpeed,
      dcbus: dcbus ?? this.dcbus,
      energyIn: energyIn ?? this.energyIn,
      fault: fault ?? this.fault,
      faultCode: faultCode ?? this.faultCode,
      statusCode: statusCode ?? this.statusCode,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      referenceFreq: referenceFreq ?? this.referenceFreq,
    );
  }

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryModel(
      id: _readString(json, ["id"]),
      deviceId: _readString(json, ["device_id", "device_uid", "deviceId"]),

      isLive: _readInt(json, ["is_live", "isLive"]),

      voltage: _readDouble(json, ["voltage"]),
      current: _readDouble(json, ["current"]),
      freq: _readDouble(json, ["freq", "frequency"]),
      power: _readDouble(json, ["power"]),
      powerPercent: _readDouble(json, ["power_percent", "powerPercent"]),
      torquePercent: _readDouble(json, ["torque_percent", "torquePercent"]),
      motorSpeed: _readDouble(json, ["motor_speed", "motorSpeed"]),
      dcbus: _readDouble(json, ["dcbus", "dc_bus", "dcBus"]),
      energyIn: _readDouble(json, ["energy_in", "energyIn"]),

      fault: _readInt(json, ["fault"]),
      faultCode: _readInt(json, ["fault_code", "faultCode"]),
      statusCode: _readInt(json, ["status_code", "statusCode"]),

      timestamp: _readInt(json, ["timestamp", "time"]),
      createdAt: _readDateTime(json, ["created_at", "createdAt"]),

      referenceFreq: _readDouble(
        json,
        ["reference_freq", "referenceFreq"],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "device_id": deviceId,
      "is_live": isLive,
      "voltage": voltage,
      "current": current,
      "freq": freq,
      "power": power,
      "power_percent": powerPercent,
      "torque_percent": torquePercent,
      "motor_speed": motorSpeed,
      "dcbus": dcbus,
      "energy_in": energyIn,
      "fault": fault,
      "fault_code": faultCode,
      "status_code": statusCode,
      "timestamp": timestamp,
      "created_at": createdAt?.toUtc().toIso8601String(),
      "reference_freq": referenceFreq,
    };
  }

  bool isFresh({
    int withinSeconds = 20,
  }) {
    final nowSeconds = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    if (createdAt != null) {
      final createdAtSeconds =
          createdAt!.toUtc().millisecondsSinceEpoch ~/ 1000;

      final diff = nowSeconds - createdAtSeconds;

      return diff >= 0 && diff <= withinSeconds;
    }

    if (timestamp == null || timestamp! <= 1700000000) {
      return false;
    }

    final diff = nowSeconds - timestamp!;

    return diff >= 0 && diff <= withinSeconds;
  }

  static dynamic _readValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) {
        return json[key];
      }
    }
    return null;
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    final value = _readValue(json, keys);
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty) return null;

    return text;
  }

  static int? _readInt(Map<String, dynamic> json, List<String> keys) {
    final value = _readValue(json, keys);
    if (value == null) return null;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  static double? _readDouble(Map<String, dynamic> json, List<String> keys) {
    final value = _readValue(json, keys);
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static DateTime? _readDateTime(
      Map<String, dynamic> json,
      List<String> keys,
      ) {
    final value = _readValue(json, keys);
    if (value == null) return null;

    return DateTime.tryParse(value.toString())?.toUtc();
  }
}