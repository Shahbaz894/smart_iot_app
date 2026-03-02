// Motor Dashboard UI
// Beautiful responsive UI with indicators, error button, ON/OFF control, and power parameters

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';


// -----------------------------------------------------------------------------
// LIGHT INDICATOR BULB
// -----------------------------------------------------------------------------
class FaultIndicatorBulb extends StatelessWidget {
  final String label;
  final bool hasFault;

  const FaultIndicatorBulb({
    super.key,
    required this.label,
    required this.hasFault,
  });

  @override
  Widget build(BuildContext context) {
    final Color glowColor = hasFault ? AppColors.error : AppColors.success;

    return Column(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glowColor,
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ))
      ],
    );
  }
}


