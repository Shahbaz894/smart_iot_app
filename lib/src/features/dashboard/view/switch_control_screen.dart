import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/device_view_model.dart' hide deviceViewModelProvider;
import 'package:smart_iot_app/src/features/dashboard/view/automation_screen.dart';
import 'package:smart_iot_app/src/features/dashboard/view/sensor_dashboard.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/custom_drawer.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/iot_control_card_switch.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/iot_slider.dart';

import '../provider/device_provide.dart';


class IoTControlScreen extends ConsumerWidget {
  const IoTControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(deviceViewModelProvider);
    final viewModel = ref.watch(deviceViewModelProvider.notifier);



    return Scaffold(
        backgroundColor: AppColors.backgroundDark,

        // 1. Professional Custom AppBar
        appBar: AppBar(
          backgroundColor: AppColors.blueDark, // Use your class variable
          elevation: 0,
          centerTitle: true,
          // Note: Removed 'const' from AppBar because it's no longer a constant expression
          title: Column(
            children: [
              const Text("COMMAND CENTER",
                  style: TextStyle(fontSize: 12, letterSpacing: 2, color: Colors.white54)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)
                  ),
                  const SizedBox(width: 8),
                  const Text("LIVE DATA",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
          // This icon opens the Drawer. Ensure it's not the same color as the background!
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white38),
              onPressed: () {},
            ),
          ],
        ),

        // 2. The Drawer
        // Remove 'const' here if ProfessionalDrawer uses appcolor inside it
        drawer: const ProfessionalDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSystemPulseCard(deviceState), // Added High-Level Status

            const SizedBox(height: 30),
            const Text("MANUAL OVERRIDE",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 16),


            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final defaultNames = ["Light", "Cooling Fan", "Water Pump", "Heater"];
                final icons = [
                  Icons.lightbulb_outline,
                  Icons.cyclone,
                  Icons.water_drop_outlined,
                  Icons.local_fire_department
                ];

                // Access the device safely
                final bool hasData = deviceState.devices.length > index;
                final String displayName = hasData ? deviceState.devices[index].name : defaultNames[index];
                final bool isOn = hasData ? deviceState.devices[index].isOn : false;

                return IoTSwitchCard(
                  title: displayName,
                  icon: icons[index],
                  isActive: isOn,
                  onToggle: (val) {
                    // This triggers the ViewModel toggle
                    viewModel.toggleDevice(index);
                  },
                  onLongPress: () {
                    // This triggers the rename dialog
                    _showRenameDialog(context, viewModel, index, displayName);
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // Slider with Custom Styling
            _buildControlContainer(
              child: IoTSlider(
                label: "MOTOR SPEED",
                value: deviceState.motorSpeed,
                onChanged: (newValue) => viewModel.setMotorSpeed(newValue),
              ),
            ),

            const SizedBox(height: 40),
            _buildEmergencyButton(viewModel),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI BUILDERS ---

  Widget _buildSystemPulseCard(dynamic state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.cyanAccent.withOpacity(0.1), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _pulseStat("LOAD", "72%", Colors.white),
          const VerticalDivider(color: Colors.white10),
          _pulseStat("UPTIME", "14h 22m", Colors.white70),
          const VerticalDivider(color: Colors.white10),
          _pulseStat("ALERTS", "0", Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _pulseStat(String label, String value, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildControlContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildEmergencyButton(dynamic viewModel) {
    return GestureDetector(
      onTap: () => viewModel.triggerEmergencyStop(),
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.redAccent, Color(0xFFB71C1C)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: const Center(
          child: Text(
            "EMERGENCY STOP",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, DeviceViewModel viewModel, int index, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Change Device Name", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Enter Name (e.g. Water Pump)",
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              // This updates the name in the ViewModel and Firebase
              viewModel.updateDeviceName(index, controller.text);
              Navigator.pop(context);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }
}