
import 'package:flutter/material.dart';


import 'package:intl/intl.dart';

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_iot_app/src/core/constant/app_color.dart';

import '../provider/motor_on_off_provider.dart';

class MotorButton extends ConsumerStatefulWidget {
  final VoidCallback onToggle;

  const MotorButton({
    super.key,
    required this.onToggle, 
    required bool isOn, DateTime? startTime,
  });

  @override
  ConsumerState<MotorButton> createState() => _MotorButtonState();
}

class _MotorButtonState extends ConsumerState<MotorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;
  DateTime? _currentTime;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime startTime) {
    _currentTime = startTime;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = _currentTime!.add(const Duration(seconds: 1));
      });
    });
    _controller.repeat();
  }

  void _stopTimer() {
    _timer?.cancel();
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    final motorState = ref.watch(motorOnOffViewModelProvider);
    final motorData = motorState.data;

    final isOn = motorData?.isOn ?? false;
    final startTime = motorData?.startTime;

    // Start/stop animation & timer based on motor state
    if (isOn && startTime != null) {
      if (_timer == null || !_timer!.isActive) _startTimer(startTime);
    } else {
      _stopTimer();
      _currentTime = null;
    }

    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     // ================= BUTTON =================
    //     GestureDetector(
    //       onTap: widget.onToggle,
    //       child: AnimatedContainer(
    //         duration: const Duration(milliseconds: 500),
    //         curve: Curves.easeInOut,
    //         height: 150,
    //         width: 150,
    //         decoration: BoxDecoration(
    //           shape: BoxShape.circle,
    //           gradient: LinearGradient(
    //             colors: isOn
    //                 ? [AppColors.green, AppColors.primary]
    //                 : [AppColors.red, AppColors.error],
    //           ),
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.black.withOpacity(0.6),
    //               blurRadius: 20,
    //               spreadRadius: 2,
    //               offset: const Offset(0, 6),
    //             ),
    //           ],
    //         ),
    //         child: Center(
    //           child: Text(
    //             isOn ? 'ON' : 'OFF',
    //             style: const TextStyle(
    //               fontSize: 28,
    //               color: Colors.white,
    //               fontWeight: FontWeight.bold,
    //               letterSpacing: 1.2,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //
    //     const SizedBox(height: 24),
    //
    //     // ================= LIVE MOTOR TIME + ROTATION =================
    //     if (isOn && _currentTime != null)
    //       Column(
    //         children: [
    //           RotationTransition(
    //             turns: _controller,
    //             child: Icon(
    //               Icons.settings, // Replace with your motor icon
    //               color: AppColors.primary,
    //               size: 36,
    //             ),
    //           ),
    //           const SizedBox(height: 8),
    //           Text(
    //             'Running: ${DateFormat('HH:mm:ss').format(_currentTime!)}',
    //             style: const TextStyle(
    //               color: Colors.white70,
    //               fontSize: 14,
    //             ),
    //           ),
    //         ],
    //       ),
    //   ],
    // );
    return Column(
      mainAxisSize: MainAxisSize.min, // ✅ VERY IMPORTANT
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ================= BUTTON =================
        GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: 120, // 🔥 reduced from 150
            width: 120,  // 🔥 reduced from 150
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isOn
                    ? [AppColors.green, AppColors.primary]
                    : [AppColors.red, AppColors.error],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                isOn ? 'ON' : 'OFF',
                style: const TextStyle(
                  fontSize: 24, // slightly reduced
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10), // 🔥 reduced from 24

        // ================= STATUS =================
        if (isOn && _currentTime != null)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _controller,
                child: Icon(
                  Icons.settings,
                  color: AppColors.primary,
                  size: 28, // reduced
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm:ss').format(_currentTime!),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12, // reduced
                ),
              ),
            ],
          ),
      ],
    );
  }
}