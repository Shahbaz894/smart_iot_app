import"package:flutter/material.dart";
import "package:smart_iot_app/src/core/contants/app_color.dart";




class StatusHeader extends StatelessWidget {
  final bool isSynced;
  final double inputVoltage;
  final double outputVoltage;
  final double current;
  final double frequency;

  const StatusHeader({
    super.key,
    required this.isSynced,
    required this.inputVoltage,
    required this.outputVoltage,
    required this.current,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSynced
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.gray800.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSynced ? AppColors.primary : AppColors.borderDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(Icons.circle,
                  size: 12,
                  color: isSynced
                      ? AppColors.primary
                      : AppColors.gray600),
              const SizedBox(width: 12),
              Text(
                isSynced
                    ? "SYSTEM STATUS: ACTIVE & SYNCED"
                    : "SYSTEM STATUS: OFFLINE / PENDING",
                style: TextStyle(
                  color: isSynced
                      ? AppColors.white
                      : AppColors.textSecondaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _MetricTile("Input V", "$inputVoltage V"),
              _MetricTile("Output V", "$outputVoltage V"),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _MetricTile("Current", "$current A"),
              _MetricTile("Frequency", "$frequency Hz"),
            ],
          ),
        ],
      ),
    );
  }
}

/// Private widget (can stay private inside this file)
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray600,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
