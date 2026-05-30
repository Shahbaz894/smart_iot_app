import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/constant/app_color.dart';

import 'package:smart_iot_app/src/features/dashboard/model/time_model.dart';

class TimerControlCard extends StatelessWidget {
  final TimerDevice timer;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  const TimerControlCard({
    super.key,
    required this.timer,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: timer.isEnabled ? AppColors.primary.withOpacity(0.5) : AppColors.borderDark,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon Background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.timer_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            // Title & Time Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timer.title,
                    style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "GPIO PIN: ${timer.espPin} • ${timer.isEnabled ? 'Active' : 'Paused'}",
                    style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  // Time Badge
                  Row(
                    children: [
                      _timeBadge(timer.startTime, Icons.play_arrow_rounded),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, size: 12, color: AppColors.gray600),
                      ),
                      _timeBadge(timer.stopTime, Icons.stop_rounded),
                    ],
                  ),
                ],
              ),
            ),
            // Switch to Enable/Disable the schedule
            Switch.adaptive(
              value: timer.isEnabled,
              activeColor: AppColors.primary,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBadge(TimeOfDay time, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}