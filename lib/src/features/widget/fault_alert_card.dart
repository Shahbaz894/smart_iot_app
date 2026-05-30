// import "package:flutter/material.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
//
//
//
// class FaultAlertCard extends StatelessWidget {
//   final MotorSnapshot snapshot;
//
//   const FaultAlertCard({
//     super.key,
//     required this.snapshot,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: AppColors.error.withOpacity(0.14),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: AppColors.error.withOpacity(0.38),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(
//             Icons.warning_amber_rounded,
//             color: AppColors.error,
//             size: 30,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   snapshot.faultName,
//                   style: const TextStyle(
//                     color: AppColors.error,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   snapshot.faultDescription,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.78),
//                     fontSize: 13.5,
//                     height: 1.35,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }