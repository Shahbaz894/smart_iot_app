import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/view/switch_control_screen.dart';

import '../dashboard_viewmodel/voice_view_model.dart';

class VoiceControlScreen extends ConsumerStatefulWidget {
  const VoiceControlScreen({super.key});

  @override
  ConsumerState<VoiceControlScreen> createState() =>
      _VoiceControlScreenState();
}

class _VoiceControlScreenState
    extends ConsumerState<VoiceControlScreen> {

  @override
  void initState() {
    super.initState();
    _checkDialog();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenFirebaseDevices();
    });
  }

  /// ------------------ PERMISSION ------------------
  Future<void> _checkDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenVoiceDialog') ?? false;
    if (!seen) _showInfoDialog();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F25),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text("Enable Voice Control",
            style: TextStyle(color: Colors.white)),
        content: const Text(
          "Allow microphone access to control your IoT devices using voice.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () async {
                final prefs =
                await SharedPreferences.getInstance();
                await prefs.setBool(
                    'hasSeenVoiceDialog', true);
                if (mounted) Navigator.pop(context);
                await _requestPermission();
              },
              child: const Text("Allow"))
        ],
      ),
    );
  }

  /// ------------------ FIREBASE LISTEN ------------------
  void _listenFirebaseDevices() {
    final notifier = ref.read(voiceProvider.notifier);
    for (int i = 0; i < 4; i++) {
      notifier.listenDeviceState(i);
    }
  }

  /// ------------------ REFRESH ------------------
  void _refresh() {
    final notifier = ref.read(voiceProvider.notifier);
    notifier.reset();
    _listenFirebaseDevices();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceProvider);
    final notifier = ref.read(voiceProvider.notifier);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const IoTControlScreen(),
              ),
                  (route) => false,
            );
          },
        ),

        title: const Text(
          "VOICE CONTROL",
          style: TextStyle(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded,
                  color: Colors.cyanAccent))
        ],
      ),

      /// ------------------ BODY ------------------
      body: Column(
        children: [

          /// ===== DEVICE GRID (BLYNK STYLE) =====
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                childAspectRatio: 1,
              ),
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                final isOn = state.isDeviceOn(index);
                final name = _deviceName(index);

                // return AnimatedContainer(
                //   duration:
                //   const Duration(milliseconds: 400),
                //   decoration: BoxDecoration(
                //     borderRadius:
                //     BorderRadius.circular(24),
                //     gradient: LinearGradient(
                //       colors: isOn
                //           ? [
                //         Colors.greenAccent
                //             .withOpacity(0.25),
                //         Colors.green
                //             .withOpacity(0.08)
                //       ]
                //           : [
                //         Colors.blueAccent
                //             ,
                //         Colors.red
                //             .withOpacity(0.08)
                //       ],
                //     ),
                //     border: Border.all(
                //       color: isOn
                //           ? Colors.greenAccent
                //           : Colors.redAccent,
                //       width: 1.5,
                //     ),
                //     boxShadow: [
                //       if (isOn)
                //         BoxShadow(
                //           color: Colors.greenAccent
                //               .withOpacity(0.4),
                //           blurRadius: 25,
                //           spreadRadius: 2,
                //         )
                //     ],
                //   ),
                //   child: Column(
                //     mainAxisAlignment:
                //     MainAxisAlignment.center,
                //     children: [
                //       AnimatedScale(
                //         scale: isOn ? 1.2 : 1,
                //         duration: const Duration(
                //             milliseconds: 300),
                //         child: Icon(
                //           Icons.power_settings_new,
                //           size: size.width * 0.12,
                //           color: isOn
                //               ? Colors.greenAccent
                //               : Colors.redAccent,
                //         ),
                //       ),
                //       const SizedBox(height: 10),
                //       Text(
                //         name.toUpperCase(),
                //         style: const TextStyle(
                //             fontWeight: FontWeight.w600,color: Colors.white),
                //       )
                //     ],
                //   ),
                // );
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),

                    /// 🔥 GLASS DARK BASE
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isOn
                          ? [
                        const Color(0xFF1E2A24),
                        const Color(0xFF0F1C18),
                      ]
                          : [
                        const Color(0xFF1C1F26),
                        const Color(0xFF111318),
                      ],
                    ),

                    /// BORDER
                    border: Border.all(
                      color: isOn
                          ? const Color(0xFF00FFB2)
                          : Colors.white.withOpacity(0.08),
                      width: 1.2,
                    ),

                    /// OUTER GLOW
                    boxShadow: [
                      if (isOn)
                        BoxShadow(
                          color: const Color(0xFF00FFB2).withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),

                      /// Soft depth shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// ICON
                      AnimatedScale(
                        scale: isOn ? 1.15 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isOn
                                ? const LinearGradient(
                              colors: [
                                Color(0xFF00FFB2),
                                Color(0xFF00C896),
                              ],
                            )
                                : null,
                            color: isOn ? null : Colors.white.withOpacity(0.05),
                            boxShadow: isOn
                                ? [
                              BoxShadow(
                                color:
                                const Color(0xFF00FFB2).withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: 3,
                              )
                            ]
                                : [],
                          ),
                          child: Icon(
                            Icons.power_settings_new_rounded,
                            size: size.width * 0.10,
                            color: isOn
                                ? Colors.black
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// DEVICE NAME
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontSize: 14,
                          color: isOn
                              ? const Color(0xFF00FFB2)
                              : Colors.white.withOpacity(0.6),
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// STATUS TEXT
                      Text(
                        isOn ? "ACTIVE" : "OFFLINE",
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1,
                          color: isOn
                              ? const Color(0xFF00FFB2).withOpacity(0.8)
                              : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                );

              },
            ),
          ),

          /// ===== WAVEFORM =====
          _buildWaveform(
              state.isListening, state.soundLevel),

          const SizedBox(height: 15),

          /// ===== RECOGNIZED TEXT =====
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              state.text.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: state.isListening
                    ? Colors.cyanAccent
                    : Colors.white38,
              ),
            ),
          ),

          const SizedBox(height: 25),

          /// ===== PREMIUM MIC BUTTON =====
          GestureDetector(
            onLongPressStart: (_) {
              HapticFeedback.heavyImpact();
              notifier.startListening();
            },
            onLongPressEnd: (_) {
              HapticFeedback.lightImpact();
              notifier.stopListening();
            },
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 300),
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: state.isListening
                    ? const LinearGradient(
                    colors: [
                      Colors.cyanAccent,
                      Colors.blueAccent
                    ])
                    : const LinearGradient(
                    colors: [
                      Color(0xFF1E293B),
                      Color(0xFF111827)
                    ]),
                boxShadow: [
                  if (state.isListening)
                    BoxShadow(
                      color: Colors.cyanAccent
                          .withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 2,
                    )
                ],
              ),
              child: Icon(
                state.isListening
                    ? Icons.graphic_eq_rounded
                    : Icons.mic_none_rounded,
                size: 40,
                color: state.isListening
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// ------------------ DEVICE NAMES ------------------
  String _deviceName(int index) {
    switch (index) {
      case 0:
        return "Light";
      case 1:
        return "Fan";
      case 2:
        return "Pump";
      case 3:
        return "Heater";
      default:
        return "Device";
    }
  }

  /// ------------------ WAVEFORM ------------------
  Widget _buildWaveform(bool listening, double level) {
    if (!listening) return const SizedBox(height: 60);

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: List.generate(
          7,
              (index) => AnimatedContainer(
            duration:
            const Duration(milliseconds: 120),
            margin:
            const EdgeInsets.symmetric(horizontal: 4),
            width: 5,
            height: 10 +
                (50 *
                    level *
                    (index.isEven ? 1 : 0.6)),
            decoration: BoxDecoration(
              color: Colors.cyanAccent,
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
