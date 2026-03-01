
//
//
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../provider/voice_provider.dart';
//
// // final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) => VoiceNotifier());
// final voiceProvider =
// StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
//   final repo = ref.read(voiceRepositoryProvider);
//   return VoiceNotifier();
// });
//
//
// class VoiceNotifier extends StateNotifier<VoiceState> {
//   final stt.SpeechToText _speech = stt.SpeechToText();
//   bool _isInitialized = false;
//
//   VoiceNotifier() : super(VoiceState()) {
//     _loadDialogPreference();
//   }
//
//   Future<void> _loadDialogPreference() async {
//     final prefs = await SharedPreferences.getInstance();
//     state = state.copyWith(hasSeenDialog: prefs.getBool('hasSeenVoiceDialog') ?? false);
//   }
//
//   Future<bool> ensureInitialized() async {
//     if (_isInitialized) return true;
//     _isInitialized = await _speech.initialize(
//       onStatus: (s) {
//         if (s == 'notListening') state = state.copyWith(isListening: false);
//       },
//       onError: (e) => state = state.copyWith(isListening: false, error: e.errorMsg),
//     );
//     return _isInitialized;
//   }
//
//   Future<void> startListening() async {
//     final ready = await ensureInitialized();
//     if (!ready) return;
//
//     state = state.copyWith(isListening: true, text: "Listening...", error: null);
//
//     await _speech.listen(
//       onResult: (result) {
//         final currentText = result.recognizedWords.toLowerCase();
//         state = state.copyWith(text: result.recognizedWords);
//
//         // INSTANT STATE TRIGGER
//         if (_isMotorOn(currentText) && !state.motorOn) {
//           state = state.copyWith(motorOn: true, motorFeedback: "Motor Activated");
//         } else if (_isMotorOff(currentText) && state.motorOn) {
//           state = state.copyWith(motorOn: false, motorFeedback: "Motor Deactivated");
//         }
//       },
//       listenFor: const Duration(seconds: 10),
//       pauseFor: const Duration(seconds: 2),
//       partialResults: true, // This is key for speed
//       listenMode: stt.ListenMode.dictation,
//       onSoundLevelChange: (level) => state = state.copyWith(soundLevel: (level + 2) / 12),
//     );
//   }
//
//   Future<void> stopListening() async {
//     await _speech.stop();
//     state = state.copyWith(isListening: false);
//
//     // If no command was found by the time the user let go
//     if (state.text == "Listening...") {
//       state = state.copyWith(text: "No command detected");
//     }
//   }
//     bool _isMotorOn(String c) {
//     final List<String> onKeywords = [
//       "on", "start", "turn on", "switch on", "activate",
//       "enable", "chala", "chalu", "shuru", "karo", "power on",
//       "motor on", "pump on", "engine on"
//     ];
//
//     return onKeywords.any((key) => c.contains(key));
//   }
//
//   bool _isMotorOff(String c) {
//     final List<String> offKeywords = [
//       "off", "stop", "turn off", "switch off", "deactivate",
//       "disable", "band", "rok", "roko", "power off",
//       "motor off", "pump off", "shut down"
//     ];
//
//     return offKeywords.any((key) => c.contains(key));
//   }
//
//   void reset() {
//     _speech.stop();
//     state = VoiceState(hasSeenDialog: state.hasSeenDialog);
//   }
// }
//
//
//
//
//
//
//
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/src/core/exceptions/device_exception.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/voice_control_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/voice_repository.dart';




import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


import '../domain/voice_control_state.dart';
import '../provider/voice_provider.dart';

/// ------------------------------------------------------------
/// Voice Provider (Inject Repository properly)
/// ------------------------------------------------------------
// final voiceProvider =
// StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
//   final repo = ref.read(voiceRepositoryProvider);
//   return VoiceNotifier(repo);
//});
//
// /// ------------------------------------------------------------
// /// Voice Notifier
// /// Handles:
// /// - Speech Recognition
// /// - Firebase Motor Control
// /// - Error Handling
// /// - Local Preferences
// /// ------------------------------------------------------------
// class VoiceNotifier extends StateNotifier<VoiceState> {
//
//   final VoiceRepository _repository;
//   final stt.SpeechToText _speech = stt.SpeechToText();
//
//   bool _isInitialized = false;
//
//   /// Constructor with dependency injection
//   VoiceNotifier(this._repository) : super(VoiceState()) {
//     _loadDialogPreference();
//     _listenMotorStateFromFirebase();
//   }
//
//   /// ------------------------------------------------------------
//   /// Load first-time dialog preference from local storage
//   /// ------------------------------------------------------------
//   Future<void> _loadDialogPreference() async {
//     final prefs = await SharedPreferences.getInstance();
//     state = state.copyWith(
//       hasSeenDialog: prefs.getBool('hasSeenVoiceDialog') ?? false,
//     );
//   }
//
//   /// ------------------------------------------------------------
//   /// Listen to Firebase Motor State (Realtime Sync)
//   /// ------------------------------------------------------------
//   void _listenMotorStateFromFirebase() {
//     _repository.listenMotorState().listen((isOn) {
//       state = state.copyWith(
//         motorOn: isOn,
//         motorFeedback:
//         isOn ? "Motor Activated from Cloud" : "Motor Deactivated from Cloud",
//       );
//     });
//   }
//
//   /// ------------------------------------------------------------
//   /// Initialize Speech Engine
//   /// ------------------------------------------------------------
//   Future<bool> ensureInitialized() async {
//     if (_isInitialized) return true;
//
//     _isInitialized = await _speech.initialize(
//       onStatus: (status) {
//         if (status == 'notListening') {
//           state = state.copyWith(isListening: false);
//         }
//       },
//       onError: (error) {
//         state = state.copyWith(
//           isListening: false,
//           error: error.errorMsg,
//         );
//       },
//     );
//
//     return _isInitialized;
//   }
//
//   /// ------------------------------------------------------------
//   /// Start Listening to Voice Commands
//   /// ------------------------------------------------------------
//   Future<void> startListening() async {
//     final ready = await ensureInitialized();
//     if (!ready) {
//       state = state.copyWith(error: "Speech engine not initialized");
//       return;
//     }
//
//     state = state.copyWith(
//       isListening: true,
//       text: "Listening...",
//       error: null,
//     );
//
//     await _speech.listen(
//       partialResults: true,
//       listenMode: stt.ListenMode.dictation,
//       listenFor: const Duration(seconds: 10),
//       pauseFor: const Duration(seconds: 2),
//
//       /// Handle Speech Result
//       onResult: (result) async {
//         final spokenText = result.recognizedWords.toLowerCase();
//
//         state = state.copyWith(text: result.recognizedWords);
//
//         try {
//           // MOTOR ON COMMAND
//           if (_isMotorOn(spokenText) && !state.motorOn) {
//             await _repository.activateMotor();
//           }
//
//           // MOTOR OFF COMMAND
//           else if (_isMotorOff(spokenText) && state.motorOn) {
//             await _repository.deactivateMotor();
//           }
//         } on DeviceException catch (e) {
//           /// Handle known device errors
//           state = state.copyWith(error: e.message);
//         } catch (e) {
//           /// Handle unknown errors
//           state = state.copyWith(error: "Unexpected error occurred");
//         }
//       },
//
//       /// Sound level animation
//       onSoundLevelChange: (level) {
//         state = state.copyWith(soundLevel: (level + 2) / 12);
//       },
//     );
//   }
//
//   /// ------------------------------------------------------------
//   /// Stop Listening
//   /// ------------------------------------------------------------
//   Future<void> stopListening() async {
//     await _speech.stop();
//
//     state = state.copyWith(isListening: false);
//
//     if (state.text == "Listening...") {
//       state = state.copyWith(text: "No command detected");
//     }
//   }
//
//   /// ------------------------------------------------------------
//   /// Motor ON Keyword Detection
//   /// ------------------------------------------------------------
//   bool _isMotorOn(String command) {
//     const onKeywords = [
//       "on",
//       "start",
//       "turn on",
//       "switch on",
//       "activate",
//       "enable",
//       "chala",
//       "chalu",
//       "shuru",
//       "karo",
//       "power on",
//       "motor on",
//       "pump on",
//       "engine on",
//     ];
//
//     return onKeywords.any((keyword) => command.contains(keyword));
//   }
//
//   /// ------------------------------------------------------------
//   /// Motor OFF Keyword Detection
//   /// ------------------------------------------------------------
//   bool _isMotorOff(String command) {
//     const offKeywords = [
//       "off",
//       "stop",
//       "turn off",
//       "switch off",
//       "deactivate",
//       "disable",
//       "band",
//       "rok",
//       "roko",
//       "power off",
//       "motor off",
//       "pump off",
//       "shut down",
//     ];
//
//     return offKeywords.any((keyword) => command.contains(keyword));
//   }
//
//   /// ------------------------------------------------------------
//   /// Reset Voice State
//   /// ------------------------------------------------------------
//   void reset() {
//     _speech.stop();
//     state = VoiceState(hasSeenDialog: state.hasSeenDialog);
//   }
// }


final voiceProvider =
StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final repo = ref.read(voiceRepositoryProvider);
  return VoiceNotifier(repo);
});
class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceRepository _repository;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Device Map: name → index
  final Map<String, int> _deviceMap = {
    "light": 0,
    "fan": 1,
    "pump": 2,
    "heater": 3,
  };

  VoiceNotifier(this._repository) : super(VoiceState()) {
    _loadDialogPreference();

    // Listen to all devices on initialization
    for (var index in _deviceMap.values) {
      listenDeviceState(index);
    }
  }

  /// ----------------- Initialize Speech -----------------
  Future<bool> ensureInitialized() async {
    if (_isInitialized) return true;

    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') state = state.copyWith(isListening: false);
      },
      onError: (error) {
        state = state.copyWith(isListening: false, error: error.errorMsg);
      },
    );

    return _isInitialized;
  }

  /// ----------------- Start Listening -----------------
  Future<void> startListening() async {
    final ready = await ensureInitialized();
    if (!ready) {
      state = state.copyWith(error: "Speech engine not initialized");
      return;
    }

    state = state.copyWith(isListening: true, text: "Listening...", error: null);

    await _speech.listen(
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) async {
        final spokenText = result.recognizedWords.toLowerCase();
        state = state.copyWith(text: result.recognizedWords);

        try {
          await _handleVoiceCommand(spokenText);
        } catch (e) {
          state = state.copyWith(error: "Command failed");
        }
      },
      onSoundLevelChange: (level) {
        state = state.copyWith(soundLevel: (level + 2) / 12);
      },
    );
  }

  /// ----------------- Handle Voice Commands -----------------
  Future<void> _handleVoiceCommand(String command) async {
    final device = _detectDevice(command);
    if (device == null) {
      state = state.copyWith(error: "Device not recognized");
      return;
    }

    final index = _deviceMap[device]!;

    try {
      if (_isOnCommand(command)) {
        await _repository.turnOn(index);
        state = state
            .updateDeviceState(index, true)
            .updateDeviceFeedback(index, "$device turned ON");
      } else if (_isOffCommand(command)) {
        await _repository.turnOff(index);
        state = state
            .updateDeviceState(index, false)
            .updateDeviceFeedback(index, "$device turned OFF");
      }
    } on DeviceException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: "Unexpected error occurred");
    }
  }

  /// ----------------- Detect Device -----------------
  String? _detectDevice(String command) {
    for (final device in _deviceMap.keys) {
      if (command.contains(device)) return device;
    }
    return null;
  }

  /// ----------------- ON Command -----------------
  bool _isOnCommand(String command) {
    const keywords = ["on", "start", "turn on", "switch on", "activate", "enable", "chalu", "shuru"];
    return keywords.any((k) => command.contains(k));
  }

  /// ----------------- OFF Command -----------------
  bool _isOffCommand(String command) {
    const keywords = ["off", "stop", "turn off", "switch off", "disable", "band", "rok"];
    return keywords.any((k) => command.contains(k));
  }

  /// ----------------- Stop Listening -----------------
  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }

  /// ----------------- Load Dialog Preference -----------------
  Future<void> _loadDialogPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenVoiceDialog') ?? false;
    state = state.copyWith(hasSeenDialog: hasSeen);
  }

  /// ----------------- Mark Dialog Seen -----------------
  Future<void> markDialogSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenVoiceDialog', true);
    state = state.copyWith(hasSeenDialog: true);
  }

  /// ----------------- Reset -----------------
  void reset() {
    _speech.stop();
    state = VoiceState(
      hasSeenDialog: state.hasSeenDialog,
      devices: state.devices,
      deviceFeedback: state.deviceFeedback,
    );
  }

  /// ----------------- Listen Device State (Real-time) -----------------
  /// Keeps the device state in sync with backend
  void listenDeviceState(int index) {
    final deviceRef = _repository.deviceRef(index);

    deviceRef.onValue.listen((event) {
      final value = event.snapshot.value;

      bool isOn;
      if (value is bool) {
        isOn = value;
      } else if (value is int) {
        isOn = value == 1;
      } else {
        isOn = false;
      }

      state = state.updateDeviceState(index, isOn);

      // Optional: feedback
      state = state.updateDeviceFeedback(
        index,
        isOn ? "Device turned ON remotely" : "Device turned OFF remotely",
      );
    });
  }
}

