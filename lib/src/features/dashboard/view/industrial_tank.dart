import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/tank_state.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../provider/tank_stream_provider.dart';
import '../widget/tank.dart';




class IndustrialTank extends StatelessWidget {
  final double level;
  final String tankName;

  const IndustrialTank({
    super.key,
    required this.level,
    this.tankName = "PRIMARY STORAGE A1",
  });

  // Logic to determine the status label and color
  (String, Color) _getStatusInfo() {
    if (level >= 90) return ("TANK FULL", Colors.redAccent);
    if (level <= 15) return ("TANK EMPTY", Colors.orangeAccent);
    if (level >= 45 && level <= 55) return ("HALF FULL", Colors.blueAccent);
    return ("STABLE", Colors.greenAccent);
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _getStatusInfo();

    return Column(
      children: [
        // 1. TANK HEADER (Name and Status Badge)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tankName,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              // Digital Percentage Readout
              Text("${level.toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.w300, fontFamily: 'monospace')),
            ],
          ),
        ),

        // 2. THE TANK VESSEL
        LayoutBuilder(
          builder: (context, constraints) {
            double tankWidth = constraints.maxWidth * 0.6;
            if (tankWidth > 220) tankWidth = 220;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Measurement Scale
                _buildMeasurementScale(),
                const SizedBox(width: 15),

                // Tank Body with Layers
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Main Container
                    Container(
                      height: 300,
                      width: tankWidth,
                      decoration: _tankOuterDecoration(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildLiquidGauge(tankWidth),
                      ),
                    ),

                    // Glass Reflection Overlay for Realism
                    _buildGlassReflection(tankWidth),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildMeasurementScale() {
    return SizedBox(
      height: 300,
      child: SfLinearGauge(
        orientation: LinearGaugeOrientation.vertical,
        minimum: 0,
        maximum: 100,
        interval: 20,
        axisLabelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
        // Fix: Use LinearTickStyle instead of MajorTickStyle
        majorTickStyle: const LinearTickStyle(
            color: Colors.white24,
            thickness: 1.5,
            length: 10
        ),
        // Fix: Use LinearTickStyle instead of MinorTickStyle
        minorTickStyle: const LinearTickStyle(
            color: Colors.white12,
            thickness: 1,
            length: 5
        ),
        axisTrackStyle: const LinearAxisTrackStyle(thickness: 0),
      ),
    );
  }

  Widget _buildLiquidGauge(double tankWidth) {
    return SfLinearGauge(
      orientation: LinearGaugeOrientation.vertical,
      showLabels: false,
      showTicks: false,
      animateRange: true,
      animationDuration: 1200,
      axisTrackStyle: const LinearAxisTrackStyle(thickness: 0),
      ranges: [
        LinearGaugeRange(
          startValue: 0,
          endValue: level,
          startWidth: tankWidth,
          endWidth: tankWidth,
          position: LinearElementPosition.cross,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF001F3F), // Deep Dark Blue
                  Colors.blue.shade700,
                  Colors.cyanAccent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassReflection(double width) {
    return IgnorePointer(
      child: Container(
        height: 300,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.transparent,
              Colors.white.withOpacity(0.05),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
        ),
      ),
    );
  }

  BoxDecoration _tankOuterDecoration() {
    return BoxDecoration(
      color: const Color(0xFF12141C),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(10)),
      border: Border.all(color: Colors.white12, width: 2),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
      ],
    );
  }
}