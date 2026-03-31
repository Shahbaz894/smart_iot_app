import 'package:smart_iot_app/src/core/exceptions/app_error.dart';

import '../../../core/exceptions/app_exception.dart';

import 'package:smart_iot_app/src/core/exceptions/app_error.dart';

class MotorOnOffModel {
  final bool success;
  final String message;

  const MotorOnOffModel({
    required this.success,
    required this.message,
  });

  factory MotorOnOffModel.fromMap(Map<String, dynamic> map) {
    return MotorOnOffModel(
      success: map['success'] == true,
      message: map['message']?.toString() ?? "Unknown response",
    );
  }

  Map<String, dynamic> toMap() => {
    "success": success,
    "message": message,
  };

  MotorOnOffModel copyWith({
    bool? success,
    String? message,
  }) {
    return MotorOnOffModel(
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }
}