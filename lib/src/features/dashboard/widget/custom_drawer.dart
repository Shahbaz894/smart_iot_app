import 'package:flutter/material.dart';
import 'package:smart_iot_app/src/features/dashboard/view/automation_screen.dart';
import 'package:smart_iot_app/src/features/dashboard/view/sensor_dashboard.dart';
import 'package:smart_iot_app/src/features/dashboard/view/voice_control_screen.dart';

class ProfessionalDrawer extends StatelessWidget {
  const ProfessionalDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF11141E),
      child: Column(
        children: [
          // Header with System Identity
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1D2D)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.cyanAccent.withOpacity(0.1),
              child: const Icon(Icons.precision_manufacturing, color: Colors.cyanAccent, size: 30),
            ),
            accountName: const Text("OPERATOR-01", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            accountEmail: const Text("System Status: Optimal", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
          ),

          // Menu Items
         // _drawerTile(context, "Control Center", Icons.dashboard_rounded, const IoTControlScreen(), isActive: true),
          _drawerTile(context, "Tank Telemetry", Icons.speed_rounded, const SensorDashboard()),
          _drawerTile(context, "Automation", Icons.settings_input_component_rounded, const AutomationScreen()),
          _drawerTile(context, "VoiceControl", Icons.mic_none_outlined, const VoiceControlScreen()),

          const Divider(color: Colors.white10, indent: 20, endIndent: 20),
          _drawerTile(context, "System Logs", Icons.list_alt_rounded, null),

          const Spacer(),
          // Footer
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("FIRMWARE V2.4.0", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, String title, IconData icon, Widget? destination, {bool isActive = false}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.cyanAccent : Colors.white54),
      title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 14)),
      selected: isActive,
      selectedTileColor: Colors.white.withOpacity(0.05),
      onTap: () {
        Navigator.pop(context); // Close Drawer
        if (destination != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}