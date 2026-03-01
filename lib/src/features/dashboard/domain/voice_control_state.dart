import 'package:flutter/material.dart';

/// State model for voice-controlled IoT devices.
///
/// Handles:
/// - Listening state
/// - Multiple devices' on/off state
/// - Per-device feedback messages
/// - Microphone permission status
/// - Voice command text and errors
class VoiceState {
  /// Whether the speech recognizer is actively listening
  final bool isListening;

  /// Map of device index to its on/off state
  final Map<int, bool> devices;

  /// Last recognized voice text
  final String text;

  /// Map of device index to feedback message (e.g., "Fan turned ON")
  final Map<int, String> deviceFeedback;

  /// Current microphone sound level (0.0 - 1.0)
  final double soundLevel;

  /// Whether microphone permission is granted
  final bool permissionGranted;

  /// Whether the first-time info dialog has been shown
  final bool hasSeenDialog;

  /// Error message if any
  final String? error;

  /// Constructor with optional maps and default values
  VoiceState({
    this.isListening = false,
    Map<int, bool>? devices,
    this.text = "Hold to give command",
    Map<int, String>? deviceFeedback,
    this.soundLevel = 0.0,
    this.permissionGranted = false,
    this.hasSeenDialog = false,
    this.error,
  })  : devices = Map.unmodifiable(devices ?? {}),
        deviceFeedback = Map.unmodifiable(deviceFeedback ?? {});

  /// CopyWith method for immutability
  VoiceState copyWith({
    bool? isListening,
    Map<int, bool>? devices,
    String? text,
    Map<int, String>? deviceFeedback,
    double? soundLevel,
    bool? permissionGranted,
    bool? hasSeenDialog,
    String? error,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      devices: devices ?? this.devices,
      text: text ?? this.text,
      deviceFeedback: deviceFeedback ?? this.deviceFeedback,
      soundLevel: soundLevel ?? this.soundLevel,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      hasSeenDialog: hasSeenDialog ?? this.hasSeenDialog,
      error: error ?? this.error,
    );
  }

  /// Returns true if the device at [index] is ON
  bool isDeviceOn(int index) => devices[index] ?? false;

  /// Returns the feedback text for the device at [index], empty string if none
  String deviceFeedbackText(int index) => deviceFeedback[index] ?? "";

  /// Returns a copy of devices map with updated value for [index]
  VoiceState updateDeviceState(int index, bool isOn) {
    final newDevices = Map<int, bool>.from(devices);
    newDevices[index] = isOn;
    return copyWith(devices: newDevices);
  }

  /// Returns a copy of deviceFeedback map with updated message for [index]
  VoiceState updateDeviceFeedback(int index, String message) {
    final newFeedback = Map<int, String>.from(deviceFeedback);
    newFeedback[index] = message;
    return copyWith(deviceFeedback: newFeedback);
  }
}
