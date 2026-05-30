import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/devices/presentation/%20views/device_screen.dart";
import "package:smart_iot_app/src/features/faults/presentation/screens/fault_screen.dart";
import "package:smart_iot_app/src/features/khata/presentation/views/%20khata_screen.dart";
import "package:smart_iot_app/src/features/logs/data/presentation/views/motor_log_screen.dart";
import "package:smart_iot_app/src/features/motor_timer/presentation/views/motor_timer_screen.dart";
import "package:smart_iot_app/src/features/schedule/presentation/views/schedule_screen.dart";
import "package:smart_iot_app/src/features/telemetry/presentation/views/telemetry_screen.dart";
import "package:smart_iot_app/src/features/vfd/presentation/views/vfd_control_screen.dart";
import 'package:url_launcher/url_launcher.dart';
//
 import "../../core/providers/theme_provider.dart";
import "../auth/ presentation/providers/auth_providers.dart";



class ProfessionalDrawer extends ConsumerWidget {
  final String deviceId;

  const ProfessionalDrawer({
    super.key,
    required this.deviceId,
  });

  // =========================
  // OPEN URL
  // =========================
  Future<void> _openUrl(
      BuildContext context,
      String url,
      ) async {
    try {
      final uri = Uri.parse(url);

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      _showError(
        context,
        "Unable to open page",
      );
    }
  }

  // =========================
  // VALIDATE DEVICE
  // =========================
  bool _validateDevice(BuildContext context) {
    if (deviceId.trim().isEmpty) {
      _showError(
        context,
        "Device ID not found",
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Drawer(
      width: size.width * 0.80,
      backgroundColor: AppColors.darkBgSoft,
      child: SafeArea(
        child: Column(
          children: [

            // =========================
            // HEADER
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                    AppColors.primary.withOpacity(0.15),
                    child: Icon(
                      Icons.precision_manufacturing_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "OPERATOR-01",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "System Status : Optimal",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // SCROLLABLE MENU
            // =========================
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                children: [

                  _drawerTile(
                    context,
                    title: "Automation",
                    icon: Icons.auto_mode_rounded,
                    onTap: () {
                      if (!_validateDevice(context)) return;

                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScheduleScreen(
                            deviceId: deviceId,
                          ),
                        ),
                      );
                    },
                  ),

                  _divider(),

                  // =========================
                  // CONTACT
                  // =========================


                  _divider(),

                  _drawerTile(
                    context,
                    title: "VFD Control",
                    icon: Icons.settings_remote_rounded,
                    onTap: () {
                      if (!_validateDevice(context)) return;

                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VfdControlScreen(
                            deviceId: deviceId,
                          ),
                        ),
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    title: "System Logs",
                    icon: Icons.list_alt_rounded,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MotorLogScreen(
                            deviceId: deviceId,
                          ),
                        ),
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    title: "Account",
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: () {
                      if (!_validateDevice(context)) return;

                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KhataScreen(
                            deviceId: deviceId,
                          ),
                        ),
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    title: "Timer",
                    icon: Icons.timer_rounded,
                    onTap: () {
                      if (!_validateDevice(context)) return;

                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MotorTimerScreen(
                            deviceId: deviceId,
                          ),
                        ),
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    title: "Motor Fault",
                    icon: Icons.analytics_rounded,
                    onTap: () {
                      if (!_validateDevice(context)) return;

                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FaultScreen(
                            deviceId: deviceId,
                          ),
                        ),
                      );
                    },
                  ),
                  _drawerTile(
                    context,
                    title: "Motor Parameter",
                    icon: Icons.analytics_rounded,
                    onTap: () {
                      if (!_validateDevice(context)) return;

                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelemetryScreen(
                            deviceId: deviceId,
                          ),
                        ),
                      );
                    },
                  ),




                  _drawerTile(
                    context,
                    title: "Devices",
                    icon: Icons.devices_rounded,
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeviceScreen(),
                        ),
                      );
                    },
                  ),


                  _divider(),
                  _drawerTile(
                    context,
                    title: "Contact Us",
                    icon: Icons.contact_support_rounded,
                    onTap: () async {
                      Navigator.pop(context);

                      await _openUrl(
                        context,
                        "https://shahbaz894.github.io/smartwell-policy/index.html",
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    title: "Privacy Policy",
                    icon: Icons.privacy_tip_rounded,
                    onTap: () async {
                      Navigator.pop(context);

                      await _openUrl(
                        context,
                        "https://shahbaz894.github.io/smartwell-policy/privacy.html",
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    title: "Terms & Conditions",
                    icon: Icons.gavel_rounded,
                    onTap: () async {
                      Navigator.pop(context);

                      await _openUrl(
                        context,
                        "https://shahbaz894.github.io/smartwell-policy/terms.html",
                      );
                    },
                  ),

                  _drawerTile(
                    context,
                    title: "Logout",
                    icon: Icons.logout_rounded,
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () async {
                      await ref
                          .read(
                        loginViewModelProvider.notifier,
                      )
                          .logout();

                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          "/login",
                              (route) => false,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // FOOTER
                  // =========================
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "AabNex Iot",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            letterSpacing: 3,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "FIRMWARE V2.4.0",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // DRAWER TILE
  // =========================
  Widget _drawerTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
        Color iconColor = Colors.white,
        Color textColor = Colors.white,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor:
          AppColors.primary.withOpacity(0.15),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [

                Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color:
                  Colors.white.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // DIVIDER
  // =========================
  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Divider(
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }

  // =========================
  // ERROR
  // =========================
  static void _showError(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}