//  import 'package:flutter/material.dart';
//
//
// // class IoTSwitchCard extends StatelessWidget {
// //   final String title;
// //   final IconData icon;
// //   final bool isActive;
// //   final ValueChanged<bool> onToggle; // Changed from onTap to handle switch state
// //
// //   const IoTSwitchCard({
// //     super.key,
// //     required this.title,
// //     required this.icon,
// //     required this.isActive,
// //     required this.onToggle, required Function() onLongPress,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         // Background turns Blue when active, Dark Grey when inactive
// //         color: isActive ? Colors.blueAccent : Colors.white.withOpacity(0.05),
// //         borderRadius: BorderRadius.circular(24),
// //         border: Border.all(
// //           color: isActive ? Colors.white24 : Colors.white10,
// //           width: 1,
// //         ),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Icon(
// //                 icon,
// //                 size: 28,
// //                 // Icon turns white when background is blue
// //                 color: isActive ? Colors.white : Colors.blueAccent,
// //               ),
// //               // The Toggle Switch
// //               Transform.scale(
// //                 scale: 0.8, // Make the switch slightly smaller/professional
// //                 child: Switch.adaptive(
// //                   value: isActive,
// //                   activeColor: Colors.white,
// //                   activeTrackColor: Colors.white.withOpacity(0.3),
// //                   inactiveThumbColor: Colors.blueAccent,
// //                   onChanged: onToggle,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 title,
// //                 style: TextStyle(
// //                   color: isActive ? Colors.white : Colors.white70,
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 16,
// //                 ),
// //               ),
// //               const SizedBox(height: 4),
// //               Text(
// //                 isActive ? "ONLINE" : "OFFLINE", // Dynamic text
// //                 style: TextStyle(
// //                   color: isActive ? Colors.white.withOpacity(0.8) : Colors.white38,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.w500,
// //                   letterSpacing: 1.1,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//  class IoTSwitchCard extends StatelessWidget {
//    final String title;
//    final IconData icon;
//    final bool isActive;
//    final ValueChanged<bool> onToggle;
//    final VoidCallback onLongPress; // Fixed: Properly declared as a property
//
//    const IoTSwitchCard({
//      super.key,
//      required this.title,
//      required this.icon,
//      required this.isActive,
//      required this.onToggle,
//      required this.onLongPress, // Fixed: properly assigned to class property
//    });
//
//    @override
//    Widget build(BuildContext context) {
//      return GestureDetector(
//        onLongPress: onLongPress, // This enables the rename dialog!
//        child: AnimatedContainer(
//          duration: const Duration(milliseconds: 300),
//          padding: const EdgeInsets.all(16),
//          decoration: BoxDecoration(
//            color: isActive ? Colors.blueAccent : Colors.white.withOpacity(0.05),
//            borderRadius: BorderRadius.circular(24),
//            border: Border.all(
//              color: isActive ? Colors.white24 : Colors.white10,
//              width: 1,
//            ),
//          ),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: [
//              Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: [
//                  Icon(
//                    icon,
//                    size: 28,
//                    color: isActive ? Colors.white : Colors.blueAccent,
//                  ),
//                  Transform.scale(
//                    scale: 0.8,
//                    child: Switch.adaptive(
//                      value: isActive,
//                      activeColor: Colors.white,
//                      activeTrackColor: Colors.white.withOpacity(0.3),
//                      inactiveThumbColor: Colors.blueAccent,
//                      onChanged: onToggle,
//                    ),
//                  ),
//                ],
//              ),
//              Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  Text(
//                    title,
//                    style: TextStyle(
//                      color: isActive ? Colors.white : Colors.white70,
//                      fontWeight: FontWeight.bold,
//                      fontSize: 16,
//                    ),
//                  ),
//                  const SizedBox(height: 4),
//                  Text(
//                    isActive ? "ON" : "OFF", // Cleaner label
//                    style: TextStyle(
//                      color: isActive ? Colors.white.withOpacity(0.8) : Colors.white38,
//                      fontSize: 12,
//                      fontWeight: FontWeight.w500,
//                      letterSpacing: 1.1,
//                    ),
//                  ),
//                ],
//              ),
//            ],
//          ),
//        ),
//      );
//    }
//  }