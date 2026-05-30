import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";

class MotorButton extends StatelessWidget {
  final MotorSnapshot snapshot;

  /// Use only manual ON/OFF command loading here.
  /// Do NOT pass background syncing here.
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

  bool get _canTap {
    if (loading) return false;

    if (snapshot.connectionStatus == DeviceConnectionStatus.noDevice) {
      return false;
    }

    if (snapshot.connectionStatus == DeviceConnectionStatus.disconnected) {
      return false;
    }

    if (snapshot.hasFault) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "🟠 MOTOR BUTTON BUILD => running=${snapshot.isRunning}, loading=$loading, status=${snapshot.connectionStatus}",
    );

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

    final IconData icon = snapshot.bannerIcon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey(
          "motor_button_tap_${snapshot.isRunning}_${snapshot.connectionStatus}_$loading",
        ),
        onTap: _canTap ? onTap : null,
        borderRadius: BorderRadius.circular(size),
        child: AnimatedContainer(
          key: ValueKey(
            "motor_button_circle_${snapshot.isRunning}_${snapshot.connectionStatus}_$label",
          ),
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
              colors: [
                activeColor,
                activeColor.withOpacity(0.72),
              ],
            ),
            border: Border.all(
              color: AppColors.white.withOpacity(0.16),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(
                  snapshot.isRunning ? 0.45 : 0.30,
                ),
                blurRadius: snapshot.isRunning ? 42 : 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: loading
              ? const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 3,
            ),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  icon,
                  key: ValueKey(
                    "motor_icon_${snapshot.isRunning}_${snapshot.connectionStatus}_$icon",
                  ),
                  color: AppColors.white,
                  size: size < 190 ? 36 : 44,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: FittedBox(
                    key: ValueKey(
                      "motor_label_${snapshot.isRunning}_${snapshot.connectionStatus}_$label",
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: label == "OFFLINE"
                            ? 22
                            : label == "MOTOR OFF"
                            ? 24
                            : label == "RUNNING"
                            ? 28
                            : size < 190
                            ? 26
                            : 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}