import 'dart:core';

class DeviceModel {
  final String id;
  final String userId;
  final String deviceUid;
  final String name;
  final String location;
  final bool isOnline;
  /// ⏳ IoT Failsafe Heartbeat parameter added
  final DateTime? updatedAt;

  const DeviceModel({
    required this.id,
    required this.userId,
    required this.deviceUid,
    required this.name,
    required this.location,
    required this.isOnline,
    this.updatedAt,
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
    final rawOnline = json["is_online"];

    final bool isOnlineValue =
        rawOnline == true ||
            rawOnline == 1 ||
            (rawOnline is String && rawOnline.toLowerCase() == "true") ||
            (rawOnline is String && rawOnline == "1");

    // Safely parse timestamp from multiple backend variants
    DateTime? parsedTime;
    final rawTime = json["updated_at"] ?? json["created_at"] ?? json["timestamp"];
    if (rawTime != null) {
      if (rawTime is int) {
        // Agar epoch timestamp (seconds/milliseconds) aa raha ho
        parsedTime = DateTime.fromMillisecondsSinceEpoch(
          rawTime < 9999999999 ? rawTime * 1000 : rawTime,
        );
      } else {
        parsedTime = DateTime.tryParse(rawTime.toString());
      }
    } else {
      // Failsafe: Agar backend se time na aaye, to app ka current runtime time record ho jaye
      parsedTime = DateTime.now();
    }

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
      updatedAt: parsedTime,
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
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  /// Helper method to safely duplicate states in riverpod/bloc providers
  DeviceModel copyWith({
    String? id,
    String? userId,
    String? deviceUid,
    String? name,
    String? location,
    bool? isOnline,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceUid: deviceUid ?? this.deviceUid,
      name: name ?? this.name,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}