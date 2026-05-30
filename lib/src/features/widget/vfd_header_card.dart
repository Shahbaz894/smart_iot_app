import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";


class VfdHeaderCard extends StatelessWidget {
  final String displayName;
  final MotorSnapshot snapshot;
  final String frequencyText;
  final String referenceFrequencyText;

  const VfdHeaderCard({
    super.key,
    required this.displayName,
    required this.snapshot,
    required this.frequencyText,
    required this.referenceFrequencyText,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 390;

    return Container(
      padding: EdgeInsets.all(compact ? 15 : 18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: compact ? 54 : 62,
            width: compact ? 54 : 62,
            decoration: BoxDecoration(
              color: snapshot.bannerColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              snapshot.bannerIcon,
              color: snapshot.bannerColor,
              size: compact ? 28 : 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.hasDevice ? displayName : "Device Not Connected",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.statusName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: snapshot.bannerColor,
                    fontSize: compact ? 12.5 : 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Running Frequency",
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.62),
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                frequencyText,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: compact ? 19 : 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Ref $referenceFrequencyText",
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.50),
                  fontSize: compact ? 10.5 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}