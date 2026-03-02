
import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';

import 'package:intl/intl.dart';
class MotorButton extends StatefulWidget {
  final bool isOn;
  final DateTime? startTime;
  final VoidCallback onToggle;

  const MotorButton({
    super.key,
    required this.isOn,
    this.startTime,
    required this.onToggle,
  });

  @override
  State<MotorButton> createState() => _MotorButtonState();
}

class _MotorButtonState extends State<MotorButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isOn) _controller.repeat();
  }

  @override
  void didUpdateWidget(MotorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOn) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ================= BUTTON =================
        GestureDetector(
          onTap: widget.onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.isOn
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
                widget.isOn ? 'ON' : 'OFF',
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ================= FAN ICON + TIME =================
        if (widget.isOn && widget.startTime != null)
          Column(
            children: [
              RotationTransition(
                turns: _controller,
                child: Icon(
                  Icons.flip_camera_android, // replace with fan/motor icon
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Started: ${DateFormat('HH:mm:ss').format(widget.startTime!)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
      ],
    );
  }
}