
import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/view/switch_control_screen.dart';



class IndustrialAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHome;

  const IndustrialAppBar({
    super.key,
    required this.title,
    this.isHome = false
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      centerTitle: true,
      // If it's home, it shows the Drawer icon. If not, it shows the Back Arrow.
      leading: isHome ? null : IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        // onPressed: () => Navigator.pop(context),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const IoTControlScreen(),
            ),
                (route) => false,
          );
        },
      ),
      title: Column(
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)
              ),
              const SizedBox(width: 6),
              const Text("SYSTEM LIVE", style: TextStyle(fontSize: 9, color: Colors.greenAccent)),
            ],
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: AppColors.textPrimaryDark),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}