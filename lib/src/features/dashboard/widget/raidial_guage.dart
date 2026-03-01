import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';



// Widget buildWaterGauge(double value) {
//   return SfRadialGauge(
//     enableLoadingAnimation: true,
//     animationDuration: 2500, // Smooth initial load
//     axes: <RadialAxis>[
//       RadialAxis(
//         minimum: 0,
//         maximum: 100,
//         showLabels: true, // Showing small labels like the screenshot
//         showTicks: true,
//         labelOffset: 20,
//         axisLabelStyle: const GaugeTextStyle(color: AppColors.gray600, fontSize: 10),
//         majorTickStyle: const MajorTickStyle(length: 6, thickness: 1, color: AppColors.gray600),
//         minorTickStyle: const MinorTickStyle(length: 3, thickness: 0.5, color: AppColors.gray600),
//
//         // 1. The Outer "Background Frame" Look
//         axisLineStyle: AxisLineStyle(
//           thickness: 0.1,
//           color: AppColors.surfaceDark.withOpacity(0.5),
//           thicknessUnit: GaugeSizeUnit.factor,
//           cornerStyle: CornerStyle.bothCurve,
//         ),
//
//         pointers: <GaugePointer>[
//           // 2. The Animated Range (The Glow)
//           RangePointer(
//             value: value,
//             width: 0.1,
//             sizeUnit: GaugeSizeUnit.factor,
//             enableAnimation: true,
//             animationDuration: 1500,
//             animationType: AnimationType.easeOutBack, // Industrial "bounce"
//             gradient: const SweepGradient(
//               colors: [Colors.orangeAccent, Colors.deepOrange],
//               stops: [0.1, 1.0],
//             ),
//             cornerStyle: CornerStyle.bothCurve,
//           ),
//
//           // 3. The Precision Needle (Matching your screenshot)
//           NeedlePointer(
//             value: value,
//             needleLength: 0.8,
//             needleEndWidth: 4,
//             needleColor: Colors.white,
//             knobStyle: KnobStyle(
//               knobRadius: 0.08,
//               sizeUnit: GaugeSizeUnit.factor,
//               color: AppColors.backgroundDark,
//               borderColor: Colors.white,
//               borderWidth: 0.02,
//             ),
//             tailStyle: TailStyle(
//               length: 0.15,
//               width: 4,
//               color: Colors.white,
//             ),
//             enableAnimation: true,
//             animationType: AnimationType.easeOutBack,
//           ),
//         ],
//
//         // 4. Center Digital Readout
//         annotations: <GaugeAnnotation>[
//           GaugeAnnotation(
//             positionFactor: 0.45,
//             angle: 90,
//             widget: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.black.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.white10),
//                   ),
//                   child: Text(
//                     value.toStringAsFixed(0),
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orangeAccent, // Matching the screenshot theme
//                       fontFamily: 'Courier', // Monospace feels industrial
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 const Text(
//                   "PERCENT",
//                   style: TextStyle(fontSize: 8, color: AppColors.gray600, letterSpacing: 2),
//                 ),
//               ],
//             ),
//           )
//         ],
//       )
//     ],
//   );
// }