import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/mqtt/mqtt_stream_service.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/models/motor_log_response.dart";
import "../../data/repositories/motor_repository.dart";

import "../state/motor_state.dart";

class MotorViewModel extends StateNotifier<MotorState> {
  final MotorRepository motorRepository;

  final MqttStreamService mqttStreamService;

  MotorViewModel({
    required this.motorRepository,
    required this.mqttStreamService,
  }) : super(const MotorState());

  /// 🛰️ START LIVE MQTT SYNC LOCK (Isay screen loading par call karein)
  // void listenToLiveHardwareSync(String deviceId) {
  //   final safeDeviceId = deviceId.trim();
  //   if (safeDeviceId.isEmpty) return;
  //
  //   // Broker se connection engine start karein
  //   mqttStreamService.initMqttSession(safeDeviceId);
  //
  //   // Jab bhi broker par koi bhi badlao aayega, UI instantly change hoga
  //   mqttStreamService.liveStatus.addListener(() {
  //     final newStatus = mqttStreamService.liveStatus.value;
  //     if (newStatus != MotorCommandStatus.unknown && state.commandStatus != newStatus) {
  //       debugPrint("⚡ RIVERPOD NOTIFIER => Syncing UI State to Match MQTT Broker: $newStatus");
  //       state = state.copyWith(commandStatus: newStatus);
  //     }
  //   });
  // }
  void listenToLiveHardwareSync(String deviceId) {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) return;

    mqttStreamService.initMqttSession(safeDeviceId);

    mqttStreamService.liveStatus.addListener(() {
      final newStatus = mqttStreamService.liveStatus.value;

      debugPrint(
        "📡 MQTT STATUS RECEIVED => $newStatus",
      );

      if (newStatus == MotorCommandStatus.unknown) {
        return;
      }

      if (state.commandStatus == newStatus) {
        return;
      }

      state = state.copyWith(
        commandStatus: newStatus,
      );

      debugPrint(
        "⚡ UI UPDATED FROM MQTT => $newStatus",
      );
    });
  }

  /// 🟢 START MOTOR BUTTON ACTION
  Future<MotorLogResponse?> startMotor({
    required String deviceId,
    required String customerName,
  }) async {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return null;
    if (state.isLoading) return null;

    try {
      state = state.copyWith(isLoading: true, error: null, message: null);

      // Secure FastAPI Gateway call
      final log = await motorRepository.start(
        deviceId: safeDeviceId,
        customerName: customerName,
      );

      // UI update immediately to show responsiveness
      state = state.copyWith(
        isLoading: false,
        error: null,
        message: "Motor started successfully",
        motorLog: log,
        commandStatus: MotorCommandStatus.on,
      );

      return log;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to start motor: ${e.toString()}");
      return null;
    }
  }

  /// 🔴 STOP MOTOR BUTTON ACTION
  Future<MotorLogResponse?> stopMotor({
    required String deviceId,
    required String customerName,
  }) async {
    final safeDeviceId = deviceId.trim();
    if (safeDeviceId.isEmpty) return null;
    if (state.isLoading) return null;

    try {
      state = state.copyWith(isLoading: true, error: null, message: null);

      // Secure FastAPI Gateway call
      final log = await motorRepository.stop(
        deviceId: safeDeviceId,
        customerName: customerName,
      );

      state = state.copyWith(
        isLoading: false,
        error: null,
        message: "Motor stopped successfully",
        motorLog: log,
        commandStatus: MotorCommandStatus.off,
      );

      return log;
    } on AppException catch (e) {
      // 🚀 HARDWARE SAFE BYPASS ZONE: Even if DB session log row gives 404 error,
      // we forcefully update UI to OFF to ensure safe manual alignment.
      state = state.copyWith(
        isLoading: false,
        commandStatus: MotorCommandStatus.off,
        error: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to stop motor: ${e.toString()}");
      return null;
    }
  }
  Future<void> loadInitialMotorState({
    required String deviceId,
  }) async {
    final safeDeviceId = deviceId.trim();

    if (safeDeviceId.isEmpty) return;

    try {
      debugPrint(
        "🔄 LOADING INITIAL MOTOR STATE => $safeDeviceId",
      );

      final status = await motorRepository.getLatestCommand(
        deviceId: safeDeviceId,
      );

      debugPrint(
        "✅ INITIAL MOTOR STATE => $status",
      );

      state = state.copyWith(
        commandStatus: status,
        error: null,
      );
    } catch (e) {
      debugPrint(
        "❌ INITIAL MOTOR STATE FAILED => $e",
      );
    }
  }

  @override
  void dispose() {
    mqttStreamService.closeSession();
    super.dispose();
  }
}