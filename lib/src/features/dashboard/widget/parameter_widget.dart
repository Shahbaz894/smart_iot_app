import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';

class ParameterCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> values;
  final VoidCallback? onMore;

  const ParameterCard({
    super.key,
    required this.title,
    required this.values,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppColors.shadowDark, blurRadius: 10, offset: const Offset(0, 6))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            if (onMore != null)
              TextButton(onPressed: onMore, child: const Text('See More'))
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: values.length,
          itemBuilder: (context, i) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(values[i]['label']!, style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                const SizedBox(height: 4),
                Text(values[i]['value']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
            );
          },
        )
      ]),
    );
  }
}