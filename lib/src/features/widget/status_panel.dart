// import "package:flutter/material.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
//
//
//
// class StatusPanel extends StatelessWidget {
//   final MotorSnapshot snapshot;
//   final Animation<double> pulseAnimation;
//
//   const StatusPanel({
//     super.key,
//     required this.snapshot,
//     required this.pulseAnimation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final phaseOk =
//         snapshot.connectionStatus == DeviceConnectionStatus.connected;
//     final motorOk = snapshot.isRunning;
//     final tripOk = !snapshot.hasFault;
//     final serviceOk =
//         snapshot.connectionStatus == DeviceConnectionStatus.connected;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: AppColors.borderDark),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: StatusDot(
//               title: "Phase",
//               ok: phaseOk,
//               blinking: false,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//           Expanded(
//             child: StatusDot(
//               title: "Motor",
//               ok: motorOk,
//               blinking: false,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//           Expanded(
//             child: StatusDot(
//               title: "Trip",
//               ok: tripOk,
//               blinking: snapshot.hasFault,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//           Expanded(
//             child: StatusDot(
//               title: "Service",
//               ok: serviceOk,
//               blinking:
//               snapshot.connectionStatus == DeviceConnectionStatus.disconnected,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class StatusDot extends StatelessWidget {
//   final String title;
//   final bool ok;
//   final bool blinking;
//   final Animation<double> pulseAnimation;
//
//   const StatusDot({
//     super.key,
//     required this.title,
//     required this.ok,
//     required this.blinking,
//     required this.pulseAnimation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final dotSize = width < 360 ? 40.0 : 48.0;
//     final baseColor = ok ? AppColors.green : AppColors.error;
//
//     return AnimatedBuilder(
//       animation: pulseAnimation,
//       builder: (context, child) {
//         final scale = blinking ? pulseAnimation.value : 1.0;
//         final opacity =
//         blinking ? (0.55 + (pulseAnimation.value - 0.82)) : 1.0;
//
//         return Column(
//           children: [
//             Transform.scale(
//               scale: scale,
//               child: Opacity(
//                 opacity: opacity.clamp(0.45, 1.0),
//                 child: Container(
//                   height: dotSize,
//                   width: dotSize,
//                   decoration: BoxDecoration(
//                     color: baseColor,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: baseColor.withOpacity(0.42),
//                         blurRadius: blinking ? 28 : 18,
//                         spreadRadius: blinking ? 4 : 2,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             FittedBox(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.7),
//                   fontSize: width < 360 ? 12 : 14,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }