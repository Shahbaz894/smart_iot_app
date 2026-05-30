// import "package:flutter/material.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
//
//
// class DeviceSessionCard extends StatelessWidget {
//   final String? deviceId;
//   final MotorSnapshot snapshot;
//   final int? timestamp;
//
//   const DeviceSessionCard({
//     super.key,
//     required this.deviceId,
//     required this.snapshot,
//     required this.timestamp,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final liveText = snapshot.statusName;
//     final liveColor = snapshot.bannerColor;
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: AppColors.borderDark),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Device Session",
//             style: TextStyle(
//               color: AppColors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Container(
//                 height: 10,
//                 width: 10,
//                 decoration: BoxDecoration(
//                   color: liveColor,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   liveText,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: liveColor,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//               Text(
//                 "Code ${snapshot.statusCode ?? "-"}",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.56),
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             "Device ID: ${snapshot.hasDevice ? deviceId : "Device not connected"}",
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.62),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Timestamp: ${timestamp?.toString() ?? "-"}",
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.62),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }