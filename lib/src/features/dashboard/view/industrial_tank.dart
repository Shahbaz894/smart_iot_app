import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/tank_state.dart';
import 'package:smart_iot_app/src/features/dashboard/view/motor_screen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../provider/tank_stream_provider.dart';
import '../widget/tank.dart';




import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// Assuming these exist in your project, otherwise using standard Colors
class AppColors {
  static const Color surfaceDark = Color(0xFF12141C);
  static const Color primary = Colors.cyanAccent;
  static const Color white = Colors.white;
  static const Color red = Colors.redAccent;
}

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

  void _clearAllSettings() {
    // Add your clear logic here
    debugPrint("Settings Cleared");
  }

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = _getStatusInfo();

    return Scaffold(
      backgroundColor: AppColors.surfaceDark, // Set background for the whole screen
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(), // Standard back navigation
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text("MOTOR CONTROL CENTER",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
            Text("GSM INDUSTRIAL V3",
                style: TextStyle(fontSize: 10, color: AppColors.primary, letterSpacing: 1.2)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.red),
            onPressed: _clearAllSettings,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 1. TANK HEADER
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tankName,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: statusColor.withOpacity(0.5)),
                          ),
                          child: Text(statusLabel,
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text("${level.toStringAsFixed(1)}%",
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 28, fontWeight: FontWeight.w300, fontFamily: 'monospace')),
                  ],
                ),
              ),

              // 2. THE TANK VESSEL
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double tankHeight = 350; // Defined height
                    double tankWidth = constraints.maxWidth * 0.5;
                    if (tankWidth > 200) tankWidth = 200;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildMeasurementScale(tankHeight),
                        const SizedBox(width: 20),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: tankHeight,
                              width: tankWidth,
                              decoration: _tankOuterDecoration(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildLiquidGauge(tankWidth),
                              ),
                            ),
                            _buildGlassReflection(tankHeight, tankWidth),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementScale(double height) {
    return SizedBox(
      height: height,
      width: 50,
      child: SfLinearGauge(
        orientation: LinearGaugeOrientation.vertical,
        minimum: 0,
        maximum: 100,
        interval: 20,
        axisLabelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
        majorTickStyle: const LinearTickStyle(color: Colors.white24, thickness: 1.5, length: 10),
        minorTickStyle: const LinearTickStyle(color: Colors.white12, thickness: 1, length: 5),
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
          rangeShapeType: LinearRangeShapeType.flat,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF001F3F),
                  Colors.blue.shade800,
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

  Widget _buildGlassReflection(double height, double width) {
    return IgnorePointer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.transparent,
              Colors.white.withOpacity(0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  BoxDecoration _tankOuterDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0A0C12),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
      border: Border.all(color: Colors.white12, width: 2),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 15, offset: const Offset(0, 8))
      ],
    );
  }
}