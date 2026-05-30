import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 360;

    return Container(
      padding: EdgeInsets.all(compact ? 13 : 17),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withOpacity(0.38)
              : AppColors.borderDark,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withOpacity(0.26),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: highlight ? AppColors.primary : AppColors.iconInactiveDark,
            size: compact ? 24 : 28,
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.62),
              fontSize: compact ? 12.5 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.white,
                height: 1.25,
                fontSize: compact ? 17 : 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}