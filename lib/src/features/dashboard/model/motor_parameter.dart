class MotorParameter {
  final int deviceId;
  final int ts;
  final double freq;
  final double current;
  final double voltage;
  final double dcbus;
  final double power;
  final double energyIn;
  final double energyTotal;
  final int fault;
  final int statusCode;
  final double referenceFreq;
  final int motorSpeed;
  final double powerPercent;
  final double torquePercent;

  MotorParameter({
    required this.deviceId,
    required this.ts,
    required this.freq,
    required this.current,
    required this.voltage,
    required this.dcbus,
    required this.power,
    required this.energyIn,
    required this.energyTotal,
    required this.fault,
    required this.statusCode,
    required this.referenceFreq,
    required this.motorSpeed,
    required this.powerPercent,
    required this.torquePercent,
  });

  factory MotorParameter.fromMap(Map<String, dynamic> map) {
    return MotorParameter(
      deviceId: map['device_id'],
      ts: map['ts'],
      freq: (map['freq'] as num).toDouble(),
      current: (map['current'] as num).toDouble(),
      voltage: (map['voltage'] as num).toDouble(),
      dcbus: (map['dcbus'] as num).toDouble(),
      power: (map['power'] as num).toDouble(),
      energyIn: (map['energy_in'] as num).toDouble(),
      energyTotal: (map['energy_total'] as num).toDouble(),
      fault: map['fault'],
      statusCode: map['status_code'],
      referenceFreq: (map['reference_freq'] as num).toDouble(),
      motorSpeed: map['motor_speed'],
      powerPercent: (map['power_percent'] as num).toDouble(),
      torquePercent: (map['torque_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'ts': ts,
      'freq': freq,
      'current': current,
      'voltage': voltage,
      'dcbus': dcbus,
      'power': power,
      'energy_in': energyIn,
      'energy_total': energyTotal,
      'fault': fault,
      'status_code': statusCode,
      'reference_freq': referenceFreq,
      'motor_speed': motorSpeed,
      'power_percent': powerPercent,
      'torque_percent': torquePercent,
    };
  }

  MotorParameter copyWith({
    int? deviceId,
    int? ts,
    double? freq,
    double? current,
    double? voltage,
    double? dcbus,
    double? power,
    double? energyIn,
    double? energyTotal,
    int? fault,
    int? statusCode,
    double? referenceFreq,
    int? motorSpeed,
    double? powerPercent,
    double? torquePercent,
  }) {
    return MotorParameter(
      deviceId: deviceId ?? this.deviceId,
      ts: ts ?? this.ts,
      freq: freq ?? this.freq,
      current: current ?? this.current,
      voltage: voltage ?? this.voltage,
      dcbus: dcbus ?? this.dcbus,
      power: power ?? this.power,
      energyIn: energyIn ?? this.energyIn,
      energyTotal: energyTotal ?? this.energyTotal,
      fault: fault ?? this.fault,
      statusCode: statusCode ?? this.statusCode,
      referenceFreq: referenceFreq ?? this.referenceFreq,
      motorSpeed: motorSpeed ?? this.motorSpeed,
      powerPercent: powerPercent ?? this.powerPercent,
      torquePercent: torquePercent ?? this.torquePercent,
    );
  }
}