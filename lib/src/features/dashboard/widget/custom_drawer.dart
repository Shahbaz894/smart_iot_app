import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/view/automation_screen.dart';
import 'package:smart_iot_app/src/features/dashboard/view/motor_parameter_screen.dart';





class ProfessionalDrawer extends StatelessWidget {
  const ProfessionalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundDark, // use your AppColors
      child: Column(
        children: [
          // Header with System Identity
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.cardDark), // dark card color
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.precision_manufacturing,
                  color: AppColors.primary, size: 30),
            ),
            accountName: const Text(
              "OPERATOR-01",
              style: TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
            ),
            accountEmail: const Text(
              "System Status: Optimal",
              style: TextStyle(color: AppColors.green, fontSize: 12),
            ),
          ),

          // Menu Items

          _drawerTile(context, "Automation", Icons.settings_input_component_rounded,
              const AutomationScreen()),


          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          _drawerTile(context, "Motor Parameter", Icons.motion_photos_on_rounded,
              const MotorParameterScreen()),

          const Divider(color: Colors.white10, indent: 20, endIndent: 20),

          _drawerTile(context, "System Logs", Icons.list_alt_rounded, null),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "FIRMWARE V2.4.0",
              style: TextStyle(
                  color: AppColors.white.withOpacity(0.3),
                  fontSize: 10,
                  letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, String title, IconData icon,
      Widget? destination,
      {bool isActive = false}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.primary : AppColors.white),
      title: Text(title,
          style: TextStyle(
              color: isActive ? AppColors.white : AppColors.white,
              fontSize: 14)),
      selected: isActive,
      selectedTileColor: AppColors.white.withOpacity(0.05),
      onTap: () {
        Navigator.pop(context); // Close Drawer
        if (destination != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => destination,
              ));
        }
      },
    );
  }
}