import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/features/dashboard/model/time_model.dart';

class MotorStatus {
  final double inputVoltage;
  final double outputVoltage;
  final double current;
  final double frequency;
  final bool running;

  MotorStatus({
    required this.inputVoltage,
    required this.outputVoltage,
    required this.current,
    required this.frequency,
    required this.running,
  });

  /// Factory constructor to safely parse values from a Map (Firebase snapshot)
  factory MotorStatus.fromMap(Map<dynamic, dynamic>? data) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    if (data == null) {
      return MotorStatus(
        inputVoltage: 0.0,
        outputVoltage: 0.0,
        current: 0.0,
        frequency: 0.0,
        running: false,
      );
    }

    return MotorStatus(
      inputVoltage: parseDouble(data['input_voltage']),
      outputVoltage: parseDouble(data['output_voltage']),
      current: parseDouble(data['current']),
      frequency: parseDouble(data['frequency']),
      running: data['running'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'input_voltage': inputVoltage,
      'output_voltage': outputVoltage,
      'current': current,
      'frequency': frequency,
      'running': running,
    };
  }

  MotorStatus copyWith({
    double? inputVoltage,
    double? outputVoltage,
    double? current,
    double? frequency,
    bool? running,
  }) {
    return MotorStatus(
      inputVoltage: inputVoltage ?? this.inputVoltage,
      outputVoltage: outputVoltage ?? this.outputVoltage,
      current: current ?? this.current,
      frequency: frequency ?? this.frequency,
      running: running ?? this.running,
    );
  }
}


