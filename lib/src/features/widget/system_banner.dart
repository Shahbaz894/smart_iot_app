// import "package:flutter/material.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
//
//
//
// class SystemBanner extends StatelessWidget {
//   final MotorSnapshot snapshot;
//
//   const SystemBanner({
//     super.key,
//     required this.snapshot,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//
//     final text = snapshot.hasFault
//         ? "${snapshot.faultName} Fault"
//         : snapshot.isRunning
//         ? "Running"
//         : snapshot.statusName;
//
//     final foregroundColor = snapshot.bannerColor == AppColors.primary
//         ? AppColors.black
//         : AppColors.white;
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         vertical: width < 360 ? 14 : 16,
//         horizontal: 18,
//       ),
//       decoration: BoxDecoration(
//         color: snapshot.bannerColor,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: snapshot.bannerColor.withOpacity(0.22),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             snapshot.bannerIcon,
//             color: foregroundColor,
//             size: width < 360 ? 24 : 27,
//           ),
//           const SizedBox(width: 10),
//           Flexible(
//             child: Text(
//               text,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: foregroundColor,
//                 fontSize: width < 360 ? 16 : 19,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }