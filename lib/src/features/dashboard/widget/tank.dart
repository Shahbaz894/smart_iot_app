import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Widget buildIndustrialTank(double level) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // 1. The Scale/Labels
      SizedBox(
        height: 300,
        child: SfLinearGauge(
          orientation: LinearGaugeOrientation.vertical,
          minimum: 0,
          maximum: 100,
          interval: 20,
          axisLabelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
          axisTrackStyle: const LinearAxisTrackStyle(thickness: 0),
        ),
      ),
      const SizedBox(width: 15),

      // 2. The Tank Body
      Expanded(
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SfLinearGauge(
              orientation: LinearGaugeOrientation.vertical,
              showLabels: false,
              showTicks: false,
              animateRange: true,
              animationDuration: 2000,
              // FIX: Removed thicknessUnit and double-thickness
              axisTrackStyle: LinearAxisTrackStyle(
                thickness: 100, // This is a double, no unit needed
                color: Colors.white.withOpacity(0.05),
                edgeStyle: LinearEdgeStyle.bothCurve,
              ),
              ranges: <LinearGaugeRange>[
                // The Liquid Fill
                LinearGaugeRange(
                  startValue: 0,
                  endValue: level,
                  startWidth: 100,
                  endWidth: 100,
                  position: LinearElementPosition.cross,
                  // FIX: Used 'child' with BoxDecoration for the gradient
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade900,
                          Colors.blueAccent,
                          Colors.cyanAccent.withOpacity(0.6),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}