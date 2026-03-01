import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/sensor_state.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/tank_state.dart';
import 'package:smart_iot_app/src/features/dashboard/model/sensor_model.dart';
import 'package:smart_iot_app/src/features/dashboard/provider/tank_stream_provider.dart';
import 'package:smart_iot_app/src/features/dashboard/view/industrial_tank.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/industrial_app_bar.dart';

import '../provider/sensor_provider.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';


// add colander  ta k daily ki ye routine , time slot for on off for motor rest , motor status run  off error,
//     run signal lena h phase say, used  current transform for
// getting ampere to check the motor running ,

// class SensorDashboard extends ConsumerWidget {
//   const SensorDashboard({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final tankAsync = ref.watch(tankStreamProvider);
//     final sensorState = ref.watch(sensorViewModelProvider);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F111A),
//       appBar: IndustrialAppBar(
//         title: "Control Center",
//         isHome: true,
//       ),
//       body: tankAsync.when(
//         loading: () =>
//         const Center(child: CircularProgressIndicator()),
//         error: (err, _) =>
//             Center(child: Text("Tank Error: $err")),
//         data: (tankData) {
//           if (tankData == null) {
//             return const Center(
//                 child: Text("No Tank Data"));
//           }
//
//           // ✅ Pass sensorState directly
//           return _buildDashboardBody(
//             tankData,
//             sensorState,
//           );
//         },
//       ),
//     );
//   }
//
//
//
//   Widget _buildDashboardBody(TankState tank, SensorState sensor) {
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionHeader("LIVE TELEMETRY"),
//           const SizedBox(height: 20),
//
//           // 1. TANK VIEW
//           _buildGlassCard(
//             child: Column(
//               children: [
//
//
//                 _buildGuageCard(
//                   height: 320,
//                   child: _buildRadialGauge(sensor.temperature),
//                 ),
//                 SizedBox(height: 15,),
//
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatTile(
//                         "TEMPERATURE",
//                         "${sensor.temperature.toStringAsFixed(1)}°C", // Correctly using sensor object
//                         Icons.thermostat_rounded,
//                         Colors.orangeAccent,
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatTile(
//                         "HUMIDITY",
//                         "${sensor.humidity.toStringAsFixed(0)}%", // Correctly using sensor object
//                         Icons.water_drop_rounded,
//                         Colors.blueAccent,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//
//                 IndustrialTank(level: tank.levelPercentage),
//                 const SizedBox(height: 24),
//                 _buildTankReadout(tank),
//               ],
//             ),
//           ),
//
//
//
//
//
//
//           // 2. ENVIRONMENTAL SENSORS
//
//         ],
//       ),
//     );
//   }
//
//   // --- REUSABLE UI COMPONENTS ---
//
//   Widget _buildTankReadout(TankState tank) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _readoutItem("LEVEL", "${tank.levelPercentage.toStringAsFixed(1)}%"),
//         _readoutItem("VOLUME", "${tank.volumeLitres.toStringAsFixed(0)}L"),
//       ],
//     );
//   }
//
//   Widget _readoutItem(String label, String value) {
//     return Column(
//       children: [
//         Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//         Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1)),
//       ],
//     );
//   }
//
//   Widget _buildStatTile(String title, String value, IconData icon, Color color) {
//     return _buildGlassCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 16),
//           Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
//           Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGlassCard({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(32),
//         border: Border.all(color: Colors.white.withOpacity(0.08)),
//       ),
//       child: child,
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Row(
//       children: [
//         Container(width: 4, height: 16, color: Colors.cyanAccent),
//         const SizedBox(width: 10),
//         Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
//       ],
//     );
//   }
//
//   // _buildGuageCard({required int height, required child}) {}
//
//     Widget _buildGuageCard({required Widget child, double? height}) {
//     return Container(
//       height: height,
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceDark.withOpacity(0.6),
//         borderRadius: BorderRadius.circular(32),
//         border: Border.all(color: AppColors.white.withOpacity(0.08)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//
//   Widget _buildRadialGauge(double value) {
//     return SfRadialGauge(
//       enableLoadingAnimation: true,
//       animationDuration: 2000,
//       axes: <RadialAxis>[
//         RadialAxis(
//           minimum: 0,
//           maximum: 100,
//           showLabels: true,
//           showTicks: true,
//           labelOffset: 15,
//           axisLabelStyle: const GaugeTextStyle(color: AppColors.gray600, fontSize: 10),
//           majorTickStyle: const MajorTickStyle(length: 8, thickness: 1.5, color: AppColors.gray700),
//           minorTickStyle: const MinorTickStyle(length: 4, thickness: 1, color: AppColors.gray800),
//           axisLineStyle: AxisLineStyle(
//             thickness: 0.1,
//             color: AppColors.black.withOpacity(0.3),
//             thicknessUnit: GaugeSizeUnit.factor,
//           ),
//           pointers: <GaugePointer>[
//             // The Outer Glow Range
//             RangePointer(
//               value: value,
//               width: 0.1,
//               sizeUnit: GaugeSizeUnit.factor,
//               gradient: SweepGradient(
//                 colors: [AppColors.primary.withOpacity(0.1), AppColors.primary],
//                 stops: const [0.1, 1.0],
//               ),
//               cornerStyle: CornerStyle.bothCurve,
//               enableAnimation: true,
//               animationType: AnimationType.easeOutBack,
//             ),
//             // The Mechanical Needle
//             NeedlePointer(
//               value: value,
//               needleLength: 0.7,
//               needleEndWidth: 4,
//               needleColor: AppColors.white,
//               knobStyle: KnobStyle(
//                 knobRadius: 0.07,
//                 color: AppColors.backgroundDark,
//                 borderColor: AppColors.white,
//                 borderWidth: 0.015,
//               ),
//               enableAnimation: true,
//               animationType: AnimationType.easeOutBack,
//             ),
//           ],
//           annotations: <GaugeAnnotation>[
//             GaugeAnnotation(
//               positionFactor: 0.5,
//               angle: 90,
//               widget: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "${value.toStringAsFixed(0)}%",
//                     style: const TextStyle(
//                       fontSize: 38,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.white,
//                     ),
//                   ),
//                   Text(
//                     "TANK LEVEL",
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: AppColors.primary.withOpacity(0.7),
//                       letterSpacing: 1.5,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         )
//       ],
//     );
//   }
//
//
// }


class SensorDashboard extends ConsumerWidget {
  const SensorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tankAsync = ref.watch(tankStreamProvider);
    final sensorState = ref.watch(sensorViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: IndustrialAppBar(
        title: "Control Center",
        isHome: true,
      ),
      body: tankAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Tank Error: $err")),
        data: (tankData) {
          return _buildDashboardBody(tankData, sensorState);
        },
      ),
    );
  }

  Widget _buildDashboardBody(TankState tank, SensorState sensor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("LIVE TELEMETRY"),
          const SizedBox(height: 20),

          // 1. TANK VIEW
          _buildGlassCard(
            child: Column(
              children: [
                _buildGuageCard(
                  height: 320,
                  child: _buildRadialGauge(sensor.waterLevel),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        "TEMPERATURE",
                        "${sensor.temperature.toStringAsFixed(1)}°C",
                        Icons.thermostat_rounded,
                        Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatTile(
                        "HUMIDITY",
                        "${sensor.humidity.toStringAsFixed(0)}%",
                        Icons.water_drop_rounded,
                        Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                IndustrialTank(level: tank.levelPercentage),
                const SizedBox(height: 24),
                _buildTankReadout(tank),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE UI COMPONENTS ---

  Widget _buildTankReadout(TankState tank) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _readoutItem("LEVEL", "${tank.levelPercentage.toStringAsFixed(1)}%"),
        _readoutItem("VOLUME", "${tank.volumeLitres.toStringAsFixed(0)}L"),
      ],
    );
  }

  Widget _readoutItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white38,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: Colors.cyanAccent),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGuageCard({required Widget child, double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRadialGauge(double value) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      animationDuration: 2000,
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          showLabels: true,
          showTicks: true,
          labelOffset: 15,
          axisLabelStyle: const GaugeTextStyle(color: AppColors.gray600, fontSize: 10),
          majorTickStyle: const MajorTickStyle(length: 8, thickness: 1.5, color: AppColors.gray700),
          minorTickStyle: const MinorTickStyle(length: 4, thickness: 1, color: AppColors.gray800),
          axisLineStyle: AxisLineStyle(
            thickness: 0.1,
            color: AppColors.black.withOpacity(0.3),
            thicknessUnit: GaugeSizeUnit.factor,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: value,
              width: 0.1,
              sizeUnit: GaugeSizeUnit.factor,
              gradient: SweepGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary],
                stops: const [0.1, 1.0],
              ),
              cornerStyle: CornerStyle.bothCurve,
              enableAnimation: true,
              animationType: AnimationType.easeOutBack,
            ),
            NeedlePointer(
              value: value,
              needleLength: 0.7,
              needleEndWidth: 4,
              needleColor: AppColors.white,
              knobStyle: KnobStyle(
                knobRadius: 0.07,
                color: AppColors.backgroundDark,
                borderColor: AppColors.white,
                borderWidth: 0.015,
              ),
              enableAnimation: true,
              animationType: AnimationType.easeOutBack,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              positionFactor: 0.5,
              angle: 90,
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${value.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    "TANK LEVEL",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary.withOpacity(0.7),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
