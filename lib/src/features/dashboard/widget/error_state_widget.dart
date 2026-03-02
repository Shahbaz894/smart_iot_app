
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/core/exceptions/device_exception.dart';

import 'package:flutter/material.dart';

class ErrorStatusButton extends StatelessWidget {
  final DeviceException? error;

  const ErrorStatusButton({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final bool hasError = error != null;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: hasError ? AppColors.error : AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(hasError ? Icons.error : Icons.check_circle, color: Colors.white),
      label: Text(
        hasError ? 'Device Error' : 'System OK',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        if (hasError) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: const Text('Device Error', style: TextStyle(color: Colors.white)),
              content: Text(error!.message,
                  style: TextStyle(color: AppColors.textSecondaryDark)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                )
              ],
            ),
          );
        }
      },
    );
  }
}