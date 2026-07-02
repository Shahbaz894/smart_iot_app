// import "dart:async";
//
// import "package:flutter/material.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
//
// import "package:smart_iot_app/src/core/constant/app_color.dart";
//
// import "../providers/telemetry_providers.dart";
//
// enum ParameterConnectionStatus {
//   noDevice,
//   waitingTelemetry,
//   connected,
//   disconnected,
// }
//
// class TelemetryScreen extends ConsumerStatefulWidget {
//   final String? deviceId;
//
//   const TelemetryScreen({
//     super.key,
//     required this.deviceId,
//   });
//
//   @override
//   ConsumerState<TelemetryScreen> createState() => _TelemetryScreenState();
// }
//
// class _TelemetryScreenState extends ConsumerState<TelemetryScreen> {
//   Timer? refreshTimer;
//
//   bool isTelemetryLoading = false;
//   int telemetryFailures = 0;
//   bool noDeviceSnackShown = false;
//
//   String get safeDeviceId {
//     return widget.deviceId?.trim() ?? "";
//   }
//
//   // bool get hasDevice {
//   //   final id = safeDeviceId;
//   //   if (id.isEmpty) return false;
//   //
//   //   // 🔥 DYNAMIC VALIDATION: Matches any standard database UUID (8-4-4-4-12 characters)
//   //   // This automatically blocks dummy text like "ESP32_001_TW" while allowing ANY real device UUID
//   //   final uuidRegex = RegExp(
//   //       r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
//   //   );
//   //
//   //   return uuidRegex.hasMatch(id);
//   // }
//   bool get hasDevice {
//     final id = safeDeviceId.trim();
//
//     // No device selected
//     if (id.isEmpty) return false;
//
//     // Accept BOTH:
//     // 1. UUID device ids
//     // 2. ESP32 custom ids like ESP32_001_TW
//
//     return true;
//   }
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() {
//       if (hasDevice) {
//         loadTelemetry(
//           showLoading: true,
//         );
//       } else {
//         _showNoDeviceSnack();
//       }
//     });
//
//     if (hasDevice) {
//       refreshTimer = Timer.periodic(
//         const Duration(seconds: 5),
//             (_) {
//           loadTelemetry(
//             showError: false,
//             showLoading: false,
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     refreshTimer?.cancel();
//     super.dispose();
//   }
//
//   void _showNoDeviceSnack() {
//     if (!mounted || noDeviceSnackShown) return;
//
//     noDeviceSnackShown = true;
//     showMessage(
//       "Device not connected. Select a device to view parameters.",
//       true,
//     );
//   }
//
//   ParameterConnectionStatus connectionStatus(dynamic latest) {
//     if (!hasDevice) return ParameterConnectionStatus.noDevice;
//
//     if (latest != null && telemetryFailures < 3) {
//       return ParameterConnectionStatus.connected;
//     }
//
//     if (telemetryFailures >= 3) {
//       return ParameterConnectionStatus.disconnected;
//     }
//
//     return ParameterConnectionStatus.waitingTelemetry;
//   }
//
//   // Future<void> loadTelemetry({bool showError = true}) async {
//   //   if (isTelemetryLoading) return;
//   //
//   //   if (!hasDevice) {
//   //     _showNoDeviceSnack();
//   //     return;
//   //   }
//   //
//   //   isTelemetryLoading = true;
//   //
//   //   try {
//   //     await ref.read(telemetryViewModelProvider.notifier).loadLatest(
//   //       safeDeviceId,
//   //     );
//   //
//   //     final state = ref.read(telemetryViewModelProvider);
//   //
//   //     if (state.latest != null) {
//   //       telemetryFailures = 0;
//   //     } else if (state.error != null) {
//   //       telemetryFailures++;
//   //     }
//   //
//   //     if (showError && state.error != null && mounted && telemetryFailures >= 3) {
//   //       showMessage(_friendlyError(state.error!), true);
//   //     }
//   //
//   //     // if (mounted) setState(() {});
//   //   } catch (_) {
//   //     telemetryFailures++;
//   //
//   //     if (mounted) {
//   //       if (showError && telemetryFailures >= 3) {
//   //         showMessage(
//   //           "Device disconnected. Showing last received values if available.",
//   //           true,
//   //         );
//   //       }
//   //       // setState(() {});
//   //     }
//   //   } finally {
//   //     isTelemetryLoading = false;
//   //   }
//   // }
//   Future<void> loadTelemetry({
//     bool showError = true,
//     bool showLoading = true,
//   }) async {
//     if (isTelemetryLoading) return;
//
//     if (!hasDevice) {
//       _showNoDeviceSnack();
//       return;
//     }
//
//     isTelemetryLoading = true;
//
//     try {
//       await ref
//           .read(telemetryViewModelProvider.notifier)
//           .loadLatest(
//         safeDeviceId,
//         showLoading: showLoading,
//       );
//
//       final state = ref.read(telemetryViewModelProvider);
//
//       if (state.latest != null) {
//         telemetryFailures = 0;
//       } else if (state.error != null) {
//         telemetryFailures++;
//       }
//
//       if (showError &&
//           state.error != null &&
//           mounted &&
//           telemetryFailures >= 3) {
//         showMessage(
//           _friendlyError(state.error!),
//           true,
//         );
//       }
//     } catch (_) {
//       telemetryFailures++;
//
//       if (mounted &&
//           showError &&
//           telemetryFailures >= 3) {
//         showMessage(
//           "Device disconnected. Showing last received values if available.",
//           true,
//         );
//       }
//     } finally {
//       isTelemetryLoading = false;
//     }
//   }
//
//   String _friendlyError(String message) {
//     final text = message.toLowerCase();
//
//     if (text.contains("socket") ||
//         text.contains("network") ||
//         text.contains("internet") ||
//         text.contains("connection") ||
//         text.contains("timeout") ||
//         text.contains("host lookup")) {
//       return "Device disconnected or internet unavailable. Showing last received values if available.";
//     }
//
//     return message;
//   }
//
//   void showMessage(String message, bool isError) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(
//         SnackBar(
//           duration: Duration(seconds: isError ? 6 : 4),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: isError ? AppColors.error : AppColors.green,
//           margin: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//       );
//   }
//
//   String formatValue(
//       double? value,
//       String unit, {
//         int decimals = 1,
//         required ParameterConnectionStatus status,
//       }) {
//     // No device selected/found: show no value, not fake zero.
//     if (status == ParameterConnectionStatus.noDevice) return "-- $unit";
//
//     // Device exists but no telemetry has arrived yet: show no value.
//     if (value == null) return "-- $unit";
//
//     // Device connected and telemetry exists: show real value.
//     return "${value.toStringAsFixed(decimals)} $unit";
//   }
//
//   String formatInt(
//       int? value, {
//         required ParameterConnectionStatus status,
//       }) {
//     if (status == ParameterConnectionStatus.noDevice) return "--";
//     if (value == null) return "--";
//     return value.toString();
//   }
//
//   String formatTimestamp(int? timestamp) {
//     if (timestamp == null || timestamp <= 0) return "-";
//
//     final dateTime = DateTime.fromMillisecondsSinceEpoch(
//       timestamp * 1000,
//       isUtc: true,
//     ).toLocal();
//
//     final date =
//         "${dateTime.year.toString().padLeft(4, "0")}-${dateTime.month.toString().padLeft(2, "0")}-${dateTime.day.toString().padLeft(2, "0")}";
//
//     final time =
//         "${dateTime.hour.toString().padLeft(2, "0")}:${dateTime.minute.toString().padLeft(2, "0")}:${dateTime.second.toString().padLeft(2, "0")}";
//
//     return "$date $time";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(telemetryViewModelProvider);
//     final latest = hasDevice ? state.latest : null;
//     final status = connectionStatus(latest);
//
//     final width = MediaQuery.of(context).size.width;
//     final isSmall = width < 380;
//     final isTablet = width >= 650;
//     final isLarge = width >= 1000;
//
//     final horizontalPadding = isLarge
//         ? 36.0
//         : isTablet
//         ? 28.0
//         : 16.0;
//
//     final crossAxisCount = isLarge
//         ? 4
//         : isTablet
//         ? 3
//         : 2;
//
//     final aspectRatio = isLarge
//         ? 1.34
//         : isTablet
//         ? 1.28
//         : isSmall
//         ? 0.96
//         : 1.05;
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: AppColors.white),
//         title: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               "VFD Parameters",
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: isSmall ? 18 : 21,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 2),
//
//           ],
//         ),
//         actions: [
//           IconButton(
//             tooltip: "Refresh",
//             onPressed: state.isLoading || isTelemetryLoading
//                 ? null
//                 : () => loadTelemetry(showError: true),
//             icon: const Icon(Icons.refresh_rounded),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.blueDark,
//               AppColors.backgroundDark,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: RefreshIndicator(
//             color: AppColors.primary,
//             backgroundColor: AppColors.primaryDark,
//             onRefresh: () => loadTelemetry(showError: true),
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(
//                 parent: BouncingScrollPhysics(),
//               ),
//               padding: EdgeInsets.symmetric(
//                 horizontal: horizontalPadding,
//                 vertical: 18,
//               ),
//               child:
//               Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 1080),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       ParameterHeaderCard(
//                         deviceId: hasDevice ? safeDeviceId : "Device Not Connected",
//                         frequency: formatValue(
//                           latest?.freq,
//                           "Hz",
//                           status: status,
//                         ),
//                         referenceFrequency: formatValue(
//                           latest?.referenceFreq,
//                           "Hz",
//                           status: status,
//                         ),
//                         lastPacket: formatTimestamp(latest?.timestamp),
//                         isLoading: state.isLoading || isTelemetryLoading,
//                         status: status,
//                       ),
//
//                       if (status == ParameterConnectionStatus.noDevice)
//                         const Padding(
//                           padding: EdgeInsets.only(top: 14),
//                           child: ParameterStatusBadge(
//                             icon: Icons.link_off_rounded,
//                             color: AppColors.warning,
//                             text:
//                             "Device not connected. Select a device to view live parameters.",
//                           ),
//                         ),
//
//                       if (status == ParameterConnectionStatus.waitingTelemetry)
//                         const Padding(
//                           padding: EdgeInsets.only(top: 14),
//                           child: ParameterStatusBadge(
//                             icon: Icons.sync_rounded,
//                             color: AppColors.primary,
//                             text:
//                             "Device selected. Waiting for latest telemetry values.",
//                           ),
//                         ),
//
//                       if (status == ParameterConnectionStatus.disconnected)
//                         const Padding(
//                           padding: EdgeInsets.only(top: 14),
//                           child: ParameterStatusBadge(
//                             icon: Icons.wifi_off_rounded,
//                             color: AppColors.warning,
//                             text:
//                             "Device disconnected. Showing last received values when available.",
//                           ),
//                         ),
//
//                       if (state.isLoading && latest == null && hasDevice)
//                         const Padding(
//                           padding: EdgeInsets.all(28),
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               color: AppColors.primary,
//                             ),
//                           ),
//                         ),
//
//                       const SizedBox(height: 20),
//
//                       SectionTitle(
//                         title: "Live Parameters",
//                         subtitle: status == ParameterConnectionStatus.connected
//                             ? "Updated automatically every 5 seconds"
//                             : status == ParameterConnectionStatus.waitingTelemetry
//                             ? "Waiting for first telemetry packet"
//                             : status == ParameterConnectionStatus.disconnected
//                             ? "Connection lost. Last values may be shown."
//                             : "No device connected",
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       GridView.count(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         crossAxisCount: crossAxisCount,
//                         crossAxisSpacing: 14,
//                         mainAxisSpacing: 14,
//                         childAspectRatio: aspectRatio,
//                         children: [
//                           ParameterCard(
//                             icon: Icons.sync_rounded,
//                             title: "Frequency",
//                             value: formatValue(latest?.freq, "Hz", status: status),
//                             highlight: true,
//                           ),
//                           ParameterCard(
//                             icon: Icons.tune_rounded,
//                             title: "Reference",
//                             value: formatValue(
//                               latest?.referenceFreq,
//                               "Hz",
//                               status: status,
//                             ),
//                           ),
//                           ParameterCard(
//                             icon: Icons.bolt_rounded,
//                             title: "Voltage",
//                             value: formatValue(latest?.voltage, "V", status: status),
//                           ),
//                           ParameterCard(
//                             icon: Icons.flash_on_rounded,
//                             title: "Current",
//                             value: formatValue(latest?.current, "A", status: status),
//                           ),
//                           ParameterCard(
//                             icon: Icons.battery_charging_full_rounded,
//                             title: "DC Bus",
//                             value: formatValue(latest?.dcbus, "V", status: status),
//                           ),
//                           ParameterCard(
//                             icon: Icons.power_rounded,
//                             title: "Power",
//                             value: formatValue(latest?.power, "kW", status: status),
//                           ),
//                           ParameterCard(
//                             icon: Icons.rotate_right_rounded,
//                             title: "Motor Speed",
//                             value: formatValue(
//                               latest?.motorSpeed,
//                               "RPM",
//                               status: status,
//                             ),
//                           ),
//                           ParameterCard(
//                             icon: Icons.speed_rounded,
//                             title: "Power Load",
//                             value: formatValue(
//                               latest?.powerPercent,
//                               "%",
//                               status: status,
//                             ),
//                           ),
//                           ParameterCard(
//                             icon: Icons.settings_input_component_rounded,
//                             title: "Torque",
//                             value: formatValue(
//                               latest?.torquePercent,
//                               "%",
//                               status: status,
//                             ),
//                           ),
//                           ParameterCard(
//                             icon: Icons.electric_meter_rounded,
//                             title: "Energy",
//                             value: formatValue(latest?.energyIn, "kWh", status: status),
//                           ),
//                           ParameterCard(
//                             icon: Icons.error_outline_rounded,
//                             title: "Fault Code",
//                             value: formatInt(latest?.faultCode, status: status),
//                           ),
//                           ParameterCard(
//                             icon: Icons.info_outline_rounded,
//                             title: "Status Code",
//                             value: formatInt(latest?.statusCode, status: status),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       ParameterInfoPanel(
//                         rows: [
//                           ParameterInfoRow(
//                             label: "Device ID",
//                             value: hasDevice ? safeDeviceId : "Device not connected",
//                           ),
//                           ParameterInfoRow(
//                             label: "Connection",
//                             value: connectionLabel(status),
//                           ),
//                           ParameterInfoRow(
//                             label: "Live Flag",
//                             value: formatInt(latest?.isLive, status: status),
//                           ),
//                           ParameterInfoRow(
//                             label: "Fault",
//                             value: formatInt(latest?.fault, status: status),
//                           ),
//                           ParameterInfoRow(
//                             label: "Last Packet",
//                             value: formatTimestamp(latest?.timestamp),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String connectionLabel(ParameterConnectionStatus status) {
//     switch (status) {
//       case ParameterConnectionStatus.noDevice:
//         return "Device not connected";
//       case ParameterConnectionStatus.waitingTelemetry:
//         return "Waiting telemetry";
//       case ParameterConnectionStatus.connected:
//         return "Connected";
//       case ParameterConnectionStatus.disconnected:
//         return "Disconnected";
//     }
//   }
// }
//
// class ParameterHeaderCard extends StatelessWidget {
//   final String deviceId;
//   final String frequency;
//   final String referenceFrequency;
//   final String lastPacket;
//   final bool isLoading;
//   final ParameterConnectionStatus status;
//
//   const ParameterHeaderCard({
//     super.key,
//     required this.deviceId,
//     required this.frequency,
//     required this.referenceFrequency,
//     required this.lastPacket,
//     required this.isLoading,
//     required this.status,
//   });
//
//   Color get statusColor {
//     switch (status) {
//       case ParameterConnectionStatus.noDevice:
//         return AppColors.warning;
//       case ParameterConnectionStatus.waitingTelemetry:
//         return AppColors.primary;
//       case ParameterConnectionStatus.connected:
//         return AppColors.green;
//       case ParameterConnectionStatus.disconnected:
//         return AppColors.warning;
//     }
//   }
//
//   IconData get statusIcon {
//     switch (status) {
//       case ParameterConnectionStatus.noDevice:
//         return Icons.link_off_rounded;
//       case ParameterConnectionStatus.waitingTelemetry:
//         return Icons.sync_rounded;
//       case ParameterConnectionStatus.connected:
//         return Icons.analytics_rounded;
//       case ParameterConnectionStatus.disconnected:
//         return Icons.wifi_off_rounded;
//     }
//   }
//
//   String get statusText {
//     switch (status) {
//       case ParameterConnectionStatus.noDevice:
//         return "Device not connected";
//       case ParameterConnectionStatus.waitingTelemetry:
//         return "Waiting for telemetry";
//       case ParameterConnectionStatus.connected:
//         return isLoading ? "Refreshing data" : "Live parameter monitor";
//       case ParameterConnectionStatus.disconnected:
//         return "Device disconnected";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final compact = width < 390;
//
//     return Container(
//       padding: EdgeInsets.all(compact ? 16 : 18),
//       decoration: BoxDecoration(
//         color: AppColors.surfaceDark.withOpacity(0.96),
//         borderRadius: BorderRadius.circular(26),
//         border: Border.all(
//           color: statusColor.withOpacity(0.22),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withOpacity(0.34),
//             blurRadius: 28,
//             offset: const Offset(0, 14),
//           ),
//           BoxShadow(
//             color: statusColor.withOpacity(0.12),
//             blurRadius: 22,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: compact ? 54 : 62,
//             width: compact ? 54 : 62,
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: statusColor.withOpacity(0.24),
//               ),
//             ),
//             child: Icon(
//               statusIcon,
//               color: statusColor,
//               size: 32,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   deviceId,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: compact ? 15 : 17,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   statusText,
//                   style: TextStyle(
//                     color: statusColor.withOpacity(0.95),
//                     fontSize: compact ? 12 : 13,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "Last packet: $lastPacket",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.50),
//                     fontSize: compact ? 10.5 : 11.5,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 frequency,
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: compact ? 20 : 24,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Ref $referenceFrequency",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.58),
//                   fontSize: compact ? 11 : 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ParameterStatusBadge extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String text;
//
//   const ParameterStatusBadge({
//     super.key,
//     required this.icon,
//     required this.color,
//     required this.text,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: color.withOpacity(0.32)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 18),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.85),
//                 fontWeight: FontWeight.w700,
//                 fontSize: 12.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class SectionTitle extends StatelessWidget {
//   final String title;
//   final String subtitle;
//
//   const SectionTitle({
//     super.key,
//     required this.title,
//     required this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final small = MediaQuery.of(context).size.width < 380;
//
//     return Row(
//       children: [
//         Container(
//           width: 5,
//           height: 38,
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.primary.withOpacity(0.35),
//                 blurRadius: 12,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: small ? 16 : 18,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.52),
//                   fontSize: small ? 11.5 : 12.5,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class ParameterCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String value;
//   final bool highlight;
//
//   const ParameterCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.value,
//     this.highlight = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final small = MediaQuery.of(context).size.width < 380;
//
//     return Container(
//       padding: EdgeInsets.all(small ? 13 : 16),
//       decoration: BoxDecoration(
//         color: highlight
//             ? AppColors.surfaceDark.withOpacity(0.98)
//             : AppColors.cardDark.withOpacity(0.98),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: highlight
//               ? AppColors.primary.withOpacity(0.40)
//               : AppColors.white.withOpacity(0.07),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withOpacity(0.30),
//             blurRadius: 18,
//             offset: const Offset(0, 10),
//           ),
//           if (highlight)
//             BoxShadow(
//               color: AppColors.primary.withOpacity(0.12),
//               blurRadius: 24,
//               offset: const Offset(0, 8),
//             ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             color: highlight ? AppColors.primary : AppColors.blueLight,
//             size: small ? 24 : 28,
//           ),
//           const Spacer(),
//           Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.62),
//               fontSize: small ? 12.5 : 14,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 7),
//           FittedBox(
//             alignment: Alignment.centerLeft,
//             fit: BoxFit.scaleDown,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: AppColors.white,
//                 height: 1.2,
//                 fontSize: small ? 17 : 20,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ParameterInfoPanel extends StatelessWidget {
//   final List<ParameterInfoRow> rows;
//
//   const ParameterInfoPanel({
//     super.key,
//     required this.rows,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.surfaceDark.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: AppColors.white.withOpacity(0.07),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.black.withOpacity(0.30),
//             blurRadius: 18,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(children: rows),
//     );
//   }
// }
//
// class ParameterInfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const ParameterInfoRow({
//     super.key,
//     required this.label,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final small = MediaQuery.of(context).size.width < 380;
//
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: small ? 14 : 16,
//         vertical: 13,
//       ),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: AppColors.white.withOpacity(0.055),
//           ),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: small ? 92 : 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.56),
//                 fontSize: small ? 12 : 13,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.88),
//                 fontSize: small ? 12.5 : 13.5,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:smart_iot_app/src/core/constant/app_color.dart";

import "../providers/telemetry_providers.dart";

enum ParameterConnectionStatus {
  noDevice,
  waitingTelemetry,
  connected,
  disconnected,
}

class TelemetryScreen extends ConsumerStatefulWidget {
  final String? deviceId;

  const TelemetryScreen({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends ConsumerState<TelemetryScreen> {
  Timer? refreshTimer;

  int telemetryFailures = 0;
  bool noDeviceSnackShown = false;

  String get safeDeviceId => widget.deviceId?.trim() ?? "";


  bool get hasDevice {
    final id = safeDeviceId;
    return id.isNotEmpty;
  }


  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (hasDevice) {
        loadTelemetry(showLoading: true);
      } else {
        _showNoDeviceSnack();
      }
    });

    if (hasDevice) {
      refreshTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) => loadTelemetry(showError: false, showLoading: false),
      );
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void _showNoDeviceSnack() {
    if (!mounted || noDeviceSnackShown) return;
    noDeviceSnackShown = true;
    showMessage("Device not connected. Select a device to view parameters.", true);
  }

  ParameterConnectionStatus connectionStatus(dynamic latest) {
    if (!hasDevice) return ParameterConnectionStatus.noDevice;
    if (latest != null && telemetryFailures < 3) return ParameterConnectionStatus.connected;
    if (telemetryFailures >= 3) return ParameterConnectionStatus.disconnected;
    return ParameterConnectionStatus.waitingTelemetry;
  }

  Future<void> loadTelemetry({
    bool showError = true,
    bool showLoading = true,
  }) async {
    if (!hasDevice) {
      _showNoDeviceSnack();
      return;
    }

    try {
      await ref
          .read(telemetryViewModelProvider.notifier)
          .loadLatest(safeDeviceId, showLoading: showLoading);

      final state = ref.read(telemetryViewModelProvider);

      if (state.latest != null) {
        telemetryFailures = 0;
      } else if (state.error != null) {
        telemetryFailures++;
      }

      if (showError && state.error != null && mounted && telemetryFailures >= 3) {
        showMessage(_friendlyError(state.error!), true);
      }
    } catch (_) {
      telemetryFailures++;
      if (mounted && showError && telemetryFailures >= 3) {
        showMessage("Device disconnected. Showing last received values if available.", true);
      }
    }
  }

  String _friendlyError(String message) {
    final text = message.toLowerCase();
    if (text.contains("socket") ||
        text.contains("network") ||
        text.contains("internet") ||
        text.contains("connection") ||
        text.contains("timeout") ||
        text.contains("host lookup")) {
      return "Device disconnected or internet unavailable. Showing last received values if available.";
    }
    return message;
  }

  void showMessage(String message, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: isError ? 6 : 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : AppColors.green,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Text(
            message,
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800),
          ),
        ),
      );
  }

  String formatValue(
      double? value,
      String unit, {
        int decimals = 1,
        required ParameterConnectionStatus status,
      }) {
    if (status == ParameterConnectionStatus.noDevice) return "-- $unit";
    if (value == null) return "-- $unit";
    return "${value.toStringAsFixed(decimals)} $unit";
  }

  String formatInt(int? value, {required ParameterConnectionStatus status}) {
    if (status == ParameterConnectionStatus.noDevice) return "--";
    if (value == null) return "--";
    return value.toString();
  }

  String formatTimestamp(int? timestamp) {
    if (timestamp == null || timestamp <= 0) return "-";
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true).toLocal();
    final date =
        "${dt.year.toString().padLeft(4, "0")}-${dt.month.toString().padLeft(2, "0")}-${dt.day.toString().padLeft(2, "0")}";
    final time =
        "${dt.hour.toString().padLeft(2, "0")}:${dt.minute.toString().padLeft(2, "0")}:${dt.second.toString().padLeft(2, "0")}";
    return "$date $time";
  }

  String connectionLabel(ParameterConnectionStatus status) {
    switch (status) {
      case ParameterConnectionStatus.noDevice:
        return "Device not connected";
      case ParameterConnectionStatus.waitingTelemetry:
        return "Waiting telemetry";
      case ParameterConnectionStatus.connected:
        return "Connected";
      case ParameterConnectionStatus.disconnected:
        return "Disconnected";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only rebuilds when latest data changes — isRefreshing is ignored here
    final latest = ref.watch(
      telemetryViewModelProvider.select((s) => hasDevice ? s.latest : null),
    );
    final isInitialLoading = ref.watch(
      telemetryViewModelProvider.select((s) => s.isLoading),
    );

    final status = connectionStatus(latest);
    print('meri ye device id hai');
    print(latest);
    print(safeDeviceId);
    print(widget.deviceId);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;
    final isTablet = width >= 650;
    final isLarge = width >= 1000;

    final horizontalPadding = isLarge ? 36.0 : isTablet ? 28.0 : 16.0;
    final crossAxisCount = isLarge ? 4 : isTablet ? 3 : 2;
    final aspectRatio = isLarge ? 1.34 : isTablet ? 1.28 : isSmall ? 0.96 : 1.05;

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          "VFD Parameters",
          style: TextStyle(
            color: AppColors.white,
            fontSize: isSmall ? 18 : 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          // Isolated widget — only rebuilds on isRefreshing, never triggers main build
          const _RefreshDot(),
          IconButton(
            tooltip: "Refresh",
            onPressed: isInitialLoading
                ? null
                : () => loadTelemetry(showError: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.blueDark, AppColors.backgroundDark],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.primaryDark,
            onRefresh: () => loadTelemetry(showError: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ParameterHeaderCard(
                        deviceId: hasDevice ? safeDeviceId : "Device Not Connected",
                        frequency: formatValue(latest?.freq, "Hz", status: status),
                        referenceFrequency: formatValue(latest?.referenceFreq, "Hz", status: status),
                        lastPacket: formatTimestamp(latest?.timestamp),
                        isLoading: isInitialLoading,
                        status: status,
                      ),

                      if (status == ParameterConnectionStatus.noDevice)
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: ParameterStatusBadge(
                            icon: Icons.link_off_rounded,
                            color: AppColors.warning,
                            text: "Device not connected. Select a device to view live parameters.",
                          ),
                        ),

                      if (status == ParameterConnectionStatus.waitingTelemetry)
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: ParameterStatusBadge(
                            icon: Icons.sync_rounded,
                            color: AppColors.primary,
                            text: "Device selected. Waiting for latest telemetry values.",
                          ),
                        ),

                      if (status == ParameterConnectionStatus.disconnected)
                        const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: ParameterStatusBadge(
                            icon: Icons.wifi_off_rounded,
                            color: AppColors.warning,
                            text: "Device disconnected. Showing last received values when available.",
                          ),
                        ),

                      if (isInitialLoading && latest == null && hasDevice)
                        const Padding(
                          padding: EdgeInsets.all(28),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),

                      const SizedBox(height: 20),

                      SectionTitle(
                        title: "Live Parameters",
                        subtitle: status == ParameterConnectionStatus.connected
                            ? "Updated automatically every 5 seconds"
                            : status == ParameterConnectionStatus.waitingTelemetry
                            ? "Waiting for first telemetry packet"
                            : status == ParameterConnectionStatus.disconnected
                            ? "Connection lost. Last values may be shown."
                            : "No device connected",
                      ),

                      const SizedBox(height: 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: aspectRatio,
                        children: [
                          ParameterCard(
                            icon: Icons.sync_rounded,
                            title: "Frequency",
                            value: formatValue(latest?.freq, "Hz", status: status),
                            highlight: true,
                          ),
                          ParameterCard(
                            icon: Icons.tune_rounded,
                            title: "Reference",
                            value: formatValue(latest?.referenceFreq, "Hz", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.bolt_rounded,
                            title: "Voltage",
                            value: formatValue(latest?.voltage, "V", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.flash_on_rounded,
                            title: "Current",
                            value: formatValue(latest?.current, "A", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.battery_charging_full_rounded,
                            title: "DC Bus",
                            value: formatValue(latest?.dcbus, "V", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.power_rounded,
                            title: "Power",
                            value: formatValue(latest?.power, "kW", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.rotate_right_rounded,
                            title: "Motor Speed",
                            value: formatValue(latest?.motorSpeed, "RPM", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.speed_rounded,
                            title: "Power Load",
                            value: formatValue(latest?.powerPercent, "%", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.settings_input_component_rounded,
                            title: "Torque",
                            value: formatValue(latest?.torquePercent, "%", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.electric_meter_rounded,
                            title: "Energy",
                            value: formatValue(latest?.energyIn, "kWh", status: status),
                          ),
                          ParameterCard(
                            icon: Icons.error_outline_rounded,
                            title: "Fault Code",
                            value: formatInt(latest?.faultCode, status: status),
                          ),
                          ParameterCard(
                            icon: Icons.info_outline_rounded,
                            title: "Status Code",
                            value: formatInt(latest?.statusCode, status: status),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      ParameterInfoPanel(
                        rows: [
                          ParameterInfoRow(
                            label: "Device ID",
                            value: hasDevice ? safeDeviceId : "Device not connected",
                          ),
                          ParameterInfoRow(
                            label: "Connection",
                            value: connectionLabel(status),
                          ),
                          ParameterInfoRow(
                            label: "Live Flag",
                            value: formatInt(latest?.isLive, status: status),
                          ),
                          ParameterInfoRow(
                            label: "Fault",
                            value: formatInt(latest?.fault, status: status),
                          ),
                          ParameterInfoRow(
                            label: "Last Packet",
                            value: formatTimestamp(latest?.timestamp),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Isolated widget — only rebuilds when isRefreshing changes
// Never causes the main screen to rebuild
class _RefreshDot extends ConsumerWidget {
  const _RefreshDot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefreshing = ref.watch(
      telemetryViewModelProvider.select((s) => s.isRefreshing),
    );

    if (!isRefreshing) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.only(right: 12),
      child: Center(
        child: SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class ParameterHeaderCard extends StatelessWidget {
  final String deviceId;
  final String frequency;
  final String referenceFrequency;
  final String lastPacket;
  final bool isLoading;
  final ParameterConnectionStatus status;

  const ParameterHeaderCard({
    super.key,
    required this.deviceId,
    required this.frequency,
    required this.referenceFrequency,
    required this.lastPacket,
    required this.isLoading,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case ParameterConnectionStatus.noDevice:
        return AppColors.warning;
      case ParameterConnectionStatus.waitingTelemetry:
        return AppColors.primary;
      case ParameterConnectionStatus.connected:
        return AppColors.green;
      case ParameterConnectionStatus.disconnected:
        return AppColors.warning;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case ParameterConnectionStatus.noDevice:
        return Icons.link_off_rounded;
      case ParameterConnectionStatus.waitingTelemetry:
        return Icons.sync_rounded;
      case ParameterConnectionStatus.connected:
        return Icons.analytics_rounded;
      case ParameterConnectionStatus.disconnected:
        return Icons.wifi_off_rounded;
    }
  }

  String get statusText {
    switch (status) {
      case ParameterConnectionStatus.noDevice:
        return "Device not connected";
      case ParameterConnectionStatus.waitingTelemetry:
        return "Waiting for telemetry";
      case ParameterConnectionStatus.connected:
        return isLoading ? "Refreshing data" : "Live parameter monitor";
      case ParameterConnectionStatus.disconnected:
        return "Device disconnected";
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 390;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: statusColor.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.34),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: statusColor.withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: compact ? 54 : 62,
            width: compact ? 54 : 62,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.24)),
            ),
            child: Icon(statusIcon, color: statusColor, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor.withOpacity(0.95),
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Last packet: $lastPacket",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.50),
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  frequency,
                  key: ValueKey(frequency),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  "Ref $referenceFrequency",
                  key: ValueKey(referenceFrequency),
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.58),
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ParameterStatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const ParameterStatusBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.32)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.85),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 380;

    return Row(
      children: [
        Container(
          width: 5,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: small ? 16 : 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.52),
                  fontSize: small ? 11.5 : 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ParameterCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;

  const ParameterCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 380;

    return Container(
      padding: EdgeInsets.all(small ? 13 : 16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.surfaceDark.withOpacity(0.98)
            : AppColors.cardDark.withOpacity(0.98),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withOpacity(0.40)
              : AppColors.white.withOpacity(0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          if (highlight)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: highlight ? AppColors.primary : AppColors.blueLight,
            size: small ? 24 : 28,
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.62),
              fontSize: small ? 12.5 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: FittedBox(
              key: ValueKey(value),
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: AppColors.white,
                  height: 1.2,
                  fontSize: small ? 17 : 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParameterInfoPanel extends StatelessWidget {
  final List<ParameterInfoRow> rows;

  const ParameterInfoPanel({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }
}

class ParameterInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ParameterInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 14 : 16,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.white.withOpacity(0.055)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: small ? 92 : 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.56),
                fontSize: small ? 12 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                value,
                key: ValueKey(value),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.88),
                  fontSize: small ? 12.5 : 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}