
import "package:flutter/cupertino.dart";

import "../../presentation/state/motor_state.dart";
import "../models/motor_log_response.dart";
import "../services/motor_api_service.dart";

class MotorRepository {
  final MotorApiService motorApiService;

  MotorRepository(this.motorApiService);

  Future<MotorCommandStatus> getLatestCommand({
    required String deviceId,
  }) {
    return motorApiService.getLatestCommand(
      deviceId: deviceId.trim(),
    );
  }

  Future<MotorLogResponse> start({
    required String deviceId,
    required String customerName,
  }) {
    return motorApiService.startMotor(
      deviceId: deviceId.trim(),
      customerName: customerName,

    );
  }

  Future<MotorLogResponse> stop({
    required String deviceId,
    required String customerName,
  }) {
    return motorApiService.stopMotor(
      deviceId: deviceId.trim(),
      customerName: customerName,
    );
  }


  Future<MotorLogResponse?> getRunningMotor(String deviceId) async {
    try {
      // Backend par naya endpoint banayein ya existing API se filter karein
      // Agar API `GET /motor/running/{deviceId}` return karti hai:
      return await motorApiService.getRunningMotor(deviceId.trim());
    } catch (e) {
      debugPrint("❌ Error fetching running motor: $e");
      return null; // Agar koi motor nahi chal rahi, toh null return karein
    }
  }
}

