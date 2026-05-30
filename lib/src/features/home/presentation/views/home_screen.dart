// // //
// // //
// // // import "dart:async";
// // //
// // // import "package:flutter/material.dart";
// // // import "package:flutter/services.dart";
// // // import "package:flutter_riverpod/flutter_riverpod.dart";
// // //
// // // import "package:smart_iot_app/src/core/constant/app_color.dart";
// // // import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
// // //
// // // import "../../../../app/routes.dart";
// // // import "../../../khata/presentation/providers/ khata_providers.dart";
// // //
// // // import "../../../motor/presentation/ providers/motor_providers.dart";
// // //
// // // import "../../../telemetry/presentation/providers/telemetry_providers.dart";
// // //
// // // import "dart:async";
// // //
// // // enum MotorRunSource {
// // //   none,
// // //   appButton,
// // //   physicalButton,
// // // }
// // //
// // // enum DeviceConnectionStatus {
// // //   noDevice,
// // //   waitingTelemetry,
// // //   connected,
// // //   disconnected,
// // // }
// // //
// // // class HomeScreen extends ConsumerStatefulWidget {
// // //   final String? deviceId;
// // //
// // //   const HomeScreen({
// // //     super.key,
// // //     this.deviceId,
// // //   });
// // //
// // //   @override
// // //   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// // // }
// // //
// // // class _HomeScreenState extends ConsumerState<HomeScreen>
// // //     with SingleTickerProviderStateMixin {
// // //   late AnimationController pulseController;
// // //   late Animation<double> pulseAnimation;
// // //
// // //   final TextEditingController customerNameController = TextEditingController();
// // //   final FocusNode customerNameFocusNode = FocusNode();
// // //
// // //   Timer? runTimer;
// // //   Timer? telemetryTimer;
// // //
// // //   int runSeconds = 0;
// // //   int telemetryFailures = 0;
// // //
// // //   String? userId;
// // //   String? deviceId;
// // //   String?deviceName;
// // //
// // //   bool didSetupDevice = false;
// // //   bool isTelemetryLoading = false;
// // //   bool noDeviceSnackShown = false;
// // //   bool appMotorOn = false;
// // //
// // //   MotorRunSource runSource = MotorRunSource.none;
// // //
// // //   bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //     pulseController = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 850),
// // //     )..repeat(reverse: true);
// // //
// // //     pulseAnimation = Tween<double>(begin: 0.82, end: 1.12).animate(
// // //       CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
// // //     );
// // //   }
// // //
// // //   @override
// // //   void didChangeDependencies() {
// // //     super.didChangeDependencies();
// // //
// // //     if (didSetupDevice) return;
// // //     didSetupDevice = true;
// // //
// // //     final args = ModalRoute.of(context)?.settings.arguments;
// // //
// // //     if (args is Map) {
// // //       userId = args["userId"]?.toString();
// // //       final rawDeviceId = args["deviceId"]?.toString();
// // //       deviceId = rawDeviceId == null || rawDeviceId.trim().isEmpty
// // //           ? null
// // //           : rawDeviceId.trim();
// // //     }
// // //
// // //     final widgetDeviceId = widget.deviceId?.trim();
// // //     deviceId ??= widgetDeviceId == null || widgetDeviceId.isEmpty
// // //         ? null
// // //         : widgetDeviceId;
// // //
// // //     // 🔥 FIX: Hard safeguard against the placeholder template name.
// // //     // If the app passes the placeholder name, override it with your working hardware UUID.
// // //     if (deviceId == "ESP32_001_TW") {
// // //       deviceId = "7a966ae8-70e1-494b-925a-0754c93064bb";
// // //     }
// // //
// // //     if (hasDevice) {
// // //       Future.microtask(() async {
// // //         await loadTelemetry();
// // //         await ref.read(khataViewModelProvider.notifier).loadEntries();
// // //       });
// // //
// // //       telemetryTimer = Timer.periodic(
// // //         const Duration(seconds: 5),
// // //             (_) => loadTelemetry(showError: false),
// // //       );
// // //     } else {
// // //       Future.microtask(() {
// // //         if (!mounted || noDeviceSnackShown) return;
// // //         noDeviceSnackShown = true;
// // //         showMessage("Device not connected. Opened dashboard safely.", false);
// // //       });
// // //     }
// // //   }
// // //   @override
// // //   void dispose() {
// // //     pulseController.dispose();
// // //     customerNameController.dispose();
// // //     customerNameFocusNode.dispose();
// // //     runTimer?.cancel();
// // //     telemetryTimer?.cancel();
// // //     super.dispose();
// // //   }
// // //
// // //   DeviceConnectionStatus connectionStatus(dynamic latest) {
// // //     if (!hasDevice) return DeviceConnectionStatus.noDevice;
// // //     if (latest != null && telemetryFailures < 3) {
// // //       return DeviceConnectionStatus.connected;
// // //     }
// // //     if (telemetryFailures >= 3) {
// // //       return DeviceConnectionStatus.disconnected;
// // //     }
// // //     return DeviceConnectionStatus.waitingTelemetry;
// // //   }
// // //
// // //   String friendlyError(String? error) {
// // //     final text = (error ?? "").toLowerCase();
// // //
// // //     if (text.contains("socket") ||
// // //         text.contains("connection") ||
// // //         text.contains("network") ||
// // //         text.contains("internet") ||
// // //         text.contains("host lookup") ||
// // //         text.contains("timeout") ||
// // //         text.contains("receive timeout") ||
// // //         text.contains("failed host lookup") ||
// // //         text.contains("connection refused") ||
// // //         text.contains("connection failed")) {
// // //       return "No internet connection. Please check Wi-Fi or mobile data.";
// // //     }
// // //
// // //     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
// // //
// // //     return error!;
// // //   }
// // //
// // //   Future<void> loadTelemetry({bool showError = false}) async {
// // //     // 1. If a network request is already out, exit immediately to prevent concurrent spamming threads
// // //     if (isTelemetryLoading) return;
// // //     if (!hasDevice) return;
// // //
// // //     isTelemetryLoading = true;
// // //
// // //     try {
// // //       // 2. Fetch data via Riverpod tracking state engine
// // //       await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);
// // //
// // //       if (!mounted) return;
// // //
// // //       final telemetryState = ref.read(telemetryViewModelProvider);
// // //
// // //       if (telemetryState.latest != null) {
// // //         telemetryFailures = 0;
// // //       } else if (telemetryState.error != null) {
// // //         telemetryFailures++;
// // //       }
// // //     } catch (_) {
// // //       telemetryFailures++;
// // //     } finally {
// // //       // 3. 🔥 FIX: Clear the loading state lock flag SAFELY within a controlled frame update
// // //       if (mounted) {
// // //         setState(() {
// // //           isTelemetryLoading = false;
// // //         });
// // //       }
// // //     }
// // //   }
// // //
// // //   void _startLocalTimer() {
// // //     runTimer?.cancel();
// // //     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// // //       if (mounted) setState(() => runSeconds++);
// // //     });
// // //   }
// // //
// // //   void _stopLocalTimer() {
// // //     runTimer?.cancel();
// // //     runTimer = null;
// // //   }
// // //
// // //   String get runningTime {
// // //     final seconds = appMotorOn && runSeconds <= 0 ? 1 : runSeconds;
// // //     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
// // //     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
// // //     final s = (seconds % 60).toString().padLeft(2, "0");
// // //     return "$h:$m:$s";
// // //   }
// // //
// // //   String formatValue(
// // //       double? value,
// // //       String unit, {
// // //         int decimals = 1,
// // //         required DeviceConnectionStatus status,
// // //       }) {
// // //     if (status == DeviceConnectionStatus.noDevice) return "-- $unit";
// // //     if (value == null) return "-- $unit";
// // //     return "${value.toStringAsFixed(decimals)} $unit";
// // //   }
// // //
// // //   Future<void> toggleMotor(MotorSnapshot snapshot) async {
// // //     if (!hasDevice) {
// // //       showMessage("Device not connected. Please select a device first.", true);
// // //       return;
// // //     }
// // //
// // //     FocusScope.of(context).unfocus();
// // //     HapticFeedback.mediumImpact();
// // //
// // //     final typedCustomerName = customerNameController.text.trim();
// // //     final customerName = typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName;
// // //     final motorVm = ref.read(motorViewModelProvider.notifier);
// // //
// // //     try {
// // //       if (appMotorOn) {
// // //         final stoppedRunSeconds = runSeconds <= 0 ? 1 : runSeconds;
// // //
// // //         final stoppedLog = await motorVm.stopMotor(
// // //           deviceId: deviceId!,
// // //           customerName: customerName,
// // //         );
// // //
// // //         final motorState = ref.read(motorViewModelProvider);
// // //         if (motorState.error != null) {
// // //           showMessage(motorState.error.toString(), true, seconds: 10);
// // //           return;
// // //         }
// // //
// // //         _stopLocalTimer();
// // //
// // //         setState(() {
// // //           appMotorOn = false;
// // //           runSource = MotorRunSource.none;
// // //           runSeconds = 0;
// // //         });
// // //
// // //         if (stoppedLog != null) {
// // //           await ref.read(khataViewModelProvider.notifier).createFromMotorLog(
// // //             log: stoppedLog,
// // //             customerName: customerName,
// // //             deviceId: deviceId!,
// // //             pricePerHour: 0,
// // //             cashReceived: 0,
// // //             fallbackRunSeconds: stoppedRunSeconds,
// // //           );
// // //         }
// // //
// // //         await loadTelemetry(showError: false);
// // //         await ref.read(khataViewModelProvider.notifier).loadEntries();
// // //
// // //         final khataState = ref.read(khataViewModelProvider);
// // //         if (khataState.error != null) {
// // //           showMessage(
// // //             "Motor stopped, but Khata was not created: ${khataState.error}",
// // //             true,
// // //             seconds: 12,
// // //           );
// // //           return;
// // //         }
// // //
// // //         showMessage("Motor stopped. Khata entry created.", false);
// // //         return;
// // //       }
// // //
// // //       if (typedCustomerName.isEmpty) {
// // //         showMessage("Customer name is required to start motor.", true);
// // //         return;
// // //       }
// // //
// // //       await motorVm.startMotor(
// // //         deviceId: deviceId!,
// // //         customerName: typedCustomerName,
// // //       );
// // //
// // //       final motorState = ref.read(motorViewModelProvider);
// // //       if (motorState.error != null) {
// // //         showMessage(motorState.error.toString(), true, seconds: 10);
// // //         return;
// // //       }
// // //
// // //       setState(() {
// // //         appMotorOn = true;
// // //         runSource = MotorRunSource.appButton;
// // //         runSeconds = 0;
// // //       });
// // //
// // //       _startLocalTimer();
// // //       await loadTelemetry(showError: false);
// // //
// // //       showMessage("Motor started successfully", false);
// // //     } catch (e) {
// // //       showMessage(
// // //         "Motor action failed: ${friendlyError(e.toString())}",
// // //         true,
// // //         seconds: 12,
// // //       );
// // //     }
// // //   }
// // //
// // //   void showMessage(String text, bool isError, {int seconds = 6}) {
// // //     if (!mounted) return;
// // //
// // //     ScaffoldMessenger.of(context)
// // //       ..clearSnackBars()
// // //       ..showSnackBar(
// // //         SnackBar(
// // //           duration: Duration(seconds: isError ? seconds : 4),
// // //           behavior: SnackBarBehavior.floating,
// // //           margin: const EdgeInsets.all(16),
// // //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// // //           backgroundColor: isError ? AppColors.error : AppColors.green,
// // //           content: Text(
// // //             isError ? friendlyError(text) : text,
// // //             style: const TextStyle(
// // //               color: AppColors.white,
// // //               fontWeight: FontWeight.w800,
// // //             ),
// // //           ),
// // //         ),
// // //       );
// // //   }
// // //
// // //   List<String> customerSuggestions() {
// // //     if (!hasDevice) return <String>[];
// // //
// // //     final khataState = ref.watch(khataViewModelProvider);
// // //     final names = <String>{};
// // //
// // //     for (final entry in khataState.entries) {
// // //       final name = entry.customerName?.trim();
// // //       if (name != null && name.isNotEmpty) names.add(name);
// // //     }
// // //
// // //     final list = names.toList();
// // //     list.sort();
// // //     return list;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final motorState = ref.watch(motorViewModelProvider);
// // //     final telemetryState = ref.watch(telemetryViewModelProvider);
// // //     final latest = hasDevice ? telemetryState.latest : null;
// // //     final status = connectionStatus(latest);
// // //
// // //     final snapshot = MotorSnapshot.fromAppState(
// // //       appMotorOn: hasDevice && appMotorOn,
// // //       latest: latest,
// // //       runSource: runSource,
// // //       status: status,
// // //     );
// // //
// // //     final size = MediaQuery.of(context).size;
// // //     final width = size.width;
// // //
// // //     final isVerySmall = width < 360;
// // //     final isTablet = width >= 650;
// // //     final isLarge = width >= 1000;
// // //
// // //     final horizontalPadding = isLarge
// // //         ? 38.0
// // //         : isTablet
// // //         ? 30.0
// // //         : 16.0;
// // //
// // //     final crossAxisCount = isLarge
// // //         ? 4
// // //         : isTablet
// // //         ? 3
// // //         : 2;
// // //
// // //     final childAspectRatio = isLarge
// // //         ? 1.36
// // //         : isTablet
// // //         ? 1.22
// // //         : 1.02;
// // //
// // //     final buttonSize = isLarge
// // //         ? 238.0
// // //         : isTablet
// // //         ? 226.0
// // //         : isVerySmall
// // //         ? 176.0
// // //         : 196.0;
// // //
// // //     return Scaffold(
// // //       backgroundColor: AppColors.darkBgSoft,
// // //       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
// // //       appBar: AppBar(
// // //         backgroundColor: AppColors.darkSurfaceSoft,
// // //         elevation: 0,
// // //         centerTitle: true,
// // //         iconTheme: const IconThemeData(color: AppColors.white),
// // //         title: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Text(
// // //               "SmartWell VFD",
// // //               maxLines: 1,
// // //               overflow: TextOverflow.ellipsis,
// // //               style: TextStyle(
// // //                 color: AppColors.white,
// // //                 fontSize: isVerySmall ? 18 : 21,
// // //                 fontWeight: FontWeight.w900,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 2),
// // //             Text(
// // //               hasDevice ? deviceId! : "Device not connected",
// // //               maxLines: 1,
// // //               overflow: TextOverflow.ellipsis,
// // //               style: TextStyle(
// // //                 color: status == DeviceConnectionStatus.connected
// // //                     ? AppColors.primary.withOpacity(0.88)
// // //                     : AppColors.warning,
// // //                 fontSize: isVerySmall ? 10 : 11,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //         actions: [
// // //           IconButton(
// // //             tooltip: "Change device",
// // //             onPressed: () {
// // //               Navigator.pushReplacementNamed(context, AppRoutes.devices);
// // //             },
// // //             icon: const Icon(Icons.devices_other_rounded),
// // //           ),
// // //         ],
// // //       ),
// // //       body: SafeArea(
// // //         child: RefreshIndicator(
// // //           onRefresh: () async {
// // //             if (hasDevice) {
// // //               await loadTelemetry();
// // //             } else {
// // //               showMessage("Device not connected. Please select a device.", true);
// // //             }
// // //           },
// // //           color: AppColors.primary,
// // //           backgroundColor: AppColors.surfaceDark,
// // //           child: SingleChildScrollView(
// // //             physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
// // //             padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 18),
// // //             child: Center(
// // //               child: ConstrainedBox(
// // //                 constraints: const BoxConstraints(maxWidth: 1080),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// // //                   children: [
// // //                     VfdHeaderCard(
// // //                       deviceId: deviceId,
// // //                       snapshot: snapshot,
// // //                       frequencyText: formatValue(
// // //                         latest?.freq,
// // //                         "Hz",
// // //                         decimals: 1,
// // //                         status: status,
// // //                       ),
// // //                       referenceFrequencyText: formatValue(
// // //                         latest?.referenceFreq ?? latest?.freq,
// // //                         "Hz",
// // //                         decimals: 1,
// // //                         status: status,
// // //                       ),
// // //                     ),
// // //                     if (status == DeviceConnectionStatus.noDevice)
// // //                       const Padding(
// // //                         padding: EdgeInsets.only(top: 10),
// // //                         child: DeviceNotConnectedBadge(),
// // //                       ),
// // //                     if (status == DeviceConnectionStatus.waitingTelemetry)
// // //                       const Padding(
// // //                         padding: EdgeInsets.only(top: 10),
// // //                         child: WaitingTelemetryBadge(),
// // //                       ),
// // //                     if (status == DeviceConnectionStatus.disconnected)
// // //                       const Padding(
// // //                         padding: EdgeInsets.only(top: 10),
// // //                         child: DeviceDisconnectedBadge(),
// // //                       ),
// // //                     const SizedBox(height: 16),
// // //                     StatusPanel(snapshot: snapshot, pulseAnimation: pulseAnimation),
// // //                     const SizedBox(height: 16),
// // //                     SystemBanner(snapshot: snapshot),
// // //                     if (snapshot.hasFault && !snapshot.hasTelemetryError) ...[
// // //                       const SizedBox(height: 14),
// // //                       FaultAlertCard(snapshot: snapshot),
// // //                     ],
// // //                     const SizedBox(height: 18),
// // //                     CustomerNameField(
// // //                       controller: customerNameController,
// // //                       focusNode: customerNameFocusNode,
// // //                       suggestions: customerSuggestions(),
// // //                       enabled: hasDevice,
// // //                     ),
// // //                     const SizedBox(height: 26),
// // //                     Center(
// // //                       child: GestureDetector(
// // //                         onTap: motorState.isLoading ? null : () => toggleMotor(snapshot),
// // //                         child: AnimatedBuilder(
// // //                           animation: pulseAnimation,
// // //                           builder: (context, child) {
// // //                             final scale = snapshot.isRunning
// // //                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
// // //                                 : 1.0;
// // //                             return Transform.scale(scale: scale, child: child);
// // //                           },
// // //                           child: MotorButton(
// // //                             snapshot: snapshot,
// // //                             loading: hasDevice && motorState.isLoading,
// // //                             size: buttonSize,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 18),
// // //                     Center(
// // //                       child: Text(
// // //                         snapshot.isRunning
// // //                             ? "${snapshot.runSourceText} | $runningTime"
// // //                             : snapshot.centerStatusText,
// // //                         textAlign: TextAlign.center,
// // //                         style: TextStyle(
// // //                           color: AppColors.white.withOpacity(0.76),
// // //                           fontSize: isVerySmall ? 14 : 16,
// // //                           fontWeight: FontWeight.w700,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 22),
// // //                     if (hasDevice && telemetryState.isLoading && latest == null)
// // //                       const Padding(
// // //                         padding: EdgeInsets.all(22),
// // //                         child: Center(
// // //                           child: CircularProgressIndicator(color: AppColors.white),
// // //                         ),
// // //                       ),
// // //                     const SizedBox(height: 14),
// // //                     GridView.count(
// // //                       shrinkWrap: true,
// // //                       physics: const NeverScrollableScrollPhysics(),
// // //                       crossAxisCount: crossAxisCount,
// // //                       crossAxisSpacing: 14,
// // //                       mainAxisSpacing: 14,
// // //                       childAspectRatio: childAspectRatio,
// // //                       children: [
// // //                         MetricCard(
// // //                           icon: Icons.sync_rounded,
// // //                           title: "Frequency",
// // //                           value: formatValue(latest?.freq, "Hz", status: status),
// // //                           highlight: true,
// // //                         ),
// // //                         MetricCard(
// // //                           icon: Icons.bolt_rounded,
// // //                           title: "Voltage",
// // //                           value: formatValue(latest?.voltage, "V", status: status),
// // //                         ),
// // //                         MetricCard(
// // //                           icon: Icons.flash_on_rounded,
// // //                           title: "Current",
// // //                           value: formatValue(latest?.current, "A", status: status),
// // //                         ),
// // //                         MetricCard(
// // //                           icon: Icons.power_rounded,
// // //                           title: "Power",
// // //                           value: formatValue(latest?.power, "kW", status: status),
// // //                         ),
// // //                         MetricCard(
// // //                           icon: Icons.speed_rounded,
// // //                           title: "Load",
// // //                           value: formatValue(latest?.powerPercent, "%", status: status),
// // //                         ),
// // //                         MetricCard(
// // //                           icon: Icons.rotate_right_rounded,
// // //                           title: "Motor Speed",
// // //                           value: formatValue(latest?.motorSpeed, "RPM", status: status),
// // //                         ),
// // //                         MetricCard(
// // //                           icon: Icons.battery_charging_full_rounded,
// // //                           title: "DC Bus",
// // //                           value: formatValue(latest?.dcbus, "V", status: status),
// // //                         ),
// // //                         MetricCard(
// // //                           icon: Icons.electric_meter_rounded,
// // //                           title: "Energy",
// // //                           value: formatValue(latest?.energyIn, "kWh", status: status),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     const SizedBox(height: 20),
// // //                     DeviceSessionCard(
// // //                       deviceId: deviceId,
// // //                       snapshot: snapshot,
// // //                       timestamp: latest?.timestamp,
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class MotorSnapshot {
// // //   final bool isRunning;
// // //   final bool hasFault;
// // //   final bool hasTelemetryError;
// // //   final int? statusCode;
// // //   final int? faultCode;
// // //   final int? isLive;
// // //   final MotorRunSource runSource;
// // //   final DeviceConnectionStatus connectionStatus;
// // //
// // //   const MotorSnapshot({
// // //     required this.isRunning,
// // //     required this.hasFault,
// // //     required this.hasTelemetryError,
// // //     required this.statusCode,
// // //     required this.faultCode,
// // //     required this.isLive,
// // //     required this.runSource,
// // //     required this.connectionStatus,
// // //   });
// // //
// // //   bool get hasDevice => connectionStatus != DeviceConnectionStatus.noDevice;
// // //
// // //   factory MotorSnapshot.fromAppState({
// // //     required bool appMotorOn,
// // //     required dynamic latest,
// // //     required MotorRunSource runSource,
// // //     required DeviceConnectionStatus status,
// // //   }) {
// // //     final int? statusCode = latest?.statusCode;
// // //     final int? faultCode = latest?.faultCode;
// // //     final int? fault = latest?.fault;
// // //     final int? isLive = latest?.isLive;
// // //
// // //     final hasFault = status == DeviceConnectionStatus.connected &&
// // //         ((fault ?? 0) == 1 || (faultCode ?? 0) > 0 || statusCode == 4);
// // //
// // //     final resolvedSource = appMotorOn
// // //         ? (runSource == MotorRunSource.none ? MotorRunSource.appButton : runSource)
// // //         : MotorRunSource.none;
// // //
// // //     return MotorSnapshot(
// // //       isRunning: status == DeviceConnectionStatus.connected && appMotorOn,
// // //       hasFault: hasFault,
// // //       hasTelemetryError: status == DeviceConnectionStatus.disconnected,
// // //       statusCode: latest == null ? null : statusCode,
// // //       faultCode: latest == null ? null : faultCode,
// // //       isLive: latest == null ? null : isLive,
// // //       runSource: resolvedSource,
// // //       connectionStatus: status,
// // //     );
// // //   }
// // //
// // //   String get statusName {
// // //     switch (connectionStatus) {
// // //       case DeviceConnectionStatus.noDevice:
// // //         return "Device Not Connected";
// // //       case DeviceConnectionStatus.waitingTelemetry:
// // //         return "Waiting for Telemetry";
// // //       case DeviceConnectionStatus.disconnected:
// // //         return "Device Disconnected";
// // //       case DeviceConnectionStatus.connected:
// // //         break;
// // //     }
// // //
// // //     if (hasFault) return "Fault Active";
// // //     if (isRunning && statusCode == 1) return "Forward Running";
// // //     if (isRunning && statusCode == 2) return "Reverse Running";
// // //     if (isRunning) return "VFD Running";
// // //     if (statusCode == 3) return "Standby";
// // //     if (statusCode == 5) return "VFD Off";
// // //     return "System Ready";
// // //   }
// // //
// // //   String get centerStatusText {
// // //     switch (connectionStatus) {
// // //       case DeviceConnectionStatus.noDevice:
// // //         return "Device not connected";
// // //       case DeviceConnectionStatus.waitingTelemetry:
// // //         return "Waiting for live readings";
// // //       case DeviceConnectionStatus.disconnected:
// // //         return "Device disconnected";
// // //       case DeviceConnectionStatus.connected:
// // //         break;
// // //     }
// // //
// // //     if (hasFault) return faultName;
// // //     if (isRunning) return runSourceText;
// // //     if (statusCode == 5) return "VFD Off";
// // //     return "System Ready";
// // //   }
// // //
// // //   String get runSourceText {
// // //     if (!isRunning) return "Stopped";
// // //     if (runSource == MotorRunSource.appButton) return "Run by App Button";
// // //     if (runSource == MotorRunSource.physicalButton) return "Run by Physical Button";
// // //     return "Running";
// // //   }
// // //
// // //   Color get bannerColor {
// // //     switch (connectionStatus) {
// // //       case DeviceConnectionStatus.noDevice:
// // //         return AppColors.warning;
// // //       case DeviceConnectionStatus.waitingTelemetry:
// // //         return AppColors.primary;
// // //       case DeviceConnectionStatus.disconnected:
// // //         return AppColors.warning;
// // //       case DeviceConnectionStatus.connected:
// // //         break;
// // //     }
// // //
// // //     if (hasFault) return AppColors.error;
// // //     if (isRunning && runSource == MotorRunSource.physicalButton) return AppColors.accent;
// // //     if (isRunning) return AppColors.green;
// // //     if (statusCode == 5) return AppColors.blueDark;
// // //     return AppColors.primary;
// // //   }
// // //
// // //   IconData get bannerIcon {
// // //     switch (connectionStatus) {
// // //       case DeviceConnectionStatus.noDevice:
// // //         return Icons.link_off_rounded;
// // //       case DeviceConnectionStatus.waitingTelemetry:
// // //         return Icons.sync_rounded;
// // //       case DeviceConnectionStatus.disconnected:
// // //         return Icons.wifi_off_rounded;
// // //       case DeviceConnectionStatus.connected:
// // //         break;
// // //     }
// // //
// // //     if (hasFault) return Icons.warning_amber_rounded;
// // //     if (isRunning && runSource == MotorRunSource.physicalButton) {
// // //       return Icons.radio_button_checked_rounded;
// // //     }
// // //     if (isRunning) return Icons.check_circle_rounded;
// // //     if (statusCode == 5) return Icons.power_off_rounded;
// // //     return Icons.verified_rounded;
// // //   }
// // //
// // //   String get faultName {
// // //     switch (faultCode ?? 0) {
// // //       case 0:
// // //         return "No Fault";
// // //       case 1:
// // //         return "OUT1";
// // //       case 2:
// // //         return "OUT2";
// // //       case 3:
// // //         return "OUT3";
// // //       case 4:
// // //         return "OC1";
// // //       case 5:
// // //         return "OC2";
// // //       case 6:
// // //         return "OC3";
// // //       case 7:
// // //         return "OV1";
// // //       case 8:
// // //         return "OV2";
// // //       case 9:
// // //         return "OV3";
// // //       case 10:
// // //         return "UV";
// // //       case 11:
// // //         return "OL1";
// // //       case 12:
// // //         return "OL2";
// // //       case 13:
// // //         return "SPI";
// // //       case 14:
// // //         return "SPO";
// // //       case 15:
// // //         return "OH1";
// // //       case 16:
// // //         return "OH2";
// // //       case 17:
// // //         return "EF";
// // //       case 18:
// // //         return "CE";
// // //       case 19:
// // //         return "ItE";
// // //       default:
// // //         return "Unknown Fault";
// // //     }
// // //   }
// // //
// // //   String get faultDescription {
// // //     switch (faultCode ?? 0) {
// // //       case 0:
// // //         return "Drive operating normally.";
// // //       case 1:
// // //         return "Output phase fault. Check motor cable, output terminal, or missing motor phase.";
// // //       case 2:
// // //         return "Output abnormality. Check motor short circuit or output wiring.";
// // //       case 3:
// // //         return "Output phase imbalance. Check open phase or motor winding damage.";
// // //       case 4:
// // //         return "Acceleration overcurrent. Check acceleration time, heavy load, or jammed motor.";
// // //       case 5:
// // //         return "Deceleration overcurrent. Check deceleration time or high inertia load.";
// // //       case 6:
// // //         return "Constant speed overcurrent. Check mechanical overload or motor current.";
// // //       case 7:
// // //         return "Acceleration overvoltage. DC bus voltage is too high during acceleration.";
// // //       case 8:
// // //         return "Deceleration overvoltage. Check fast deceleration or braking resistor.";
// // //       case 9:
// // //         return "Constant overvoltage. Check supply voltage.";
// // //       case 10:
// // //         return "Under voltage. Check weak supply or loose input cable.";
// // //       case 11:
// // //         return "Motor overload. Current stayed too high for long duration.";
// // //       case 12:
// // //         return "Drive overload. Load may exceed VFD capacity.";
// // //       case 13:
// // //         return "Internal communication fault.";
// // //       case 14:
// // //         return "Output protection triggered.";
// // //       case 15:
// // //         return "Drive overheat. Check cooling fan and ventilation.";
// // //       case 16:
// // //         return "Motor overheat. Motor thermal protection triggered.";
// // //       case 17:
// // //         return "External fault. External safety device triggered.";
// // //       case 18:
// // //         return "Communication error.";
// // //       case 19:
// // //         return "Current detection error.";
// // //       default:
// // //         return "Unknown fault code.";
// // //     }
// // //   }
// // // }
// // //
// // // class VfdHeaderCard extends StatelessWidget {
// // //   final String? deviceId;
// // //   final MotorSnapshot snapshot;
// // //   final String frequencyText;
// // //   final String referenceFrequencyText;
// // //
// // //   const VfdHeaderCard({
// // //     super.key,
// // //     required this.deviceId,
// // //     required this.snapshot,
// // //     required this.frequencyText,
// // //     required this.referenceFrequencyText,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final width = MediaQuery.of(context).size.width;
// // //     final compact = width < 390;
// // //
// // //     return Container(
// // //       padding: EdgeInsets.all(compact ? 15 : 18),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.cardDark,
// // //         borderRadius: BorderRadius.circular(26),
// // //         border: Border.all(color: AppColors.borderDark),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: AppColors.primary.withOpacity(0.10),
// // //             blurRadius: 28,
// // //             offset: const Offset(0, 14),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Container(
// // //             height: compact ? 54 : 62,
// // //             width: compact ? 54 : 62,
// // //             decoration: BoxDecoration(
// // //               color: snapshot.bannerColor.withOpacity(0.14),
// // //               borderRadius: BorderRadius.circular(20),
// // //             ),
// // //             child: Icon(
// // //               snapshot.bannerIcon,
// // //               color: snapshot.bannerColor,
// // //               size: compact ? 28 : 32,
// // //             ),
// // //           ),
// // //           const SizedBox(width: 14),
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   snapshot.hasDevice ? deviceId! : "Device Not Connected",
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: TextStyle(
// // //                     color: AppColors.white,
// // //                     fontSize: compact ? 15 : 17,
// // //                     fontWeight: FontWeight.w900,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 6),
// // //                 Text(
// // //                   snapshot.statusName,
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: TextStyle(
// // //                     color: snapshot.bannerColor,
// // //                     fontSize: compact ? 12.5 : 14,
// // //                     fontWeight: FontWeight.w800,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           const SizedBox(width: 10),
// // //           Column(
// // //             crossAxisAlignment: CrossAxisAlignment.end,
// // //             children: [
// // //               Text(
// // //                 "Frequency",
// // //                 style: TextStyle(
// // //                   color: AppColors.white.withOpacity(0.62),
// // //                   fontSize: compact ? 11 : 12,
// // //                   fontWeight: FontWeight.w700,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 5),
// // //               Text(
// // //                 frequencyText,
// // //                 style: TextStyle(
// // //                   color: AppColors.white,
// // //                   fontSize: compact ? 19 : 23,
// // //                   fontWeight: FontWeight.w900,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Text(
// // //                 "Ref $referenceFrequencyText",
// // //                 style: TextStyle(
// // //                   color: AppColors.white.withOpacity(0.50),
// // //                   fontSize: compact ? 10.5 : 12,
// // //                   fontWeight: FontWeight.w700,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class DeviceNotConnectedBadge extends StatelessWidget {
// // //   const DeviceNotConnectedBadge({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return _InfoBadge(
// // //       icon: Icons.link_off_rounded,
// // //       color: AppColors.warning,
// // //       text: "Device not connected. Select a device to view live parameters.",
// // //     );
// // //   }
// // // }
// // //
// // // class WaitingTelemetryBadge extends StatelessWidget {
// // //   const WaitingTelemetryBadge({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return _InfoBadge(
// // //       icon: Icons.sync_rounded,
// // //       color: AppColors.primary,
// // //       text: "Device selected. Waiting for latest telemetry values.",
// // //     );
// // //   }
// // // }
// // //
// // // class DeviceDisconnectedBadge extends StatelessWidget {
// // //   const DeviceDisconnectedBadge({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return _InfoBadge(
// // //       icon: Icons.wifi_off_rounded,
// // //       color: AppColors.warning,
// // //       text: "Device disconnected. Showing last received values when available.",
// // //     );
// // //   }
// // // }
// // //
// // // class _InfoBadge extends StatelessWidget {
// // //   final IconData icon;
// // //   final Color color;
// // //   final String text;
// // //
// // //   const _InfoBadge({
// // //     required this.icon,
// // //     required this.color,
// // //     required this.text,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// // //       decoration: BoxDecoration(
// // //         color: color.withOpacity(0.12),
// // //         borderRadius: BorderRadius.circular(14),
// // //         border: Border.all(color: color.withOpacity(0.3)),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Icon(icon, color: color, size: 18),
// // //           const SizedBox(width: 8),
// // //           Expanded(
// // //             child: Text(
// // //               text,
// // //               style: TextStyle(
// // //                 color: AppColors.white.withOpacity(0.85),
// // //                 fontWeight: FontWeight.w700,
// // //                 fontSize: 12.5,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class StatusPanel extends StatelessWidget {
// // //   final MotorSnapshot snapshot;
// // //   final Animation<double> pulseAnimation;
// // //
// // //   const StatusPanel({
// // //     super.key,
// // //     required this.snapshot,
// // //     required this.pulseAnimation,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final phaseOk = snapshot.connectionStatus == DeviceConnectionStatus.connected;
// // //     final motorOk = snapshot.isRunning;
// // //     final tripOk = !snapshot.hasFault;
// // //     final serviceOk = snapshot.connectionStatus == DeviceConnectionStatus.connected;
// // //
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.cardDark,
// // //         borderRadius: BorderRadius.circular(24),
// // //         border: Border.all(color: AppColors.borderDark),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Expanded(
// // //             child: StatusDot(
// // //               title: "Phase",
// // //               ok: phaseOk,
// // //               blinking: false,
// // //               pulseAnimation: pulseAnimation,
// // //             ),
// // //           ),
// // //           Expanded(
// // //             child: StatusDot(
// // //               title: "Motor",
// // //               ok: motorOk,
// // //               blinking: false,
// // //               pulseAnimation: pulseAnimation,
// // //             ),
// // //           ),
// // //           Expanded(
// // //             child: StatusDot(
// // //               title: "Trip",
// // //               ok: tripOk,
// // //               blinking: snapshot.hasFault,
// // //               pulseAnimation: pulseAnimation,
// // //             ),
// // //           ),
// // //           Expanded(
// // //             child: StatusDot(
// // //               title: "Service",
// // //               ok: serviceOk,
// // //               blinking: snapshot.connectionStatus == DeviceConnectionStatus.disconnected,
// // //               pulseAnimation: pulseAnimation,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class StatusDot extends StatelessWidget {
// // //   final String title;
// // //   final bool ok;
// // //   final bool blinking;
// // //   final Animation<double> pulseAnimation;
// // //
// // //   const StatusDot({
// // //     super.key,
// // //     required this.title,
// // //     required this.ok,
// // //     required this.blinking,
// // //     required this.pulseAnimation,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final width = MediaQuery.of(context).size.width;
// // //     final dotSize = width < 360 ? 40.0 : 48.0;
// // //     final baseColor = ok ? AppColors.green : AppColors.error;
// // //
// // //     return AnimatedBuilder(
// // //       animation: pulseAnimation,
// // //       builder: (context, child) {
// // //         final scale = blinking ? pulseAnimation.value : 1.0;
// // //         final opacity = blinking ? (0.55 + (pulseAnimation.value - 0.82)) : 1.0;
// // //
// // //         return Column(
// // //           children: [
// // //             Transform.scale(
// // //               scale: scale,
// // //               child: Opacity(
// // //                 opacity: opacity.clamp(0.45, 1.0),
// // //                 child: Container(
// // //                   height: dotSize,
// // //                   width: dotSize,
// // //                   decoration: BoxDecoration(
// // //                     color: baseColor,
// // //                     shape: BoxShape.circle,
// // //                     boxShadow: [
// // //                       BoxShadow(
// // //                         color: baseColor.withOpacity(0.42),
// // //                         blurRadius: blinking ? 28 : 18,
// // //                         spreadRadius: blinking ? 4 : 2,
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 8),
// // //             FittedBox(
// // //               child: Text(
// // //                 title,
// // //                 style: TextStyle(
// // //                   color: AppColors.white.withOpacity(0.7),
// // //                   fontSize: width < 360 ? 12 : 14,
// // //                   fontWeight: FontWeight.w700,
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         );
// // //       },
// // //     );
// // //   }
// // // }
// // //
// // // class SystemBanner extends StatelessWidget {
// // //   final MotorSnapshot snapshot;
// // //
// // //   const SystemBanner({super.key, required this.snapshot});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final width = MediaQuery.of(context).size.width;
// // //
// // //     final text = snapshot.hasFault
// // //         ? "${snapshot.faultName} Fault"
// // //         : snapshot.isRunning
// // //         ? snapshot.runSourceText
// // //         : snapshot.statusName;
// // //
// // //     final foregroundColor = snapshot.bannerColor == AppColors.primary
// // //         ? AppColors.black
// // //         : AppColors.white;
// // //
// // //     return Container(
// // //       width: double.infinity,
// // //       padding: EdgeInsets.symmetric(
// // //         vertical: width < 360 ? 14 : 16,
// // //         horizontal: 18,
// // //       ),
// // //       decoration: BoxDecoration(
// // //         color: snapshot.bannerColor,
// // //         borderRadius: BorderRadius.circular(22),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: snapshot.bannerColor.withOpacity(0.22),
// // //             blurRadius: 20,
// // //             offset: const Offset(0, 10),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(snapshot.bannerIcon, color: foregroundColor, size: width < 360 ? 24 : 27),
// // //           const SizedBox(width: 10),
// // //           Flexible(
// // //             child: Text(
// // //               text,
// // //               overflow: TextOverflow.ellipsis,
// // //               textAlign: TextAlign.center,
// // //               style: TextStyle(
// // //                 color: foregroundColor,
// // //                 fontSize: width < 360 ? 16 : 19,
// // //                 fontWeight: FontWeight.w900,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class FaultAlertCard extends StatelessWidget {
// // //   final MotorSnapshot snapshot;
// // //
// // //   const FaultAlertCard({super.key, required this.snapshot});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       width: double.infinity,
// // //       padding: const EdgeInsets.all(17),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.error.withOpacity(0.14),
// // //         borderRadius: BorderRadius.circular(22),
// // //         border: Border.all(color: AppColors.error.withOpacity(0.38)),
// // //       ),
// // //       child: Row(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 30),
// // //           const SizedBox(width: 12),
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   snapshot.faultName,
// // //                   style: const TextStyle(
// // //                     color: AppColors.error,
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.w900,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 5),
// // //                 Text(
// // //                   snapshot.faultDescription,
// // //                   style: TextStyle(
// // //                     color: AppColors.white.withOpacity(0.78),
// // //                     fontSize: 13.5,
// // //                     height: 1.35,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class CustomerNameField extends StatelessWidget {
// // //   final TextEditingController controller;
// // //   final FocusNode focusNode;
// // //   final List<String> suggestions;
// // //   final bool enabled;
// // //
// // //   const CustomerNameField({
// // //     super.key,
// // //     required this.controller,
// // //     required this.focusNode,
// // //     required this.suggestions,
// // //     required this.enabled,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return RawAutocomplete<String>(
// // //       textEditingController: controller,
// // //       focusNode: focusNode,
// // //       optionsBuilder: (TextEditingValue value) {
// // //         if (!enabled) return const Iterable<String>.empty();
// // //
// // //         final input = value.text.trim().toLowerCase();
// // //         if (input.isEmpty) return const Iterable<String>.empty();
// // //
// // //         return suggestions.where((name) => name.toLowerCase().contains(input));
// // //       },
// // //       onSelected: (String value) {
// // //         controller.text = value;
// // //         controller.selection = TextSelection.fromPosition(
// // //           TextPosition(offset: controller.text.length),
// // //         );
// // //       },
// // //       fieldViewBuilder: (context, textEditingController, fieldFocusNode, onFieldSubmitted) {
// // //         return Container(
// // //           decoration: BoxDecoration(
// // //             color: AppColors.cardDark,
// // //             borderRadius: BorderRadius.circular(22),
// // //             border: Border.all(color: AppColors.borderDark),
// // //           ),
// // //           child: TextField(
// // //             enabled: enabled,
// // //             controller: textEditingController,
// // //             focusNode: fieldFocusNode,
// // //             keyboardType: TextInputType.text,
// // //             style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
// // //             textInputAction: TextInputAction.done,
// // //             decoration: InputDecoration(
// // //               hintText: enabled ? "Customer name for Khata" : "Select a device first",
// // //               hintStyle: TextStyle(color: AppColors.white.withOpacity(0.42)),
// // //               prefixIcon: Icon(
// // //                 enabled ? Icons.person_outline_rounded : Icons.lock_outline_rounded,
// // //                 color: AppColors.primary,
// // //               ),
// // //               suffixIcon: suggestions.isEmpty || !enabled
// // //                   ? null
// // //                   : Icon(Icons.manage_search_rounded, color: AppColors.white.withOpacity(0.45)),
// // //               border: InputBorder.none,
// // //               contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //       optionsViewBuilder: (context, onSelected, options) {
// // //         return Align(
// // //           alignment: Alignment.topLeft,
// // //           child: Material(
// // //             color: Colors.transparent,
// // //             child: Container(
// // //               width: MediaQuery.of(context).size.width - 36,
// // //               constraints: const BoxConstraints(maxHeight: 240, maxWidth: 560),
// // //               margin: const EdgeInsets.only(top: 8),
// // //               decoration: BoxDecoration(
// // //                 color: AppColors.cardDark,
// // //                 borderRadius: BorderRadius.circular(18),
// // //                 border: Border.all(color: AppColors.borderDark),
// // //                 boxShadow: [
// // //                   BoxShadow(
// // //                     color: Colors.black.withOpacity(0.34),
// // //                     blurRadius: 22,
// // //                     offset: const Offset(0, 12),
// // //                   ),
// // //                 ],
// // //               ),
// // //               child: ListView.separated(
// // //                 padding: const EdgeInsets.symmetric(vertical: 6),
// // //                 shrinkWrap: true,
// // //                 itemCount: options.length,
// // //                 separatorBuilder: (_, __) {
// // //                   return Divider(height: 1, color: AppColors.white.withOpacity(0.06));
// // //                 },
// // //                 itemBuilder: (context, index) {
// // //                   final option = options.elementAt(index);
// // //                   return ListTile(
// // //                     dense: true,
// // //                     leading: const Icon(Icons.person_rounded, color: AppColors.primary),
// // //                     title: Text(
// // //                       option,
// // //                       style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800),
// // //                     ),
// // //                     onTap: () => onSelected(option),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }
// // //
// // // class MotorButton extends StatelessWidget {
// // //   final MotorSnapshot snapshot;
// // //   final bool loading;
// // //   final double size;
// // //
// // //   const MotorButton({
// // //     super.key,
// // //     required this.snapshot,
// // //     required this.loading,
// // //     required this.size,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final activeColor = snapshot.connectionStatus == DeviceConnectionStatus.noDevice
// // //         ? AppColors.warning
// // //         : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
// // //         ? AppColors.warning
// // //         : snapshot.hasFault
// // //         ? AppColors.error
// // //         : snapshot.isRunning
// // //         ? AppColors.green
// // //         : AppColors.error;
// // //
// // //     final label = snapshot.connectionStatus == DeviceConnectionStatus.noDevice
// // //         ? "N/A"
// // //         : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
// // //         ? "OFFLINE"
// // //         : snapshot.hasFault
// // //         ? "FAULT"
// // //         : snapshot.isRunning
// // //         ? "ON"
// // //         : "OFF";
// // //
// // //     return AnimatedContainer(
// // //       duration: const Duration(milliseconds: 300),
// // //       width: size,
// // //       height: size,
// // //       alignment: Alignment.center,
// // //       decoration: BoxDecoration(
// // //         shape: BoxShape.circle,
// // //         gradient: LinearGradient(
// // //           begin: Alignment.topLeft,
// // //           end: Alignment.bottomRight,
// // //           colors: [activeColor, activeColor.withOpacity(0.72)],
// // //         ),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: activeColor.withOpacity(0.34),
// // //             blurRadius: 34,
// // //             offset: const Offset(0, 16),
// // //           ),
// // //         ],
// // //       ),
// // //       child: loading
// // //           ? const CircularProgressIndicator(color: AppColors.white)
// // //           : Column(
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           Icon(snapshot.bannerIcon, color: AppColors.white, size: size < 190 ? 36 : 42),
// // //           const SizedBox(height: 8),
// // //           FittedBox(
// // //             child: Text(
// // //               label,
// // //               style: TextStyle(
// // //                 color: AppColors.white,
// // //                 fontSize: label == "OFFLINE" ? 22 : size < 190 ? 26 : 36,
// // //                 fontWeight: FontWeight.w900,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class MetricCard extends StatelessWidget {
// // //   final IconData icon;
// // //   final String title;
// // //   final String value;
// // //   final bool highlight;
// // //
// // //   const MetricCard({
// // //     super.key,
// // //     required this.icon,
// // //     required this.title,
// // //     required this.value,
// // //     this.highlight = false,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final width = MediaQuery.of(context).size.width;
// // //     final compact = width < 360;
// // //
// // //     return Container(
// // //       padding: EdgeInsets.all(compact ? 13 : 17),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.cardDark,
// // //         borderRadius: BorderRadius.circular(22),
// // //         border: Border.all(
// // //           color: highlight ? AppColors.primary.withOpacity(0.38) : AppColors.borderDark,
// // //         ),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: AppColors.shadowDark.withOpacity(0.26),
// // //             blurRadius: 18,
// // //             offset: const Offset(0, 9),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Icon(
// // //             icon,
// // //             color: highlight ? AppColors.primary : AppColors.iconInactiveDark,
// // //             size: compact ? 24 : 28,
// // //           ),
// // //           const Spacer(),
// // //           Text(
// // //             title,
// // //             maxLines: 1,
// // //             overflow: TextOverflow.ellipsis,
// // //             style: TextStyle(
// // //               color: AppColors.white.withOpacity(0.62),
// // //               fontSize: compact ? 12.5 : 14,
// // //               fontWeight: FontWeight.w700,
// // //             ),
// // //           ),
// // //           const SizedBox(height: 8),
// // //           FittedBox(
// // //             alignment: Alignment.centerLeft,
// // //             fit: BoxFit.scaleDown,
// // //             child: Text(
// // //               value,
// // //               style: TextStyle(
// // //                 color: AppColors.white,
// // //                 height: 1.25,
// // //                 fontSize: compact ? 17 : 20,
// // //                 fontWeight: FontWeight.w900,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class DeviceSessionCard extends StatelessWidget {
// // //   final String? deviceId;
// // //   final MotorSnapshot snapshot;
// // //   final int? timestamp;
// // //
// // //   const DeviceSessionCard({
// // //     super.key,
// // //     required this.deviceId,
// // //     required this.snapshot,
// // //     required this.timestamp,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final liveText = snapshot.statusName;
// // //     final liveColor = snapshot.bannerColor;
// // //
// // //     return Container(
// // //       width: double.infinity,
// // //       padding: const EdgeInsets.all(18),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.cardDark,
// // //         borderRadius: BorderRadius.circular(22),
// // //         border: Border.all(color: AppColors.borderDark),
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           const Text(
// // //             "Device Session",
// // //             style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w900),
// // //           ),
// // //           const SizedBox(height: 12),
// // //           Row(
// // //             children: [
// // //               Container(
// // //                 height: 10,
// // //                 width: 10,
// // //                 decoration: BoxDecoration(color: liveColor, shape: BoxShape.circle),
// // //               ),
// // //               const SizedBox(width: 8),
// // //               Expanded(
// // //                 child: Text(
// // //                   liveText,
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: TextStyle(color: liveColor, fontWeight: FontWeight.w900),
// // //                 ),
// // //               ),
// // //               Text(
// // //                 "Code ${snapshot.statusCode ?? "-"}",
// // //                 style: TextStyle(color: AppColors.white.withOpacity(0.56), fontWeight: FontWeight.w700),
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(height: 12),
// // //           Text(
// // //             "Device ID: ${snapshot.hasDevice ? deviceId : "Device not connected"}",
// // //             style: TextStyle(color: AppColors.white.withOpacity(0.62), fontWeight: FontWeight.w600),
// // //           ),
// // //           const SizedBox(height: 6),
// // //           Text(
// // //             "Timestamp: ${timestamp?.toString() ?? "-"}",
// // //             style: TextStyle(color: AppColors.white.withOpacity(0.62), fontWeight: FontWeight.w600),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// //
// // import "dart:async";
// // import 'package:intl/intl.dart';
// // import "package:flutter/material.dart";
// // import "package:flutter/services.dart";
// // import "package:flutter_riverpod/flutter_riverpod.dart";
// //
// // import "package:smart_iot_app/src/core/constant/app_color.dart";
// // import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
// //
// // import "../../../../app/routes.dart";
// // import "../../../khata/presentation/providers/ khata_providers.dart";
// // import "../../../motor/presentation/ providers/motor_providers.dart";
// // import "../../../telemetry/presentation/providers/telemetry_providers.dart";
// //
// // enum MotorRunSource {
// //   none,
// //   appButton,
// //   physicalButton,
// // }
// //
// // enum DeviceConnectionStatus {
// //   noDevice,
// //   waitingTelemetry,
// //   connected,
// //   disconnected,
// // }
// //
// // class HomeScreen extends ConsumerStatefulWidget {
// //   final String? deviceId;
// //
// //   const HomeScreen({
// //     super.key,
// //     this.deviceId,
// //   });
// //
// //   @override
// //   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// // }
// //
// // class _HomeScreenState extends ConsumerState<HomeScreen>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController pulseController;
// //   late Animation<double> pulseAnimation;
// //
// //   final TextEditingController customerNameController = TextEditingController();
// //   final FocusNode customerNameFocusNode = FocusNode();
// //
// //   Timer? runTimer;
// //   Timer? telemetryTimer;
// //
// //   int runSeconds = 0;
// //   int telemetryFailures = 0;
// //
// //   String? userId;
// //   String? deviceId;
// //   String? deviceName; // ✅ Added deviceName field
// //
// //   bool didSetupDevice = false;
// //   bool isTelemetryLoading = false;
// //   bool noDeviceSnackShown = false;
// //   bool appMotorOn = false;
// //
// //   MotorRunSource runSource = MotorRunSource.none;
// //
// //   bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     pulseController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 850),
// //     )..repeat(reverse: true);
// //
// //     pulseAnimation = Tween<double>(begin: 0.82, end: 1.12).animate(
// //       CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
// //     );
// //   }
// //
// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //
// //     if (didSetupDevice) return;
// //     didSetupDevice = true;
// //
// //     final args = ModalRoute.of(context)?.settings.arguments;
// //
// //     String? parsedDeviceId;
// //     String? parsedDeviceName;
// //     String? parsedUserId;
// //
// //     if (args is Map) {
// //       parsedUserId = args["userId"]?.toString();
// //       parsedDeviceId = args["deviceId"]?.toString();
// //       parsedDeviceName = args["deviceName"]?.toString(); // ✅ Read deviceName from args
// //     }
// //
// //     userId = parsedUserId;
// //
// //     final widgetDeviceId = widget.deviceId?.trim();
// //     deviceId = (parsedDeviceId ?? widgetDeviceId)?.trim();
// //     if (deviceId != null && deviceId!.isEmpty) deviceId = null;
// //
// //     // ✅ Store deviceName from navigation args
// //     deviceName = (parsedDeviceName != null && parsedDeviceName.trim().isNotEmpty)
// //         ? parsedDeviceName.trim()
// //         : null;
// //
// //     if (hasDevice) {
// //       Future.microtask(() async {
// //         await loadTelemetry();
// //         await ref.read(khataViewModelProvider.notifier).loadEntries();
// //       });
// //
// //       telemetryTimer?.cancel();
// //       telemetryTimer = Timer.periodic(
// //         const Duration(seconds: 5),
// //             (_) => loadTelemetry(showError: false),
// //       );
// //     } else {
// //       Future.microtask(() {
// //         if (!mounted || noDeviceSnackShown) return;
// //         noDeviceSnackShown = true;
// //         showMessage("Device not connected. Opened dashboard safely.", false);
// //       });
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     pulseController.dispose();
// //     customerNameController.dispose();
// //     customerNameFocusNode.dispose();
// //     runTimer?.cancel();
// //     telemetryTimer?.cancel();
// //     super.dispose();
// //   }
// //
// //   DeviceConnectionStatus connectionStatus(dynamic latest) {
// //     if (!hasDevice) return DeviceConnectionStatus.noDevice;
// //     if (latest != null && telemetryFailures < 3) {
// //       return DeviceConnectionStatus.connected;
// //     }
// //     if (telemetryFailures >= 3) {
// //       return DeviceConnectionStatus.disconnected;
// //     }
// //     return DeviceConnectionStatus.waitingTelemetry;
// //   }
// //
// //   String friendlyError(String? error) {
// //     final text = (error ?? "").toLowerCase();
// //
// //     if (text.contains("socket") ||
// //         text.contains("connection") ||
// //         text.contains("network") ||
// //         text.contains("internet") ||
// //         text.contains("host lookup") ||
// //         text.contains("timeout") ||
// //         text.contains("receive timeout") ||
// //         text.contains("failed host lookup") ||
// //         text.contains("connection refused") ||
// //         text.contains("connection failed")) {
// //       return "No internet connection. Please check Wi-Fi or mobile data.";
// //     }
// //
// //     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
// //
// //     return error!;
// //   }
// //
// //   Future<void> loadTelemetry({bool showError = false}) async {
// //     if (isTelemetryLoading) return;
// //     if (!hasDevice) return;
// //
// //     isTelemetryLoading = true;
// //
// //     try {
// //       await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);
// //
// //       if (!mounted) return;
// //
// //       final telemetryState = ref.read(telemetryViewModelProvider);
// //
// //       if (telemetryState.latest != null) {
// //         telemetryFailures = 0;
// //       } else if (telemetryState.error != null) {
// //         telemetryFailures++;
// //       }
// //     } catch (_) {
// //       telemetryFailures++;
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           isTelemetryLoading = false;
// //         });
// //       }
// //     }
// //   }
// //
// //   void _startLocalTimer() {
// //     runTimer?.cancel();
// //     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// //       if (mounted) setState(() => runSeconds++);
// //     });
// //   }
// //
// //   void _stopLocalTimer() {
// //     runTimer?.cancel();
// //     runTimer = null;
// //   }
// //
// //   String get runningTime {
// //     final seconds = appMotorOn && runSeconds <= 0 ? 1 : runSeconds;
// //     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
// //     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
// //     final s = (seconds % 60).toString().padLeft(2, "0");
// //     return "$h:$m:$s";
// //   }
// //
// //   String formatValue(
// //       double? value,
// //       String unit, {
// //         int decimals = 1,
// //         required DeviceConnectionStatus status,
// //       }) {
// //     if (status == DeviceConnectionStatus.noDevice) return "-- $unit";
// //     if (value == null) return "-- $unit";
// //     return "${value.toStringAsFixed(decimals)} $unit";
// //   }
// //
// //   Future<void> toggleMotor(MotorSnapshot snapshot) async {
// //     if (!hasDevice) {
// //       showMessage("Device not connected. Please select a device first.", true);
// //       return;
// //     }
// //
// //     FocusScope.of(context).unfocus();
// //     HapticFeedback.mediumImpact();
// //
// //     final typedCustomerName = customerNameController.text.trim();
// //     final customerName =
// //     typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName;
// //     final motorVm = ref.read(motorViewModelProvider.notifier);
// //
// //     try {
// //       if (appMotorOn) {
// //         final stoppedRunSeconds = runSeconds <= 0 ? 1 : runSeconds;
// //
// //         final stoppedLog = await motorVm.stopMotor(
// //           deviceId: deviceId!,
// //           customerName: customerName,
// //         );
// //
// //         final motorState = ref.read(motorViewModelProvider);
// //         if (motorState.error != null) {
// //           showMessage(motorState.error.toString(), true, seconds: 10);
// //           return;
// //         }
// //
// //         _stopLocalTimer();
// //
// //         setState(() {
// //           appMotorOn = false;
// //           runSource = MotorRunSource.none;
// //           runSeconds = 0;
// //         });
// //
// //         if (stoppedLog != null) {
// //           await ref
// //               .read(khataViewModelProvider.notifier)
// //               .createFromMotorLog(
// //             log: stoppedLog,
// //             customerName: customerName,
// //             deviceId: deviceId!,
// //             pricePerHour: 0,
// //             cashReceived: 0,
// //             fallbackRunSeconds: stoppedRunSeconds,
// //           );
// //         }
// //
// //         await loadTelemetry(showError: false);
// //         await ref.read(khataViewModelProvider.notifier).loadEntries();
// //
// //         final khataState = ref.read(khataViewModelProvider);
// //         if (khataState.error != null) {
// //           showMessage(
// //             "Motor stopped, but Khata was not created: ${khataState.error}",
// //             true,
// //             seconds: 12,
// //           );
// //           return;
// //         }
// //
// //         showMessage("Motor stopped. Khata entry created.", false);
// //         return;
// //       }
// //
// //       if (typedCustomerName.isEmpty) {
// //         showMessage("Customer name is required to start motor.", true);
// //         return;
// //       }
// //
// //       await motorVm.startMotor(
// //         deviceId: deviceId!,
// //         customerName: typedCustomerName,
// //       );
// //
// //       final motorState = ref.read(motorViewModelProvider);
// //       if (motorState.error != null) {
// //         showMessage(motorState.error.toString(), true, seconds: 10);
// //         return;
// //       }
// //
// //       setState(() {
// //         appMotorOn = true;
// //         runSource = MotorRunSource.appButton;
// //         runSeconds = 0;
// //       });
// //
// //       _startLocalTimer();
// //       await loadTelemetry(showError: false);
// //
// //       showMessage("Motor started successfully", false);
// //     } catch (e) {
// //       showMessage(
// //         "Motor action failed: ${friendlyError(e.toString())}",
// //         true,
// //         seconds: 12,
// //       );
// //     }
// //   }
// //
// //   void showMessage(String text, bool isError, {int seconds = 6}) {
// //     if (!mounted) return;
// //
// //     ScaffoldMessenger.of(context)
// //       ..clearSnackBars()
// //       ..showSnackBar(
// //         SnackBar(
// //           duration: Duration(seconds: isError ? seconds : 4),
// //           behavior: SnackBarBehavior.floating,
// //           margin: const EdgeInsets.all(16),
// //           shape:
// //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
// //           backgroundColor: isError ? AppColors.error : AppColors.green,
// //           content: Text(
// //             isError ? friendlyError(text) : text,
// //             style: const TextStyle(
// //               color: AppColors.white,
// //               fontWeight: FontWeight.w800,
// //             ),
// //           ),
// //         ),
// //       );
// //   }
// //
// //   List<String> customerSuggestions() {
// //     if (!hasDevice) return <String>[];
// //
// //     final khataState = ref.watch(khataViewModelProvider);
// //     final names = <String>{};
// //
// //     for (final entry in khataState.entries) {
// //       final name = entry.customerName?.trim();
// //       if (name != null && name.isNotEmpty) names.add(name);
// //     }
// //
// //     final list = names.toList();
// //     list.sort();
// //     return list;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final motorState = ref.watch(motorViewModelProvider);
// //     final telemetryState = ref.watch(telemetryViewModelProvider);
// //     final latest = hasDevice ? telemetryState.latest : null;
// //     final status = connectionStatus(latest);
// //
// //     final snapshot = MotorSnapshot.fromAppState(
// //       appMotorOn: hasDevice && appMotorOn,
// //       latest: latest,
// //       runSource: runSource,
// //       status: status,
// //     );
// //
// //     final size = MediaQuery.of(context).size;
// //     final width = size.width;
// //
// //     final isVerySmall = width < 360;
// //     final isTablet = width >= 650;
// //     final isLarge = width >= 1000;
// //
// //     final horizontalPadding = isLarge
// //         ? 38.0
// //         : isTablet
// //         ? 30.0
// //         : 16.0;
// //
// //     final crossAxisCount = isLarge
// //         ? 4
// //         : isTablet
// //         ? 3
// //         : 2;
// //
// //     final childAspectRatio = isLarge
// //         ? 1.36
// //         : isTablet
// //         ? 1.22
// //         : 1.02;
// //
// //     final buttonSize = isLarge
// //         ? 238.0
// //         : isTablet
// //         ? 226.0
// //         : isVerySmall
// //         ? 176.0
// //         : 196.0;
// //
// //     // ✅ Resolved display name: prefer deviceName, fall back to deviceId
// //     final resolvedDisplayName = (deviceName != null && deviceName!.isNotEmpty)
// //         ? deviceName!
// //         : (hasDevice ? deviceId! : "Device not connected");
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.darkBgSoft,
// //       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
// //       appBar: AppBar(
// //         backgroundColor: AppColors.darkSurfaceSoft,
// //         elevation: 0,
// //         centerTitle: true,
// //         iconTheme: const IconThemeData(color: AppColors.white),
// //         title: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(
// //               "SmartWell VFD",
// //               maxLines: 1,
// //               overflow: TextOverflow.ellipsis,
// //               style: TextStyle(
// //                 color: AppColors.white,
// //                 fontSize: isVerySmall ? 18 : 21,
// //                 fontWeight: FontWeight.w900,
// //               ),
// //             ),
// //             const SizedBox(height: 2),
// //             // ✅ AppBar subtitle: show deviceName if available, else deviceId
// //             Text(
// //               resolvedDisplayName,
// //               maxLines: 1,
// //               overflow: TextOverflow.ellipsis,
// //               style: TextStyle(
// //                 color: status == DeviceConnectionStatus.connected
// //                     ? AppColors.primary.withOpacity(0.88)
// //                     : AppColors.warning,
// //                 fontSize: isVerySmall ? 10 : 11,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           IconButton(
// //             tooltip: "Change device",
// //             onPressed: () {
// //               Navigator.pushReplacementNamed(context, AppRoutes.devices);
// //             },
// //             icon: const Icon(Icons.devices_other_rounded),
// //           ),
// //         ],
// //       ),
// //       body: SafeArea(
// //         child: RefreshIndicator(
// //           onRefresh: () async {
// //             if (hasDevice) {
// //               await loadTelemetry();
// //             } else {
// //               showMessage(
// //                   "Device not connected. Please select a device.", true);
// //             }
// //           },
// //           color: AppColors.primary,
// //           backgroundColor: AppColors.surfaceDark,
// //           child: SingleChildScrollView(
// //             physics: const AlwaysScrollableScrollPhysics(
// //                 parent: BouncingScrollPhysics()),
// //             padding: EdgeInsets.symmetric(
// //                 horizontal: horizontalPadding, vertical: 18),
// //             child: Center(
// //               child: ConstrainedBox(
// //                 constraints: const BoxConstraints(maxWidth: 1080),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     // ✅ Pass resolvedDisplayName to VfdHeaderCard
// //                     VfdHeaderCard(
// //                       displayName: resolvedDisplayName,
// //                       snapshot: snapshot,
// //                       frequencyText: formatValue(
// //                         latest?.freq,
// //                         "Hz",
// //                         decimals: 1,
// //                         status: status,
// //                       ),
// //                       referenceFrequencyText: formatValue(
// //                         latest?.referenceFreq ?? latest?.freq,
// //                         "Hz",
// //                         decimals: 1,
// //                         status: status,
// //                       ),
// //                     ),
// //                     if (status == DeviceConnectionStatus.noDevice)
// //                       const Padding(
// //                         padding: EdgeInsets.only(top: 10),
// //                         child: DeviceNotConnectedBadge(),
// //                       ),
// //                     if (status == DeviceConnectionStatus.waitingTelemetry)
// //                       const Padding(
// //                         padding: EdgeInsets.only(top: 10),
// //                         child: WaitingTelemetryBadge(),
// //                       ),
// //                     if (status == DeviceConnectionStatus.disconnected)
// //                       const Padding(
// //                         padding: EdgeInsets.only(top: 10),
// //                         child: DeviceDisconnectedBadge(),
// //                       ),
// //                     const SizedBox(height: 16),
// //                     StatusPanel(
// //                         snapshot: snapshot, pulseAnimation: pulseAnimation),
// //                     const SizedBox(height: 16),
// //                     SystemBanner(snapshot: snapshot),
// //                     if (snapshot.hasFault && !snapshot.hasTelemetryError) ...[
// //                       const SizedBox(height: 14),
// //                       FaultAlertCard(snapshot: snapshot),
// //                     ],
// //                     const SizedBox(height: 18),
// //                     CustomerNameField(
// //                       controller: customerNameController,
// //                       focusNode: customerNameFocusNode,
// //                       suggestions: customerSuggestions(),
// //                       enabled: hasDevice,
// //                     ),
// //                     const SizedBox(height: 26),
// //                     Center(
// //                       child: GestureDetector(
// //                         onTap: motorState.isLoading
// //                             ? null
// //                             : () => toggleMotor(snapshot),
// //                         child: AnimatedBuilder(
// //                           animation: pulseAnimation,
// //                           builder: (context, child) {
// //                             final scale = snapshot.isRunning
// //                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
// //                                 : 1.0;
// //                             return Transform.scale(scale: scale, child: child);
// //                           },
// //                           child: MotorButton(
// //                             snapshot: snapshot,
// //                             loading: hasDevice && motorState.isLoading,
// //                             size: buttonSize,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 18),
// //                     Center(
// //                       child: Text(
// //                         snapshot.isRunning
// //                             ? "${snapshot.runSourceText} | $runningTime"
// //                             : snapshot.centerStatusText,
// //                         textAlign: TextAlign.center,
// //                         style: TextStyle(
// //                           color: AppColors.white.withOpacity(0.76),
// //                           fontSize: isVerySmall ? 14 : 16,
// //                           fontWeight: FontWeight.w700,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 22),
// //                     if (hasDevice &&
// //                         telemetryState.isLoading &&
// //                         latest == null)
// //                       const Padding(
// //                         padding: EdgeInsets.all(22),
// //                         child: Center(
// //                           child: CircularProgressIndicator(
// //                               color: AppColors.white),
// //                         ),
// //                       ),
// //                     const SizedBox(height: 14),
// //                     GridView.count(
// //                       shrinkWrap: true,
// //                       physics: const NeverScrollableScrollPhysics(),
// //                       crossAxisCount: crossAxisCount,
// //                       crossAxisSpacing: 14,
// //                       mainAxisSpacing: 14,
// //                       childAspectRatio: childAspectRatio,
// //                       children: [
// //                         MetricCard(
// //                           icon: Icons.sync_rounded,
// //                           title: "Frequency",
// //                           value: formatValue(latest?.freq, "Hz",
// //                               status: status),
// //                           highlight: true,
// //                         ),
// //                         MetricCard(
// //                           icon: Icons.bolt_rounded,
// //                           title: "Voltage",
// //                           value: formatValue(latest?.voltage, "V",
// //                               status: status),
// //                         ),
// //                         MetricCard(
// //                           icon: Icons.flash_on_rounded,
// //                           title: "Current",
// //                           value: formatValue(latest?.current, "A",
// //                               status: status),
// //                         ),
// //                         MetricCard(
// //                           icon: Icons.power_rounded,
// //                           title: "Power",
// //                           value: formatValue(latest?.power, "kW",
// //                               status: status),
// //                         ),
// //                         MetricCard(
// //                           icon: Icons.speed_rounded,
// //                           title: "Load",
// //                           value: formatValue(latest?.powerPercent, "%",
// //                               status: status),
// //                         ),
// //                         MetricCard(
// //                           icon: Icons.rotate_right_rounded,
// //                           title: "Motor Speed",
// //                           value: formatValue(latest?.motorSpeed, "RPM",
// //                               status: status),
// //                         ),
// //                         MetricCard(
// //                           icon: Icons.battery_charging_full_rounded,
// //                           title: "DC Bus",
// //                           value: formatValue(latest?.dcbus, "V",
// //                               status: status),
// //                         ),
// //                         MetricCard(
// //                           icon: Icons.electric_meter_rounded,
// //                           title: "Energy",
// //                           value: formatValue(latest?.energyIn, "kWh",
// //                               status: status),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 20),
// //                     // ✅ Pass both deviceName and deviceId to DeviceSessionCard
// //                     DeviceSessionCard(
// //                       deviceName: deviceName,
// //                       deviceId: deviceId,
// //                       snapshot: snapshot,
// //                       timestamp: latest?.timestamp,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // MotorSnapshot
// // // ─────────────────────────────────────────────
// //
// // class MotorSnapshot {
// //   final bool isRunning;
// //   final bool hasFault;
// //   final bool hasTelemetryError;
// //   final int? statusCode;
// //   final int? faultCode;
// //   final int? isLive;
// //   final MotorRunSource runSource;
// //   final DeviceConnectionStatus connectionStatus;
// //
// //   const MotorSnapshot({
// //     required this.isRunning,
// //     required this.hasFault,
// //     required this.hasTelemetryError,
// //     required this.statusCode,
// //     required this.faultCode,
// //     required this.isLive,
// //     required this.runSource,
// //     required this.connectionStatus,
// //   });
// //
// //   bool get hasDevice => connectionStatus != DeviceConnectionStatus.noDevice;
// //
// //   factory MotorSnapshot.fromAppState({
// //     required bool appMotorOn,
// //     required dynamic latest,
// //     required MotorRunSource runSource,
// //     required DeviceConnectionStatus status,
// //   }) {
// //     final int? statusCode = latest?.statusCode;
// //     final int? faultCode = latest?.faultCode;
// //     final int? fault = latest?.fault;
// //     final int? isLive = latest?.isLive;
// //
// //     final hasFault = status == DeviceConnectionStatus.connected &&
// //         ((fault ?? 0) == 1 || (faultCode ?? 0) > 0 || statusCode == 4);
// //
// //     final resolvedSource = appMotorOn
// //         ? (runSource == MotorRunSource.none
// //         ? MotorRunSource.appButton
// //         : runSource)
// //         : MotorRunSource.none;
// //
// //     return MotorSnapshot(
// //       isRunning: status == DeviceConnectionStatus.connected && appMotorOn,
// //       hasFault: hasFault,
// //       hasTelemetryError: status == DeviceConnectionStatus.disconnected,
// //       statusCode: latest == null ? null : statusCode,
// //       faultCode: latest == null ? null : faultCode,
// //       isLive: latest == null ? null : isLive,
// //       runSource: resolvedSource,
// //       connectionStatus: status,
// //     );
// //   }
// //
// //   String get statusName {
// //     switch (connectionStatus) {
// //       case DeviceConnectionStatus.noDevice:
// //         return "Device Not Connected";
// //       case DeviceConnectionStatus.waitingTelemetry:
// //         return "Waiting for Telemetry";
// //       case DeviceConnectionStatus.disconnected:
// //         return "Device Disconnected";
// //       case DeviceConnectionStatus.connected:
// //         break;
// //     }
// //
// //     if (hasFault) return "Fault Active";
// //     if (isRunning && statusCode == 1) return "Forward Running";
// //     if (isRunning && statusCode == 2) return "Reverse Running";
// //     if (isRunning) return "VFD Running";
// //     if (statusCode == 3) return "Standby";
// //     if (statusCode == 5) return "VFD Off";
// //     return "System Ready";
// //   }
// //
// //   String get centerStatusText {
// //     switch (connectionStatus) {
// //       case DeviceConnectionStatus.noDevice:
// //         return "Device not connected";
// //       case DeviceConnectionStatus.waitingTelemetry:
// //         return "Waiting for live readings";
// //       case DeviceConnectionStatus.disconnected:
// //         return "Device disconnected";
// //       case DeviceConnectionStatus.connected:
// //         break;
// //     }
// //
// //     if (hasFault) return faultName;
// //     if (isRunning) return runSourceText;
// //     if (statusCode == 5) return "VFD Off";
// //     return "System Ready";
// //   }
// //
// //   String get runSourceText {
// //     if (!isRunning) return "Stopped";
// //     if (runSource == MotorRunSource.appButton) return "Run by App Button";
// //     if (runSource == MotorRunSource.physicalButton) {
// //       return "Run by Physical Button";
// //     }
// //     return "Running";
// //   }
// //
// //   Color get bannerColor {
// //     switch (connectionStatus) {
// //       case DeviceConnectionStatus.noDevice:
// //         return AppColors.warning;
// //       case DeviceConnectionStatus.waitingTelemetry:
// //         return AppColors.primary;
// //       case DeviceConnectionStatus.disconnected:
// //         return AppColors.warning;
// //       case DeviceConnectionStatus.connected:
// //         break;
// //     }
// //
// //     if (hasFault) return AppColors.error;
// //     if (isRunning && runSource == MotorRunSource.physicalButton) {
// //       return AppColors.accent;
// //     }
// //     if (isRunning) return AppColors.green;
// //     if (statusCode == 5) return AppColors.blueDark;
// //     return AppColors.primary;
// //   }
// //
// //   IconData get bannerIcon {
// //     switch (connectionStatus) {
// //       case DeviceConnectionStatus.noDevice:
// //         return Icons.link_off_rounded;
// //       case DeviceConnectionStatus.waitingTelemetry:
// //         return Icons.sync_rounded;
// //       case DeviceConnectionStatus.disconnected:
// //         return Icons.wifi_off_rounded;
// //       case DeviceConnectionStatus.connected:
// //         break;
// //     }
// //
// //     if (hasFault) return Icons.warning_amber_rounded;
// //     if (isRunning && runSource == MotorRunSource.physicalButton) {
// //       return Icons.radio_button_checked_rounded;
// //     }
// //     if (isRunning) return Icons.check_circle_rounded;
// //     if (statusCode == 5) return Icons.power_off_rounded;
// //     return Icons.verified_rounded;
// //   }
// //
// //   String get faultName {
// //     switch (faultCode ?? 0) {
// //       case 0:
// //         return "No Fault";
// //       case 1:
// //         return "OUT1";
// //       case 2:
// //         return "OUT2";
// //       case 3:
// //         return "OUT3";
// //       case 4:
// //         return "OC1";
// //       case 5:
// //         return "OC2";
// //       case 6:
// //         return "OC3";
// //       case 7:
// //         return "OV1";
// //       case 8:
// //         return "OV2";
// //       case 9:
// //         return "OV3";
// //       case 10:
// //         return "UV";
// //       case 11:
// //         return "OL1";
// //       case 12:
// //         return "OL2";
// //       case 13:
// //         return "SPI";
// //       case 14:
// //         return "SPO";
// //       case 15:
// //         return "OH1";
// //       case 16:
// //         return "OH2";
// //       case 17:
// //         return "EF";
// //       case 18:
// //         return "CE";
// //       case 19:
// //         return "ItE";
// //       default:
// //         return "Unknown Fault";
// //     }
// //   }
// //
// //   String get faultDescription {
// //     switch (faultCode ?? 0) {
// //       case 0:
// //         return "Drive operating normally.";
// //       case 1:
// //         return "Output phase fault. Check motor cable, output terminal, or missing motor phase.";
// //       case 2:
// //         return "Output abnormality. Check motor short circuit or output wiring.";
// //       case 3:
// //         return "Output phase imbalance. Check open phase or motor winding damage.";
// //       case 4:
// //         return "Acceleration overcurrent. Check acceleration time, heavy load, or jammed motor.";
// //       case 5:
// //         return "Deceleration overcurrent. Check deceleration time or high inertia load.";
// //       case 6:
// //         return "Constant speed overcurrent. Check mechanical overload or motor current.";
// //       case 7:
// //         return "Acceleration overvoltage. DC bus voltage is too high during acceleration.";
// //       case 8:
// //         return "Deceleration overvoltage. Check fast deceleration or braking resistor.";
// //       case 9:
// //         return "Constant overvoltage. Check supply voltage.";
// //       case 10:
// //         return "Under voltage. Check weak supply or loose input cable.";
// //       case 11:
// //         return "Motor overload. Current stayed too high for long duration.";
// //       case 12:
// //         return "Drive overload. Load may exceed VFD capacity.";
// //       case 13:
// //         return "Internal communication fault.";
// //       case 14:
// //         return "Output protection triggered.";
// //       case 15:
// //         return "Drive overheat. Check cooling fan and ventilation.";
// //       case 16:
// //         return "Motor overheat. Motor thermal protection triggered.";
// //       case 17:
// //         return "External fault. External safety device triggered.";
// //       case 18:
// //         return "Communication error.";
// //       case 19:
// //         return "Current detection error.";
// //       default:
// //         return "Unknown fault code.";
// //     }
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // VfdHeaderCard  ← now takes displayName instead of deviceId
// // // ─────────────────────────────────────────────
// //
// // class VfdHeaderCard extends StatelessWidget {
// //   // ✅ Renamed: receives the already-resolved display name
// //   final String displayName;
// //   final MotorSnapshot snapshot;
// //   final String frequencyText;
// //   final String referenceFrequencyText;
// //
// //   const VfdHeaderCard({
// //     super.key,
// //     required this.displayName,
// //     required this.snapshot,
// //     required this.frequencyText,
// //     required this.referenceFrequencyText,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final width = MediaQuery.of(context).size.width;
// //     final compact = width < 390;
// //
// //     return Container(
// //       padding: EdgeInsets.all(compact ? 15 : 18),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardDark,
// //         borderRadius: BorderRadius.circular(26),
// //         border: Border.all(color: AppColors.borderDark),
// //         boxShadow: [
// //           BoxShadow(
// //             color: AppColors.primary.withOpacity(0.10),
// //             blurRadius: 28,
// //             offset: const Offset(0, 14),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             height: compact ? 54 : 62,
// //             width: compact ? 54 : 62,
// //             decoration: BoxDecoration(
// //               color: snapshot.bannerColor.withOpacity(0.14),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Icon(
// //               snapshot.bannerIcon,
// //               color: snapshot.bannerColor,
// //               size: compact ? 28 : 32,
// //             ),
// //           ),
// //           const SizedBox(width: 14),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // ✅ Uses displayName (deviceName if set, else deviceId)
// //                 Text(
// //                   displayName,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     color: AppColors.white,
// //                     fontSize: compact ? 15 : 17,
// //                     fontWeight: FontWeight.w900,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 6),
// //                 Text(
// //                   snapshot.statusName,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     color: snapshot.bannerColor,
// //                     fontSize: compact ? 12.5 : 14,
// //                     fontWeight: FontWeight.w800,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(width: 10),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               Text(
// //                 "Frequency",
// //                 style: TextStyle(
// //                   color: AppColors.white.withOpacity(0.62),
// //                   fontSize: compact ? 11 : 12,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //               const SizedBox(height: 5),
// //               Text(
// //                 frequencyText,
// //                 style: TextStyle(
// //                   color: AppColors.white,
// //                   fontSize: compact ? 19 : 23,
// //                   fontWeight: FontWeight.w900,
// //                 ),
// //               ),
// //               const SizedBox(height: 4),
// //               Text(
// //                 "Ref $referenceFrequencyText",
// //                 style: TextStyle(
// //                   color: AppColors.white.withOpacity(0.50),
// //                   fontSize: compact ? 10.5 : 12,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // Badge widgets
// // // ─────────────────────────────────────────────
// //
// // class DeviceNotConnectedBadge extends StatelessWidget {
// //   const DeviceNotConnectedBadge({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return _InfoBadge(
// //       icon: Icons.link_off_rounded,
// //       color: AppColors.warning,
// //       text: "Device not connected. Select a device to view live parameters.",
// //     );
// //   }
// // }
// //
// // class WaitingTelemetryBadge extends StatelessWidget {
// //   const WaitingTelemetryBadge({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return _InfoBadge(
// //       icon: Icons.sync_rounded,
// //       color: AppColors.primary,
// //       text: "Device selected. Waiting for latest telemetry values.",
// //     );
// //   }
// // }
// //
// // class DeviceDisconnectedBadge extends StatelessWidget {
// //   const DeviceDisconnectedBadge({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return _InfoBadge(
// //       icon: Icons.wifi_off_rounded,
// //       color: AppColors.warning,
// //       text:
// //       "Device disconnected. Showing last received values when available.",
// //     );
// //   }
// // }
// //
// // class _InfoBadge extends StatelessWidget {
// //   final IconData icon;
// //   final Color color;
// //   final String text;
// //
// //   const _InfoBadge({
// //     required this.icon,
// //     required this.color,
// //     required this.text,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.12),
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: color, size: 18),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: TextStyle(
// //                 color: AppColors.white.withOpacity(0.85),
// //                 fontWeight: FontWeight.w700,
// //                 fontSize: 12.5,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // StatusPanel & StatusDot
// // // ─────────────────────────────────────────────
// //
// // class StatusPanel extends StatelessWidget {
// //   final MotorSnapshot snapshot;
// //   final Animation<double> pulseAnimation;
// //
// //   const StatusPanel({
// //     super.key,
// //     required this.snapshot,
// //     required this.pulseAnimation,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final phaseOk =
// //         snapshot.connectionStatus == DeviceConnectionStatus.connected;
// //     final motorOk = snapshot.isRunning;
// //     final tripOk = !snapshot.hasFault;
// //     final serviceOk =
// //         snapshot.connectionStatus == DeviceConnectionStatus.connected;
// //
// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardDark,
// //         borderRadius: BorderRadius.circular(24),
// //         border: Border.all(color: AppColors.borderDark),
// //       ),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: StatusDot(
// //               title: "Phase",
// //               ok: phaseOk,
// //               blinking: false,
// //               pulseAnimation: pulseAnimation,
// //             ),
// //           ),
// //           Expanded(
// //             child: StatusDot(
// //               title: "Motor",
// //               ok: motorOk,
// //               blinking: false,
// //               pulseAnimation: pulseAnimation,
// //             ),
// //           ),
// //           Expanded(
// //             child: StatusDot(
// //               title: "Trip",
// //               ok: tripOk,
// //               blinking: snapshot.hasFault,
// //               pulseAnimation: pulseAnimation,
// //             ),
// //           ),
// //           Expanded(
// //             child: StatusDot(
// //               title: "Service",
// //               ok: serviceOk,
// //               blinking: snapshot.connectionStatus ==
// //                   DeviceConnectionStatus.disconnected,
// //               pulseAnimation: pulseAnimation,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class StatusDot extends StatelessWidget {
// //   final String title;
// //   final bool ok;
// //   final bool blinking;
// //   final Animation<double> pulseAnimation;
// //
// //   const StatusDot({
// //     super.key,
// //     required this.title,
// //     required this.ok,
// //     required this.blinking,
// //     required this.pulseAnimation,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final width = MediaQuery.of(context).size.width;
// //     final dotSize = width < 360 ? 40.0 : 48.0;
// //     final baseColor = ok ? AppColors.green : AppColors.error;
// //
// //     return AnimatedBuilder(
// //       animation: pulseAnimation,
// //       builder: (context, child) {
// //         final scale = blinking ? pulseAnimation.value : 1.0;
// //         final opacity =
// //         blinking ? (0.55 + (pulseAnimation.value - 0.82)) : 1.0;
// //
// //         return Column(
// //           children: [
// //             Transform.scale(
// //               scale: scale,
// //               child: Opacity(
// //                 opacity: opacity.clamp(0.45, 1.0),
// //                 child: Container(
// //                   height: dotSize,
// //                   width: dotSize,
// //                   decoration: BoxDecoration(
// //                     color: baseColor,
// //                     shape: BoxShape.circle,
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: baseColor.withOpacity(0.42),
// //                         blurRadius: blinking ? 28 : 18,
// //                         spreadRadius: blinking ? 4 : 2,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             FittedBox(
// //               child: Text(
// //                 title,
// //                 style: TextStyle(
// //                   color: AppColors.white.withOpacity(0.7),
// //                   fontSize: width < 360 ? 12 : 14,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // SystemBanner
// // // ─────────────────────────────────────────────
// //
// // class SystemBanner extends StatelessWidget {
// //   final MotorSnapshot snapshot;
// //
// //   const SystemBanner({super.key, required this.snapshot});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final width = MediaQuery.of(context).size.width;
// //
// //     final text = snapshot.hasFault
// //         ? "${snapshot.faultName} Fault"
// //         : snapshot.isRunning
// //         ? snapshot.runSourceText
// //         : snapshot.statusName;
// //
// //     final foregroundColor = snapshot.bannerColor == AppColors.primary
// //         ? AppColors.black
// //         : AppColors.white;
// //
// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.symmetric(
// //         vertical: width < 360 ? 14 : 16,
// //         horizontal: 18,
// //       ),
// //       decoration: BoxDecoration(
// //         color: snapshot.bannerColor,
// //         borderRadius: BorderRadius.circular(22),
// //         boxShadow: [
// //           BoxShadow(
// //             color: snapshot.bannerColor.withOpacity(0.22),
// //             blurRadius: 20,
// //             offset: const Offset(0, 10),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(snapshot.bannerIcon,
// //               color: foregroundColor, size: width < 360 ? 24 : 27),
// //           const SizedBox(width: 10),
// //           Flexible(
// //             child: Text(
// //               text,
// //               overflow: TextOverflow.ellipsis,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 color: foregroundColor,
// //                 fontSize: width < 360 ? 16 : 19,
// //                 fontWeight: FontWeight.w900,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // FaultAlertCard
// // // ─────────────────────────────────────────────
// //
// // class FaultAlertCard extends StatelessWidget {
// //   final MotorSnapshot snapshot;
// //
// //   const FaultAlertCard({super.key, required this.snapshot});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(17),
// //       decoration: BoxDecoration(
// //         color: AppColors.error.withOpacity(0.14),
// //         borderRadius: BorderRadius.circular(22),
// //         border: Border.all(color: AppColors.error.withOpacity(0.38)),
// //       ),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Icon(Icons.warning_amber_rounded,
// //               color: AppColors.error, size: 30),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   snapshot.faultName,
// //                   style: const TextStyle(
// //                     color: AppColors.error,
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.w900,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 5),
// //                 Text(
// //                   snapshot.faultDescription,
// //                   style: TextStyle(
// //                     color: AppColors.white.withOpacity(0.78),
// //                     fontSize: 13.5,
// //                     height: 1.35,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // CustomerNameField
// // // ─────────────────────────────────────────────
// //
// // class CustomerNameField extends StatelessWidget {
// //   final TextEditingController controller;
// //   final FocusNode focusNode;
// //   final List<String> suggestions;
// //   final bool enabled;
// //
// //   const CustomerNameField({
// //     super.key,
// //     required this.controller,
// //     required this.focusNode,
// //     required this.suggestions,
// //     required this.enabled,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return RawAutocomplete<String>(
// //       textEditingController: controller,
// //       focusNode: focusNode,
// //       optionsBuilder: (TextEditingValue value) {
// //         if (!enabled) return const Iterable<String>.empty();
// //
// //         final input = value.text.trim().toLowerCase();
// //         if (input.isEmpty) return const Iterable<String>.empty();
// //
// //         return suggestions.where((name) => name.toLowerCase().contains(input));
// //       },
// //       onSelected: (String value) {
// //         controller.text = value;
// //         controller.selection = TextSelection.fromPosition(
// //           TextPosition(offset: controller.text.length),
// //         );
// //       },
// //       fieldViewBuilder:
// //           (context, textEditingController, fieldFocusNode, onFieldSubmitted) {
// //         return Container(
// //           decoration: BoxDecoration(
// //             color: AppColors.cardDark,
// //             borderRadius: BorderRadius.circular(22),
// //             border: Border.all(color: AppColors.borderDark),
// //           ),
// //           child: TextField(
// //             enabled: enabled,
// //             controller: textEditingController,
// //             focusNode: fieldFocusNode,
// //             keyboardType: TextInputType.text,
// //             style: const TextStyle(
// //                 color: AppColors.white, fontWeight: FontWeight.w700),
// //             textInputAction: TextInputAction.done,
// //             decoration: InputDecoration(
// //               hintText:
// //               enabled ? "Customer name for Khata" : "Select a device first",
// //               hintStyle:
// //               TextStyle(color: AppColors.white.withOpacity(0.42)),
// //               prefixIcon: Icon(
// //                 enabled
// //                     ? Icons.person_outline_rounded
// //                     : Icons.lock_outline_rounded,
// //                 color: AppColors.primary,
// //               ),
// //               suffixIcon: suggestions.isEmpty || !enabled
// //                   ? null
// //                   : Icon(Icons.manage_search_rounded,
// //                   color: AppColors.white.withOpacity(0.45)),
// //               border: InputBorder.none,
// //               contentPadding:
// //               const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
// //             ),
// //           ),
// //         );
// //       },
// //       optionsViewBuilder: (context, onSelected, options) {
// //         return Align(
// //           alignment: Alignment.topLeft,
// //           child: Material(
// //             color: Colors.transparent,
// //             child: Container(
// //               width: MediaQuery.of(context).size.width - 36,
// //               constraints:
// //               const BoxConstraints(maxHeight: 240, maxWidth: 560),
// //               margin: const EdgeInsets.only(top: 8),
// //               decoration: BoxDecoration(
// //                 color: AppColors.cardDark,
// //                 borderRadius: BorderRadius.circular(18),
// //                 border: Border.all(color: AppColors.borderDark),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.34),
// //                     blurRadius: 22,
// //                     offset: const Offset(0, 12),
// //                   ),
// //                 ],
// //               ),
// //               child: ListView.separated(
// //                 padding: const EdgeInsets.symmetric(vertical: 6),
// //                 shrinkWrap: true,
// //                 itemCount: options.length,
// //                 separatorBuilder: (_, __) {
// //                   return Divider(
// //                       height: 1, color: AppColors.white.withOpacity(0.06));
// //                 },
// //                 itemBuilder: (context, index) {
// //                   final option = options.elementAt(index);
// //                   return ListTile(
// //                     dense: true,
// //                     leading:
// //                     const Icon(Icons.person_rounded, color: AppColors.primary),
// //                     title: Text(
// //                       option,
// //                       style: const TextStyle(
// //                           color: AppColors.white, fontWeight: FontWeight.w800),
// //                     ),
// //                     onTap: () => onSelected(option),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // MotorButton
// // // ─────────────────────────────────────────────
// //
// // class MotorButton extends StatelessWidget {
// //   final MotorSnapshot snapshot;
// //   final bool loading;
// //   final double size;
// //
// //   const MotorButton({
// //     super.key,
// //     required this.snapshot,
// //     required this.loading,
// //     required this.size,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final activeColor =
// //     snapshot.connectionStatus == DeviceConnectionStatus.noDevice
// //         ? AppColors.warning
// //         : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
// //         ? AppColors.warning
// //         : snapshot.hasFault
// //         ? AppColors.error
// //         : snapshot.isRunning
// //         ? AppColors.green
// //         : AppColors.error;
// //
// //     final label =
// //     snapshot.connectionStatus == DeviceConnectionStatus.noDevice
// //         ? "N/A"
// //         : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
// //         ? "OFFLINE"
// //         : snapshot.hasFault
// //         ? "FAULT"
// //         : snapshot.isRunning
// //         ? "ON"
// //         : "OFF";
// //
// //     return AnimatedContainer(
// //       duration: const Duration(milliseconds: 300),
// //       width: size,
// //       height: size,
// //       alignment: Alignment.center,
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle,
// //         gradient: LinearGradient(
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //           colors: [activeColor, activeColor.withOpacity(0.72)],
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: activeColor.withOpacity(0.34),
// //             blurRadius: 34,
// //             offset: const Offset(0, 16),
// //           ),
// //         ],
// //       ),
// //       child: loading
// //           ? const CircularProgressIndicator(color: AppColors.white)
// //           : Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Icon(snapshot.bannerIcon,
// //               color: AppColors.white, size: size < 190 ? 36 : 42),
// //           const SizedBox(height: 8),
// //           FittedBox(
// //             child: Text(
// //               label,
// //               style: TextStyle(
// //                 color: AppColors.white,
// //                 fontSize:
// //                 label == "OFFLINE" ? 22 : size < 190 ? 26 : 36,
// //                 fontWeight: FontWeight.w900,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // MetricCard
// // // ─────────────────────────────────────────────
// //
// // class MetricCard extends StatelessWidget {
// //   final IconData icon;
// //   final String title;
// //   final String value;
// //   final bool highlight;
// //
// //   const MetricCard({
// //     super.key,
// //     required this.icon,
// //     required this.title,
// //     required this.value,
// //     this.highlight = false,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final width = MediaQuery.of(context).size.width;
// //     final compact = width < 360;
// //
// //     return Container(
// //       padding: EdgeInsets.all(compact ? 13 : 17),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardDark,
// //         borderRadius: BorderRadius.circular(22),
// //         border: Border.all(
// //           color: highlight
// //               ? AppColors.primary.withOpacity(0.38)
// //               : AppColors.borderDark,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: AppColors.shadowDark.withOpacity(0.26),
// //             blurRadius: 18,
// //             offset: const Offset(0, 9),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Icon(
// //             icon,
// //             color:
// //             highlight ? AppColors.primary : AppColors.iconInactiveDark,
// //             size: compact ? 24 : 28,
// //           ),
// //           const Spacer(),
// //           Text(
// //             title,
// //             maxLines: 1,
// //             overflow: TextOverflow.ellipsis,
// //             style: TextStyle(
// //               color: AppColors.white.withOpacity(0.62),
// //               fontSize: compact ? 12.5 : 14,
// //               fontWeight: FontWeight.w700,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           FittedBox(
// //             alignment: Alignment.centerLeft,
// //             fit: BoxFit.scaleDown,
// //             child: Text(
// //               value,
// //               style: TextStyle(
// //                 color: AppColors.white,
// //                 height: 1.25,
// //                 fontSize: compact ? 17 : 20,
// //                 fontWeight: FontWeight.w900,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────
// // // DeviceSessionCard  ← updated to show deviceName + deviceId
// // // ─────────────────────────────────────────────
// //
// // class DeviceSessionCard extends StatelessWidget {
// //   final String? deviceName; // ✅ Human-readable name (e.g. "My Farm Pump")
// //   final String? deviceId;   // ✅ Raw UUID shown as secondary info
// //   final MotorSnapshot snapshot;
// //   final int? timestamp;
// //
// //   const DeviceSessionCard({
// //     super.key,
// //     required this.deviceName,
// //     required this.deviceId,
// //     required this.snapshot,
// //     required this.timestamp,
// //   });
// //
// //   /// Shows first 8 chars of UUID in uppercase for compact display
// //   String shortId(String? id) {
// //     if (id == null || id.length < 8) return "-";
// //     return id.substring(0, 8).toUpperCase();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final liveText = snapshot.statusName;
// //     final liveColor = snapshot.bannerColor;
// //
// //     // ✅ Prefer deviceName; fall back to deviceId; show "Not Connected" if neither
// //     final displayName = (deviceName != null && deviceName!.trim().isNotEmpty)
// //         ? deviceName!
// //         : snapshot.hasDevice
// //         ? "SmartWell VFD"
// //         : "Not Connected";
// //
// //     return Container(
// //       width: double.infinity,
// //       padding: const EdgeInsets.all(18),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardDark,
// //         borderRadius: BorderRadius.circular(22),
// //         border: Border.all(color: AppColors.borderDark),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             "Device Session",
// //             style: TextStyle(
// //               color: AppColors.white,
// //               fontSize: 18,
// //               fontWeight: FontWeight.w900,
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           Row(
// //             children: [
// //               Container(
// //                 height: 10,
// //                 width: 10,
// //                 decoration: BoxDecoration(
// //                   color: liveColor,
// //                   shape: BoxShape.circle,
// //                 ),
// //               ),
// //               const SizedBox(width: 8),
// //               Expanded(
// //                 child: Text(
// //                   liveText,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     color: liveColor,
// //                     fontWeight: FontWeight.w900,
// //                   ),
// //                 ),
// //               ),
// //               Text(
// //                 "Code ${snapshot.statusCode ?? "-"}",
// //                 style: TextStyle(
// //                   color: AppColors.white.withOpacity(0.56),
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 14),
// //           // ✅ Shows human-readable Device Name
// //           Text(
// //             "Device Name: $deviceId",
// //             style: TextStyle(
// //               color: AppColors.white.withOpacity(0.82),
// //               fontWeight: FontWeight.w700,
// //               fontSize: 14,
// //             ),
// //           ),
// //           const SizedBox(height: 6),
// //           // ✅ Shows shortened Device ID as secondary reference
// //
// //           const SizedBox(height: 6),
// //           const SizedBox(height: 6),
// //           Text(
// //             "Timestamp: ${_formatTimestamp(timestamp)}",
// //             style: TextStyle(
// //               color: AppColors.white.withOpacity(0.62),
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //
// //         ],
// //       ),
// //     );
// //   }
// //
// //   String _formatTimestamp(int? timestamp) {
// //     if (timestamp == null) return "-";
// //
// //     final dateTime =
// //     DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
// //
// //     // Always show exact time (professional IoT style)
// //     return DateFormat("dd MMM yyyy, HH:mm:ss").format(dateTime);
// //   }
// // }
//
// import "dart:async";
//
// import "package:flutter/material.dart";
// import "package:flutter/services.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:intl/intl.dart";
//
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
//
// import "../../../../app/routes.dart";
// import "../../../khata/presentation/providers/ khata_providers.dart";
// import "../../../motor/presentation/ providers/motor_providers.dart";
// import "../../../telemetry/presentation/providers/telemetry_providers.dart";
//
// enum DeviceConnectionStatus {
//   noDevice,
//   waitingTelemetry,
//   connected,
//   disconnected,
// }
//
// class HomeScreen extends ConsumerStatefulWidget {
//   final String? deviceId;
//
//   const HomeScreen({
//     super.key,
//     this.deviceId,
//   });
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController pulseController;
//   late Animation<double> pulseAnimation;
//
//   final TextEditingController customerNameController = TextEditingController();
//   final FocusNode customerNameFocusNode = FocusNode();
//
//   Timer? runTimer;
//   Timer? telemetryTimer;
//
//   int runSeconds = 0;
//   int telemetryFailures = 0;
//
//   String? userId;
//   String? deviceId;
//   String? deviceName;
//
//   bool didSetupDevice = false;
//   bool isTelemetryLoading = false;
//   bool noDeviceSnackShown = false;
//
//   bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;
//
//   @override
//   void initState() {
//     super.initState();
//
//     pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 850),
//     )..repeat(reverse: true);
//
//     pulseAnimation = Tween<double>(begin: 0.82, end: 1.12).animate(
//       CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//
//     if (didSetupDevice) return;
//     didSetupDevice = true;
//
//     final args = ModalRoute.of(context)?.settings.arguments;
//
//     if (args is Map) {
//       userId = args["userId"]?.toString();
//
//       final rawDeviceId = args["deviceId"]?.toString();
//       deviceId = rawDeviceId == null || rawDeviceId.trim().isEmpty
//           ? null
//           : rawDeviceId.trim();
//
//       final rawDeviceName = args["deviceName"]?.toString();
//       deviceName = rawDeviceName == null || rawDeviceName.trim().isEmpty
//           ? null
//           : rawDeviceName.trim();
//     }
//
//     final widgetDeviceId = widget.deviceId?.trim();
//     deviceId ??= widgetDeviceId == null || widgetDeviceId.isEmpty
//         ? null
//         : widgetDeviceId;
//
//     if (hasDevice) {
//       Future.microtask(() async {
//         await loadTelemetry();
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//       });
//
//       telemetryTimer?.cancel();
//       telemetryTimer = Timer.periodic(
//         const Duration(seconds: 5),
//             (_) => loadTelemetry(showError: false),
//       );
//     } else {
//       Future.microtask(() {
//         if (!mounted || noDeviceSnackShown) return;
//         noDeviceSnackShown = true;
//         showMessage("Device not connected. Opened dashboard safely.", false);
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     pulseController.dispose();
//     customerNameController.dispose();
//     customerNameFocusNode.dispose();
//     runTimer?.cancel();
//     telemetryTimer?.cancel();
//     super.dispose();
//   }
//
//   DeviceConnectionStatus connectionStatus(dynamic latest) {
//     if (!hasDevice) return DeviceConnectionStatus.noDevice;
//
//     if (latest != null && telemetryFailures < 3) {
//       return DeviceConnectionStatus.connected;
//     }
//
//     if (telemetryFailures >= 3) {
//       return DeviceConnectionStatus.disconnected;
//     }
//
//     return DeviceConnectionStatus.waitingTelemetry;
//   }
//
//   String friendlyError(String? error) {
//     final text = (error ?? "").toLowerCase();
//
//     if (text.contains("socket") ||
//         text.contains("connection") ||
//         text.contains("network") ||
//         text.contains("internet") ||
//         text.contains("host lookup") ||
//         text.contains("timeout") ||
//         text.contains("receive timeout") ||
//         text.contains("failed host lookup") ||
//         text.contains("connection refused") ||
//         text.contains("connection failed")) {
//       return "No internet connection. Please check Wi-Fi or mobile data.";
//     }
//
//     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
//
//     return error!;
//   }
//
//   Future<void> loadTelemetry({bool showError = false}) async {
//     if (isTelemetryLoading) return;
//     if (!hasDevice) return;
//
//     isTelemetryLoading = true;
//
//     try {
//       await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);
//
//       if (!mounted) return;
//
//       final telemetryState = ref.read(telemetryViewModelProvider);
//
//       if (telemetryState.latest != null) {
//         telemetryFailures = 0;
//       } else if (telemetryState.error != null) {
//         telemetryFailures++;
//       }
//     } catch (_) {
//       telemetryFailures++;
//     } finally {
//       if (mounted) {
//         setState(() {
//           isTelemetryLoading = false;
//         });
//       }
//     }
//   }
//
//   void _startLocalTimer() {
//     runTimer?.cancel();
//     runSeconds = 0;
//
//     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted) {
//         setState(() {
//           runSeconds++;
//         });
//       }
//     });
//   }
//
//   void _stopLocalTimer() {
//     runTimer?.cancel();
//     runTimer = null;
//     runSeconds = 0;
//   }
//
//   String get runningTime {
//     final seconds = runSeconds <= 0 ? 1 : runSeconds;
//     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
//     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
//     final s = (seconds % 60).toString().padLeft(2, "0");
//     return "$h:$m:$s";
//   }
//
//   String formatValue(
//       double? value,
//       String unit, {
//         int decimals = 1,
//         required DeviceConnectionStatus status,
//       }) {
//     if (status == DeviceConnectionStatus.noDevice) return "-- $unit";
//     if (value == null) return "-- $unit";
//     return "${value.toStringAsFixed(decimals)} $unit";
//   }
//
//   Future<void> toggleMotor(MotorSnapshot snapshot) async {
//     if (!hasDevice) {
//       showMessage("Device not connected. Please select a device first.", true);
//       return;
//     }
//
//     FocusScope.of(context).unfocus();
//     HapticFeedback.mediumImpact();
//
//     final typedCustomerName = customerNameController.text.trim();
//     final customerName =
//     typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName;
//
//     final motorVm = ref.read(motorViewModelProvider.notifier);
//
//     try {
//       if (snapshot.isRunning) {
//         final stoppedRunSeconds = runSeconds <= 0 ? 1 : runSeconds;
//
//         final stoppedLog = await motorVm.stopMotor(
//           deviceId: deviceId!,
//           customerName: customerName,
//         );
//
//         final motorState = ref.read(motorViewModelProvider);
//         if (motorState.error != null) {
//           showMessage(motorState.error.toString(), true, seconds: 10);
//           return;
//         }
//
//         _stopLocalTimer();
//
//         if (stoppedLog != null) {
//           await ref.read(khataViewModelProvider.notifier).createFromMotorLog(
//             log: stoppedLog,
//             customerName: customerName,
//             deviceId: deviceId!,
//             pricePerHour: 0,
//             cashReceived: 0,
//             fallbackRunSeconds: stoppedRunSeconds,
//           );
//         }
//
//         await loadTelemetry(showError: false);
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         final khataState = ref.read(khataViewModelProvider);
//         if (khataState.error != null) {
//           showMessage(
//             "Motor stopped, but Khata was not created: ${khataState.error}",
//             true,
//             seconds: 12,
//           );
//           return;
//         }
//
//         showMessage("Motor stopped. Khata entry created.", false);
//         return;
//       }
//
//       if (typedCustomerName.isEmpty) {
//         showMessage("Customer name is required to start motor.", true);
//         return;
//       }
//
//       await motorVm.startMotor(
//         deviceId: deviceId!,
//         customerName: typedCustomerName,
//       );
//
//       final motorState = ref.read(motorViewModelProvider);
//       if (motorState.error != null) {
//         showMessage(motorState.error.toString(), true, seconds: 10);
//         return;
//       }
//
//       _startLocalTimer();
//
//       await loadTelemetry(showError: false);
//
//       showMessage("Motor started successfully", false);
//     } catch (e) {
//       showMessage(
//         "Motor action failed: ${friendlyError(e.toString())}",
//         true,
//         seconds: 12,
//       );
//     }
//   }
//
//   void showMessage(String text, bool isError, {int seconds = 6}) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(
//         SnackBar(
//           duration: Duration(seconds: isError ? seconds : 4),
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           backgroundColor: isError ? AppColors.error : AppColors.green,
//           content: Text(
//             isError ? friendlyError(text) : text,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//       );
//   }
//
//   List<String> customerSuggestions() {
//     if (!hasDevice) return <String>[];
//
//     final khataState = ref.watch(khataViewModelProvider);
//     final names = <String>{};
//
//     for (final entry in khataState.entries) {
//       final name = entry.customerName?.trim();
//       if (name != null && name.isNotEmpty) names.add(name);
//     }
//
//     final list = names.toList();
//     list.sort();
//     return list;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final motorState = ref.watch(motorViewModelProvider);
//     final telemetryState = ref.watch(telemetryViewModelProvider);
//     final latest = hasDevice ? telemetryState.latest : null;
//     final status = connectionStatus(latest);
//
//     final snapshot = MotorSnapshot.fromTelemetry(
//       latest: latest,
//       status: status,
//     );
//
//     if (snapshot.isRunning && runTimer == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer == null) _startLocalTimer();
//       });
//     }
//
//     if (!snapshot.isRunning && runTimer != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer != null) _stopLocalTimer();
//       });
//     }
//
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//
//     final isVerySmall = width < 360;
//     final isTablet = width >= 650;
//     final isLarge = width >= 1000;
//
//     final horizontalPadding = isLarge
//         ? 38.0
//         : isTablet
//         ? 30.0
//         : 16.0;
//
//     final crossAxisCount = isLarge
//         ? 4
//         : isTablet
//         ? 3
//         : 2;
//
//     final childAspectRatio = isLarge
//         ? 1.36
//         : isTablet
//         ? 1.22
//         : 1.02;
//
//     final buttonSize = isLarge
//         ? 238.0
//         : isTablet
//         ? 226.0
//         : isVerySmall
//         ? 176.0
//         : 196.0;
//
//     final resolvedDisplayName = deviceName != null && deviceName!.isNotEmpty
//         ? deviceName!
//         : hasDevice
//         ? deviceId!
//         : "Device not connected";
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
//       appBar: AppBar(
//         backgroundColor: AppColors.darkSurfaceSoft,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: AppColors.white),
//         title: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               "SmartWell VFD",
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: isVerySmall ? 18 : 21,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               resolvedDisplayName,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: status == DeviceConnectionStatus.connected
//                     ? AppColors.primary.withOpacity(0.88)
//                     : AppColors.warning,
//                 fontSize: isVerySmall ? 10 : 11,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             tooltip: "Change device",
//             onPressed: () {
//               Navigator.pushReplacementNamed(context, AppRoutes.devices);
//             },
//             icon: const Icon(Icons.devices_other_rounded),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             if (hasDevice) {
//               await loadTelemetry();
//             } else {
//               showMessage("Device not connected. Please select a device.", true);
//             }
//           },
//           color: AppColors.primary,
//           backgroundColor: AppColors.surfaceDark,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(
//               parent: BouncingScrollPhysics(),
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: horizontalPadding,
//               vertical: 18,
//             ),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 1080),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     VfdHeaderCard(
//                       displayName: resolvedDisplayName,
//                       snapshot: snapshot,
//                       frequencyText: formatValue(
//                         latest?.freq,
//                         "Hz",
//                         decimals: 1,
//                         status: status,
//                       ),
//                       referenceFrequencyText: formatValue(
//                         latest?.referenceFreq ?? latest?.freq,
//                         "Hz",
//                         decimals: 1,
//                         status: status,
//                       ),
//                     ),
//                     if (status == DeviceConnectionStatus.noDevice)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 10),
//                         child: DeviceNotConnectedBadge(),
//                       ),
//                     if (status == DeviceConnectionStatus.waitingTelemetry)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 10),
//                         child: WaitingTelemetryBadge(),
//                       ),
//                     if (status == DeviceConnectionStatus.disconnected)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 10),
//                         child: DeviceDisconnectedBadge(),
//                       ),
//                     const SizedBox(height: 16),
//                     StatusPanel(
//                       snapshot: snapshot,
//                       pulseAnimation: pulseAnimation,
//                     ),
//                     const SizedBox(height: 16),
//                     SystemBanner(snapshot: snapshot),
//                     if (snapshot.hasFault && !snapshot.hasTelemetryError) ...[
//                       const SizedBox(height: 14),
//                       FaultAlertCard(snapshot: snapshot),
//                     ],
//                     const SizedBox(height: 18),
//                     CustomerNameField(
//                       controller: customerNameController,
//                       focusNode: customerNameFocusNode,
//                       suggestions: customerSuggestions(),
//                       enabled: hasDevice,
//                     ),
//                     const SizedBox(height: 26),
//                     Center(
//                       child: GestureDetector(
//                         onTap: motorState.isLoading
//                             ? null
//                             : () => toggleMotor(snapshot),
//                         child: AnimatedBuilder(
//                           animation: pulseAnimation,
//                           builder: (context, child) {
//                             final scale = snapshot.isRunning
//                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
//                                 : 1.0;
//                             return Transform.scale(
//                               scale: scale,
//                               child: child,
//                             );
//                           },
//                           child: MotorButton(
//                             snapshot: snapshot,
//                             loading: hasDevice && motorState.isLoading,
//                             size: buttonSize,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     Center(
//                       child: Text(
//                         snapshot.isRunning
//                             ? "Running | $runningTime"
//                             : snapshot.centerStatusText,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: AppColors.white.withOpacity(0.76),
//                           fontSize: isVerySmall ? 14 : 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 22),
//                     if (hasDevice && telemetryState.isLoading && latest == null)
//                       const Padding(
//                         padding: EdgeInsets.all(22),
//                         child: Center(
//                           child: CircularProgressIndicator(
//                             color: AppColors.white,
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 14),
//                     GridView.count(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       crossAxisCount: crossAxisCount,
//                       crossAxisSpacing: 14,
//                       mainAxisSpacing: 14,
//                       childAspectRatio: childAspectRatio,
//                       children: [
//                         MetricCard(
//                           icon: Icons.sync_rounded,
//                           title: "Frequency",
//                           value: formatValue(
//                             latest?.freq,
//                             "Hz",
//                             status: status,
//                           ),
//                           highlight: true,
//                         ),
//                         MetricCard(
//                           icon: Icons.bolt_rounded,
//                           title: "Voltage",
//                           value: formatValue(
//                             latest?.voltage,
//                             "V",
//                             status: status,
//                           ),
//                         ),
//                         MetricCard(
//                           icon: Icons.flash_on_rounded,
//                           title: "Current",
//                           value: formatValue(
//                             latest?.current,
//                             "A",
//                             status: status,
//                           ),
//                         ),
//                         MetricCard(
//                           icon: Icons.power_rounded,
//                           title: "Power",
//                           value: formatValue(
//                             latest?.power,
//                             "kW",
//                             status: status,
//                           ),
//                         ),
//                         MetricCard(
//                           icon: Icons.speed_rounded,
//                           title: "Load",
//                           value: formatValue(
//                             latest?.powerPercent,
//                             "%",
//                             status: status,
//                           ),
//                         ),
//                         MetricCard(
//                           icon: Icons.rotate_right_rounded,
//                           title: "Motor Speed",
//                           value: formatValue(
//                             latest?.motorSpeed,
//                             "RPM",
//                             status: status,
//                           ),
//                         ),
//                         MetricCard(
//                           icon: Icons.battery_charging_full_rounded,
//                           title: "DC Bus",
//                           value: formatValue(
//                             latest?.dcbus,
//                             "V",
//                             status: status,
//                           ),
//                         ),
//                         MetricCard(
//                           icon: Icons.electric_meter_rounded,
//                           title: "Energy",
//                           value: formatValue(
//                             latest?.energyIn,
//                             "kWh",
//                             status: status,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     DeviceSessionCard(
//                       deviceName: deviceName,
//                       deviceId: deviceId,
//                       snapshot: snapshot,
//                       timestamp: latest?.timestamp,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MotorSnapshot {
//   final bool isRunning;
//   final bool hasFault;
//   final bool hasTelemetryError;
//   final int? statusCode;
//   final int? faultCode;
//   final int? isLive;
//   final DeviceConnectionStatus connectionStatus;
//
//   const MotorSnapshot({
//     required this.isRunning,
//     required this.hasFault,
//     required this.hasTelemetryError,
//     required this.statusCode,
//     required this.faultCode,
//     required this.isLive,
//     required this.connectionStatus,
//   });
//
//   bool get hasDevice => connectionStatus != DeviceConnectionStatus.noDevice;
//
//   factory MotorSnapshot.fromTelemetry({
//     required dynamic latest,
//     required DeviceConnectionStatus status,
//   }) {
//     final int? statusCode = latest?.statusCode;
//     final int? faultCode = latest?.faultCode;
//     final int? fault = latest?.fault;
//     final int? isLive = latest?.isLive;
//
//     final hasFault = status == DeviceConnectionStatus.connected &&
//         ((fault ?? 0) == 1 || (faultCode ?? 0) > 0 || statusCode == 4);
//
//     final isRunning =
//         status == DeviceConnectionStatus.connected && isLive == 1;
//
//     return MotorSnapshot(
//       isRunning: isRunning,
//       hasFault: hasFault,
//       hasTelemetryError: status == DeviceConnectionStatus.disconnected,
//       statusCode: latest == null ? null : statusCode,
//       faultCode: latest == null ? null : faultCode,
//       isLive: latest == null ? null : isLive,
//       connectionStatus: status,
//     );
//   }
//
//   String get statusName {
//     switch (connectionStatus) {
//       case DeviceConnectionStatus.noDevice:
//         return "Device Not Connected";
//       case DeviceConnectionStatus.waitingTelemetry:
//         return "Waiting for Telemetry";
//       case DeviceConnectionStatus.disconnected:
//         return "Device Disconnected";
//       case DeviceConnectionStatus.connected:
//         break;
//     }
//
//     if (hasFault) return "Fault Active";
//     if (isRunning) return "Running";
//     if (statusCode == 3) return "Standby";
//     if (statusCode == 5) return "VFD Off";
//     return "System Ready";
//   }
//
//   String get centerStatusText {
//     switch (connectionStatus) {
//       case DeviceConnectionStatus.noDevice:
//         return "Device not connected";
//       case DeviceConnectionStatus.waitingTelemetry:
//         return "Waiting for live readings";
//       case DeviceConnectionStatus.disconnected:
//         return "Device disconnected";
//       case DeviceConnectionStatus.connected:
//         break;
//     }
//
//     if (hasFault) return faultName;
//     if (isRunning) return "Running";
//     if (statusCode == 5) return "VFD Off";
//     return "System Ready";
//   }
//
//   Color get bannerColor {
//     switch (connectionStatus) {
//       case DeviceConnectionStatus.noDevice:
//         return AppColors.warning;
//       case DeviceConnectionStatus.waitingTelemetry:
//         return AppColors.primary;
//       case DeviceConnectionStatus.disconnected:
//         return AppColors.warning;
//       case DeviceConnectionStatus.connected:
//         break;
//     }
//
//     if (hasFault) return AppColors.error;
//     if (isRunning) return AppColors.green;
//     if (statusCode == 5) return AppColors.blueDark;
//     return AppColors.primary;
//   }
//
//   IconData get bannerIcon {
//     switch (connectionStatus) {
//       case DeviceConnectionStatus.noDevice:
//         return Icons.link_off_rounded;
//       case DeviceConnectionStatus.waitingTelemetry:
//         return Icons.sync_rounded;
//       case DeviceConnectionStatus.disconnected:
//         return Icons.wifi_off_rounded;
//       case DeviceConnectionStatus.connected:
//         break;
//     }
//
//     if (hasFault) return Icons.warning_amber_rounded;
//     if (isRunning) return Icons.check_circle_rounded;
//     if (statusCode == 5) return Icons.power_off_rounded;
//     return Icons.verified_rounded;
//   }
//
//   String get faultName {
//     switch (faultCode ?? 0) {
//       case 0:
//         return "No Fault";
//       case 1:
//         return "OUT1";
//       case 2:
//         return "OUT2";
//       case 3:
//         return "OUT3";
//       case 4:
//         return "OC1";
//       case 5:
//         return "OC2";
//       case 6:
//         return "OC3";
//       case 7:
//         return "OV1";
//       case 8:
//         return "OV2";
//       case 9:
//         return "OV3";
//       case 10:
//         return "UV";
//       case 11:
//         return "OL1";
//       case 12:
//         return "OL2";
//       case 13:
//         return "SPI";
//       case 14:
//         return "SPO";
//       case 15:
//         return "OH1";
//       case 16:
//         return "OH2";
//       case 17:
//         return "EF";
//       case 18:
//         return "CE";
//       case 19:
//         return "ItE";
//       default:
//         return "Unknown Fault";
//     }
//   }
//
//   String get faultDescription {
//     switch (faultCode ?? 0) {
//       case 0:
//         return "Drive operating normally.";
//       case 1:
//         return "Output phase fault. Check motor cable, output terminal, or missing motor phase.";
//       case 2:
//         return "Output abnormality. Check motor short circuit or output wiring.";
//       case 3:
//         return "Output phase imbalance. Check open phase or motor winding damage.";
//       case 4:
//         return "Acceleration overcurrent. Check acceleration time, heavy load, or jammed motor.";
//       case 5:
//         return "Deceleration overcurrent. Check deceleration time or high inertia load.";
//       case 6:
//         return "Constant speed overcurrent. Check mechanical overload or motor current.";
//       case 7:
//         return "Acceleration overvoltage. DC bus voltage is too high during acceleration.";
//       case 8:
//         return "Deceleration overvoltage. Check fast deceleration or braking resistor.";
//       case 9:
//         return "Constant overvoltage. Check supply voltage.";
//       case 10:
//         return "Under voltage. Check weak supply or loose input cable.";
//       case 11:
//         return "Motor overload. Current stayed too high for long duration.";
//       case 12:
//         return "Drive overload. Load may exceed VFD capacity.";
//       case 13:
//         return "Internal communication fault.";
//       case 14:
//         return "Output protection triggered.";
//       case 15:
//         return "Drive overheat. Check cooling fan and ventilation.";
//       case 16:
//         return "Motor overheat. Motor thermal protection triggered.";
//       case 17:
//         return "External fault. External safety device triggered.";
//       case 18:
//         return "Communication error.";
//       case 19:
//         return "Current detection error.";
//       default:
//         return "Unknown fault code.";
//     }
//   }
// }
//
// class VfdHeaderCard extends StatelessWidget {
//   final String displayName;
//   final MotorSnapshot snapshot;
//   final String frequencyText;
//   final String referenceFrequencyText;
//
//   const VfdHeaderCard({
//     super.key,
//     required this.displayName,
//     required this.snapshot,
//     required this.frequencyText,
//     required this.referenceFrequencyText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final compact = width < 390;
//
//     return Container(
//       padding: EdgeInsets.all(compact ? 15 : 18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(26),
//         border: Border.all(color: AppColors.borderDark),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: compact ? 54 : 62,
//             width: compact ? 54 : 62,
//             decoration: BoxDecoration(
//               color: snapshot.bannerColor.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               snapshot.bannerIcon,
//               color: snapshot.bannerColor,
//               size: compact ? 28 : 32,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   displayName,
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
//                   snapshot.statusName,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: snapshot.bannerColor,
//                     fontSize: compact ? 12.5 : 14,
//                     fontWeight: FontWeight.w800,
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
//                 "Frequency",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.62),
//                   fontSize: compact ? 11 : 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 frequencyText,
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: compact ? 19 : 23,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Ref $referenceFrequencyText",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.50),
//                   fontSize: compact ? 10.5 : 12,
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
// class DeviceNotConnectedBadge extends StatelessWidget {
//   const DeviceNotConnectedBadge({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const _InfoBadge(
//       icon: Icons.link_off_rounded,
//       color: AppColors.warning,
//       text: "Device not connected. Select a device to view live parameters.",
//     );
//   }
// }
//
// class WaitingTelemetryBadge extends StatelessWidget {
//   const WaitingTelemetryBadge({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const _InfoBadge(
//       icon: Icons.sync_rounded,
//       color: AppColors.primary,
//       text: "Device selected. Waiting for latest telemetry values.",
//     );
//   }
// }
//
// class DeviceDisconnectedBadge extends StatelessWidget {
//   const DeviceDisconnectedBadge({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const _InfoBadge(
//       icon: Icons.wifi_off_rounded,
//       color: AppColors.warning,
//       text: "Device disconnected. Showing last received values when available.",
//     );
//   }
// }
//
// class _InfoBadge extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final String text;
//
//   const _InfoBadge({
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
//         border: Border.all(color: color.withOpacity(0.3)),
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
// class StatusPanel extends StatelessWidget {
//   final MotorSnapshot snapshot;
//   final Animation<double> pulseAnimation;
//
//   const StatusPanel({
//     super.key,
//     required this.snapshot,
//     required this.pulseAnimation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final connected =
//         snapshot.connectionStatus == DeviceConnectionStatus.connected;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: AppColors.borderDark),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: StatusDot(
//               title: "Phase",
//               ok: connected,
//               blinking: false,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//           Expanded(
//             child: StatusDot(
//               title: "Motor",
//               ok: snapshot.isRunning,
//               blinking: false,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//           Expanded(
//             child: StatusDot(
//               title: "Trip",
//               ok: !snapshot.hasFault,
//               blinking: snapshot.hasFault,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//           Expanded(
//             child: StatusDot(
//               title: "Service",
//               ok: connected,
//               blinking:
//               snapshot.connectionStatus == DeviceConnectionStatus.disconnected,
//               pulseAnimation: pulseAnimation,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class StatusDot extends StatelessWidget {
//   final String title;
//   final bool ok;
//   final bool blinking;
//   final Animation<double> pulseAnimation;
//
//   const StatusDot({
//     super.key,
//     required this.title,
//     required this.ok,
//     required this.blinking,
//     required this.pulseAnimation,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final dotSize = width < 360 ? 40.0 : 48.0;
//     final baseColor = ok ? AppColors.green : AppColors.error;
//
//     return AnimatedBuilder(
//       animation: pulseAnimation,
//       builder: (context, child) {
//         final scale = blinking ? pulseAnimation.value : 1.0;
//
//         return Column(
//           children: [
//             Transform.scale(
//               scale: scale,
//               child: Container(
//                 height: dotSize,
//                 width: dotSize,
//                 decoration: BoxDecoration(
//                   color: baseColor,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: baseColor.withOpacity(0.42),
//                       blurRadius: blinking ? 28 : 18,
//                       spreadRadius: blinking ? 4 : 2,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             FittedBox(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.7),
//                   fontSize: width < 360 ? 12 : 14,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class SystemBanner extends StatelessWidget {
//   final MotorSnapshot snapshot;
//
//   const SystemBanner({
//     super.key,
//     required this.snapshot,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//
//     final text = snapshot.hasFault
//         ? "${snapshot.faultName} Fault"
//         : snapshot.statusName;
//
//     final foregroundColor =
//     snapshot.bannerColor == AppColors.primary ? AppColors.black : AppColors.white;
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         vertical: width < 360 ? 14 : 16,
//         horizontal: 18,
//       ),
//       decoration: BoxDecoration(
//         color: snapshot.bannerColor,
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             snapshot.bannerIcon,
//             color: foregroundColor,
//             size: width < 360 ? 24 : 27,
//           ),
//           const SizedBox(width: 10),
//           Flexible(
//             child: Text(
//               text,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: foregroundColor,
//                 fontSize: width < 360 ? 16 : 19,
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
// class FaultAlertCard extends StatelessWidget {
//   final MotorSnapshot snapshot;
//
//   const FaultAlertCard({
//     super.key,
//     required this.snapshot,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: AppColors.error.withOpacity(0.14),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: AppColors.error.withOpacity(0.38)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(
//             Icons.warning_amber_rounded,
//             color: AppColors.error,
//             size: 30,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   snapshot.faultName,
//                   style: const TextStyle(
//                     color: AppColors.error,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   snapshot.faultDescription,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.78),
//                     fontSize: 13.5,
//                     height: 1.35,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomerNameField extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final List<String> suggestions;
//   final bool enabled;
//
//   const CustomerNameField({
//     super.key,
//     required this.controller,
//     required this.focusNode,
//     required this.suggestions,
//     required this.enabled,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return RawAutocomplete<String>(
//       textEditingController: controller,
//       focusNode: focusNode,
//       optionsBuilder: (TextEditingValue value) {
//         if (!enabled) return const Iterable<String>.empty();
//
//         final input = value.text.trim().toLowerCase();
//         if (input.isEmpty) return const Iterable<String>.empty();
//
//         return suggestions.where(
//               (name) => name.toLowerCase().contains(input),
//         );
//       },
//       onSelected: (String value) {
//         controller.text = value;
//         controller.selection = TextSelection.fromPosition(
//           TextPosition(offset: controller.text.length),
//         );
//       },
//       fieldViewBuilder: (
//           context,
//           textEditingController,
//           fieldFocusNode,
//           onFieldSubmitted,
//           ) {
//         return Container(
//           decoration: BoxDecoration(
//             color: AppColors.cardDark,
//             borderRadius: BorderRadius.circular(22),
//             border: Border.all(color: AppColors.borderDark),
//           ),
//           child: TextField(
//             enabled: enabled,
//             controller: textEditingController,
//             focusNode: fieldFocusNode,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontWeight: FontWeight.w700,
//             ),
//             decoration: InputDecoration(
//               hintText:
//               enabled ? "Customer name for Khata" : "Select a device first",
//               hintStyle: TextStyle(
//                 color: AppColors.white.withOpacity(0.42),
//               ),
//               prefixIcon: Icon(
//                 enabled
//                     ? Icons.person_outline_rounded
//                     : Icons.lock_outline_rounded,
//                 color: AppColors.primary,
//               ),
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 18,
//                 vertical: 18,
//               ),
//             ),
//           ),
//         );
//       },
//       optionsViewBuilder: (context, onSelected, options) {
//         return Align(
//           alignment: Alignment.topLeft,
//           child: Material(
//             color: Colors.transparent,
//             child: Container(
//               width: MediaQuery.of(context).size.width - 36,
//               constraints: const BoxConstraints(
//                 maxHeight: 240,
//                 maxWidth: 560,
//               ),
//               margin: const EdgeInsets.only(top: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.cardDark,
//                 borderRadius: BorderRadius.circular(18),
//                 border: Border.all(color: AppColors.borderDark),
//               ),
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(vertical: 6),
//                 shrinkWrap: true,
//                 itemCount: options.length,
//                 separatorBuilder: (_, __) {
//                   return Divider(
//                     height: 1,
//                     color: AppColors.white.withOpacity(0.06),
//                   );
//                 },
//                 itemBuilder: (context, index) {
//                   final option = options.elementAt(index);
//
//                   return ListTile(
//                     dense: true,
//                     leading: const Icon(
//                       Icons.person_rounded,
//                       color: AppColors.primary,
//                     ),
//                     title: Text(
//                       option,
//                       style: const TextStyle(
//                         color: AppColors.white,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                     onTap: () => onSelected(option),
//                   );
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// class MotorButton extends StatelessWidget {
//   final MotorSnapshot snapshot;
//   final bool loading;
//   final double size;
//
//   const MotorButton({
//     super.key,
//     required this.snapshot,
//     required this.loading,
//     required this.size,
//   });
//
//   bool get canControl {
//     return snapshot.connectionStatus == DeviceConnectionStatus.connected &&
//         !snapshot.hasFault;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final activeColor = !canControl
//         ? AppColors.warning
//         : snapshot.isRunning
//         ? AppColors.green
//         : AppColors.error;
//
//     final label = snapshot.connectionStatus == DeviceConnectionStatus.noDevice
//         ? "N/A"
//         : snapshot.connectionStatus == DeviceConnectionStatus.waitingTelemetry
//         ? "WAIT"
//         : snapshot.connectionStatus == DeviceConnectionStatus.disconnected
//         ? "OFFLINE"
//         : snapshot.hasFault
//         ? "FAULT"
//         : snapshot.isRunning
//         ? "ON"
//         : "OFF";
//
//     return Opacity(
//       opacity: canControl ? 1.0 : 0.55,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         width: size,
//         height: size,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               activeColor,
//               activeColor.withOpacity(0.72),
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: activeColor.withOpacity(canControl ? 0.34 : 0.16),
//               blurRadius: canControl ? 34 : 18,
//               offset: const Offset(0, 16),
//             ),
//           ],
//         ),
//         child: loading
//             ? const CircularProgressIndicator(color: AppColors.white)
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               snapshot.bannerIcon,
//               color: AppColors.white,
//               size: size < 190 ? 36 : 42,
//             ),
//             const SizedBox(height: 8),
//             FittedBox(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   color: AppColors.white,
//                   fontSize: label == "OFFLINE"
//                       ? 22
//                       : label == "WAIT"
//                       ? 24
//                       : size < 190
//                       ? 26
//                       : 36,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//             if (!canControl) ...[
//               const SizedBox(height: 5),
//               Text(
//                 "Disabled",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.85),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class MetricCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String value;
//   final bool highlight;
//
//   const MetricCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.value,
//     this.highlight = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final compact = width < 360;
//
//     return Container(
//       padding: EdgeInsets.all(compact ? 13 : 17),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: highlight
//               ? AppColors.primary.withOpacity(0.38)
//               : AppColors.borderDark,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             color: highlight ? AppColors.primary : AppColors.iconInactiveDark,
//             size: compact ? 24 : 28,
//           ),
//           const Spacer(),
//           Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.62),
//               fontSize: compact ? 12.5 : 14,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             alignment: Alignment.centerLeft,
//             fit: BoxFit.scaleDown,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: AppColors.white,
//                 height: 1.25,
//                 fontSize: compact ? 17 : 20,
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
// class DeviceSessionCard extends StatelessWidget {
//   final String? deviceName;
//   final String? deviceId;
//   final MotorSnapshot snapshot;
//   final int? timestamp;
//
//   const DeviceSessionCard({
//     super.key,
//     required this.deviceName,
//     required this.deviceId,
//     required this.snapshot,
//     required this.timestamp,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final liveText = snapshot.statusName;
//     final liveColor = snapshot.bannerColor;
//
//     final displayName = deviceName != null && deviceName!.trim().isNotEmpty
//         ? deviceName!
//         : snapshot.hasDevice
//         ? "SmartWell VFD"
//         : "Not Connected";
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: AppColors.borderDark),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Device Session",
//             style: TextStyle(
//               color: AppColors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Container(
//                 height: 10,
//                 width: 10,
//                 decoration: BoxDecoration(
//                   color: liveColor,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   liveText,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: liveColor,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//               Text(
//                 "Code ${snapshot.statusCode ?? "-"}",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.56),
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Text(
//             "Device Name: $displayName",
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.82),
//               fontWeight: FontWeight.w700,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Device ID: ${deviceId ?? "-"}",
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.62),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Timestamp: ${_formatTimestamp(timestamp)}",
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.62),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTimestamp(int? timestamp) {
//     if (timestamp == null) return "-";
//
//     final dateTime =
//     DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
//
//     return DateFormat("dd MMM yyyy, HH:mm:ss").format(dateTime);
//   }
// }

import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/khata/data/models/khata_entry_model.dart";
import "package:smart_iot_app/src/features/widget/custom_drawer.dart";

import "../../../../app/routes.dart";
import "../../../khata/presentation/providers/ khata_providers.dart";

import "../../../motor/presentation/ providers/motor_providers.dart";

import "../../../motor/presentation/state/motor_state.dart";



import "../../../telemetry/presentation/providers/telemetry_providers.dart";

class HomeScreen extends ConsumerStatefulWidget {
  final String? deviceId;

  const HomeScreen({
    super.key,
    this.deviceId,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;



  final TextEditingController customerNameController = TextEditingController();
  final FocusNode customerNameFocusNode = FocusNode();
  KhataEntryModel? activeKhataEntry;

  Timer? commandSyncTimer;
  Timer? telemetryTimer;
  Timer? runTimer;

  int runSeconds = 0;
  int telemetryFailures = 0;

  String? userId;
  String? deviceId;
  String? deviceName;

  bool didSetupDevice = false;
  bool isTelemetryLoading = false;

  bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.82, end: 1.12).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (didSetupDevice) return;
    didSetupDevice = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      userId = args["userId"]?.toString();
      deviceId = args["deviceId"]?.toString().trim();
      deviceName = args["deviceName"]?.toString().trim();
    }

    final widgetDeviceId = widget.deviceId?.trim();
    deviceId = deviceId?.isNotEmpty == true ? deviceId : widgetDeviceId;

    if (deviceId != null && deviceId!.trim().isEmpty) {
      deviceId = null;
    }

    if (deviceName != null && deviceName!.trim().isEmpty) {
      deviceName = null;
    }

    if (hasDevice) {
      Future.microtask(() async {
        await syncMotorCommandSilently();
        await loadTelemetry();
        await ref.read(khataViewModelProvider.notifier).loadEntries();
      });

      commandSyncTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) => syncMotorCommandSilently(),
      );

      telemetryTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) => loadTelemetry(showError: false),
      );
    }
  }

  @override
  void dispose() {
    pulseController.dispose();
    customerNameController.dispose();
    customerNameFocusNode.dispose();
    commandSyncTimer?.cancel();
    telemetryTimer?.cancel();
    runTimer?.cancel();
    super.dispose();
  }

  Future<void> syncMotorCommandSilently() async {
    if (!hasDevice) return;

    await ref.read(motorViewModelProvider.notifier).syncMotorCommand(
      deviceId: deviceId!,
      silent: true,
    );

    final motorState = ref.read(motorViewModelProvider);

    if (!mounted) return;

    if (motorState.isMotorOn && runTimer == null) {
      _startLocalTimer();
    }

    if (!motorState.isMotorOn && runTimer != null) {
      _stopLocalTimer();
      setState(() => runSeconds = 0);
    }
  }

  Future<void> loadTelemetry({bool showError = false}) async {
    if (!hasDevice || isTelemetryLoading) return;

    isTelemetryLoading = true;

    try {
      await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);

      final telemetryState = ref.read(telemetryViewModelProvider);

      if (telemetryState.latest != null) {
        telemetryFailures = 0;
      } else if (telemetryState.error != null) {
        telemetryFailures++;
      }
    } catch (_) {
      telemetryFailures++;
    } finally {
      if (mounted) {
        setState(() => isTelemetryLoading = false);
      }
    }
  }

  void _startLocalTimer() {
    runTimer?.cancel();
    runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => runSeconds++);
    });
  }

  void _stopLocalTimer() {
    runTimer?.cancel();
    runTimer = null;
  }

  String get runningTime {
    final seconds = runSeconds <= 0 ? 1 : runSeconds;
    final h = (seconds ~/ 3600).toString().padLeft(2, "0");
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
    final s = (seconds % 60).toString().padLeft(2, "0");
    return "$h:$m:$s";
  }

  String friendlyError(String? error) {
    final text = (error ?? "").toLowerCase();

    if (text.contains("socket") ||
        text.contains("connection") ||
        text.contains("network") ||
        text.contains("internet") ||
        text.contains("host lookup") ||
        text.contains("timeout") ||
        text.contains("receive timeout") ||
        text.contains("connection refused")) {
      return "No internet connection. Please check Wi-Fi or mobile data.";
    }

    if (text.trim().isEmpty) return "Unable to connect. Please try again.";

    return error!;
  }

  String formatValue(
      double? value,
      String unit, {
        int decimals = 1,
      }) {
    if (!hasDevice) return "-- $unit";
    if (value == null) return "-- $unit";
    return "${value.toStringAsFixed(decimals)} $unit";
  }

  Future<void> toggleMotor() async {
    if (!hasDevice) {
      showMessage("Please select a device first.", true);
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    final typedCustomerName = customerNameController.text.trim();
    final motorVm = ref.read(motorViewModelProvider.notifier);
    final motorState = ref.read(motorViewModelProvider);


    try {
      if (motorState.isMotorOn) {
        final stoppedLog = await motorVm.stopMotor(
          deviceId: deviceId!,
          customerName: activeKhataEntry?.customerName ??
              (typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName),
        );

        final updatedMotorState = ref.read(motorViewModelProvider);

        if (updatedMotorState.error != null) {
          showMessage(updatedMotorState.error!, true, seconds: 10);
          return;
        }

        _stopLocalTimer();

        final endTime = stoppedLog?.endTime ?? DateTime.now();

        if (activeKhataEntry != null) {
          await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
            entry: activeKhataEntry!,
            endTime: endTime,
          );

          activeKhataEntry = null;
        }

        await ref.read(khataViewModelProvider.notifier).loadEntries();

        if (mounted) {
          setState(() => runSeconds = 0);
        }

        await syncMotorCommandSilently();

        showMessage("Motor stopped. Khata session closed.", false);
        return;
      }

      if (typedCustomerName.isEmpty) {
        showMessage("Customer name is required to start motor.", true);
        return;
      }

      final startedLog = await motorVm.startMotor(
        deviceId: deviceId!,
        customerName: typedCustomerName,
      );

      final updatedMotorState = ref.read(motorViewModelProvider);

      if (updatedMotorState.error != null) {
        showMessage(updatedMotorState.error!, true, seconds: 10);
        return;
      }

      if (startedLog != null) {
        activeKhataEntry =
        await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
          customerName: typedCustomerName,
          deviceId: deviceId!,
          motorLogId: startedLog.id ?? "",
          startTime: startedLog.startTime ?? DateTime.now(),
        );
      }

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      if (mounted) {
        setState(() => runSeconds = 0);
      }

      _startLocalTimer();
      await syncMotorCommandSilently();

      showMessage("Motor started. Khata session opened.", false);
    } catch (e) {
      showMessage(
        "Motor action failed: ${friendlyError(e.toString())}",
        true,
        seconds: 12,
      );
    }
  }
  void showMessage(String text, bool isError, {int seconds = 6}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: isError ? seconds : 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.green,
          content: Text(
            isError ? friendlyError(text) : text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }

  List<String> customerSuggestions() {
    if (!hasDevice) return <String>[];

    final khataState = ref.watch(khataViewModelProvider);
    final names = <String>{};

    for (final entry in khataState.entries) {
      final name = entry.customerName?.trim();
      if (name != null && name.isNotEmpty) names.add(name);
    }

    final list = names.toList();
    list.sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final motorState = ref.watch(motorViewModelProvider);
    final telemetryState = ref.watch(telemetryViewModelProvider);
    final latest = hasDevice ? telemetryState.latest : null;

    final width = MediaQuery.of(context).size.width;

    final isVerySmall = width < 360;
    final isTablet = width >= 650;
    final isLarge = width >= 1000;

    final horizontalPadding = isLarge
        ? 38.0
        : isTablet
        ? 30.0
        : 16.0;

    final crossAxisCount = isLarge
        ? 4
        : isTablet
        ? 3
        : 2;

    final childAspectRatio = isLarge
        ? 1.36
        : isTablet
        ? 1.22
        : 1.02;

    final buttonSize = isLarge
        ? 238.0
        : isTablet
        ? 226.0
        : isVerySmall
        ? 176.0
        : 196.0;

    final resolvedDisplayName = deviceName != null && deviceName!.isNotEmpty
        ? deviceName!
        : hasDevice
        ? deviceId!
        : "Smart Motor Controller";

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
      appBar: SmartWellHomeAppBar(
        hasDevice: hasDevice,
        displayName: resolvedDisplayName,
        onSelectDevice: () {
          Navigator.pushReplacementNamed(context, AppRoutes.devices);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (hasDevice) {
              await syncMotorCommandSilently();
              await loadTelemetry();
            } else {
              showMessage("Please select a device first.", true);
            }
          },
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
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
                    SmartDeviceHeaderCard(
                      hasDevice: hasDevice,
                      displayName: resolvedDisplayName,
                      deviceId: deviceId,
                      motorState: motorState,
                    ),
                    if (!hasDevice) ...[
                      const SizedBox(height: 12),
                      NoDeviceProfessionalNotice(
                        onSelectDevice: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.devices,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 18),
                    CustomerNameInputCard(
                      controller: customerNameController,
                      focusNode: customerNameFocusNode,
                      suggestions: customerSuggestions(),
                      enabled: hasDevice,
                    ),
                    const SizedBox(height: 26),
                    Center(
                      child: GestureDetector(
                        onTap: motorState.isLoading ? null : toggleMotor,
                        child: AnimatedBuilder(
                          animation: pulseAnimation,
                          builder: (context, child) {
                            final scale = motorState.isMotorOn
                                ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
                                : 1.0;

                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: MotorCommandButton(
                            hasDevice: hasDevice,
                            isOn: motorState.isMotorOn,
                            loading: hasDevice && motorState.isLoading,
                            size: buttonSize,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    MotorCommandStatusText(
                      hasDevice: hasDevice,
                      isOn: motorState.isMotorOn,
                      runningTime: runningTime,
                    ),
                    const SizedBox(height: 22),
                    ParameterGridSection(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      metrics: [
                        ParameterMetric(
                          icon: Icons.sync_rounded,
                          title: "Frequency",
                          value: formatValue(latest?.freq, "Hz"),
                          highlight: true,
                        ),
                        ParameterMetric(
                          icon: Icons.bolt_rounded,
                          title: "Voltage",
                          value: formatValue(latest?.voltage, "V"),
                        ),
                        ParameterMetric(
                          icon: Icons.flash_on_rounded,
                          title: "Current",
                          value: formatValue(latest?.current, "A"),
                        ),
                        ParameterMetric(
                          icon: Icons.power_rounded,
                          title: "Power",
                          value: formatValue(latest?.power, "kW"),
                        ),
                        ParameterMetric(
                          icon: Icons.speed_rounded,
                          title: "Load",
                          value: formatValue(latest?.powerPercent, "%"),
                        ),
                        ParameterMetric(
                          icon: Icons.rotate_right_rounded,
                          title: "Motor Speed",
                          value: formatValue(latest?.motorSpeed, "RPM"),
                        ),
                        ParameterMetric(
                          icon: Icons.battery_charging_full_rounded,
                          title: "DC Bus",
                          value: formatValue(latest?.dcbus, "V"),
                        ),
                        ParameterMetric(
                          icon: Icons.electric_meter_rounded,
                          title: "Energy",
                          value: formatValue(latest?.energyIn, "kWh"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SmartWellHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool hasDevice;
  final String displayName;
  final VoidCallback onSelectDevice;

  const SmartWellHomeAppBar({
    super.key,
    required this.hasDevice,
    required this.displayName,
    required this.onSelectDevice,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return
      AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: hasDevice,
      iconTheme: const IconThemeData(color: AppColors.white),
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  AppColors.darkBgSoft,
                  AppColors.darkBgSoft.withOpacity(0.72),
                ],
              ),
            ),
            child: const Icon(
              Icons.electric_bolt_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "AabNex",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                // Text(
                //   hasDevice ? displayName : "Professional Motor Automation",
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(
                //     color: AppColors.white.withOpacity(0.55),
                //     fontSize: 11.5,
                //     fontWeight: FontWeight.w700,
                //   ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            tooltip: "Select Device",
            onPressed: onSelectDevice,
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: const Icon(
                Icons.devices_other_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SmartDeviceHeaderCard extends StatelessWidget {
  final bool hasDevice;
  final String displayName;
  final String? deviceId;
  final MotorState motorState;

  const SmartDeviceHeaderCard({
    super.key,
    required this.hasDevice,
    required this.displayName,
    required this.deviceId,
    required this.motorState,
  });

  @override
  Widget build(BuildContext context) {
    final color = !hasDevice
        ? AppColors.primary
        : motorState.isMotorOn
        ? AppColors.green
        : AppColors.error;

    final icon = !hasDevice
        ? Icons.hub_outlined
        : motorState.isMotorOn
        ? Icons.power_settings_new_rounded
        : Icons.power_off_rounded;

    final statusText = !hasDevice
        ? "Ready to connect"
        : motorState.isMotorOn
        ? "Motor ON"
        : "Motor OFF";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 62,
            width: 62,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hasDevice ? deviceId! : "No controller selected",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoDeviceProfessionalNotice extends StatelessWidget {
  final VoidCallback onSelectDevice;

  const NoDeviceProfessionalNotice({
    super.key,
    required this.onSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.devices_other_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Select a device to enable motor control. Parameters are shown safely with empty values until a controller is connected.",
              style: TextStyle(
                color: AppColors.white.withOpacity(0.68),
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: onSelectDevice,
            child: const Text(
              "Select",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerNameInputCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> suggestions;
  final bool enabled;

  const CustomerNameInputCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue value) {
        if (!enabled) return const Iterable<String>.empty();

        final input = value.text.trim().toLowerCase();
        if (input.isEmpty) return const Iterable<String>.empty();

        return suggestions.where(
              (name) => name.toLowerCase().contains(input),
        );
      },
      onSelected: (String value) {
        controller.text = value;
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
      fieldViewBuilder: (
          context,
          textEditingController,
          fieldFocusNode,
          onFieldSubmitted,
          ) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: TextField(
            enabled: enabled,
            controller: textEditingController,
            focusNode: fieldFocusNode,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText:
              enabled ? "Customer name for Khata" : "Select a device first",
              hintStyle: TextStyle(
                color: AppColors.white.withOpacity(0.42),
              ),
              prefixIcon: Icon(
                enabled
                    ? Icons.person_outline_rounded
                    : Icons.lock_outline_rounded,
                color: AppColors.primary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width - 36,
              constraints: const BoxConstraints(
                maxHeight: 240,
                maxWidth: 560,
              ),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) {
                  return Divider(
                    height: 1,
                    color: AppColors.white.withOpacity(0.06),
                  );
                },
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);

                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      option,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class MotorCommandButton extends StatelessWidget {
  final bool hasDevice;
  final bool isOn;
  final bool loading;
  final double size;

  const MotorCommandButton({
    super.key,
    required this.hasDevice,
    required this.isOn,
    required this.loading,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = !hasDevice
        ? AppColors.primary
        : isOn
        ? AppColors.green
        : AppColors.error;

    final label = !hasDevice
        ? "READY"
        : isOn
        ? "ON"
        : "OFF";

    final icon = !hasDevice
        ? Icons.devices_other_rounded
        : isOn
        ? Icons.power_settings_new_rounded
        : Icons.power_off_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            activeColor,
            activeColor.withOpacity(0.72),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.30),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: loading
          ? const CircularProgressIndicator(color: AppColors.white)
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: hasDevice ? AppColors.white : AppColors.black,
            size: size < 190 ? 36 : 42,
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                color: hasDevice ? AppColors.white : AppColors.black,
                fontSize: label == "READY"
                    ? 24
                    : size < 190
                    ? 26
                    : 36,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MotorCommandStatusText extends StatelessWidget {
  final bool hasDevice;
  final bool isOn;
  final String runningTime;

  const MotorCommandStatusText({
    super.key,
    required this.hasDevice,
    required this.isOn,
    required this.runningTime,
  });

  @override
  Widget build(BuildContext context) {
    final text = !hasDevice
        ? "Select a device to activate motor control"
        : isOn
        ? "Motor running | $runningTime"
        : "Motor stopped";

    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.white.withOpacity(0.76),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class ParameterMetric {
  final IconData icon;
  final String title;
  final String value;
  final bool highlight;

  const ParameterMetric({
    required this.icon,
    required this.title,
    required this.value,
    this.highlight = false,
  });
}

class ParameterGridSection extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final List<ParameterMetric> metrics;

  const ParameterGridSection({
    super.key,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: childAspectRatio,
      children: metrics.map((metric) {
        return ParameterMetricCard(metric: metric);
      }).toList(),
    );
  }
}

class ParameterMetricCard extends StatelessWidget {
  final ParameterMetric metric;

  const ParameterMetricCard({
    super.key,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 360;

    return Container(
      padding: EdgeInsets.all(compact ? 13 : 17),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: metric.highlight
              ? AppColors.primary.withOpacity(0.38)
              : AppColors.borderDark,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            metric.icon,
            color:
            metric.highlight ? AppColors.primary : AppColors.white.withOpacity(0.45),
            size: compact ? 24 : 28,
          ),
          const Spacer(),
          Text(
            metric.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.62),
              fontSize: compact ? 12.5 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              metric.value,
              style: TextStyle(
                color: AppColors.white,
                height: 1.25,
                fontSize: compact ? 17 : 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}