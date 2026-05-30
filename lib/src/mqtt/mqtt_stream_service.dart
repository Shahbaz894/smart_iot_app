import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:smart_iot_app/src/features/dashboard/domain/motor_on_off_state.dart';
import 'package:smart_iot_app/src/features/motor/presentation/state/motor_state.dart';

class MqttStreamService {
  final String serverIp = "157.245.55.83";
  final int port = 1883;
  MqttServerClient? _client;

  // 🚀 Live Stream Status Notifier
  final ValueNotifier<MotorCommandStatus> liveStatus =
  ValueNotifier<MotorCommandStatus>(MotorCommandStatus.unknown);

  Future<void> initMqttSession(String deviceId) async {
    final String safeId = deviceId.trim();
    if (safeId.isEmpty) return;

    final String clientId = 'smartwell_flutter_${safeId}_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(serverIp, clientId);
    _client!.port = port;
    _client!.keepAlivePeriod = 30;
    _client!.logging(on: false);

    _client!.onDisconnected = () {
      debugPrint("❌ MQTT Stream: Disconnected from Broker");
    };

    _client!.onConnected = () {
      debugPrint("✅ MQTT Stream: Connected to Mosquitto Broker!");
      _subscribeToTopics(safeId);
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      debugPrint("❌ MQTT Connection Failed: $e");
      _client!.disconnect();
    }

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c == null || c.isEmpty) return;

      final recMess = c[0].payload as MqttPublishMessage;
      final rawPayload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      final topic = c[0].topic;

      try {
        final data = jsonDecode(rawPayload);
        debugPrint("🛰️ MQTT LIVE PACKET CAPTURED: $data");

        if (topic.contains('motor') || topic.contains('telemetry')) {
          bool? isEngineRunning;

          // 1. Check inside explicit command/action keys (from app or direct commands)
          final rawCmd = data["command"] ?? data["status"] ?? data["state"] ?? data["action"];
          if (rawCmd != null) {
            final text = rawCmd.toString().toLowerCase().trim();
            if (text == "on" || text == "start" || text == "1") {
              isEngineRunning = true;
            } else if (text == "off" || text == "stop" || text == "0") {
              isEngineRunning = false;
            }
          }

          // 2. Check explicitly for boolean indicators
          if (data["is_on"] != null) {
            isEngineRunning = data["is_on"] == true;
          }

          // 3. 🎯 CRITICAL FIX: Extract VFD status codes directly from ESP32 telemetry packet
          if (data["status_code"] != null) {
            final int statusCode = int.tryParse(data["status_code"].toString()) ?? 0;
            // 1 = Forward Running, 2 = Reverse Running. Anything else (0) means Motor is stopped/off!
            isEngineRunning = (statusCode == 1 || statusCode == 2);
          }

          // 4. Fallback Safety Check (Agar status_code miss ho jaye but current/freq zero ho)
          if (data["freq"] != null && data["current"] != null) {
            final double freq = double.tryParse(data["freq"].toString()) ?? 0.0;
            final double current = double.tryParse(data["current"].toString()) ?? 0.0;
            if (freq == 0.0 && current == 0.0) {
              isEngineRunning = false;
            }
          }

          // 🔥 Update the ValueNotifier instantly to update UI hooks
          if (isEngineRunning != null) {
            liveStatus.value = isEngineRunning ? MotorCommandStatus.on : MotorCommandStatus.off;
            debugPrint("🧠 STATE RESOLVER OUTPUT => ${liveStatus.value}");
          }
        }
      } catch (e) {
        debugPrint("🧠 MQTT JSON Parse Error: $e");
      }
    });
  }

  void _subscribeToTopics(String deviceId) {
    _client?.subscribe('tubewell/$deviceId/motor', MqttQos.atLeastOnce);
    _client?.subscribe('tubewell/$deviceId/telemetry', MqttQos.atMostOnce);
  }

  void closeSession() {
    _client?.disconnect();
  }
}

final mqttStreamServiceProvider = Provider<MqttStreamService>((ref) {
  return MqttStreamService();
});