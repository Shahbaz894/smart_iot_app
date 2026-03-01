class IoTDevice {
  final String name;
  final bool isOn;
  final int pin;

  IoTDevice({required this.name, required this.isOn, required this.pin});

  // Convert Firebase Map to Object
  factory IoTDevice.fromMap(Map<dynamic, dynamic> map) {
    return IoTDevice(
      name: map['name'] ?? 'Unknown Device',
      isOn: map['is_on'] ?? false,
      pin: map['pin'] ?? 0,
    );
  }

  // Convert Object to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'is_on': isOn,
      'pin': pin,
    };
  }

  IoTDevice copyWith({String? name, bool? isOn, int? pin}) {
    return IoTDevice(
      name: name ?? this.name,
      isOn: isOn ?? this.isOn,
      pin: pin ?? this.pin,
    );
  }
}