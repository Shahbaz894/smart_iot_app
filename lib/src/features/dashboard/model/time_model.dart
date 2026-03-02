// import 'package:flutter/material.dart';
//
// class TimerDevice {
//   final String id;
//   final String title;
//   final TimeOfDay startTime;
//   final TimeOfDay stopTime;
//   final int espPin;
//   final bool isEnabled;
//
//   TimerDevice({
//     required this.id,
//     required this.title,
//     required this.startTime,
//     required this.stopTime,
//     required this.espPin,
//     this.isEnabled = true,
//   });
//
//   // To display in the UI
//   String formatRange(BuildContext context) {
//     return "${startTime.format(context)} - ${stopTime.format(context)}";
//   }
//
//   // To save to Realtime Database (ESP32 friendly format)
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'startHour': startTime.hour,
//       'startMinute': startTime.minute,
//       'stopHour': stopTime.hour,
//       'stopMinute': stopTime.minute,
//       'gpio': espPin,
//       'active': isEnabled,
//     };
//   }
//
//
// }

import 'package:flutter/material.dart';

class TimerDevice {
  final String id;
  final String title;
  final int day; // NEW: day of month, e.g., 1-31
  final TimeOfDay startTime;
  final TimeOfDay stopTime;
  final int espPin;
  final bool isEnabled;

  TimerDevice({
    required this.id,
    required this.title,
    required this.day, // include day in constructor
    required this.startTime,
    required this.stopTime,
    required this.espPin,
    this.isEnabled = true,
  });

  // CopyWith Method
  TimerDevice copyWith({
    String? id,
    String? title,
    int? day,
    TimeOfDay? startTime,
    TimeOfDay? stopTime,
    int? espPin,
    bool? isEnabled,
  }) {
    return TimerDevice(
      id: id ?? this.id,
      title: title ?? this.title,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      stopTime: stopTime ?? this.stopTime,
      espPin: espPin ?? this.espPin,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  // To display in UI
  String formatRange(BuildContext context) {
    return "${startTime.format(context)} - ${stopTime.format(context)}";
  }

  // Convert to Map (Firebase / ESP32 friendly)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'day': day,
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'stopHour': stopTime.hour,
      'stopMinute': stopTime.minute,
      'gpio': espPin,
      'active': isEnabled,
    };
  }

  // Create from Map (Firebase read)
  factory TimerDevice.fromMap(String id, Map<dynamic, dynamic> map) {
    return TimerDevice(
      id: id,
      title: map['title'] ?? '',
      day: map['day'] ?? 1, // read day from map
      startTime: TimeOfDay(
        hour: map['startHour'] ?? 0,
        minute: map['startMinute'] ?? 0,
      ),
      stopTime: TimeOfDay(
        hour: map['stopHour'] ?? 0,
        minute: map['stopMinute'] ?? 0,
      ),
      espPin: map['gpio'] ?? 0,
      isEnabled: map['active'] ?? true,
    );
  }
}
