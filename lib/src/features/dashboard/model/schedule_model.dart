
import 'package:flutter/material.dart';

class ScheduleModel {
  final int id;
  final int deviceId;
  final String scheduleType;
  final DateTime? startDateTime;
  final DateTime? stopDateTime;
  final TimeOfDay? startTime;
  final TimeOfDay? stopTime;
  final bool isEnabled;

  ScheduleModel({
    required this.id,
    required this.deviceId,
    required this.scheduleType,
    this.startDateTime,
    this.stopDateTime,
    this.startTime,
    this.stopTime,
    required this.isEnabled,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? t) {
      if (t == null) return null;
      final parts = t.split(":");
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return ScheduleModel(
      id: json['id'],
      deviceId: json['device_id'],
      scheduleType: json['schedule_type'],
      startDateTime: json['start_datetime'] != null
          ? DateTime.parse(json['start_datetime'])
          : null,
      stopDateTime: json['stop_datetime'] != null
          ? DateTime.parse(json['stop_datetime'])
          : null,
      startTime: parseTime(json['start_time']),
      stopTime: parseTime(json['stop_time']),
      isEnabled: json['is_enabled'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "device_id": deviceId,
      "schedule_type": scheduleType,
      "start_datetime": startDateTime?.toIso8601String(),
      "stop_datetime": stopDateTime?.toIso8601String(),
      "start_time":
      startTime != null ? "${startTime!.hour}:${startTime!.minute}:00" : null,
      "stop_time":
      stopTime != null ? "${stopTime!.hour}:${stopTime!.minute}:00" : null,
      "is_enabled": isEnabled ? 1 : 0,
    };
  }
}