class FaultModel {
  final int id;
  final int deviceId;
  final int ts;
  final String datetime;
  final int faultCode;

  FaultModel({
    required this.id,
    required this.deviceId,
    required this.ts,
    required this.datetime,
    required this.faultCode,
  });

  FaultModel copyWith({
    int? id,
    int? deviceId,
    int? ts,
    String? datetime,
    int? faultCode,
  }) {
    return FaultModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      ts: ts ?? this.ts,
      datetime: datetime ?? this.datetime,
      faultCode: faultCode ?? this.faultCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "device_id": deviceId,
      "ts": ts,
      "datetime": datetime,
      "fault_code": faultCode,
    };
  }

  factory FaultModel.fromMap(Map<String, dynamic> map) {
    return FaultModel(
      id: map['id'] ?? 0,
      deviceId: map['device_id'] ?? 0,
      ts: map['ts'] ?? 0,
      datetime: map['datetime'] ?? '',
      faultCode: map['fault_code'] ?? 0,
    );
  }
}