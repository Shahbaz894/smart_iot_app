class ScheduleSlot {
  final String startTime;
  final String endTime;

  const ScheduleSlot({
    required this.startTime,
    required this.endTime,
  });

  ScheduleSlot copyWith({
    String? startTime,
    String? endTime,
  }) {
    return ScheduleSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "start_time": startTime,
      "end_time": endTime,
    };
  }

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      startTime: json["start_time"]?.toString() ??
          json["startTime"]?.toString() ??
          json["start"]?.toString() ??
          "09:00",
      endTime: json["end_time"]?.toString() ??
          json["endTime"]?.toString() ??
          json["end"]?.toString() ??
          "12:00",
    );
  }

  bool get isValid {
    return _toMinutes(startTime) < _toMinutes(endTime);
  }

  static int _toMinutes(String value) {
    final parts = value.split(":");

    if (parts.length < 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }
}

class ScheduleDayConfig {
  final String day;
  final bool enabled;
  final List<ScheduleSlot> slots;

  const ScheduleDayConfig({
    required this.day,
    required this.enabled,
    required this.slots,
  });

  ScheduleDayConfig copyWith({
    String? day,
    bool? enabled,
    List<ScheduleSlot>? slots,
  }) {
    return ScheduleDayConfig(
      day: day ?? this.day,
      enabled: enabled ?? this.enabled,
      slots: slots ?? this.slots,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "day": day,
      "enabled": enabled,
      "slots": slots.map((slot) => slot.toJson()).toList(),
    };
  }

  factory ScheduleDayConfig.fromJson(Map<String, dynamic> json) {
    final rawSlots = json["slots"];

    return ScheduleDayConfig(
      day: json["day"]?.toString().toLowerCase() ?? "",
      enabled: _toBool(json["enabled"]),
      slots: rawSlots is List
          ? rawSlots
          .whereType<Map>()
          .map(
            (slot) => ScheduleSlot.fromJson(
          Map<String, dynamic>.from(slot),
        ),
      )
          .toList()
          : <ScheduleSlot>[],
    );
  }

  static bool _toBool(dynamic value) {
    if (value == true) return true;
    if (value == 1) return true;
    if (value?.toString().toLowerCase() == "true") return true;
    return false;
  }
}

class ScheduleModel {
  final String? id;
  final String deviceId;
  final String scheduleType;
  final Map<String, dynamic> pattern;
  final String? scheduleName;
  final bool isActive;
  final DateTime? createdAt;

  const ScheduleModel({
    this.id,
    required this.deviceId,
    required this.scheduleType,
    required this.pattern,
    this.scheduleName,
    this.isActive = true,
    this.createdAt,
  });

  factory ScheduleModel.weekly({
    required String deviceId,
    required List<ScheduleDayConfig> days,
    String scheduleName = "Weekly Motor Irrigation Schedule",
    String timezone = "Asia/Karachi",
    bool enabled = true,
  }) {
    return ScheduleModel(
      deviceId: deviceId,
      scheduleType: "weekly",
      scheduleName: scheduleName,
      isActive: enabled,
      pattern: {
        "timezone": timezone,
        "enabled": enabled,
        "days": days.map((day) => day.toJson()).toList(),
      },
    );
  }

  bool get enabled {
    final value = pattern["enabled"];
    return isActive && value != false;
  }

  String get timezone {
    return pattern["timezone"]?.toString() ?? "Asia/Karachi";
  }

  List<ScheduleDayConfig> get weeklyDays {
    final rawDays = pattern["days"];

    if (rawDays is! List) return <ScheduleDayConfig>[];

    return rawDays
        .whereType<Map>()
        .map(
          (day) => ScheduleDayConfig.fromJson(
        Map<String, dynamic>.from(day),
      ),
    )
        .toList();
  }

  ScheduleModel copyWith({
    String? id,
    String? deviceId,
    String? scheduleType,
    Map<String, dynamic>? pattern,
    String? scheduleName,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      scheduleType: scheduleType ?? this.scheduleType,
      pattern: pattern ?? this.pattern,
      scheduleName: scheduleName ?? this.scheduleName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "device_id": deviceId,
      "schedule_type": scheduleType,
      "pattern": pattern,
      "schedule_name": scheduleName,
      "is_active": isActive,
    };
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    dynamic pick(String snake, String camel) {
      return json[snake] ?? json[camel];
    }

    final rawPattern = json["pattern"];

    return ScheduleModel(
      id: json["id"]?.toString(),
      deviceId: pick("device_id", "deviceId")?.toString() ?? "",
      scheduleType: pick("schedule_type", "scheduleType")?.toString() ?? "weekly",
      pattern: rawPattern is Map
          ? Map<String, dynamic>.from(rawPattern)
          : <String, dynamic>{},
      scheduleName: pick("schedule_name", "scheduleName")?.toString(),
      isActive: _toBool(pick("is_active", "isActive")),
      createdAt: pick("created_at", "createdAt") == null
          ? null
          : DateTime.tryParse(pick("created_at", "createdAt").toString()),
    );
  }

  static bool _toBool(dynamic value) {
    if (value == null) return true;
    if (value == true) return true;
    if (value == 1) return true;
    if (value?.toString().toLowerCase() == "true") return true;
    return false;
  }
}
