// import "package:flutter/material.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/widget/connection_badges.dart";
// import "package:smart_iot_app/src/features/widget/vfd_header_card.dart";
//
// import "customer_name_field.dart";
// import "motor_button.dart";
// import "telemetry_metrics_grid.dart";
// import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
//
// class HomeDashboardContent extends StatelessWidget {
//   final bool isSyncing;
//   final bool hasDevice;
//   final String? deviceId;
//   final String displayName;
//   final dynamic latest;
//   final dynamic telemetryState;
//   final dynamic motorState;
//   final MotorSnapshot snapshot;
//   final DeviceConnectionStatus status;
//   final Animation<double> pulseAnimation;
//   final TextEditingController customerNameController;
//   final FocusNode customerNameFocusNode;
//   final List<String> customerSuggestions;
//   final String runningTime;
//   final double horizontalPadding;
//   final int crossAxisCount;
//   final double childAspectRatio;
//   final double buttonSize;
//   final bool isVerySmall;
//   final Future<void> Function() onRefresh;
//   final VoidCallback onMotorTap;
//   final String Function(
//       double? value,
//       String unit, {
//       int decimals,
//       required DeviceConnectionStatus status,
//       }) formatValue;
//
//   const HomeDashboardContent({
//     super.key,
//     required this.isSyncing,
//     required this.hasDevice,
//     required this.deviceId,
//     required this.displayName,
//     required this.latest,
//     required this.telemetryState,
//     required this.motorState,
//     required this.snapshot,
//     required this.status,
//     required this.pulseAnimation,
//     required this.customerNameController,
//     required this.customerNameFocusNode,
//     required this.customerSuggestions,
//     required this.runningTime,
//     required this.horizontalPadding,
//     required this.crossAxisCount,
//     required this.childAspectRatio,
//     required this.buttonSize,
//     required this.isVerySmall,
//     required this.onRefresh,
//     required this.onMotorTap,
//     required this.formatValue,
//   });
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   debugPrint(
//   //     "🟤 DASHBOARD SNAPSHOT => running=${snapshot.isRunning} "
//   //         "syncing=${snapshot.isSyncing} status=${snapshot.connectionStatus}",
//   //   );
//   //
//   //   // The button area shows a full spinner ONLY when we are waiting for the
//   //   // very first telemetry packet and no command is in progress.
//   //   // During a command (_isProcessingCommand → isSyncing=true), the
//   //   // MotorButton itself shows its internal loading indicator so the button
//   //   // // stays visible and doesn't disappear.
//   //   // final bool showInitialSpinner =
//   //   //     status == DeviceConnectionStatus.waitingTelemetry && !isSyncing;
//   //   final bool showInitialSpinner = (latest == null && (isSyncing || status == DeviceConnectionStatus.waitingTelemetry));
//   //
//   //   return SafeArea(
//   //     child: RefreshIndicator(
//   //       onRefresh: onRefresh,
//   //       color: AppColors.primary,
//   //       backgroundColor: AppColors.surfaceDark,
//   //       child: SingleChildScrollView(
//   //         physics: const AlwaysScrollableScrollPhysics(
//   //           parent: BouncingScrollPhysics(),
//   //         ),
//   //         padding: EdgeInsets.symmetric(
//   //           horizontal: horizontalPadding,
//   //           vertical: 18,
//   //         ),
//   //         child: Center(
//   //           child: ConstrainedBox(
//   //             constraints: const BoxConstraints(maxWidth: 1080),
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.stretch,
//   //               children: [
//   //                 // ── Header card ──────────────────────────────────────────
//   //                 VfdHeaderCard(
//   //                   key: ValueKey(
//   //                     "header_${snapshot.isRunning}_${snapshot.connectionStatus}",
//   //                   ),
//   //                   displayName: displayName,
//   //                   snapshot: snapshot,
//   //                   frequencyText: formatValue(
//   //                     latest?.freq,
//   //                     "Hz",
//   //                     decimals: 1,
//   //                     status: status,
//   //                   ),
//   //                   referenceFrequencyText: formatValue(
//   //                     latest?.referenceFreq ?? latest?.freq,
//   //                     "Hz",
//   //                     decimals: 1,
//   //                     status: status,
//   //                   ),
//   //                 ),
//   //
//   //                 // ── Connection status badges ──────────────────────────────
//   //                 if (status == DeviceConnectionStatus.noDevice)
//   //                   const Padding(
//   //                     padding: EdgeInsets.only(top: 10),
//   //                     child: DeviceNotConnectedBadge(),
//   //                   ),
//   //
//   //                 if (status == DeviceConnectionStatus.waitingTelemetry)
//   //                   const Padding(
//   //                     padding: EdgeInsets.only(top: 10),
//   //                     child: WaitingTelemetryBadge(),
//   //                   ),
//   //
//   //                 if (status == DeviceConnectionStatus.disconnected)
//   //                   const Padding(
//   //                     padding: EdgeInsets.only(top: 10),
//   //                     child: DeviceDisconnectedBadge(),
//   //                   ),
//   //
//   //                 const SizedBox(height: 18),
//   //
//   //                 // ── Customer name field ───────────────────────────────────
//   //                 CustomerNameField(
//   //                   controller: customerNameController,
//   //                   focusNode: customerNameFocusNode,
//   //                   suggestions: customerSuggestions,
//   //                   // Disable while a command is processing to prevent edits
//   //                   enabled: hasDevice && !isSyncing,
//   //                 ),
//   //
//   //                 const SizedBox(height: 26),
//   //
//   //                 // ── Motor button area ─────────────────────────────────────
//   //                 Center(
//   //                   child: AnimatedBuilder(
//   //                     animation: pulseAnimation,
//   //                     builder: (context, _) {
//   //                       final scale = snapshot.isRunning && !isSyncing
//   //                           ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
//   //                           : 1.0;
//   //
//   //                       return Transform.scale(
//   //                         scale: scale,
//   //                         child: showInitialSpinner
//   //                         // Only show bare spinner on very first load
//   //                             ? SizedBox(
//   //                           width: buttonSize,
//   //                           height: buttonSize,
//   //                           child: const Center(
//   //                             child: CircularProgressIndicator(
//   //                               color: Colors.white,
//   //                             ),
//   //                           ),
//   //                         )
//   //                         // Otherwise ALWAYS show the button (it handles
//   //                         // its own loading indicator via `loading: isSyncing`)
//   //                             : MotorButton(
//   //                           key: ValueKey(
//   //                             // Key only changes on actual state change,
//   //                             // NOT on every telemetry tick
//   //                             "motor_btn_${snapshot.isRunning}_${snapshot.connectionStatus}",
//   //                           ),
//   //                           snapshot: snapshot,
//   //                           loading: isSyncing,
//   //                           size: buttonSize,
//   //                           onTap: onMotorTap,
//   //                         ),
//   //                       );
//   //                     },
//   //                   ),
//   //                 ),
//   //
//   //                 const SizedBox(height: 18),
//   //
//   //                 // ── Status text below button ──────────────────────────────
//   //                 Center(
//   //                   child: AnimatedSwitcher(
//   //                     duration: const Duration(milliseconds: 300),
//   //                     child: isSyncing
//   //                     // Command in progress → show syncing row
//   //                         ? Row(
//   //                       key: const ValueKey("syncing"),
//   //                       mainAxisSize: MainAxisSize.min,
//   //                       children: [
//   //                         SizedBox(
//   //                           width: 16,
//   //                           height: 16,
//   //                           child: CircularProgressIndicator(
//   //                             strokeWidth: 2,
//   //                             color: AppColors.primary,
//   //                           ),
//   //                         ),
//   //                         const SizedBox(width: 10),
//   //                         Text(
//   //                           snapshot.isRunning
//   //                               ? "Starting motor..."
//   //                               : "Stopping motor...",
//   //                           style: TextStyle(
//   //                             color: AppColors.white.withOpacity(0.76),
//   //                             fontSize: isVerySmall ? 13 : 15,
//   //                             fontWeight: FontWeight.w600,
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     )
//   //                         : status == DeviceConnectionStatus.waitingTelemetry
//   //                     // Still waiting for first packet
//   //                         ? Row(
//   //                       key: const ValueKey("waiting"),
//   //                       mainAxisSize: MainAxisSize.min,
//   //                       children: [
//   //                         SizedBox(
//   //                           width: 16,
//   //                           height: 16,
//   //                           child: CircularProgressIndicator(
//   //                             strokeWidth: 2,
//   //                             color: AppColors.primary,
//   //                           ),
//   //                         ),
//   //                         const SizedBox(width: 10),
//   //                         Text(
//   //                           "Loading status...",
//   //                           style: TextStyle(
//   //                             color: AppColors.white.withOpacity(0.76),
//   //                             fontSize: isVerySmall ? 13 : 15,
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     )
//   //                     // Normal state text
//   //                         : Text(
//   //                       snapshot.hasFault
//   //                           ? snapshot.faultName
//   //                           : (snapshot.isRunning
//   //                           ? "Running | $runningTime"
//   //                           : snapshot.centerStatusText),
//   //                       key: ValueKey(
//   //                         "status_${snapshot.isRunning}_"
//   //                             "${snapshot.centerStatusText}_$runningTime",
//   //                       ),
//   //                       textAlign: TextAlign.center,
//   //                       style: TextStyle(
//   //                         color: AppColors.white.withOpacity(0.76),
//   //                         fontSize: isVerySmall ? 14 : 16,
//   //                         fontWeight: FontWeight.w700,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //
//   //                 const SizedBox(height: 22),
//   //
//   //                 // ── Telemetry loading indicator (first load only) ─────────
//   //                 if (hasDevice && telemetryState.isLoading && latest == null)
//   //                   const Padding(
//   //                     padding: EdgeInsets.all(22),
//   //                     child: Center(
//   //                       child: CircularProgressIndicator(color: AppColors.white),
//   //                     ),
//   //                   ),
//   //
//   //                 const SizedBox(height: 14),
//   //
//   //                 // ── Metrics grid ──────────────────────────────────────────
//   //                 TelemetryMetricsGrid(
//   //                   latest: latest,
//   //                   status: status,
//   //                   crossAxisCount: crossAxisCount,
//   //                   childAspectRatio: childAspectRatio,
//   //                   formatValue: formatValue,
//   //                 ),
//   //
//   //                 const SizedBox(height: 20),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) {
//     debugPrint(
//       "🟤 DASHBOARD SNAPSHOT => running=${snapshot.isRunning} "
//           "syncing=${snapshot.isSyncing} status=${snapshot.connectionStatus}",
//     );
//
//     final bool showInitialSpinner = (latest == null && (isSyncing || status == DeviceConnectionStatus.waitingTelemetry));
//
//     return SafeArea(
//       child: RefreshIndicator(
//         onRefresh: onRefresh,
//         color: AppColors.primary,
//         backgroundColor: AppColors.surfaceDark,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(
//             parent: BouncingScrollPhysics(),
//           ),
//           padding: EdgeInsets.symmetric(
//             horizontal: horizontalPadding,
//             vertical: 18,
//           ),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1080),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // ── Header card ──────────────────────────────────────────
//                   VfdHeaderCard(
//                     key: ValueKey(
//                       "header_${snapshot.isRunning}_${snapshot.connectionStatus}",
//                     ),
//                     displayName: displayName,
//                     snapshot: snapshot,
//                     frequencyText: formatValue(
//                       latest?.freq,
//                       "Hz",
//                       decimals: 1,
//                       status: status,
//                     ),
//                     referenceFrequencyText: formatValue(
//                       latest?.referenceFreq ?? latest?.freq,
//                       "Hz",
//                       decimals: 1,
//                       status: status,
//                     ),
//                   ),
//
//                   // ── Connection status badges ──────────────────────────────
//                   if (status == DeviceConnectionStatus.noDevice)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 10),
//                       child: DeviceNotConnectedBadge(),
//                     ),
//
//                   if (status == DeviceConnectionStatus.waitingTelemetry)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 10),
//                       child: WaitingTelemetryBadge(),
//                     ),
//
//                   if (status == DeviceConnectionStatus.disconnected)
//                     const Padding(
//                       padding: EdgeInsets.only(top: 10),
//                       child: DeviceDisconnectedBadge(),
//                     ),
//
//                   const SizedBox(height: 18),
//
//                   // ── Customer name field ───────────────────────────────────
//                   CustomerNameField(
//                     controller: customerNameController,
//                     focusNode: customerNameFocusNode,
//                     suggestions: customerSuggestions,
//                     enabled: hasDevice && !isSyncing,
//                   ),
//
//                   const SizedBox(height: 26),
//
//                   // ── Motor button area ─────────────────────────────────────
//                   Center(
//                     child: AnimatedBuilder(
//                       animation: pulseAnimation,
//                       builder: (context, _) {
//                         final scale = snapshot.isRunning && !isSyncing
//                             ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
//                             : 1.0;
//
//                         return Transform.scale(
//                           scale: scale,
//                           child: showInitialSpinner
//                               ? SizedBox(
//                             width: buttonSize,
//                             height: buttonSize,
//                             child: const Center(
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           )
//                           // ⚡ ULTIMATE BYPASS BLOCK: Click ko baahir hi paker lene ka tareeqa
//                               : GestureDetector(
//                             behavior: HitTestBehavior.opaque,
//                             onTap: () {
//                               debugPrint("🎯 BYPASS MASTER HIT => Calling onMotorTap()");
//                               onMotorTap(); // Direct HomeScreen ka function chalega
//                             },
//                             child: IgnorePointer(
//                               ignoring: true, // 👈 Yeh button ke internal click interceptor ko block kar dega
//                               child: MotorButton(
//                                 key: const ValueKey("smartwell_motor_primary_btn_final"),
//                                 snapshot: snapshot,
//                                 loading: isSyncing,
//                                 size: buttonSize,
//                                 onTap: () {}, // Isay ab khali chhor dein
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//
//                   // ── Status text below button ──────────────────────────────
//                   Center(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: isSyncing
//                           ? Row(
//                         key: const ValueKey("syncing"),
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             // ⚡ FIX: Text display dynamic output handler matching state transition
//                             snapshot.isRunning
//                                 ? "Starting motor..."
//                                 : "Stopping motor...",
//                             style: TextStyle(
//                               color: AppColors.white.withOpacity(0.76),
//                               fontSize: isVerySmall ? 13 : 15,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       )
//                           : status == DeviceConnectionStatus.waitingTelemetry
//                           ? Row(
//                         key: const ValueKey("waiting"),
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: AppColors.primary,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             "Loading status...",
//                             style: TextStyle(
//                               color: AppColors.white.withOpacity(0.76),
//                               fontSize: isVerySmall ? 13 : 15,
//                             ),
//                           ),
//                         ],
//                       )
//                           : Text(
//                         snapshot.hasFault
//                             ? snapshot.faultName
//                             : (snapshot.isRunning
//                             ? "Running | $runningTime"
//                             : snapshot.centerStatusText),
//                         key: ValueKey(
//                           "status_${snapshot.isRunning}_"
//                               "${snapshot.centerStatusText}_$runningTime",
//                         ),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: AppColors.white.withOpacity(0.76),
//                           fontSize: isVerySmall ? 14 : 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 22),
//
//                   if (hasDevice && telemetryState.isLoading && latest == null)
//                     const Padding(
//                       padding: EdgeInsets.all(22),
//                       child: Center(
//                         child: CircularProgressIndicator(color: AppColors.white),
//                       ),
//                     ),
//
//                   const SizedBox(height: 14),
//
//                   // ── Metrics grid ──────────────────────────────────────────
//                   TelemetryMetricsGrid(
//                     latest: latest,
//                     status: status,
//                     crossAxisCount: crossAxisCount,
//                     childAspectRatio: childAspectRatio,
//                     formatValue: formatValue,
//                   ),
//
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/widget/connection_badges.dart";
import "package:smart_iot_app/src/features/widget/vfd_header_card.dart";
import "customer_name_field.dart";
import "motor_button.dart";
import "telemetry_metrics_grid.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";

import "package:flutter/material.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/widget/connection_badges.dart";
import "package:smart_iot_app/src/features/widget/vfd_header_card.dart";
import "customer_name_field.dart";
import "motor_button.dart";
import "telemetry_metrics_grid.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";

class HomeDashboardContent extends StatelessWidget {
  final bool isSyncing;
  final bool hasDevice;
  final String? deviceId;
  final String displayName;
  final dynamic latest;
  final dynamic telemetryState;
  final dynamic motorState;
  final MotorSnapshot snapshot;
  final DeviceConnectionStatus status;
  final Animation<double> pulseAnimation;
  final TextEditingController customerNameController;
  final FocusNode customerNameFocusNode;
  final List<String> customerSuggestions;
  final String runningTime;
  final double horizontalPadding;
  final int crossAxisCount;
  final double childAspectRatio;
  final double buttonSize;
  final bool isVerySmall;
  final Future<void> Function() onRefresh;
  final VoidCallback onMotorTap;
  final String Function(
      double? value,
      String unit, {
      int decimals,
      required DeviceConnectionStatus status,
      }) formatValue;

  const HomeDashboardContent({
    super.key,
    required this.isSyncing,
    required this.hasDevice,
    required this.deviceId,
    required this.displayName,
    required this.latest,
    required this.telemetryState,
    required this.motorState,
    required this.snapshot,
    required this.status,
    required this.pulseAnimation,
    required this.customerNameController,
    required this.customerNameFocusNode,
    required this.customerSuggestions,
    required this.runningTime,
    required this.horizontalPadding,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.buttonSize,
    required this.isVerySmall,
    required this.onRefresh,
    required this.onMotorTap,
    required this.formatValue,
  });

  @override
  Widget build(BuildContext context) {
    final bool showInitialSpinner = (latest == null && (isSyncing || status == DeviceConnectionStatus.waitingTelemetry));

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header card ──────────────────────────────────────────
                  VfdHeaderCard(
                    displayName: displayName,
                    snapshot: snapshot,
                    frequencyText: formatValue(
                      latest?.freq,
                      "Hz",
                      decimals: 1,
                      status: status,
                    ),
                    referenceFrequencyText: formatValue(
                      latest?.referenceFreq ?? latest?.freq,
                      "Hz",
                      decimals: 1,
                      status: status,
                    ),
                  ),

                  // ── Connection status badges ──────────────────────────────
                  if (status == DeviceConnectionStatus.noDevice)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: DeviceNotConnectedBadge(),
                    ),

                  if (status == DeviceConnectionStatus.waitingTelemetry)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: WaitingTelemetryBadge(),
                    ),

                  if (status == DeviceConnectionStatus.disconnected)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: DeviceDisconnectedBadge(),
                    ),

                  const SizedBox(height: 18),

                  // ── Customer name field ───────────────────────────────────
                  CustomerNameField(
                    controller: customerNameController,
                    focusNode: customerNameFocusNode,
                    suggestions: customerSuggestions,
                    enabled: hasDevice && !isSyncing,
                  ),

                  const SizedBox(height: 26),

                  // ── Motor button area ─────────────────────────────────────
                  Center(
                    child: AnimatedBuilder(
                      animation: pulseAnimation,
                      builder: (context, _) {
                        final scale = snapshot.isRunning && !isSyncing
                            ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
                            : 1.0;

                        return Transform.scale(
                          scale: scale,
                          child: showInitialSpinner
                              ? SizedBox(
                            width: buttonSize,
                            height: buttonSize,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                          // ⚡ SAARA HACK REMOVED: Ab direct original button hai jo click pass karega!
                              : MotorButton(
                            snapshot: snapshot,
                            loading: isSyncing,
                            size: buttonSize,
                            onTap: onMotorTap, // 👈 Yeh ab directly HomeScreen ko call bhejay ga
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Status text below button ──────────────────────────────
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 900),
                      child: isSyncing
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            snapshot.isRunning ? "Stopping motor..." : "Starting motor...",
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.76),
                              fontSize: isVerySmall ? 13 : 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                          : status == DeviceConnectionStatus.waitingTelemetry
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Loading status...",
                            style: TextStyle(color: AppColors.white.withOpacity(0.76), fontSize: isVerySmall ? 13 : 15),
                          ),
                        ],
                      )
                          : Text(
                        snapshot.hasFault
                            ? snapshot.faultName
                            : (snapshot.isRunning
                            ? "Running | $runningTime"
                            : snapshot.centerStatusText),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.76),
                          fontSize: isVerySmall ? 14 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (hasDevice && telemetryState.isLoading && latest == null)
                    const Padding(
                      padding: EdgeInsets.all(22),
                      child: Center(child: CircularProgressIndicator(color: AppColors.white)),
                    ),

                  const SizedBox(height: 14),

                  // ── Metrics grid ──────────────────────────────────────────
                  TelemetryMetricsGrid(
                    latest: latest,
                    status: status,
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    formatValue: formatValue,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}