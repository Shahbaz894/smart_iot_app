// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod/riverpod.dart';
// import 'package:smart_iot_app/src/core/constant/app_color.dart';
//
// import 'package:smart_iot_app/src/features/dashboard/model/motor_model.dart';
// import 'package:smart_iot_app/src/features/dashboard/model/motor_parameter.dart';
// import 'package:smart_iot_app/src/features/dashboard/provider/motor_on_off_provider.dart';
// import 'package:smart_iot_app/src/features/dashboard/widget/custom_drawer.dart';
// import 'package:smart_iot_app/src/features/dashboard/widget/error_state_widget.dart';
// import 'package:smart_iot_app/src/features/dashboard/widget/iot_slider.dart';
// import 'package:smart_iot_app/src/features/dashboard/widget/motor_button.dart';
// import 'package:smart_iot_app/src/features/dashboard/widget/vfd_fault_widget.dart';
// import 'package:intl/intl.dart';
// import '../provider/motor_parameter_provider.dart';
// import '../provider/motor_provider.dart';
//
//
// import 'dart:async';
//
//
// class MotorScreen extends ConsumerStatefulWidget {
//   const MotorScreen({super.key});
//
//   @override
//   ConsumerState<MotorScreen> createState() => _MotorScreenState();
// }
//
// class _MotorScreenState extends ConsumerState<MotorScreen> {
//   Timer? _timer;
//   final int deviceId = 5;
//   final int refreshIntervalSeconds = 5;
//
//   @override
//   void initState() {
//     super.initState();
//     // Use postFrameCallback to avoid state collisions during build
//     WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMotorData());
//
//     _timer = Timer.periodic(
//       Duration(seconds: refreshIntervalSeconds),
//           (_) => _fetchMotorData(),
//     );
//   }
//
//   void _fetchMotorData() {
//     if (mounted) {
//       ref.read(motorParameterViewModelProvider.notifier).fetchMotorParameter(deviceId);
//     }
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final motorState = ref.watch(motorParameterViewModelProvider);
//     final motorOnOff = ref.watch(motorOnOffViewModelProvider);
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryDark,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text("Motor Control", style: TextStyle(fontWeight: FontWeight.bold)),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: Icon(Icons.settings),
//           )
//         ],
//       ),
//       drawer: const Drawer(child: ProfessionalDrawer()),
//       body: SafeArea(
//         // LayoutBuilder ensures we recalculate based on the actual visible area
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return motorState.when(
//               initial: () => const Center(child: CircularProgressIndicator()),
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (message) => Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Text(message, style: const TextStyle(color: Colors.white)),
//                 ),
//               ),
//               loaded: (motor) => _buildLoadedBody(motor, motorOnOff, constraints),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadedBody(MotorParameter motor, dynamic motorOnOff, BoxConstraints constraints) {
//     final double width = constraints.maxWidth;
//
//     // Calculate grid columns based on available width
//     int crossAxisCount = 3;
//     double aspectRatio = 1.2;
//
//     if (width >= 800) {
//       crossAxisCount = 4;
//       aspectRatio = 1.5;
//     } else if (width >= 500) {
//       crossAxisCount = 3;
//       aspectRatio = 1.4;
//     }
//
//     return SingleChildScrollView(
//       physics: const BouncingScrollPhysics(),
//       padding: EdgeInsets.symmetric(
//         horizontal: width * 0.04,
//         vertical: 16,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           /// Fault Indicators - Using Wrap to prevent horizontal overflow
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.cardDark,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Wrap(
//               alignment: WrapAlignment.spaceEvenly,
//               runSpacing: 12,
//               children: [
//                 _faultBulb("Phase", motor.fault == 1),
//                 _faultBulb("Voltage", motor.fault == 2),
//                 _faultBulb("Trip", motor.fault == 3),
//                 _faultBulb("Service", motor.statusCode != 2),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 20),
//           const ErrorStatusButton(error: null),
//           const SizedBox(height: 24),
//
//           /// Motor Button - Responsive Sizing using ConstrainedBox
//           Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 180, maxHeight: 190),
//               child: MotorButton(
//                 isOn: motorOnOff.data.isOn,
//                 startTime: motorOnOff.data.startTime,
//                 onToggle: () {
//                   final notifier = ref.read(motorOnOffViewModelProvider.notifier);
//                   motorOnOff.data.isOn
//                       ? notifier.stopMotor(deviceId)
//                       : notifier.startMotor(deviceId);
//                 },
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 60),
//
//           /// Parameters Grid
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: 7,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               crossAxisSpacing: 13,
//               mainAxisSpacing: 13,
//               childAspectRatio: aspectRatio,
//             ),
//             itemBuilder: (context, index) {
//               // List of params to map to the grid
//               final params = [
//                     () => _parameterTile("Voltage", motor.voltage, Icons.flash_on, unit: "V", min: 340, max: 400),
//                     () => _parameterTile("Current", motor.current, Icons.bolt, unit: "A", min: 0, max: 50),
//                     () => _parameterTile("Frequency", motor.freq, Icons.sync, unit: "Hz", min: 49, max: 51),
//                     () => _parameterTile("Power", motor.power, Icons.power, unit: "W"),
//                     () => _parameterTile("Speed", motor.motorSpeed.toDouble(), Icons.speed, unit: "rpm", min: 1400, max: 1500),
//                     () => _parameterTile("Power %", motor.powerPercent, Icons.percent, unit: "%"),
//                     () => _parameterTile("Torque %", motor.torquePercent, Icons.settings, unit: "%"),
//               ];
//               return params[index]();
//             },
//           ),
//
//           // Bottom padding to ensure scrollability on small screens
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _faultBulb(String label, bool hasFault) {
//     return FaultIndicatorBulb(
//       label: label,
//       hasFault: hasFault,
//     );
//   }
//
//   Widget _parameterTile(String title, double value, IconData icon, {String unit = '', double? min, double? max}) {
//     Color valueColor = Colors.white;
//
//     if (min != null && max != null) {
//       if (value < min || value > max) {
//         valueColor = (value < min * 0.9 || value > max * 1.1) ? Colors.red : Colors.orange;
//       } else {
//         valueColor = Colors.greenAccent;
//       }
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 4, offset: const Offset(0, 2))
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: AppColors.primary, size: 18),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 2),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               "${value.toStringAsFixed(1)} $unit",
//               style: TextStyle(color: valueColor, fontSize: 15, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }