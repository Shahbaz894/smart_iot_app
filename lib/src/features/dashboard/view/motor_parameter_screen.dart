// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:smart_iot_app/src/core/constant/app_color.dart';
//
// import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/motor_viewmodel.dart';
// import 'package:smart_iot_app/src/features/dashboard/view/motor_screen.dart';
//
// import '../provider/motor_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// class MotorParameterScreen extends ConsumerWidget {
//   const MotorParameterScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     //final motorAsync = ref.watch(motorViewModelProvider);
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundDark,
//         elevation: 0,
//         title: const Text(
//           "Motor Parameters",
//           style: TextStyle(
//               color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.white),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const MotorScreen()),
//             );
//           },
//         ),
//       ),
//       body: motorAsync.when(
//         loading: () => const Center(
//           child: CircularProgressIndicator(color: AppColors.primary),
//         ),
//         error: (e, _) => Center(
//             child: Text("Error: $e",
//                 style: const TextStyle(color: AppColors.white))),
//         data: (motor) => ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//
//
//
//
//             _parameterCard("Voltage", [
//               ["L1 Voltage", "${motor.vL1.toStringAsFixed(1)} V"],
//               ["L2 Voltage", "${motor.vL2.toStringAsFixed(1)} V"],
//               ["L3 Voltage", "${motor.vL3.toStringAsFixed(1)} V"],
//               ["Frequency", "${motor.frequency.toStringAsFixed(1)} Hz"],
//             ]),
//             _parameterCard("Current", [
//               ["L1 Current", "${motor.cL1.toStringAsFixed(2)} A"],
//               ["L2 Current", "${motor.cL2.toStringAsFixed(2)} A"],
//               ["L3 Current", "${motor.cL3.toStringAsFixed(2)} A"],
//               ["Load", "${motor.load.toStringAsFixed(1)} %"],
//             ]),
//             _parameterCard("Power", [
//               ["Active Power", "${motor.activePower.toStringAsFixed(2)} kW"],
//               ["Reactive Power", "${motor.reactivePower.toStringAsFixed(2)} kVAR"],
//               ["Apparent Power", "${motor.apparentPower.toStringAsFixed(2)} kVA"],
//               ["Power Factor", motor.powerFactor.toStringAsFixed(2)],
//             ]),
//             _parameterCard("System", [
//               ["Mode", motor.mode],
//               ["Motor State", motor.isOn ? "Running" : "Stopped"],
//               ["Start Time", motor.startTime != null
//                   ? DateFormat('HH:mm:ss').format(motor.startTime!)
//                   : "-"],
//             ]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _parameterCard(String title, List<List<String>> rows) {
//     return Card(
//       color: AppColors.cardDark, // card background
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5)),
//             Divider(color: AppColors.white.withOpacity(0.2), thickness: 1.2, height: 16),
//             ...rows.map(
//                   (r) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(r[0], style: const TextStyle(color: AppColors.white)),
//                     Text(r[1], style: const TextStyle(color: AppColors.white)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }