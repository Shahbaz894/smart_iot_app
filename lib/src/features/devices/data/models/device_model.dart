class DeviceModel {
  final String id;
  final String userId;
  final String deviceUid;
  final String name;
  final String location;
  final bool isOnline;

  const DeviceModel({
    required this.id,
    required this.userId,
    required this.deviceUid,
    required this.name,
    required this.location,
    required this.isOnline,
  });

  String get primaryDeviceId {
    if (deviceUid.trim().isNotEmpty) return deviceUid;
    return id;
  }

  String get displayName {
    if (name.trim().isNotEmpty) return name;
    if (deviceUid.trim().isNotEmpty) return deviceUid;
    return "SmartWell Device";
  }

  bool matches(String value) {
    final input = value.trim().toLowerCase();

    return id.toLowerCase() == input ||
        deviceUid.toLowerCase() == input ||
        name.toLowerCase() == input;
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final rawOnline = json["is_online"] ?? json["online"] ?? json["is_live"];

    final bool isOnlineValue =
        rawOnline == true ||
            rawOnline == 1 ||
            (rawOnline is String && rawOnline.toLowerCase() == "true") ||
            (rawOnline is String && rawOnline == "1");

    return DeviceModel(
      id: (json["id"] ?? "").toString(),
      userId: (json["user_id"] ?? "").toString(),
      deviceUid: (json["device_uid"] ??
          json["device_id"] ??
          "")
          .toString(),
      name: (json["device_name"] ??
          json["name"] ??
          "")
          .toString(),
      location: (json["location"] ?? "").toString(),
      isOnline: isOnlineValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "device_uid": deviceUid,
      "device_name": name,
      "location": location,
      "is_online": isOnline,
    };
  }
}