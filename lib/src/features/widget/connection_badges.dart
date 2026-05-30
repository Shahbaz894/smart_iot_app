import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

class DeviceNotConnectedBadge extends StatelessWidget {
  const DeviceNotConnectedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoBadge(
      icon: Icons.link_off_rounded,
      color: AppColors.warning,
      text: "Device not connected. Select a device to view live parameters.",
    );
  }
}

class WaitingTelemetryBadge extends StatelessWidget {
  const WaitingTelemetryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoBadge(
      icon: Icons.sync_rounded,
      color: AppColors.primary,
      text: "Device selected. Waiting for latest telemetry values.",
    );
  }
}

class DeviceDisconnectedBadge extends StatelessWidget {
  const DeviceDisconnectedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return _InfoBadge(
      icon: Icons.wifi_off_rounded,
      color: AppColors.warning,
      text: "Device disconnected. Showing last received values when available.",
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoBadge({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.85),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}