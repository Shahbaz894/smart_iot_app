import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:smart_iot_app/src/core/contants/app_color.dart';
import 'package:smart_iot_app/src/features/dashboard/model/motor_model.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/custom_drawer.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/error_state_widget.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/iot_slider.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/motor_button.dart';
import 'package:smart_iot_app/src/features/dashboard/widget/vfd_fault_widget.dart';
import 'package:intl/intl.dart';
import '../provider/motor_provider.dart';

// MOTOR SCREEN
// ---


// ================= MOTOR SCREEN =================
class MotorScreen extends ConsumerWidget {
  const MotorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motorAsync = ref.watch(motorViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true, // ensure drawer icon appears
        title: const Text(
          'Motor Control',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings, color: Colors.white),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.cardDark, // lighter than backgroundDark
        child: ProfessionalDrawer(),  // separate widget with drawer items
      ),
      body: SafeArea(
        child: motorAsync.when(
          loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) =>
              Center(child: Text("Error: $e", style: const TextStyle(color: Colors.white))),
          data: (motor) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ================= FAULT INDICATORS =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FaultIndicatorBulb(label: 'Phase', hasFault: motor.phaseFault),
                    FaultIndicatorBulb(label: 'Voltage', hasFault: motor.voltageFault),
                    FaultIndicatorBulb(label: 'Trip', hasFault: motor.tripFault),
                    FaultIndicatorBulb(label: 'Service', hasFault: motor.maintenanceRequired),
                  ],
                ),
                const SizedBox(height: 20),

                // ================= ERROR STATUS =================
                ErrorStatusButton(error: motor.deviceError),
                const SizedBox(height: 30),


                // MotorButton(
                //   isOn: motor.isOn,
                //   startTime: motor.startTime,
                //   onToggle: () {
                //     ref.read(motorViewModelProvider.notifier).toggle(!motor.isOn);
                //   },
                // ),
                MotorButton(
                  isOn: motor.isOn,
                  startTime: motor.startTime,
                  onToggle: () {
                    final faults = _getActiveFaults(motor);

                    if (faults.isNotEmpty) {
                      // 🚨 Fault exists → show dialog
                      _showFaultDialog(context, faults);
                    } else {
                      // ✅ No fault → allow motor control
                      ref.read(motorViewModelProvider.notifier).toggle(!motor.isOn);
                    }
                  },
                ),


                const SizedBox(height: 30),

                // ================= PARAMETERS (Professional Cards) =================
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _parameterTileVoltage('Voltage', motor.vL1, motor.vL2, motor.vL3),
                    _parameterTileCurrent('Current', motor.cL1, motor.cL2, motor.cL3),
                    _parameterTileSingle('Frequency', '${motor.frequency.toStringAsFixed(1)} Hz', Icons.sync),
                    _parameterTileSingle('Load', '${motor.load.toStringAsFixed(1)} %', Icons.speed),
                    _parameterTileSingle('Power Factor', motor.powerFactor.toStringAsFixed(2), Icons.power),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= PARAMETER TILE =================
  // ================= VOLTAGE TILE =================
  Widget _parameterTileVoltage(String title, double vL1, double vL2, double vL3) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flash_on, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          Text('L1: ${vL1.toStringAsFixed(1)} V',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('L2: ${vL2.toStringAsFixed(1)} V',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('L3: ${vL3.toStringAsFixed(1)} V',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// ================= CURRENT TILE =================
  Widget _parameterTileCurrent(String title, double cL1, double cL2, double cL3) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          Text('L1: ${cL1.toStringAsFixed(2)} A',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('L2: ${cL2.toStringAsFixed(2)} A',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('L3: ${cL3.toStringAsFixed(2)} A',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// ================= SINGLE PARAMETER TILE =================
  Widget _parameterTileSingle(String title, String value, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
  List<String> _getActiveFaults(MotorModel motor) {
    final faults = <String>[];

    if (motor.phaseFault) faults.add("Phase Fault");
    if (motor.voltageFault) faults.add("Voltage Fault");
    if (motor.tripFault) faults.add("Trip Fault");
    if (motor.maintenanceRequired) faults.add("Maintenance Required");

    if (motor.deviceError != null) {
      faults.add(motor.deviceError!.message);
    }

    return faults;
  }

  void _showFaultDialog(BuildContext context, List<String> faults) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Motor Fault",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: faults
                .map(
                  (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}




