

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class IoTSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const IoTSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  // Helper method to determine color based on value intensity
  Color _getStatusColor(double val) {
    if (val < 30) return Colors.greenAccent;
    if (val < 75) return Colors.blueAccent;
    return Colors.orangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          if (value > 80) // Subtle glow when reaching high intensity
            BoxShadow(
              color: statusColor.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 2,
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "System Active",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              // Dynamic Value Chip
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  "${value.round()}%",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Monospace', // Digital look
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 12, // Thicker track for industrial feel
              activeTrackColor: statusColor,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              // Customizing the thumb for a "physical" hardware look
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 5,
                pressedElevation: 8,
              ),
              overlayColor: statusColor.withOpacity(0.1),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100, // Enables discrete steps for precision
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 10),
          // Range Indicators
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("0%", style: TextStyle(color: Colors.white24, fontSize: 10)),
              Text("50%", style: TextStyle(color: Colors.white24, fontSize: 10)),
              Text("100%", style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}