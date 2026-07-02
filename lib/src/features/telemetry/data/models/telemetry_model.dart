class TelemetryModel {
  final DateTime? createdAt;
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
  final double? referenceFreq;
  final String? triggerType; // <--- Naya Field

  TelemetryModel({
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
    this.referenceFreq,
    this.createdAt,
    this.triggerType, // <--- Constructor mein add kiya
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TelemetryModel &&
        other.createdAt == createdAt &&
        other.id == id &&
        other.deviceId == deviceId &&
        other.isLive == isLive &&
        other.voltage == voltage &&
        other.current == current &&
        other.freq == freq &&
        other.power == power &&
        other.powerPercent == powerPercent &&
        other.torquePercent == torquePercent &&
        other.motorSpeed == motorSpeed &&
        other.dcbus == dcbus &&
        other.energyIn == energyIn &&
        other.fault == fault &&
        other.faultCode == faultCode &&
        other.statusCode == statusCode &&
        other.timestamp == timestamp &&
        other.referenceFreq == referenceFreq &&
        other.triggerType == triggerType; // <--- Equality mein add kiya
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    deviceId,
    isLive,
    voltage,
    current,
    freq,
    power,
    powerPercent,
    torquePercent,
    motorSpeed,
    dcbus,
    energyIn,
    fault,
    faultCode,
    statusCode,
    timestamp,
    referenceFreq,
    triggerType, // <--- HashCode mein add kiya
  );

  TelemetryModel copyWith({
    DateTime? createdAt,
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
    double? referenceFreq,
    String? triggerType, // <--- CopyWith mein add kiya
  }) {
    return TelemetryModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
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
      referenceFreq: referenceFreq ?? this.referenceFreq,
      triggerType: triggerType ?? this.triggerType, // <--- Assignment
    );
  }

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    int? toInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    return TelemetryModel(
      createdAt: json["created_at"] != null
          ? DateTime.tryParse(json["created_at"].toString())
          : null,
      id: json["id"]?.toString(),
      deviceId: json["device_id"]?.toString(),
      isLive: toInt(json["is_live"]),
      voltage: toDouble(json["voltage"]),
      current: toDouble(json["current"]),
      freq: toDouble(json["freq"]),
      power: toDouble(json["power"]),
      powerPercent: toDouble(json["power_percent"]),
      torquePercent: toDouble(json["torque_percent"]),
      motorSpeed: toDouble(json["motor_speed"]),
      dcbus: toDouble(json["dcbus"]),
      energyIn: toDouble(json["energy_in"]),
      fault: toInt(json["fault"]),
      faultCode: toInt(json["fault_code"]),
      statusCode: toInt(json["status_code"]),
      timestamp: toInt(json["timestamp"]),
      referenceFreq: toDouble(json["reference_freq"] ?? json["referenceFreq"]),
      triggerType: json["trigger_type"]?.toString(), // <--- JSON Parser mein add kiya
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
      "reference_freq": referenceFreq,
      "trigger_type": triggerType, // <--- Yeh sabse important hai!
    };
  }

  void operator [](String other) {}
}