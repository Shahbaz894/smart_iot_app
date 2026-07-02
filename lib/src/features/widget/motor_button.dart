// import "package:flutter/material.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
//
// class MotorButton extends StatelessWidget {
//   final MotorSnapshot snapshot;
//   final bool loading;
//   final double size;
//   final VoidCallback? onTap;
//
//   const MotorButton({
//     super.key,
//     required this.snapshot,
//     required this.loading,
//     required this.size,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     debugPrint("🟠 MOTOR BUTTON BUILD => running=${snapshot.isRunning}, loading=$loading");
//
//     final Color activeColor =
//     snapshot.connectionStatus == DeviceConnectionStatus.noDevice
//         ? AppColors.warning
//         : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
//         ? AppColors.warning
//         : snapshot.hasFault
//         ? AppColors.error
//         : snapshot.isRunning
//         ? AppColors.green
//         : AppColors.error;
//
//     final String label =
//     snapshot.connectionStatus == DeviceConnectionStatus.noDevice
//         ? "N/A"
//         : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
//         ? "OFFLINE"
//         : snapshot.hasFault
//         ? "FAULT"
//         : snapshot.isRunning
//         ? "RUNNING"
//         : "MOTOR OFF";
//
//     final IconData icon = snapshot.bannerIcon;
//
//     // ⚡ 100% TOUCH CATCHER: Ab click zaya nahi hoga!
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () {
//         debugPrint("🚨 PHYSICAL TOUCH DETECTED ON MOTOR BUTTON!");
//         if (loading) {
//           debugPrint("⏳ Button Ignored: Already loading...");
//           return;
//         }
//         if (onTap != null) {
//           debugPrint("✅ VALID CLICK: Forwarding to HomeScreen...");
//           onTap!();
//         } else {
//           debugPrint("❌ ERROR: onTap Callback is NULL!");
//         }
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//         width: size,
//         height: size,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [activeColor, activeColor.withOpacity(0.72)],
//           ),
//           border: Border.all(
//             color: Colors.white.withOpacity(0.16),
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: activeColor.withOpacity(snapshot.isRunning ? 0.45 : 0.30),
//               blurRadius: snapshot.isRunning ? 42 : 34,
//               offset: const Offset(0, 16),
//             ),
//           ],
//         ),
//         child: loading
//             ? const SizedBox(
//           width: 36,
//           height: 36,
//           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
//         )
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.white, size: size < 190 ? 36 : 44),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: FittedBox(
//                 child: Text(
//                   label,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: label == "OFFLINE" ? 22 : label == "MOTOR OFF" ? 24 : label == "RUNNING" ? 28 : size < 190 ? 26 : 36,
//                     fontWeight: FontWeight.w900,
//                     letterSpacing: 0.4,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";

class MotorButton extends StatelessWidget {
  final MotorSnapshot snapshot;
  final bool loading;
  final double size;
  final VoidCallback? onTap;

  const MotorButton({
    super.key,
    required this.snapshot,
    required this.loading,
    required this.size,
    this.onTap,
  });

  /// ⚙️ Helper to map trigger types to UI labels and icons
  Map<String, dynamic> _getTriggerInfo(String? type) {
    switch (type?.toLowerCase()) {
      case 'physical':
        return {'label': 'MANUAL', 'icon': Icons.touch_app};
      case 'app':
        return {'label': 'APP', 'icon': Icons.smartphone};
      case 'timer':
        return {'label': 'TIMER', 'icon': Icons.timer_rounded};
      case 'schedule':
        return {'label': 'SCHEDULE', 'icon': Icons.event_note_rounded};
      default:
      // Default case for remote or null triggers
        return {'label': 'REMOTE', 'icon': Icons.cloud_queue_rounded};
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Color Logic
    final Color activeColor =
    snapshot.connectionStatus == DeviceConnectionStatus.noDevice
        ? AppColors.warning
        : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
        ? AppColors.warning
        : snapshot.hasFault
        ? AppColors.error
        : snapshot.isRunning
        ? AppColors.green
        : AppColors.error;

    // 2. Status Label Logic
    final String label =
    snapshot.connectionStatus == DeviceConnectionStatus.noDevice
        ? "N/A"
        : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
        ? "OFFLINE"
        : snapshot.hasFault
        ? "FAULT"
        : snapshot.isRunning
        ? "RUNNING"
        : "MOTOR OFF";

    // 3. Trigger Logic
    final triggerData = _getTriggerInfo(snapshot.triggerType);
    final String triggerLabel = triggerData['label'];
    final IconData triggerIcon = triggerData['icon'];

    // Only show badge if we are actually connected
    final bool showBadge = snapshot.connectionStatus == DeviceConnectionStatus.connected
        && snapshot.triggerType != null;

    final IconData icon = snapshot.bannerIcon;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (loading) return;
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [activeColor, activeColor.withOpacity(0.72)],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.16), width: 2),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(snapshot.isRunning ? 0.4 : 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: size < 190 ? 36 : 44),

            // Main Status Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: FittedBox(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size < 190 ? 22 : 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Industry Level Trigger Badge
            if (showBadge)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(triggerIcon, size: 10, color: Colors.white.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      triggerLabel,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}