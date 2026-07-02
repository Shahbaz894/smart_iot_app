import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:web_socket_channel/web_socket_channel.dart";

import "../../../../core/error/app_exception.dart";
import "../../data/models/device_model.dart";
import "../../data/repositories/device_repository.dart";
import "../state/device_state.dart";

class DeviceSelectionViewModel extends StateNotifier<DeviceSelectionState> {
  final DeviceRepository deviceRepository;

  // Kept dynamic to avoid AuthStorage import conflict in your project.
  final dynamic authStorage;

  final Map<String, WebSocketChannel> _activeChannels = {};
  final Map<String, StreamSubscription<dynamic>> _activeSubscriptions = {};

  Timer? _liveStatusPollTimer;

  bool _disposed = false;
  bool _allowReconnect = true;
  bool _isPollingLiveStatus = false;

  // Backend WebSocket is currently giving "Connection refused".
  // Keep false until backend WebSocket is fixed.
  static const bool _enableWebSocketSync = false;

  // Device online/offline auto update interval.
  static const Duration _livePollInterval = Duration(seconds: 3);

  DeviceSelectionViewModel({
    required this.deviceRepository,
    required this.authStorage,
  }) : super(const DeviceSelectionState());

  Future<void> loadDevices() async {
    try {
      _allowReconnect = true;

      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final session = await authStorage.getSession();

      if (!session.hasValidLogin || session.userId == null) {
        if (!mounted || _disposed) return;

        state = state.copyWith(
          isLoading: false,
          error: "Session expired. Please login again.",
        );
        return;
      }

      final devices = await deviceRepository.getDevicesByUserId(
        session.userId!,
      );

      final devicesWithLiveStatus = await _attachLatestLiveStatus(devices);

      if (!mounted || _disposed) return;

      state = state.copyWith(
        isLoading: false,
        devices: devicesWithLiveStatus,
        selectedDeviceId: session.deviceId,
      );

      // Auto-update by API polling. No manual refresh needed.
      _startLiveStatusPolling();

      // WebSocket kept in code, but disabled until backend socket works.
      if (_enableWebSocketSync) {
        _startLiveDeviceSync(devicesWithLiveStatus);
      } else {
        debugPrint("🟡 DEVICE WS DISABLED: using API polling for live status.");
      }
    } on AppException catch (e) {
      if (!mounted || _disposed) return;

      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      if (!mounted || _disposed) return;

      state = state.copyWith(
        isLoading: false,
        error: "Failed to load devices: ${e.toString()}",
      );
    }
  }

  Future<List<DeviceModel>> _attachLatestLiveStatus(
      List<DeviceModel> devices,
      ) async {
    final updatedDevices = <DeviceModel>[];

    for (final device in devices) {
      final updatedDevice = await _readLatestStatusForDevice(device);
      updatedDevices.add(updatedDevice);
    }

    return updatedDevices;
  }

  Future<DeviceModel> _readLatestStatusForDevice(DeviceModel device) async {
    final deviceId = device.primaryDeviceId.toString().trim();

    if (deviceId.isEmpty) return device;

    try {
      final latestTelemetry =
      await deviceRepository.getLatestTelemetryByDeviceId(deviceId);

      if (latestTelemetry == null) {
        debugPrint(
          "DEVICE AUTO STATUS => $deviceId | latestTelemetry=null | keep old=${device.isOnline}",
        );

        return device;
      }

      final rawLive = latestTelemetry["is_live"] ??
          latestTelemetry["isLive"] ??
          latestTelemetry["is_online"] ??
          latestTelemetry["isOnline"];

      final bool isOnline = _readBoolFromLive(rawLive);
      final DateTime latestTime = _readPacketTime(latestTelemetry);

      debugPrint(
        "🔄 DEVICE AUTO LIVE => $deviceId | rawLive=$rawLive | isOnline=$isOnline | time=$latestTime",
      );

      return device.copyWith(
        updatedAt: latestTime,
        isOnline: isOnline,
      );
    } catch (e) {
      debugPrint("DEVICE AUTO STATUS FAILED => $deviceId | $e");

      return device;
    }
  }

  void _startLiveStatusPolling() {
    _liveStatusPollTimer?.cancel();

    _liveStatusPollTimer = Timer.periodic(_livePollInterval, (_) {
      _pollLatestLiveStatus();
    });

    debugPrint(
      "✅ DEVICE LIVE POLLING STARTED every ${_livePollInterval.inSeconds}s",
    );
  }

  Future<void> _pollLatestLiveStatus() async {
    if (_disposed) return;
    if (_isPollingLiveStatus) return;
    if (state.devices.isEmpty) return;

    _isPollingLiveStatus = true;

    try {
      final currentDevices = List<DeviceModel>.from(state.devices);
      final updatedDevices = await _attachLatestLiveStatus(currentDevices);

      if (!mounted || _disposed) return;

      state = state.copyWith(
        devices: updatedDevices,
        error: null,
      );

      debugPrint("✅ DEVICE LIVE POLLING UPDATED UI STATE");
    } catch (e) {
      debugPrint("DEVICE LIVE POLLING ERROR: $e");
    } finally {
      _isPollingLiveStatus = false;
    }
  }

  Future<void> refreshLiveStatusNow() async {
    await _pollLatestLiveStatus();
  }

  Future<String?> selectDevice(DeviceModel device) async {
    try {
      final deviceId = device.primaryDeviceId.toString().trim();

      if (deviceId.isEmpty) {
        if (!mounted || _disposed) return null;

        state = state.copyWith(
          error: "Selected device ID missing",
          message: null,
        );
        return null;
      }

      await authStorage.saveSelectedDeviceId(deviceId);

      if (!mounted || _disposed) return null;

      state = state.copyWith(
        selectedDeviceId: deviceId,
        error: null,
        message: "Device selected",
      );

      return deviceId;
    } catch (e) {
      if (mounted && !_disposed) {
        state = state.copyWith(
          error: "Failed to select device: ${e.toString()}",
        );
      }

      return null;
    }
  }

  Future<void> logout() async {
    _allowReconnect = false;

    await closeAllStreams();

    await authStorage.clear();

    if (!mounted || _disposed) return;

    state = const DeviceSelectionState(
      message: "Logged out",
    );
  }

  void _startLiveDeviceSync(List<DeviceModel> devices) {
    if (!_enableWebSocketSync) {
      debugPrint("🟡 DEVICE WS SKIPPED: websocket disabled.");
      return;
    }

    for (final device in devices) {
      final deviceId = device.primaryDeviceId.toString().trim();

      if (deviceId.isEmpty) continue;

      if (_activeChannels.containsKey(deviceId)) {
        debugPrint("🟡 DEVICE WS ALREADY ACTIVE: $deviceId");
        continue;
      }

      _connectToDeviceStream(deviceId);
    }
  }

  void _connectToDeviceStream(String deviceId) {
    if (!_enableWebSocketSync) return;
    if (_disposed) return;
    if (!_allowReconnect) return;
    if (_activeChannels.containsKey(deviceId)) return;

    final wsUrl = Uri.parse(
      "ws://157.245.55.83:8000/api/v1/telemetry/ws/$deviceId",
    );

    try {
      final channel = WebSocketChannel.connect(wsUrl);

      _activeChannels[deviceId] = channel;

      debugPrint("🟢 DEVICE WS CONNECTED: $deviceId");

      final subscription = channel.stream.listen(
            (message) {
          _handleDeviceSocketMessage(
            channelDeviceId: deviceId,
            message: message,
          );
        },
        onDone: () {
          debugPrint("🟡 DEVICE WS CLOSED: $deviceId");

          _removeDeviceStream(deviceId);
          _scheduleReconnect(deviceId);
        },
        onError: (e) {
          debugPrint("🔴 DEVICE WS ERROR for $deviceId: $e");

          _removeDeviceStream(deviceId);
          _scheduleReconnect(deviceId);
        },
        cancelOnError: false,
      );

      _activeSubscriptions[deviceId] = subscription;
    } catch (e) {
      debugPrint("🔴 WebSocket Connection Failed for $deviceId: $e");

      _removeDeviceStream(deviceId);
      _scheduleReconnect(deviceId);
    }
  }

  void _handleDeviceSocketMessage({
    required String channelDeviceId,
    required dynamic message,
  }) {
    try {
      final decoded = jsonDecode(message.toString());

      final data = _extractTelemetryMap(decoded);

      if (data == null) {
        debugPrint("🔴 DEVICE WS INVALID MESSAGE: $message");
        return;
      }

      final String packetDeviceId = _readText(
        data["device_id"] ??
            data["deviceId"] ??
            data["device"] ??
            channelDeviceId,
      );

      final String targetDeviceId = packetDeviceId.trim().isEmpty
          ? channelDeviceId
          : packetDeviceId.trim();

      final dynamic rawLive = data["is_live"] ??
          data["isLive"] ??
          data["is_online"] ??
          data["isOnline"];

      final bool isOnline = _readBoolFromLive(rawLive);
      final DateTime packetTime = _readPacketTime(data);

      debugPrint(
        "📡 DEVICE WS UPDATE => channel=$channelDeviceId | packetDevice=$targetDeviceId | rawLive=$rawLive | isOnline=$isOnline | time=$packetTime",
      );

      bool matched = false;

      final updatedDevices = state.devices.map((device) {
        final currentDeviceId = device.primaryDeviceId.toString().trim();

        if (currentDeviceId == targetDeviceId ||
            currentDeviceId == channelDeviceId) {
          matched = true;

          return device.copyWith(
            updatedAt: packetTime,
            isOnline: isOnline,
          );
        }

        return device;
      }).toList();

      if (!matched) {
        debugPrint(
          "🟠 DEVICE WS UPDATE RECEIVED BUT NO DEVICE MATCHED => $targetDeviceId",
        );
      }

      if (mounted && !_disposed) {
        state = state.copyWith(
          devices: updatedDevices,
          error: null,
        );
      }
    } catch (e) {
      debugPrint("🔴 Multi-Stream Parse Error for $channelDeviceId: $e");
    }
  }

  Map<String, dynamic>? _extractTelemetryMap(dynamic decoded) {
    if (decoded == null) return null;

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);

      if (map.containsKey("is_live") ||
          map.containsKey("isLive") ||
          map.containsKey("is_online") ||
          map.containsKey("isOnline")) {
        return map;
      }

      final nested = map["data"] ?? map["payload"] ?? map["telemetry"];

      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }

      return map;
    }

    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first as Map);
    }

    return null;
  }

  DateTime _readPacketTime(Map<String, dynamic> data) {
    final rawTime = data["created_at"] ??
        data["createdAt"] ??
        data["updated_at"] ??
        data["updatedAt"] ??
        data["timestamp"];

    if (rawTime == null) {
      return DateTime.now();
    }

    if (rawTime is int) {
      if (rawTime < 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(
          rawTime * 1000,
          isUtc: true,
        ).toLocal();
      }

      return DateTime.fromMillisecondsSinceEpoch(
        rawTime,
        isUtc: true,
      ).toLocal();
    }

    if (rawTime is double) {
      final value = rawTime.toInt();

      if (value < 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(
          value * 1000,
          isUtc: true,
        ).toLocal();
      }

      return DateTime.fromMillisecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }

    final parsed = DateTime.tryParse(rawTime.toString());

    return parsed?.toLocal() ?? DateTime.now();
  }

  bool _readBoolFromLive(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) return value == 1;

    if (value is num) return value.toInt() == 1;

    final text = value.toString().trim().toLowerCase();

    return text == "1" || text == "true" || text == "online";
  }

  String _readText(dynamic value) {
    if (value == null) return "";

    return value.toString().trim();
  }

  void _scheduleReconnect(String deviceId) {
    if (!_enableWebSocketSync) return;
    if (_disposed) return;
    if (!_allowReconnect) return;

    Future.delayed(const Duration(seconds: 10), () {
      if (!_enableWebSocketSync) return;
      if (_disposed) return;
      if (!_allowReconnect) return;
      if (_activeChannels.containsKey(deviceId)) return;

      final stillExists = state.devices.any(
            (device) => device.primaryDeviceId.toString().trim() == deviceId,
      );

      if (!stillExists) return;

      debugPrint("🔁 DEVICE WS RECONNECTING: $deviceId");

      _connectToDeviceStream(deviceId);
    });
  }

  void _removeDeviceStream(String deviceId) {
    _activeSubscriptions.remove(deviceId);
    _activeChannels.remove(deviceId);
  }

  Future<void> closeAllStreams() async {
    _liveStatusPollTimer?.cancel();
    _liveStatusPollTimer = null;

    final subscriptions = List<StreamSubscription<dynamic>>.from(
      _activeSubscriptions.values,
    );

    final channels = List<WebSocketChannel>.from(
      _activeChannels.values,
    );

    _activeSubscriptions.clear();
    _activeChannels.clear();

    for (final subscription in subscriptions) {
      try {
        await subscription.cancel();
      } catch (e) {
        debugPrint("Stream subscription cancel error: $e");
      }
    }

    for (final channel in channels) {
      try {
        await channel.sink.close();
      } catch (e) {
        debugPrint("WebSocket close error: $e");
      }
    }

    debugPrint("🛑 All multi-device streams safely closed.");
  }

  @override
  void dispose() {
    _disposed = true;
    _allowReconnect = false;

    unawaited(closeAllStreams());

    super.dispose();
  }
}g