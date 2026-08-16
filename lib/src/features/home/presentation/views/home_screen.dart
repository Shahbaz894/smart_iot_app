// // //
// // // import "dart:async";
// // //
// // // import "package:flutter/material.dart";
// // // import "package:flutter/services.dart";
// // // import "package:flutter_riverpod/flutter_riverpod.dart";
// // //
// // // import "package:smart_iot_app/src/core/constant/app_color.dart";
// // // import "package:smart_iot_app/src/features/khata/data/models/khata_entry_model.dart";
// // // import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
// // //
// // // import "../../../../app/routes.dart";
// // // import "../../../khata/presentation/providers/ khata_providers.dart";
// // // import "../../../motor/presentation/ providers/motor_providers.dart";
// // // import "../../../telemetry/presentation/providers/telemetry_providers.dart";
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
// // //   KhataEntryModel? activeKhataEntry;
// // //
// // //   Timer? telemetryTimer;
// // //   Timer? runTimer;
// // //
// // //   int runSeconds = 0;
// // //
// // //   String? userId;
// // //   String? deviceId;
// // //   String? deviceName;
// // //
// // //   bool didSetupDevice = false;
// // //   bool isTelemetryLoading = false;
// // //   bool firstTelemetryLoaded = false;
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
// // //
// // //       final rawDeviceId = args["deviceId"]?.toString().trim();
// // //       if (rawDeviceId != null && rawDeviceId.isNotEmpty) {
// // //         deviceId = rawDeviceId;
// // //       }
// // //
// // //       final rawDeviceName = args["deviceName"]?.toString().trim();
// // //       if (rawDeviceName != null && rawDeviceName.isNotEmpty) {
// // //         deviceName = rawDeviceName;
// // //       }
// // //     }
// // //
// // //     final widgetDeviceId = widget.deviceId?.trim();
// // //
// // //     if (!hasDevice && widgetDeviceId != null && widgetDeviceId.isNotEmpty) {
// // //       deviceId = widgetDeviceId;
// // //     }
// // //
// // //     if (hasDevice) {
// // //       Future.microtask(() async {
// // //         await loadTelemetry();
// // //         await ref.read(khataViewModelProvider.notifier).loadEntries();
// // //       });
// // //
// // //       telemetryTimer?.cancel();
// // //       telemetryTimer = Timer.periodic(
// // //         const Duration(seconds: 5),
// // //             (_) => loadTelemetry(showError: false),
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     pulseController.dispose();
// // //     customerNameController.dispose();
// // //     customerNameFocusNode.dispose();
// // //     telemetryTimer?.cancel();
// // //     runTimer?.cancel();
// // //     super.dispose();
// // //   }
// // //
// // //   int _toInt(dynamic value) {
// // //     if (value == null) return 0;
// // //     if (value is int) return value;
// // //     if (value is double) return value.toInt();
// // //     if (value is num) return value.toInt();
// // //     return int.tryParse(value.toString()) ?? 0;
// // //   }
// // //
// // //   bool isDeviceOnline(dynamic latest) {
// // //     if (!hasDevice) return false;
// // //     if (latest == null) return false;
// // //
// // //     final live = _toInt(latest.isLive) == 1;
// // //     final fresh = latest.isFresh(withinSeconds: 20);
// // //
// // //     return live && fresh;
// // //   }
// // //   // bool isDeviceOnline(dynamic latest) {
// // //   //   if (!hasDevice) return false;
// // //   //   if (latest == null) return false;
// // //   //
// // //   //   return _toInt(latest.isLive) == 1;
// // //   // }
// // //
// // //   // bool isMotorRunning(dynamic latest) {
// // //   //   if (!hasDevice) return false;
// // //   //   if (latest == null) return false;
// // //   //
// // //   //   final statusCode = _toInt(latest.statusCode);
// // //   //
// // //   //   return statusCode == 1 || statusCode == 2;
// // //   // }
// // //
// // //   bool isMotorRunning(dynamic latest) {
// // //     if (!hasDevice) return false;
// // //     if (!isDeviceOnline(latest)) return false;
// // //
// // //     final statusCode = _toInt(latest.statusCode);
// // //
// // //     return statusCode == 1 || statusCode == 2;
// // //   }
// // //
// // //   // Future<void> loadTelemetry({bool showError = false}) async {
// // //   //   if (!hasDevice) return;
// // //   //   if (isTelemetryLoading) return;
// // //   //
// // //   //   isTelemetryLoading = true;
// // //   //
// // //   //   try {
// // //   //     await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);
// // //   //   } catch (e) {
// // //   //     if (showError) {
// // //   //       showMessage(
// // //   //         "Telemetry failed: ${friendlyError(e.toString())}",
// // //   //         true,
// // //   //         seconds: 8,
// // //   //       );
// // //   //     }
// // //   //   } finally {
// // //   //     isTelemetryLoading = false;
// // //   //   }
// // //   // }
// // //   Future<void> loadTelemetry({bool showError = false}) async {
// // //     if (!hasDevice) return;
// // //     if (isTelemetryLoading) return;
// // //
// // //     final isFirstLoad = !firstTelemetryLoaded;
// // //
// // //     isTelemetryLoading = true;
// // //
// // //     try {
// // //       await ref.read(telemetryViewModelProvider.notifier).loadLatest(
// // //         deviceId!,
// // //         showLoading: isFirstLoad,
// // //       );
// // //     } catch (e) {
// // //       if (showError) {
// // //         showMessage(
// // //           "Telemetry failed: ${friendlyError(e.toString())}",
// // //           true,
// // //           seconds: 8,
// // //         );
// // //       }
// // //     } finally {
// // //       isTelemetryLoading = false;
// // //
// // //       if (mounted && isFirstLoad) {
// // //         setState(() {
// // //           firstTelemetryLoaded = true;
// // //         });
// // //       }
// // //     }
// // //   }
// // //
// // //   void _startLocalTimer() {
// // //     runTimer?.cancel();
// // //
// // //     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// // //       if (!mounted) return;
// // //
// // //       setState(() {
// // //         runSeconds++;
// // //       });
// // //     });
// // //   }
// // //
// // //   void _stopLocalTimer() {
// // //     runTimer?.cancel();
// // //     runTimer = null;
// // //   }
// // //
// // //   String get runningTime {
// // //     final seconds = runSeconds <= 0 ? 1 : runSeconds;
// // //     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
// // //     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
// // //     final s = (seconds % 60).toString().padLeft(2, "0");
// // //     return "$h:$m:$s";
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
// // //         text.contains("connection refused")) {
// // //       return "No internet connection. Please check Wi-Fi or mobile data.";
// // //     }
// // //
// // //     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
// // //
// // //     return error!;
// // //   }
// // //
// // //   String formatValue(
// // //       double? value,
// // //       String unit, {
// // //         int decimals = 1,
// // //       }) {
// // //     if (!hasDevice) return "-- $unit";
// // //     if (value == null) return "-- $unit";
// // //     return "${value.toStringAsFixed(decimals)} $unit";
// // //   }
// // //
// // //   Future<void> toggleMotor() async {
// // //     if (!hasDevice) {
// // //       showMessage("Please select a device first.", true);
// // //       return;
// // //     }
// // //
// // //     final latest = ref.read(telemetryViewModelProvider).latest;
// // //
// // //     final deviceOnline = isDeviceOnline(latest);
// // //     final motorRunning = isMotorRunning(latest);
// // //
// // //     if (!deviceOnline) {
// // //       showMessage(
// // //         "Device is offline. Wait for live telemetry before motor control.",
// // //         true,
// // //         seconds: 8,
// // //       );
// // //       return;
// // //     }
// // //
// // //     FocusScope.of(context).unfocus();
// // //     HapticFeedback.mediumImpact();
// // //
// // //     final typedCustomerName = customerNameController.text.trim();
// // //     final motorVm = ref.read(motorViewModelProvider.notifier);
// // //
// // //     try {
// // //       if (motorRunning) {
// // //         final stoppedLog = await motorVm.stopMotor(
// // //           deviceId: deviceId!,
// // //           customerName: activeKhataEntry?.customerName ??
// // //               (typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName),
// // //         );
// // //
// // //         final updatedMotorState = ref.read(motorViewModelProvider);
// // //
// // //         if (updatedMotorState.error != null) {
// // //           showMessage(updatedMotorState.error!, true, seconds: 10);
// // //           return;
// // //         }
// // //
// // //         _stopLocalTimer();
// // //
// // //         final endTime = stoppedLog?.endTime ?? DateTime.now();
// // //
// // //         if (activeKhataEntry != null) {
// // //           await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
// // //             entry: activeKhataEntry!,
// // //             endTime: endTime,
// // //           );
// // //
// // //           activeKhataEntry = null;
// // //         }
// // //
// // //         await ref.read(khataViewModelProvider.notifier).loadEntries();
// // //
// // //         if (mounted) {
// // //           setState(() {
// // //             runSeconds = 0;
// // //           });
// // //         }
// // //
// // //         await loadTelemetry(showError: false);
// // //
// // //         showMessage("Motor stopped. Khata session closed.", false);
// // //         return;
// // //       }
// // //
// // //       if (typedCustomerName.isEmpty) {
// // //         showMessage("Customer name is required to start motor.", true);
// // //         return;
// // //       }
// // //
// // //       final startedLog = await motorVm.startMotor(
// // //         deviceId: deviceId!,
// // //         customerName: typedCustomerName,
// // //       );
// // //
// // //       final updatedMotorState = ref.read(motorViewModelProvider);
// // //
// // //       if (updatedMotorState.error != null) {
// // //         showMessage(updatedMotorState.error!, true, seconds: 10);
// // //         return;
// // //       }
// // //
// // //       if (startedLog != null) {
// // //         activeKhataEntry =
// // //         await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
// // //           customerName: typedCustomerName,
// // //           deviceId: deviceId!,
// // //           motorLogId: startedLog.id ?? "",
// // //           startTime: startedLog.startTime ?? DateTime.now(),
// // //         );
// // //       }
// // //
// // //       await ref.read(khataViewModelProvider.notifier).loadEntries();
// // //
// // //       if (mounted) {
// // //         setState(() {
// // //           runSeconds = 0;
// // //         });
// // //       }
// // //
// // //       _startLocalTimer();
// // //
// // //       await loadTelemetry(showError: false);
// // //
// // //       showMessage("Motor started. Khata session opened.", false);
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
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(14),
// // //           ),
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
// // //       if (name != null && name.isNotEmpty) {
// // //         names.add(name);
// // //       }
// // //     }
// // //
// // //     final list = names.toList();
// // //     list.sort();
// // //     return list;
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final latest = ref.watch(
// // //       telemetryViewModelProvider.select((state) => state.latest),
// // //     );
// // //
// // //     final motorLoading = ref.watch(
// // //       motorViewModelProvider.select((state) => state.isLoading),
// // //     );
// // //
// // //     // final effectiveLatest = hasDevice ? latest : null;
// // //     //
// // //     // final deviceOnline = isDeviceOnline(effectiveLatest);
// // //     // final motorRunning = isMotorRunning(effectiveLatest);
// // //     // final displayLatest = deviceOnline ? effectiveLatest : null;
// // //
// // //
// // //     //////////////////////
// // //     final checkingDevice = hasDevice && !firstTelemetryLoaded;
// // //
// // //     final effectiveLatest = hasDevice && firstTelemetryLoaded ? latest : null;
// // //
// // //     final deviceOnline = checkingDevice ? false : isDeviceOnline(effectiveLatest);
// // //     final motorRunning = checkingDevice ? false : isMotorRunning(effectiveLatest);
// // //     final displayLatest = deviceOnline ? effectiveLatest : null;
// // //
// // //     if (motorRunning && runTimer == null) {
// // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // //         if (mounted && runTimer == null) {
// // //           _startLocalTimer();
// // //         }
// // //       });
// // //     }
// // //
// // //     if (!motorRunning && runTimer != null) {
// // //       WidgetsBinding.instance.addPostFrameCallback((_) {
// // //         if (mounted && runTimer != null) {
// // //           _stopLocalTimer();
// // //           setState(() {
// // //             runSeconds = 0;
// // //           });
// // //         }
// // //       });
// // //     }
// // //
// // //     final width = MediaQuery.of(context).size.width;
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
// // //     final resolvedDisplayName = deviceName != null && deviceName!.isNotEmpty
// // //         ? deviceName!
// // //         : hasDevice
// // //         ? deviceId!
// // //         : "Smart Motor Controller";
// // //
// // //     return Scaffold(
// // //       backgroundColor: AppColors.darkBgSoft,
// // //       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
// // //       appBar: SmartWellHomeAppBar(
// // //         hasDevice: hasDevice,
// // //         deviceOnline: deviceOnline,
// // //         onSelectDevice: () {
// // //           Navigator.pushReplacementNamed(context, AppRoutes.devices);
// // //         },
// // //       ),
// // //       body: SafeArea(
// // //         child: RefreshIndicator(
// // //           color: AppColors.primary,
// // //           backgroundColor: AppColors.cardDark,
// // //           onRefresh: () async {
// // //             if (hasDevice) {
// // //               await loadTelemetry(showError: true);
// // //             } else {
// // //               showMessage("Please select a device first.", true);
// // //             }
// // //           },
// // //           child: SingleChildScrollView(
// // //             physics: const AlwaysScrollableScrollPhysics(
// // //               parent: BouncingScrollPhysics(),
// // //             ),
// // //             padding: EdgeInsets.symmetric(
// // //               horizontal: horizontalPadding,
// // //               vertical: 18,
// // //             ),
// // //             child: Center(
// // //               child: ConstrainedBox(
// // //                 constraints: const BoxConstraints(maxWidth: 1080),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// // //                   children: [
// // //                     SmartDeviceHeaderCard(
// // //                       hasDevice: hasDevice,
// // //                       deviceOnline: deviceOnline,
// // //                       motorRunning: motorRunning,
// // //                       displayName: resolvedDisplayName,
// // //                       deviceId: deviceId,
// // //                     ),
// // //                     if (!hasDevice) ...[
// // //                       const SizedBox(height: 12),
// // //                       NoDeviceProfessionalNotice(
// // //                         onSelectDevice: () {
// // //                           Navigator.pushReplacementNamed(
// // //                             context,
// // //                             AppRoutes.devices,
// // //                           );
// // //                         },
// // //                       ),
// // //                     ],
// // //                     if (hasDevice && !deviceOnline) ...[
// // //                       const SizedBox(height: 12),
// // //                       DeviceOfflineNotice(
// // //                         onRetry: () => loadTelemetry(showError: true),
// // //                       ),
// // //                     ],
// // //                     if (hasDevice && deviceOnline) ...[
// // //                       const SizedBox(height: 12),
// // //                       DeviceOnlineNotice(
// // //                         motorRunning: motorRunning,
// // //                       ),
// // //                     ],
// // //                     const SizedBox(height: 18),
// // //                     CustomerNameInputCard(
// // //                       controller: customerNameController,
// // //                       focusNode: customerNameFocusNode,
// // //                       suggestions: customerSuggestions(),
// // //                       enabled: hasDevice && deviceOnline,
// // //                     ),
// // //                     const SizedBox(height: 26),
// // //                     Center(
// // //                       child: GestureDetector(
// // //                         onTap: motorLoading ? null : toggleMotor,
// // //                         child: AnimatedBuilder(
// // //                           animation: pulseAnimation,
// // //                           builder: (context, child) {
// // //                             final scale = motorRunning
// // //                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
// // //                                 : 1.0;
// // //
// // //                             return Transform.scale(
// // //                               scale: scale,
// // //                               child: child,
// // //                             );
// // //                           },
// // //                           child: MotorCommandButton(
// // //                             hasDevice: hasDevice,
// // //                             deviceOnline: deviceOnline,
// // //                             isOn: motorRunning,
// // //                             loading: hasDevice && motorLoading,
// // //                             size: buttonSize,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(height: 18),
// // //                     MotorCommandStatusText(
// // //                       hasDevice: hasDevice,
// // //                       deviceOnline: deviceOnline,
// // //                       isOn: motorRunning,
// // //                       runningTime: runningTime,
// // //                     ),
// // //                     const SizedBox(height: 22),
// // //                     ParameterGridSection(
// // //                       crossAxisCount: crossAxisCount,
// // //                       childAspectRatio: childAspectRatio,
// // //                       metrics: [
// // //                         ParameterMetric(
// // //                           icon: Icons.sync_rounded,
// // //                           title: "Frequency",
// // //                           value: formatValue(displayLatest?.freq, "Hz"),
// // //                           highlight: true,
// // //                         ),
// // //                         ParameterMetric(
// // //                           icon: Icons.bolt_rounded,
// // //                           title: "Voltage",
// // //                           value: formatValue(displayLatest?.voltage, "V"),
// // //                         ),
// // //                         ParameterMetric(
// // //                           icon: Icons.flash_on_rounded,
// // //                           title: "Current",
// // //                           value: formatValue(displayLatest?.current, "A"),
// // //                         ),
// // //                         ParameterMetric(
// // //                           icon: Icons.power_rounded,
// // //                           title: "Power",
// // //                           value: formatValue(displayLatest?.power, "kW"),
// // //                         ),
// // //                         ParameterMetric(
// // //                           icon: Icons.speed_rounded,
// // //                           title: "Load",
// // //                           value: formatValue(
// // //                             displayLatest?.powerPercent,
// // //                             "%",
// // //                           ),
// // //                         ),
// // //                         ParameterMetric(
// // //                           icon: Icons.rotate_right_rounded,
// // //                           title: "Motor Speed",
// // //                           value: formatValue(
// // //                             displayLatest?.motorSpeed,
// // //                             "RPM",
// // //                           ),
// // //                         ),
// // //                         ParameterMetric(
// // //                           icon: Icons.battery_charging_full_rounded,
// // //                           title: "DC Bus",
// // //                           value: formatValue(displayLatest?.dcbus, "V"),
// // //                         ),
// // //                         ParameterMetric(
// // //                           icon: Icons.electric_meter_rounded,
// // //                           title: "Energy",
// // //                           value: formatValue(
// // //                             displayLatest?.energyIn,
// // //                             "kWh",
// // //                           ),
// // //                         ),
// // //                       ],
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
// // // class SmartWellHomeAppBar extends StatelessWidget
// // //     implements PreferredSizeWidget {
// // //   final bool hasDevice;
// // //   final bool deviceOnline;
// // //   final VoidCallback onSelectDevice;
// // //
// // //   const SmartWellHomeAppBar({
// // //     super.key,
// // //     required this.hasDevice,
// // //     required this.deviceOnline,
// // //     required this.onSelectDevice,
// // //   });
// // //
// // //   @override
// // //   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final statusText = !hasDevice
// // //         ? "No device selected"
// // //         : deviceOnline
// // //         ? "Device online"
// // //         : "Waiting for device";
// // //
// // //     final statusColor = !hasDevice
// // //         ? AppColors.white.withOpacity(0.55)
// // //         : deviceOnline
// // //         ? AppColors.green
// // //         : AppColors.warning;
// // //
// // //     return AppBar(
// // //       backgroundColor: AppColors.primaryDark,
// // //       elevation: 0,
// // //       centerTitle: false,
// // //       automaticallyImplyLeading: hasDevice,
// // //       iconTheme: const IconThemeData(color: AppColors.white),
// // //       titleSpacing: 18,
// // //       title: Row(
// // //         children: [
// // //           Container(
// // //             height: 42,
// // //             width: 42,
// // //             decoration: BoxDecoration(
// // //               borderRadius: BorderRadius.circular(14),
// // //               gradient: LinearGradient(
// // //                 colors: [
// // //                   AppColors.darkBgSoft,
// // //                   AppColors.darkBgSoft.withOpacity(0.72),
// // //                 ],
// // //               ),
// // //             ),
// // //             child: const Icon(
// // //               Icons.electric_bolt_rounded,
// // //               color: AppColors.white,
// // //               size: 24,
// // //             ),
// // //           ),
// // //           const SizedBox(width: 14),
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 const Text(
// // //                   "AabNex",
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: TextStyle(
// // //                     color: AppColors.white,
// // //                     fontSize: 20,
// // //                     fontWeight: FontWeight.w900,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 2),
// // //                 Text(
// // //                   statusText,
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: TextStyle(
// // //                     color: statusColor,
// // //                     fontSize: 11.5,
// // //                     fontWeight: FontWeight.w800,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //       actions: [
// // //         Padding(
// // //           padding: const EdgeInsets.only(right: 10),
// // //           child: IconButton(
// // //             tooltip: "Select Device",
// // //             onPressed: onSelectDevice,
// // //             icon: Container(
// // //               padding: const EdgeInsets.all(10),
// // //               decoration: BoxDecoration(
// // //                 color: AppColors.cardDark,
// // //                 borderRadius: BorderRadius.circular(14),
// // //                 border: Border.all(color: AppColors.borderDark),
// // //               ),
// // //               child: const Icon(
// // //                 Icons.devices_other_rounded,
// // //                 color: AppColors.primary,
// // //                 size: 22,
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }
// // //
// // // class SmartDeviceHeaderCard extends StatelessWidget {
// // //   final bool hasDevice;
// // //   final bool deviceOnline;
// // //   final bool motorRunning;
// // //   final String displayName;
// // //   final String? deviceId;
// // //
// // //   const SmartDeviceHeaderCard({
// // //     super.key,
// // //     required this.hasDevice,
// // //     required this.deviceOnline,
// // //     required this.motorRunning,
// // //     required this.displayName,
// // //     required this.deviceId,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final color = !hasDevice
// // //         ? AppColors.primary
// // //         : !deviceOnline
// // //         ? AppColors.warning
// // //         : motorRunning
// // //         ? AppColors.green
// // //         : AppColors.primary;
// // //
// // //     final icon = !hasDevice
// // //         ? Icons.hub_outlined
// // //         : !deviceOnline
// // //         ? Icons.wifi_tethering_error_rounded
// // //         : motorRunning
// // //         ? Icons.power_settings_new_rounded
// // //         : Icons.verified_rounded;
// // //
// // //     final statusText = !hasDevice
// // //         ? "Ready to connect"
// // //         : !deviceOnline
// // //         ? "Waiting for live telemetry"
// // //         : motorRunning
// // //         ? "Device online | Motor ON"
// // //         : "Device online | Motor OFF";
// // //
// // //     return Container(
// // //       padding: const EdgeInsets.all(18),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.cardDark,
// // //         borderRadius: BorderRadius.circular(26),
// // //         border: Border.all(color: AppColors.borderDark),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: color.withOpacity(0.10),
// // //             blurRadius: 28,
// // //             offset: const Offset(0, 14),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Container(
// // //             height: 62,
// // //             width: 62,
// // //             decoration: BoxDecoration(
// // //               color: color.withOpacity(0.14),
// // //               borderRadius: BorderRadius.circular(20),
// // //             ),
// // //             child: Icon(
// // //               icon,
// // //               color: color,
// // //               size: 32,
// // //             ),
// // //           ),
// // //           const SizedBox(width: 14),
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   displayName,
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: const TextStyle(
// // //                     color: AppColors.white,
// // //                     fontSize: 17,
// // //                     fontWeight: FontWeight.w900,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 6),
// // //                 Text(
// // //                   statusText,
// // //                   style: TextStyle(
// // //                     color: color,
// // //                     fontSize: 14,
// // //                     fontWeight: FontWeight.w800,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 5),
// // //                 Text(
// // //                   hasDevice ? deviceId! : "No controller selected",
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: TextStyle(
// // //                     color: AppColors.white.withOpacity(0.45),
// // //                     fontSize: 11,
// // //                     fontWeight: FontWeight.w700,
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
// // // class NoDeviceProfessionalNotice extends StatelessWidget {
// // //   final VoidCallback onSelectDevice;
// // //
// // //   const NoDeviceProfessionalNotice({
// // //     super.key,
// // //     required this.onSelectDevice,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.all(18),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.cardDark,
// // //         borderRadius: BorderRadius.circular(24),
// // //         border: Border.all(color: AppColors.borderDark),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Container(
// // //             height: 46,
// // //             width: 46,
// // //             decoration: BoxDecoration(
// // //               color: AppColors.primary.withOpacity(0.10),
// // //               borderRadius: BorderRadius.circular(16),
// // //             ),
// // //             child: const Icon(
// // //               Icons.devices_other_rounded,
// // //               color: AppColors.primary,
// // //             ),
// // //           ),
// // //           const SizedBox(width: 14),
// // //           Expanded(
// // //             child: Text(
// // //               "Select a device to enable motor control. Parameters stay empty until a controller is selected.",
// // //               style: TextStyle(
// // //                 color: AppColors.white.withOpacity(0.68),
// // //                 fontSize: 13.5,
// // //                 height: 1.4,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ),
// // //           const SizedBox(width: 10),
// // //           TextButton(
// // //             onPressed: onSelectDevice,
// // //             child: const Text(
// // //               "Select",
// // //               style: TextStyle(
// // //                 color: AppColors.primary,
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
// // // class DeviceOfflineNotice extends StatelessWidget {
// // //   final Future<void> Function() onRetry;
// // //
// // //   const DeviceOfflineNotice({
// // //     super.key,
// // //     required this.onRetry,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       padding: const EdgeInsets.all(14),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.warning.withOpacity(0.10),
// // //         borderRadius: BorderRadius.circular(18),
// // //         border: Border.all(color: AppColors.warning.withOpacity(0.24)),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           const Icon(
// // //             Icons.info_outline_rounded,
// // //             color: AppColors.warning,
// // //             size: 22,
// // //           ),
// // //           const SizedBox(width: 10),
// // //           Expanded(
// // //             child: Text(
// // //               "Device selected. Waiting for latest live reading.",
// // //               style: TextStyle(
// // //                 color: AppColors.white.withOpacity(0.78),
// // //                 fontSize: 12.8,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ),
// // //           TextButton(
// // //             onPressed: onRetry,
// // //             child: const Text(
// // //               "Retry",
// // //               style: TextStyle(
// // //                 color: AppColors.warning,
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
// // // class DeviceOnlineNotice extends StatelessWidget {
// // //   final bool motorRunning;
// // //
// // //   const DeviceOnlineNotice({
// // //     super.key,
// // //     required this.motorRunning,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final text = motorRunning
// // //         ? "Live telemetry received. Motor is running."
// // //         : "Live telemetry received. Motor is stopped.";
// // //
// // //     return Container(
// // //       padding: const EdgeInsets.all(14),
// // //       decoration: BoxDecoration(
// // //         color: AppColors.green.withOpacity(0.10),
// // //         borderRadius: BorderRadius.circular(18),
// // //         border: Border.all(color: AppColors.green.withOpacity(0.24)),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           const Icon(
// // //             Icons.check_circle_rounded,
// // //             color: AppColors.green,
// // //             size: 22,
// // //           ),
// // //           const SizedBox(width: 10),
// // //           Expanded(
// // //             child: Text(
// // //               text,
// // //               style: TextStyle(
// // //                 color: AppColors.white.withOpacity(0.78),
// // //                 fontSize: 12.8,
// // //                 fontWeight: FontWeight.w700,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class CustomerNameInputCard extends StatelessWidget {
// // //   final TextEditingController controller;
// // //   final FocusNode focusNode;
// // //   final List<String> suggestions;
// // //   final bool enabled;
// // //
// // //   const CustomerNameInputCard({
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
// // //         return suggestions.where(
// // //               (name) => name.toLowerCase().contains(input),
// // //         );
// // //       },
// // //       onSelected: (String value) {
// // //         controller.text = value;
// // //         controller.selection = TextSelection.fromPosition(
// // //           TextPosition(offset: controller.text.length),
// // //         );
// // //       },
// // //       fieldViewBuilder: (
// // //           context,
// // //           textEditingController,
// // //           fieldFocusNode,
// // //           onFieldSubmitted,
// // //           ) {
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
// // //             style: const TextStyle(
// // //               color: AppColors.white,
// // //               fontWeight: FontWeight.w700,
// // //             ),
// // //             textInputAction: TextInputAction.done,
// // //             decoration: InputDecoration(
// // //               hintText: enabled
// // //                   ? "Customer name for Khata"
// // //                   : "Device must be online first",
// // //               hintStyle: TextStyle(
// // //                 color: AppColors.white.withOpacity(0.42),
// // //               ),
// // //               prefixIcon: Icon(
// // //                 enabled
// // //                     ? Icons.person_outline_rounded
// // //                     : Icons.lock_outline_rounded,
// // //                 color: AppColors.primary,
// // //               ),
// // //               border: InputBorder.none,
// // //               contentPadding: const EdgeInsets.symmetric(
// // //                 horizontal: 18,
// // //                 vertical: 18,
// // //               ),
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
// // //               constraints: const BoxConstraints(
// // //                 maxHeight: 240,
// // //                 maxWidth: 560,
// // //               ),
// // //               margin: const EdgeInsets.only(top: 8),
// // //               decoration: BoxDecoration(
// // //                 color: AppColors.cardDark,
// // //                 borderRadius: BorderRadius.circular(18),
// // //                 border: Border.all(color: AppColors.borderDark),
// // //               ),
// // //               child: ListView.separated(
// // //                 padding: const EdgeInsets.symmetric(vertical: 6),
// // //                 shrinkWrap: true,
// // //                 itemCount: options.length,
// // //                 separatorBuilder: (_, __) {
// // //                   return Divider(
// // //                     height: 1,
// // //                     color: AppColors.white.withOpacity(0.06),
// // //                   );
// // //                 },
// // //                 itemBuilder: (context, index) {
// // //                   final option = options.elementAt(index);
// // //
// // //                   return ListTile(
// // //                     dense: true,
// // //                     leading: const Icon(
// // //                       Icons.person_rounded,
// // //                       color: AppColors.primary,
// // //                     ),
// // //                     title: Text(
// // //                       option,
// // //                       style: const TextStyle(
// // //                         color: AppColors.white,
// // //                         fontWeight: FontWeight.w800,
// // //                       ),
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
// // // class MotorCommandButton extends StatelessWidget {
// // //   final bool hasDevice;
// // //   final bool deviceOnline;
// // //   final bool isOn;
// // //   final bool loading;
// // //   final double size;
// // //
// // //   const MotorCommandButton({
// // //     super.key,
// // //     required this.hasDevice,
// // //     required this.deviceOnline,
// // //     required this.isOn,
// // //     required this.loading,
// // //     required this.size,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final activeColor = !hasDevice
// // //         ? AppColors.primary
// // //         : !deviceOnline
// // //         ? AppColors.warning
// // //         : isOn
// // //         ? AppColors.green
// // //         : AppColors.error;
// // //
// // //     final label = !hasDevice
// // //         ? "SELECT"
// // //         : !deviceOnline
// // //         ? "WAIT"
// // //         : isOn
// // //         ? "ON"
// // //         : "OFF";
// // //
// // //     final icon = !hasDevice
// // //         ? Icons.devices_other_rounded
// // //         : !deviceOnline
// // //         ? Icons.wifi_tethering_error_rounded
// // //         : isOn
// // //         ? Icons.power_settings_new_rounded
// // //         : Icons.power_off_rounded;
// // //
// // //     final textColor = !hasDevice ? AppColors.black : AppColors.white;
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
// // //           colors: [
// // //             activeColor,
// // //             activeColor.withOpacity(0.72),
// // //           ],
// // //         ),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: activeColor.withOpacity(0.30),
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
// // //           Icon(
// // //             icon,
// // //             color: textColor,
// // //             size: size < 190 ? 36 : 42,
// // //           ),
// // //           const SizedBox(height: 8),
// // //           FittedBox(
// // //             child: Text(
// // //               label,
// // //               style: TextStyle(
// // //                 color: textColor,
// // //                 fontSize: label == "SELECT"
// // //                     ? 24
// // //                     : label == "WAIT"
// // //                     ? 24
// // //                     : size < 190
// // //                     ? 26
// // //                     : 36,
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
// // // class MotorCommandStatusText extends StatelessWidget {
// // //   final bool hasDevice;
// // //   final bool deviceOnline;
// // //   final bool isOn;
// // //   final String runningTime;
// // //
// // //   const MotorCommandStatusText({
// // //     super.key,
// // //     required this.hasDevice,
// // //     required this.deviceOnline,
// // //     required this.isOn,
// // //     required this.runningTime,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final text = !hasDevice
// // //         ? "Select a device to activate motor control"
// // //         : !deviceOnline
// // //         ? "Waiting for live telemetry"
// // //         : isOn
// // //         ? "Motor running | $runningTime"
// // //         : "Device online | Motor stopped";
// // //
// // //     return Text(
// // //       text,
// // //       textAlign: TextAlign.center,
// // //       style: TextStyle(
// // //         color: AppColors.white.withOpacity(0.76),
// // //         fontSize: 16,
// // //         fontWeight: FontWeight.w700,
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class ParameterMetric {
// // //   final IconData icon;
// // //   final String title;
// // //   final String value;
// // //   final bool highlight;
// // //
// // //   const ParameterMetric({
// // //     required this.icon,
// // //     required this.title,
// // //     required this.value,
// // //     this.highlight = false,
// // //   });
// // // }
// // //
// // // class ParameterGridSection extends StatelessWidget {
// // //   final int crossAxisCount;
// // //   final double childAspectRatio;
// // //   final List<ParameterMetric> metrics;
// // //
// // //   const ParameterGridSection({
// // //     super.key,
// // //     required this.crossAxisCount,
// // //     required this.childAspectRatio,
// // //     required this.metrics,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GridView.count(
// // //       shrinkWrap: true,
// // //       physics: const NeverScrollableScrollPhysics(),
// // //       crossAxisCount: crossAxisCount,
// // //       crossAxisSpacing: 14,
// // //       mainAxisSpacing: 14,
// // //       childAspectRatio: childAspectRatio,
// // //       children: metrics.map((metric) {
// // //         return ParameterMetricCard(metric: metric);
// // //       }).toList(),
// // //     );
// // //   }
// // // }
// // //
// // // class ParameterMetricCard extends StatelessWidget {
// // //   final ParameterMetric metric;
// // //
// // //   const ParameterMetricCard({
// // //     super.key,
// // //     required this.metric,
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
// // //           color: metric.highlight
// // //               ? AppColors.primary.withOpacity(0.38)
// // //               : AppColors.borderDark,
// // //         ),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.20),
// // //             blurRadius: 18,
// // //             offset: const Offset(0, 9),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Icon(
// // //             metric.icon,
// // //             color: metric.highlight
// // //                 ? AppColors.primary
// // //                 : AppColors.white.withOpacity(0.45),
// // //             size: compact ? 24 : 28,
// // //           ),
// // //           const Spacer(),
// // //           Text(
// // //             metric.title,
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
// // //               metric.value,
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
// // import "dart:async";
// // import "dart:ui" show FontFeature;
// //
// // import "package:flutter/material.dart";
// // import "package:flutter/services.dart";
// // import "package:flutter_riverpod/flutter_riverpod.dart";
// //
// // import "package:smart_iot_app/src/core/constant/app_color.dart";
// // import "package:smart_iot_app/src/features/khata/data/models/khata_entry_model.dart";
// // import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
// //
// // import "../../../../app/routes.dart";
// // import "../../../khata/presentation/providers/ khata_providers.dart";
// // import "../../../motor/presentation/ providers/motor_providers.dart";
// // import "../../../telemetry/presentation/providers/telemetry_providers.dart";
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
// //     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
// //   late AnimationController pulseController;
// //   late Animation<double> pulseAnimation;
// //
// //   final TextEditingController customerNameController = TextEditingController();
// //   final FocusNode customerNameFocusNode = FocusNode();
// //
// //   KhataEntryModel? activeKhataEntry;
// //
// //   Timer? telemetryTimer;
// //   Timer? runTimer;
// //
// //   int runSeconds = 0;
// //   DateTime? motorStartedAt;
// //
// //   String? userId;
// //   String? deviceId;
// //   String? deviceName;
// //
// //   bool didSetupDevice = false;
// //   bool isTelemetryLoading = false;
// //   bool firstTelemetryLoaded = false;
// //
// //   // Keeps the motor button in loading state until VFD telemetry confirms
// //   // the requested ON/OFF state.
// //   bool isWaitingForVfdConfirmation = false;
// //
// //   // While a command is pending, keep showing the last confirmed state.
// //   // This prevents ON -> OFF -> ON / OFF -> ON -> OFF visual flicker.
// //   bool? motorStateBeforePendingCommand;
// //
// //   bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
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
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.resumed) {
// //       _refreshRunSeconds();
// //
// //       if (hasDevice) {
// //         Future.microtask(() => loadTelemetry(showError: false));
// //       }
// //     }
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
// //     if (args is Map) {
// //       userId = args["userId"]?.toString();
// //
// //       final rawDeviceId = args["deviceId"]?.toString().trim();
// //       if (rawDeviceId != null && rawDeviceId.isNotEmpty) {
// //         deviceId = rawDeviceId;
// //       }
// //
// //       final rawDeviceName = args["deviceName"]?.toString().trim();
// //       if (rawDeviceName != null && rawDeviceName.isNotEmpty) {
// //         deviceName = rawDeviceName;
// //       }
// //     }
// //
// //     final widgetDeviceId = widget.deviceId?.trim();
// //
// //     if (!hasDevice && widgetDeviceId != null && widgetDeviceId.isNotEmpty) {
// //       deviceId = widgetDeviceId;
// //     }
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
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     pulseController.dispose();
// //     customerNameController.dispose();
// //     customerNameFocusNode.dispose();
// //     telemetryTimer?.cancel();
// //     runTimer?.cancel();
// //     super.dispose();
// //   }
// //
// //   int _toInt(dynamic value) {
// //     if (value == null) return 0;
// //     if (value is int) return value;
// //     if (value is double) return value.toInt();
// //     if (value is num) return value.toInt();
// //     return int.tryParse(value.toString()) ?? 0;
// //   }
// //
// //   bool isDeviceOnline(dynamic latest) {
// //     if (!hasDevice) return false;
// //     if (latest == null) return false;
// //
// //     final live = _toInt(latest.isLive) == 1;
// //     final fresh = latest.isFresh(withinSeconds: 20);
// //
// //     return live && fresh;
// //   }
// //
// //
// //   bool isMotorRunning(dynamic latest) {
// //     if (!hasDevice) return false;
// //     if (!isDeviceOnline(latest)) return false;
// //
// //     final statusCode = _toInt(latest.statusCode);
// //
// //     return statusCode == 1 || statusCode == 2;
// //   }
// //
// //   Future<void> loadTelemetry({bool showError = false}) async {
// //     if (!hasDevice) return;
// //     if (isTelemetryLoading) return;
// //
// //     final isFirstLoad = !firstTelemetryLoaded;
// //
// //     isTelemetryLoading = true;
// //
// //     try {
// //       await ref.read(telemetryViewModelProvider.notifier).loadLatest(
// //         deviceId!,
// //         showLoading: isFirstLoad,
// //       );
// //     } catch (e) {
// //       if (showError) {
// //         showMessage(
// //           "Telemetry failed: ${friendlyError(e.toString())}",
// //           true,
// //           seconds: 8,
// //         );
// //       }
// //     } finally {
// //       isTelemetryLoading = false;
// //
// //       if (mounted && isFirstLoad) {
// //         setState(() {
// //           firstTelemetryLoaded = true;
// //         });
// //       }
// //     }
// //   }
// //
// //   Future<bool> _waitForVfdConfirmation({
// //     required bool expectedOn,
// //     required int telemetryTimestampBeforeCommand,
// //   }) async {
// //     final deadline = DateTime.now().add(const Duration(seconds: 30));
// //
// //     int consecutiveMatches = 0;
// //     int lastCheckedTimestamp = telemetryTimestampBeforeCommand;
// //
// //     while (mounted && DateTime.now().isBefore(deadline)) {
// //       await loadTelemetry(showError: false);
// //
// //       if (!mounted) return false;
// //
// //       final latest = ref.read(telemetryViewModelProvider).latest;
// //
// //       if (!isDeviceOnline(latest)) {
// //         await Future.delayed(const Duration(seconds: 1));
// //         continue;
// //       }
// //
// //       final telemetryTimestamp = _toInt(latest?.timestamp);
// //
// //       // Do not confirm from the telemetry record that existed before
// //       // the command, and do not count the same telemetry record twice.
// //       if (telemetryTimestamp <= telemetryTimestampBeforeCommand ||
// //           telemetryTimestamp <= lastCheckedTimestamp) {
// //         await Future.delayed(const Duration(seconds: 1));
// //         continue;
// //       }
// //
// //       lastCheckedTimestamp = telemetryTimestamp;
// //
// //       final confirmedMotorState = isMotorRunning(latest);
// //
// //       if (confirmedMotorState == expectedOn) {
// //         consecutiveMatches++;
// //
// //         // Two NEW consecutive VFD readings must agree before the UI
// //         // leaves the circular progress state. This removes transient
// //         // ON/OFF/ON or OFF/ON/OFF flicker.
// //         if (consecutiveMatches >= 2) {
// //           return true;
// //         }
// //       } else {
// //         consecutiveMatches = 0;
// //       }
// //
// //       await Future.delayed(const Duration(seconds: 1));
// //     }
// //
// //     return false;
// //   }
// //
// //   void _startLocalTimer({DateTime? startedAt}) {
// //     if (startedAt != null) {
// //       motorStartedAt = startedAt;
// //     } else {
// //       motorStartedAt ??= DateTime.now();
// //     }
// //
// //     runTimer?.cancel();
// //     _refreshRunSeconds();
// //
// //     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
// //       _refreshRunSeconds();
// //     });
// //   }
// //
// //   void _refreshRunSeconds() {
// //     final startedAt = motorStartedAt;
// //     if (!mounted || startedAt == null) return;
// //
// //     final elapsed = DateTime.now().difference(startedAt).inSeconds;
// //     final safeElapsed = elapsed < 0 ? 0 : elapsed;
// //
// //     if (safeElapsed != runSeconds) {
// //       setState(() {
// //         runSeconds = safeElapsed;
// //       });
// //     }
// //   }
// //
// //   void _stopLocalTimer({bool resetStart = true}) {
// //     runTimer?.cancel();
// //     runTimer = null;
// //
// //     if (resetStart) {
// //       motorStartedAt = null;
// //     }
// //   }
// //
// //   String get runningTime {
// //     final seconds = runSeconds < 0 ? 0 : runSeconds;
// //     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
// //     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
// //     final s = (seconds % 60).toString().padLeft(2, "0");
// //     return "$h:$m:$s";
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
// //         text.contains("connection refused")) {
// //       return "No internet connection. Please check Wi-Fi or mobile data.";
// //     }
// //
// //     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
// //
// //     return error!;
// //   }
// //
// //   String formatValue(
// //       double? value,
// //       String unit, {
// //         int decimals = 1,
// //       }) {
// //     if (!hasDevice) return "-- $unit";
// //     if (value == null) return "-- $unit";
// //     return "${value.toStringAsFixed(decimals)} $unit";
// //   }
// //
// //   Future<void> toggleMotor() async {
// //     if (!hasDevice) {
// //       showMessage("Please select a device first.", true);
// //       return;
// //     }
// //
// //     final latest = ref.read(telemetryViewModelProvider).latest;
// //
// //     final deviceOnline = isDeviceOnline(latest);
// //     final motorRunning = isMotorRunning(latest);
// //     final telemetryTimestampBeforeCommand = _toInt(latest?.timestamp);
// //
// //     if (!deviceOnline) {
// //       showMessage(
// //         "Device is offline. Wait for live telemetry before motor control.",
// //         true,
// //         seconds: 8,
// //       );
// //       return;
// //     }
// //
// //     FocusScope.of(context).unfocus();
// //     HapticFeedback.mediumImpact();
// //
// //     final typedCustomerName = customerNameController.text.trim();
// //     final motorVm = ref.read(motorViewModelProvider.notifier);
// //
// //     // Validate before showing the command spinner.
// //     if (!motorRunning && typedCustomerName.isEmpty) {
// //       showMessage("Customer name is required to start motor.", true);
// //       return;
// //     }
// //
// //     if (mounted) {
// //       setState(() {
// //         motorStateBeforePendingCommand = motorRunning;
// //         isWaitingForVfdConfirmation = true;
// //       });
// //     }
// //
// //     try {
// //       if (motorRunning) {
// //         final stoppedLog = await motorVm.stopMotor(
// //           deviceId: deviceId!,
// //           customerName: activeKhataEntry?.customerName ??
// //               (typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName),
// //         );
// //
// //         final updatedMotorState = ref.read(motorViewModelProvider);
// //
// //         if (updatedMotorState.error != null) {
// //           showMessage(updatedMotorState.error!, true, seconds: 10);
// //           return;
// //         }
// //
// //         final endTime = stoppedLog?.endTime ?? DateTime.now();
// //
// //         if (activeKhataEntry != null) {
// //           await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
// //             entry: activeKhataEntry!,
// //             endTime: endTime,
// //           );
// //
// //           activeKhataEntry = null;
// //         }
// //
// //         await ref.read(khataViewModelProvider.notifier).loadEntries();
// //
// //         // Do NOT show OFF just because the stop API returned successfully.
// //         // Keep circular progress visible until VFD telemetry itself says OFF.
// //         final vfdConfirmedOff = await _waitForVfdConfirmation(
// //           expectedOn: false,
// //           telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
// //         );
// //
// //         if (!vfdConfirmedOff) {
// //           showMessage(
// //             "Stop command was sent, but OFF confirmation was not received from VFD telemetry.",
// //             true,
// //             seconds: 10,
// //           );
// //           return;
// //         }
// //
// //         _stopLocalTimer();
// //
// //         if (mounted) {
// //           setState(() {
// //             runSeconds = 0;
// //           });
// //         }
// //
// //         showMessage("Motor stopped. Khata session closed.", false);
// //         return;
// //       }
// //
// //       final startedLog = await motorVm.startMotor(
// //         deviceId: deviceId!,
// //         customerName: typedCustomerName,
// //       );
// //
// //       final motorCommandStartedAt = startedLog?.startTime ?? DateTime.now();
// //
// //       final updatedMotorState = ref.read(motorViewModelProvider);
// //
// //       if (updatedMotorState.error != null) {
// //         showMessage(updatedMotorState.error!, true, seconds: 10);
// //         return;
// //       }
// //
// //       if (startedLog != null) {
// //         activeKhataEntry =
// //         await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
// //           customerName: typedCustomerName,
// //           deviceId: deviceId!,
// //           motorLogId: startedLog.id ?? "",
// //           startTime: startedLog.startTime ?? motorCommandStartedAt,
// //         );
// //       }
// //
// //       await ref.read(khataViewModelProvider.notifier).loadEntries();
// //
// //       // Do NOT show ON just because the start API returned successfully.
// //       // Keep circular progress visible until VFD telemetry itself says ON.
// //       final vfdConfirmedOn = await _waitForVfdConfirmation(
// //         expectedOn: true,
// //         telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
// //       );
// //
// //       if (!vfdConfirmedOn) {
// //         showMessage(
// //           "Start command was sent, but ON confirmation was not received from VFD telemetry.",
// //           true,
// //           seconds: 10,
// //         );
// //         return;
// //       }
// //
// //       if (mounted) {
// //         setState(() {
// //           runSeconds = 0;
// //         });
// //       }
// //
// //       _startLocalTimer(startedAt: motorCommandStartedAt);
// //
// //       showMessage("Motor started. Khata session opened.", false);
// //     } catch (e) {
// //       showMessage(
// //         "Motor action failed: ${friendlyError(e.toString())}",
// //         true,
// //         seconds: 12,
// //       );
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           isWaitingForVfdConfirmation = false;
// //           motorStateBeforePendingCommand = null;
// //         });
// //       } else {
// //         isWaitingForVfdConfirmation = false;
// //         motorStateBeforePendingCommand = null;
// //       }
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
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(14),
// //           ),
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
// //     final names = <String>[];
// //     final seen = <String>{};
// //
// //     // Newest customers first. Duplicate names are removed case-insensitively.
// //     for (final entry in khataState.entries.reversed) {
// //       final name = entry.customerName?.trim();
// //       if (name == null || name.isEmpty) continue;
// //
// //       final key = name.toLowerCase();
// //       if (seen.add(key)) {
// //         names.add(name);
// //       }
// //     }
// //
// //     return names.take(20).toList();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final latest = ref.watch(
// //       telemetryViewModelProvider.select((state) => state.latest),
// //     );
// //
// //     final motorLoading = ref.watch(
// //       motorViewModelProvider.select((state) => state.isLoading),
// //     );
// //
// //     final motorButtonLoading =
// //         hasDevice && (motorLoading || isWaitingForVfdConfirmation);
// //
// //     final checkingDevice = hasDevice && !firstTelemetryLoaded;
// //
// //     final effectiveLatest = hasDevice && firstTelemetryLoaded ? latest : null;
// //
// //     final deviceOnline = checkingDevice ? false : isDeviceOnline(effectiveLatest);
// //     final telemetryMotorRunning =
// //     checkingDevice ? false : isMotorRunning(effectiveLatest);
// //
// //     final motorRunning = isWaitingForVfdConfirmation &&
// //         motorStateBeforePendingCommand != null
// //         ? motorStateBeforePendingCommand!
// //         : telemetryMotorRunning;
// //
// //     final displayLatest = deviceOnline ? effectiveLatest : null;
// //
// //     if (motorRunning && runTimer == null && !isWaitingForVfdConfirmation) {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (mounted && runTimer == null) {
// //           _startLocalTimer();
// //         }
// //       });
// //     }
// //
// //     // Never reset the run timer just because telemetry becomes stale while
// //     // the app is backgrounded. Stop it only when fresh VFD telemetry says OFF.
// //     if (deviceOnline &&
// //         !telemetryMotorRunning &&
// //         runTimer != null &&
// //         !isWaitingForVfdConfirmation) {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         if (mounted && runTimer != null) {
// //           _stopLocalTimer();
// //           setState(() {
// //             runSeconds = 0;
// //           });
// //         }
// //       });
// //     }
// //
// //     final width = MediaQuery.of(context).size.width;
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
// //     final resolvedDisplayName = deviceName != null && deviceName!.isNotEmpty
// //         ? deviceName!
// //         : hasDevice
// //         ? deviceId!
// //         : "Smart Motor Controller";
// //
// //     return Scaffold(
// //       backgroundColor: AppColors.darkBgSoft,
// //       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
// //       appBar: SmartWellHomeAppBar(
// //         hasDevice: hasDevice,
// //         deviceOnline: deviceOnline,
// //         onSelectDevice: () {
// //           Navigator.pushReplacementNamed(context, AppRoutes.devices);
// //         },
// //       ),
// //       body: SafeArea(
// //         child: RefreshIndicator(
// //           color: AppColors.primary,
// //           backgroundColor: AppColors.cardDark,
// //           onRefresh: () async {
// //             if (hasDevice) {
// //               await loadTelemetry(showError: true);
// //             } else {
// //               showMessage("Please select a device first.", true);
// //             }
// //           },
// //           child: SingleChildScrollView(
// //             physics: const AlwaysScrollableScrollPhysics(
// //               parent: BouncingScrollPhysics(),
// //             ),
// //             padding: EdgeInsets.symmetric(
// //               horizontal: horizontalPadding,
// //               vertical: 18,
// //             ),
// //             child: Center(
// //               child: ConstrainedBox(
// //                 constraints: const BoxConstraints(maxWidth: 1080),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.stretch,
// //                   children: [
// //                     SmartDeviceHeaderCard(
// //                       hasDevice: hasDevice,
// //                       deviceOnline: deviceOnline,
// //                       motorRunning: motorRunning,
// //                       displayName: resolvedDisplayName,
// //                       deviceId: deviceId,
// //                     ),
// //                     if (!hasDevice) ...[
// //                       const SizedBox(height: 12),
// //                       NoDeviceProfessionalNotice(
// //                         onSelectDevice: () {
// //                           Navigator.pushReplacementNamed(
// //                             context,
// //                             AppRoutes.devices,
// //                           );
// //                         },
// //                       ),
// //                     ],
// //                     if (hasDevice && !deviceOnline) ...[
// //                       const SizedBox(height: 12),
// //                       DeviceOfflineNotice(
// //                         onRetry: () => loadTelemetry(showError: true),
// //                       ),
// //                     ],
// //                     if (hasDevice && deviceOnline) ...[
// //                       const SizedBox(height: 12),
// //                       DeviceOnlineNotice(
// //                         motorRunning: motorRunning,
// //                       ),
// //                     ],
// //                     const SizedBox(height: 18),
// //                     CustomerNameInputCard(
// //                       controller: customerNameController,
// //                       focusNode: customerNameFocusNode,
// //                       suggestions: customerSuggestions(),
// //                       enabled: hasDevice && deviceOnline,
// //                     ),
// //                     const SizedBox(height: 26),
// //                     Center(
// //                       child: GestureDetector(
// //                         onTap: motorButtonLoading ? null : toggleMotor,
// //                         child: AnimatedBuilder(
// //                           animation: pulseAnimation,
// //                           builder: (context, child) {
// //                             final scale = motorButtonLoading
// //                                 ? 1.0
// //                                 : motorRunning
// //                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
// //                                 : 1.0;
// //
// //                             return Transform.scale(
// //                               scale: scale,
// //                               child: child,
// //                             );
// //                           },
// //                           child: MotorCommandButton(
// //                             hasDevice: hasDevice,
// //                             deviceOnline: deviceOnline,
// //                             isOn: motorRunning,
// //                             loading: motorButtonLoading,
// //                             size: buttonSize,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 18),
// //                     MotorRunStatusCard(
// //                       hasDevice: hasDevice,
// //                       deviceOnline: deviceOnline,
// //                       isOn: motorRunning,
// //                       waitingForVfd: isWaitingForVfdConfirmation,
// //                       runningTime: runningTime,
// //                     ),
// //                     const SizedBox(height: 22),
// //                     ParameterGridSection(
// //                       crossAxisCount: crossAxisCount,
// //                       childAspectRatio: childAspectRatio,
// //                       metrics: [
// //                         ParameterMetric(
// //                           icon: Icons.sync_rounded,
// //                           title: "Frequency",
// //                           value: formatValue(displayLatest?.freq, "Hz"),
// //                           highlight: true,
// //                         ),
// //                         ParameterMetric(
// //                           icon: Icons.bolt_rounded,
// //                           title: "Voltage",
// //                           value: formatValue(displayLatest?.voltage, "V"),
// //                         ),
// //                         ParameterMetric(
// //                           icon: Icons.flash_on_rounded,
// //                           title: "Current",
// //                           value: formatValue(displayLatest?.current, "A"),
// //                         ),
// //                         ParameterMetric(
// //                           icon: Icons.power_rounded,
// //                           title: "Power",
// //                           value: formatValue(displayLatest?.power, "kW"),
// //                         ),
// //                         ParameterMetric(
// //                           icon: Icons.speed_rounded,
// //                           title: "Load",
// //                           value: formatValue(
// //                             displayLatest?.powerPercent,
// //                             "%",
// //                           ),
// //                         ),
// //                         ParameterMetric(
// //                           icon: Icons.rotate_right_rounded,
// //                           title: "Motor Speed",
// //                           value: formatValue(
// //                             displayLatest?.motorSpeed,
// //                             "RPM",
// //                           ),
// //                         ),
// //                         ParameterMetric(
// //                           icon: Icons.battery_charging_full_rounded,
// //                           title: "DC Bus",
// //                           value: formatValue(displayLatest?.dcbus, "V"),
// //                         ),
// //                         ParameterMetric(
// //                           icon: Icons.electric_meter_rounded,
// //                           title: "Energy",
// //                           value: formatValue(
// //                             displayLatest?.energyIn,
// //                             "kWh",
// //                           ),
// //                         ),
// //                       ],
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
// // class SmartWellHomeAppBar extends StatelessWidget
// //     implements PreferredSizeWidget {
// //   final bool hasDevice;
// //   final bool deviceOnline;
// //   final VoidCallback onSelectDevice;
// //
// //   const SmartWellHomeAppBar({
// //     super.key,
// //     required this.hasDevice,
// //     required this.deviceOnline,
// //     required this.onSelectDevice,
// //   });
// //
// //   @override
// //   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final statusText = !hasDevice
// //         ? "No device selected"
// //         : deviceOnline
// //         ? "Device online"
// //         : "Waiting for device";
// //
// //     final statusColor = !hasDevice
// //         ? AppColors.white.withOpacity(0.55)
// //         : deviceOnline
// //         ? AppColors.green
// //         : AppColors.warning;
// //
// //     return AppBar(
// //       backgroundColor: AppColors.primaryDark,
// //       elevation: 0,
// //       centerTitle: false,
// //       automaticallyImplyLeading: hasDevice,
// //       iconTheme: const IconThemeData(color: AppColors.white),
// //       titleSpacing: 18,
// //       title: Row(
// //         children: [
// //           Container(
// //             height: 42,
// //             width: 42,
// //             decoration: BoxDecoration(
// //               borderRadius: BorderRadius.circular(14),
// //               gradient: LinearGradient(
// //                 colors: [
// //                   AppColors.darkBgSoft,
// //                   AppColors.darkBgSoft.withOpacity(0.72),
// //                 ],
// //               ),
// //             ),
// //             child: const Icon(
// //               Icons.electric_bolt_rounded,
// //               color: AppColors.white,
// //               size: 24,
// //             ),
// //           ),
// //           const SizedBox(width: 14),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 const Text(
// //                   "AabNex",
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     color: AppColors.white,
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.w900,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   statusText,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     color: statusColor,
// //                     fontSize: 11.5,
// //                     fontWeight: FontWeight.w800,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //       actions: [
// //         Padding(
// //           padding: const EdgeInsets.only(right: 10),
// //           child: IconButton(
// //             tooltip: "Select Device",
// //             onPressed: onSelectDevice,
// //             icon: Container(
// //               padding: const EdgeInsets.all(10),
// //               decoration: BoxDecoration(
// //                 color: AppColors.cardDark,
// //                 borderRadius: BorderRadius.circular(14),
// //                 border: Border.all(color: AppColors.borderDark),
// //               ),
// //               child: const Icon(
// //                 Icons.devices_other_rounded,
// //                 color: AppColors.primary,
// //                 size: 22,
// //               ),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // class SmartDeviceHeaderCard extends StatelessWidget {
// //   final bool hasDevice;
// //   final bool deviceOnline;
// //   final bool motorRunning;
// //   final String displayName;
// //   final String? deviceId;
// //
// //   const SmartDeviceHeaderCard({
// //     super.key,
// //     required this.hasDevice,
// //     required this.deviceOnline,
// //     required this.motorRunning,
// //     required this.displayName,
// //     required this.deviceId,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = !hasDevice
// //         ? AppColors.primary
// //         : !deviceOnline
// //         ? AppColors.warning
// //         : motorRunning
// //         ? AppColors.green
// //         : AppColors.primary;
// //
// //     final icon = !hasDevice
// //         ? Icons.hub_outlined
// //         : !deviceOnline
// //         ? Icons.wifi_tethering_error_rounded
// //         : motorRunning
// //         ? Icons.power_settings_new_rounded
// //         : Icons.verified_rounded;
// //
// //     final statusText = !hasDevice
// //         ? "Ready to connect"
// //         : !deviceOnline
// //         ? "Waiting for live telemetry"
// //         : motorRunning
// //         ? "Device online | Motor ON"
// //         : "Device online | Motor OFF";
// //
// //     return Container(
// //       padding: const EdgeInsets.all(18),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardDark,
// //         borderRadius: BorderRadius.circular(26),
// //         border: Border.all(color: AppColors.borderDark),
// //         boxShadow: [
// //           BoxShadow(
// //             color: color.withOpacity(0.10),
// //             blurRadius: 28,
// //             offset: const Offset(0, 14),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             height: 62,
// //             width: 62,
// //             decoration: BoxDecoration(
// //               color: color.withOpacity(0.14),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Icon(
// //               icon,
// //               color: color,
// //               size: 32,
// //             ),
// //           ),
// //           const SizedBox(width: 14),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   displayName,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: const TextStyle(
// //                     color: AppColors.white,
// //                     fontSize: 17,
// //                     fontWeight: FontWeight.w900,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 6),
// //                 Text(
// //                   statusText,
// //                   style: TextStyle(
// //                     color: color,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w800,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 5),
// //                 Text(
// //                   hasDevice ? deviceId! : "No controller selected",
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     color: AppColors.white.withOpacity(0.45),
// //                     fontSize: 11,
// //                     fontWeight: FontWeight.w700,
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
// // class NoDeviceProfessionalNotice extends StatelessWidget {
// //   final VoidCallback onSelectDevice;
// //
// //   const NoDeviceProfessionalNotice({
// //     super.key,
// //     required this.onSelectDevice,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(18),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardDark,
// //         borderRadius: BorderRadius.circular(24),
// //         border: Border.all(color: AppColors.borderDark),
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             height: 46,
// //             width: 46,
// //             decoration: BoxDecoration(
// //               color: AppColors.primary.withOpacity(0.10),
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: const Icon(
// //               Icons.devices_other_rounded,
// //               color: AppColors.primary,
// //             ),
// //           ),
// //           const SizedBox(width: 14),
// //           Expanded(
// //             child: Text(
// //               "Select a device to enable motor control. Parameters stay empty until a controller is selected.",
// //               style: TextStyle(
// //                 color: AppColors.white.withOpacity(0.68),
// //                 fontSize: 13.5,
// //                 height: 1.4,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 10),
// //           TextButton(
// //             onPressed: onSelectDevice,
// //             child: const Text(
// //               "Select",
// //               style: TextStyle(
// //                 color: AppColors.primary,
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
// // class DeviceOfflineNotice extends StatelessWidget {
// //   final Future<void> Function() onRetry;
// //
// //   const DeviceOfflineNotice({
// //     super.key,
// //     required this.onRetry,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: AppColors.warning.withOpacity(0.10),
// //         borderRadius: BorderRadius.circular(18),
// //         border: Border.all(color: AppColors.warning.withOpacity(0.24)),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(
// //             Icons.info_outline_rounded,
// //             color: AppColors.warning,
// //             size: 22,
// //           ),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Text(
// //               "Device selected. Waiting for latest live reading.",
// //               style: TextStyle(
// //                 color: AppColors.white.withOpacity(0.78),
// //                 fontSize: 12.8,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //           TextButton(
// //             onPressed: onRetry,
// //             child: const Text(
// //               "Retry",
// //               style: TextStyle(
// //                 color: AppColors.warning,
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
// // class DeviceOnlineNotice extends StatelessWidget {
// //   final bool motorRunning;
// //
// //   const DeviceOnlineNotice({
// //     super.key,
// //     required this.motorRunning,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final text = motorRunning
// //         ? "Live telemetry received. Motor is running."
// //         : "Live telemetry received. Motor is stopped.";
// //
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: AppColors.green.withOpacity(0.10),
// //         borderRadius: BorderRadius.circular(18),
// //         border: Border.all(color: AppColors.green.withOpacity(0.24)),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(
// //             Icons.check_circle_rounded,
// //             color: AppColors.green,
// //             size: 22,
// //           ),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: TextStyle(
// //                 color: AppColors.white.withOpacity(0.78),
// //                 fontSize: 12.8,
// //                 fontWeight: FontWeight.w700,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class CustomerNameInputCard extends StatelessWidget {
// //   final TextEditingController controller;
// //   final FocusNode focusNode;
// //   final List<String> suggestions;
// //   final bool enabled;
// //
// //   const CustomerNameInputCard({
// //     super.key,
// //     required this.controller,
// //     required this.focusNode,
// //     required this.suggestions,
// //     required this.enabled,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.only(left: 4, bottom: 9),
// //           child: Row(
// //             children: [
// //               Icon(
// //                 Icons.account_circle_outlined,
// //                 size: 17,
// //                 color: AppColors.white.withOpacity(0.48),
// //               ),
// //               const SizedBox(width: 7),
// //               Text(
// //                 "CUSTOMER / KHATA",
// //                 style: TextStyle(
// //                   color: AppColors.white.withOpacity(0.56),
// //                   fontSize: 11,
// //                   letterSpacing: 1.1,
// //                   fontWeight: FontWeight.w900,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         RawAutocomplete<String>(
// //           textEditingController: controller,
// //           focusNode: focusNode,
// //           optionsBuilder: (TextEditingValue value) {
// //             if (!enabled) return const Iterable<String>.empty();
// //
// //             final input = value.text.trim().toLowerCase();
// //
// //             if (input.isEmpty) {
// //               return suggestions.take(8);
// //             }
// //
// //             final startsWith = <String>[];
// //             final contains = <String>[];
// //
// //             for (final name in suggestions) {
// //               final lower = name.toLowerCase();
// //               if (lower.startsWith(input)) {
// //                 startsWith.add(name);
// //               } else if (lower.contains(input)) {
// //                 contains.add(name);
// //               }
// //             }
// //
// //             return [...startsWith, ...contains].take(8);
// //           },
// //           onSelected: (String value) {
// //             controller.text = value;
// //             controller.selection = TextSelection.collapsed(
// //               offset: controller.text.length,
// //             );
// //           },
// //           fieldViewBuilder: (
// //               context,
// //               textEditingController,
// //               fieldFocusNode,
// //               onFieldSubmitted,
// //               ) {
// //             return AnimatedContainer(
// //               duration: const Duration(milliseconds: 180),
// //               decoration: BoxDecoration(
// //                 color: AppColors.cardDark,
// //                 borderRadius: BorderRadius.circular(20),
// //                 border: Border.all(
// //                   color: fieldFocusNode.hasFocus
// //                       ? AppColors.primary.withOpacity(0.70)
// //                       : AppColors.borderDark,
// //                 ),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.black.withOpacity(0.16),
// //                     blurRadius: 16,
// //                     offset: const Offset(0, 8),
// //                   ),
// //                 ],
// //               ),
// //               child: TextField(
// //                 enabled: enabled,
// //                 controller: textEditingController,
// //                 focusNode: fieldFocusNode,
// //                 keyboardType: TextInputType.name,
// //                 textCapitalization: TextCapitalization.words,
// //                 autocorrect: false,
// //                 style: const TextStyle(
// //                   color: AppColors.white,
// //                   fontSize: 15.5,
// //                   fontWeight: FontWeight.w800,
// //                 ),
// //                 textInputAction: TextInputAction.done,
// //                 decoration: InputDecoration(
// //                   hintText: enabled
// //                       ? "Enter new or previous customer"
// //                       : "Device must be online first",
// //                   hintStyle: TextStyle(
// //                     color: AppColors.white.withOpacity(0.38),
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                   prefixIcon: Icon(
// //                     enabled
// //                         ? Icons.person_search_rounded
// //                         : Icons.lock_outline_rounded,
// //                     color: AppColors.primary,
// //                   ),
// //                   suffixIcon: enabled && suggestions.isNotEmpty
// //                       ? Tooltip(
// //                     message: "Previous customers available",
// //                     child: Icon(
// //                       Icons.history_rounded,
// //                       color: AppColors.white.withOpacity(0.38),
// //                     ),
// //                   )
// //                       : null,
// //                   border: InputBorder.none,
// //                   contentPadding: const EdgeInsets.symmetric(
// //                     horizontal: 18,
// //                     vertical: 18,
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //           optionsViewBuilder: (context, onSelected, options) {
// //             final optionList = options.toList();
// //
// //             return Align(
// //               alignment: Alignment.topLeft,
// //               child: Material(
// //                 color: Colors.transparent,
// //                 child: Container(
// //                   width: MediaQuery.of(context).size.width - 36,
// //                   constraints: const BoxConstraints(
// //                     maxHeight: 290,
// //                     maxWidth: 560,
// //                   ),
// //                   margin: const EdgeInsets.only(top: 8),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.cardDark,
// //                     borderRadius: BorderRadius.circular(18),
// //                     border: Border.all(color: AppColors.borderDark),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.28),
// //                         blurRadius: 24,
// //                         offset: const Offset(0, 12),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Padding(
// //                         padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
// //                         child: Row(
// //                           children: [
// //                             const Icon(
// //                               Icons.history_rounded,
// //                               color: AppColors.primary,
// //                               size: 18,
// //                             ),
// //                             const SizedBox(width: 8),
// //                             Text(
// //                               "Previous customers",
// //                               style: TextStyle(
// //                                 color: AppColors.white.withOpacity(0.62),
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.w900,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       Flexible(
// //                         child: ListView.separated(
// //                           padding: const EdgeInsets.only(bottom: 7),
// //                           shrinkWrap: true,
// //                           itemCount: optionList.length,
// //                           separatorBuilder: (_, __) => Divider(
// //                             height: 1,
// //                             color: AppColors.white.withOpacity(0.06),
// //                           ),
// //                           itemBuilder: (context, index) {
// //                             final option = optionList[index];
// //
// //                             return ListTile(
// //                               dense: true,
// //                               leading: Container(
// //                                 height: 34,
// //                                 width: 34,
// //                                 alignment: Alignment.center,
// //                                 decoration: BoxDecoration(
// //                                   color: AppColors.primary.withOpacity(0.10),
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                                 child: const Icon(
// //                                   Icons.person_rounded,
// //                                   color: AppColors.primary,
// //                                   size: 18,
// //                                 ),
// //                               ),
// //                               title: Text(
// //                                 option,
// //                                 style: const TextStyle(
// //                                   color: AppColors.white,
// //                                   fontWeight: FontWeight.w800,
// //                                 ),
// //                               ),
// //                               trailing: Icon(
// //                                 Icons.north_west_rounded,
// //                                 size: 17,
// //                                 color: AppColors.white.withOpacity(0.30),
// //                               ),
// //                               onTap: () => onSelected(option),
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //         if (enabled)
// //           Padding(
// //             padding: const EdgeInsets.only(left: 5, top: 8),
// //             child: Text(
// //               suggestions.isEmpty
// //                   ? "New customer names will appear here next time."
// //                   : "Type to search, or select a previously used customer.",
// //               style: TextStyle(
// //                 color: AppColors.white.withOpacity(0.38),
// //                 fontSize: 11.5,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// // }
// //
// // class MotorCommandButton extends StatelessWidget {
// //   final bool hasDevice;
// //   final bool deviceOnline;
// //   final bool isOn;
// //   final bool loading;
// //   final double size;
// //
// //   const MotorCommandButton({
// //     super.key,
// //     required this.hasDevice,
// //     required this.deviceOnline,
// //     required this.isOn,
// //     required this.loading,
// //     required this.size,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final activeColor = !hasDevice
// //         ? AppColors.primary
// //         : !deviceOnline
// //         ? AppColors.warning
// //         : isOn
// //         ? AppColors.green
// //         : AppColors.error;
// //
// //     final label = !hasDevice
// //         ? "SELECT"
// //         : !deviceOnline
// //         ? "WAIT"
// //         : isOn
// //         ? "ON"
// //         : "OFF";
// //
// //     final icon = !hasDevice
// //         ? Icons.devices_other_rounded
// //         : !deviceOnline
// //         ? Icons.wifi_tethering_error_rounded
// //         : isOn
// //         ? Icons.power_settings_new_rounded
// //         : Icons.power_off_rounded;
// //
// //     final textColor = !hasDevice ? AppColors.black : AppColors.white;
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
// //           colors: [
// //             activeColor,
// //             activeColor.withOpacity(0.72),
// //           ],
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: activeColor.withOpacity(0.30),
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
// //           Icon(
// //             icon,
// //             color: textColor,
// //             size: size < 190 ? 36 : 42,
// //           ),
// //           const SizedBox(height: 8),
// //           FittedBox(
// //             child: Text(
// //               label,
// //               style: TextStyle(
// //                 color: textColor,
// //                 fontSize: label == "SELECT"
// //                     ? 24
// //                     : label == "WAIT"
// //                     ? 24
// //                     : size < 190
// //                     ? 26
// //                     : 36,
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
// // class MotorRunStatusCard extends StatelessWidget {
// //   final bool hasDevice;
// //   final bool deviceOnline;
// //   final bool isOn;
// //   final bool waitingForVfd;
// //   final String runningTime;
// //
// //   const MotorRunStatusCard({
// //     super.key,
// //     required this.hasDevice,
// //     required this.deviceOnline,
// //     required this.isOn,
// //     required this.waitingForVfd,
// //     required this.runningTime,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final active = hasDevice && deviceOnline && isOn;
// //
// //     final title = !hasDevice
// //         ? "NO DEVICE"
// //         : !deviceOnline
// //         ? "WAITING FOR DEVICE"
// //         : waitingForVfd
// //         ? "SYNCING WITH VFD"
// //         : active
// //         ? "MOTOR RUN TIME"
// //         : "MOTOR STOPPED";
// //
// //     final subtitle = !hasDevice
// //         ? "Select a controller to start monitoring"
// //         : !deviceOnline
// //         ? "Waiting for fresh live telemetry"
// //         : waitingForVfd
// //         ? "Waiting for the VFD to confirm the command"
// //         : active
// //         ? "Elapsed time since this motor run started"
// //         : "Timer starts only after VFD confirms ON";
// //
// //     final accent = active ? AppColors.green : AppColors.primary;
// //
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
// //       decoration: BoxDecoration(
// //         color: AppColors.cardDark,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(
// //           color: active
// //               ? AppColors.green.withOpacity(0.28)
// //               : AppColors.borderDark,
// //         ),
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             height: 44,
// //             width: 44,
// //             alignment: Alignment.center,
// //             decoration: BoxDecoration(
// //               color: accent.withOpacity(0.11),
// //               borderRadius: BorderRadius.circular(14),
// //             ),
// //             child: waitingForVfd
// //                 ? SizedBox(
// //               height: 21,
// //               width: 21,
// //               child: CircularProgressIndicator(
// //                 strokeWidth: 2.4,
// //                 color: accent,
// //               ),
// //             )
// //                 : Icon(
// //               active ? Icons.timer_rounded : Icons.timer_off_outlined,
// //               color: accent,
// //               size: 23,
// //             ),
// //           ),
// //           const SizedBox(width: 13),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   title,
// //                   style: TextStyle(
// //                     color: AppColors.white.withOpacity(0.54),
// //                     fontSize: 10.5,
// //                     letterSpacing: 0.9,
// //                     fontWeight: FontWeight.w900,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   subtitle,
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     color: AppColors.white.withOpacity(0.60),
// //                     fontSize: 11.8,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Text(
// //             active ? runningTime : "00:00:00",
// //             style: TextStyle(
// //               color: active
// //                   ? AppColors.green
// //                   : AppColors.white.withOpacity(0.42),
// //               fontSize: 20,
// //               fontWeight: FontWeight.w900,
// //               fontFeatures: const [FontFeature.tabularFigures()],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class ParameterMetric {
// //   final IconData icon;
// //   final String title;
// //   final String value;
// //   final bool highlight;
// //
// //   const ParameterMetric({
// //     required this.icon,
// //     required this.title,
// //     required this.value,
// //     this.highlight = false,
// //   });
// // }
// //
// // class ParameterGridSection extends StatelessWidget {
// //   final int crossAxisCount;
// //   final double childAspectRatio;
// //   final List<ParameterMetric> metrics;
// //
// //   const ParameterGridSection({
// //     super.key,
// //     required this.crossAxisCount,
// //     required this.childAspectRatio,
// //     required this.metrics,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GridView.count(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       crossAxisCount: crossAxisCount,
// //       crossAxisSpacing: 14,
// //       mainAxisSpacing: 14,
// //       childAspectRatio: childAspectRatio,
// //       children: metrics.map((metric) {
// //         return ParameterMetricCard(metric: metric);
// //       }).toList(),
// //     );
// //   }
// // }
// //
// // class ParameterMetricCard extends StatelessWidget {
// //   final ParameterMetric metric;
// //
// //   const ParameterMetricCard({
// //     super.key,
// //     required this.metric,
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
// //           color: metric.highlight
// //               ? AppColors.primary.withOpacity(0.38)
// //               : AppColors.borderDark,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.20),
// //             blurRadius: 18,
// //             offset: const Offset(0, 9),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Icon(
// //             metric.icon,
// //             color: metric.highlight
// //                 ? AppColors.primary
// //                 : AppColors.white.withOpacity(0.45),
// //             size: compact ? 24 : 28,
// //           ),
// //           const Spacer(),
// //           Text(
// //             metric.title,
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
// //               metric.value,
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
// import "dart:async";
// import "dart:ui" show FontFeature;
//
// import "package:flutter/material.dart";
// import "package:flutter/services.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
//
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/khata/data/models/khata_entry_model.dart";
// import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
//
// import "../../../../app/routes.dart";
// import "../../../khata/presentation/providers/ khata_providers.dart";
// import "../../../motor/presentation/ providers/motor_providers.dart";
// import "../../../telemetry/presentation/providers/telemetry_providers.dart";
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
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late AnimationController pulseController;
//   late Animation<double> pulseAnimation;
//
//   final TextEditingController customerNameController = TextEditingController();
//   final FocusNode customerNameFocusNode = FocusNode();
//
//   KhataEntryModel? activeKhataEntry;
//
//   Timer? telemetryTimer;
//   Timer? runTimer;
//
//   int runSeconds = 0;
//   DateTime? motorStartedAt;
//
//   String? userId;
//   String? deviceId;
//   String? deviceName;
//
//   bool didSetupDevice = false;
//   bool isTelemetryLoading = false;
//   bool firstTelemetryLoaded = false;
//
//   // Prevents the UI from starting a brand-new timer before we have checked
//   // whether an existing open Khata session already has the real start time.
//   bool didRestoreMotorSession = false;
//   bool isRestoringMotorSession = false;
//
//   // Keeps the motor button in loading state until VFD telemetry confirms
//   // the requested ON/OFF state.
//   bool isWaitingForVfdConfirmation = false;
//
//   // While a command is pending, keep showing the last confirmed state.
//   // This prevents ON -> OFF -> ON / OFF -> ON -> OFF visual flicker.
//   bool? motorStateBeforePendingCommand;
//
//   bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
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
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _refreshRunSeconds();
//
//       if (hasDevice) {
//         Future.microtask(() async {
//           await loadTelemetry(showError: false);
//           await ref.read(khataViewModelProvider.notifier).loadEntries();
//           await _restoreMotorSessionFromKhata();
//         });
//       }
//     }
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
//       final rawDeviceId = args["deviceId"]?.toString().trim();
//       if (rawDeviceId != null && rawDeviceId.isNotEmpty) {
//         deviceId = rawDeviceId;
//       }
//
//       final rawDeviceName = args["deviceName"]?.toString().trim();
//       if (rawDeviceName != null && rawDeviceName.isNotEmpty) {
//         deviceName = rawDeviceName;
//       }
//     }
//
//     final widgetDeviceId = widget.deviceId?.trim();
//
//     if (!hasDevice && widgetDeviceId != null && widgetDeviceId.isNotEmpty) {
//       deviceId = widgetDeviceId;
//     }
//
//     if (hasDevice) {
//       Future.microtask(() async {
//         await loadTelemetry();
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//         await _restoreMotorSessionFromKhata();
//       });
//
//       telemetryTimer?.cancel();
//       telemetryTimer = Timer.periodic(
//         const Duration(seconds: 5),
//             (_) => loadTelemetry(showError: false),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     pulseController.dispose();
//     customerNameController.dispose();
//     customerNameFocusNode.dispose();
//     telemetryTimer?.cancel();
//     runTimer?.cancel();
//     super.dispose();
//   }
//
//   int _toInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is num) return value.toInt();
//     return int.tryParse(value.toString()) ?? 0;
//   }
//
//   bool isDeviceOnline(dynamic latest) {
//     if (!hasDevice) return false;
//     if (latest == null) return false;
//
//     final live = _toInt(latest.isLive) == 1;
//     final fresh = latest.isFresh(withinSeconds: 20);
//
//     return live && fresh;
//   }
//
//
//   bool isMotorRunning(dynamic latest) {
//     if (!hasDevice) return false;
//     if (!isDeviceOnline(latest)) return false;
//
//     final statusCode = _toInt(latest.statusCode);
//
//     return statusCode == 1 || statusCode == 2;
//   }
//
//   Future<void> loadTelemetry({bool showError = false}) async {
//     if (!hasDevice) return;
//     if (isTelemetryLoading) return;
//
//     final isFirstLoad = !firstTelemetryLoaded;
//
//     isTelemetryLoading = true;
//
//     try {
//       await ref.read(telemetryViewModelProvider.notifier).loadLatest(
//         deviceId!,
//         showLoading: isFirstLoad,
//       );
//     } catch (e) {
//       if (showError) {
//         showMessage(
//           "Telemetry failed: ${friendlyError(e.toString())}",
//           true,
//           seconds: 8,
//         );
//       }
//     } finally {
//       isTelemetryLoading = false;
//
//       if (mounted && isFirstLoad) {
//         setState(() {
//           firstTelemetryLoaded = true;
//         });
//       }
//     }
//   }
//
//   Future<bool> _waitForVfdConfirmation({
//     required bool expectedOn,
//     required int telemetryTimestampBeforeCommand,
//   }) async {
//     final deadline = DateTime.now().add(const Duration(seconds: 30));
//
//     int consecutiveMatches = 0;
//     int lastCheckedTimestamp = telemetryTimestampBeforeCommand;
//
//     while (mounted && DateTime.now().isBefore(deadline)) {
//       await loadTelemetry(showError: false);
//
//       if (!mounted) return false;
//
//       final latest = ref.read(telemetryViewModelProvider).latest;
//
//       if (!isDeviceOnline(latest)) {
//         await Future.delayed(const Duration(seconds: 1));
//         continue;
//       }
//
//       final telemetryTimestamp = _toInt(latest?.timestamp);
//
//       // Do not confirm from the telemetry record that existed before
//       // the command, and do not count the same telemetry record twice.
//       if (telemetryTimestamp <= telemetryTimestampBeforeCommand ||
//           telemetryTimestamp <= lastCheckedTimestamp) {
//         await Future.delayed(const Duration(seconds: 1));
//         continue;
//       }
//
//       lastCheckedTimestamp = telemetryTimestamp;
//
//       final confirmedMotorState = isMotorRunning(latest);
//
//       if (confirmedMotorState == expectedOn) {
//         consecutiveMatches++;
//
//         // Two NEW consecutive VFD readings must agree before the UI
//         // leaves the circular progress state. This removes transient
//         // ON/OFF/ON or OFF/ON/OFF flicker.
//         if (consecutiveMatches >= 2) {
//           return true;
//         }
//       } else {
//         consecutiveMatches = 0;
//       }
//
//       await Future.delayed(const Duration(seconds: 1));
//     }
//
//     return false;
//   }
//
//   KhataEntryModel? _latestOpenKhataForCurrentDevice() {
//     if (!hasDevice) return null;
//
//     final entries = ref.read(khataViewModelProvider).entries;
//
//     KhataEntryModel? latestOpen;
//
//     for (final entry in entries) {
//       if (entry.deviceId.trim() != deviceId!.trim()) continue;
//       if (!entry.isOpen) continue;
//       if (entry.startTime == null) continue;
//       if (entry.endTime != null) continue;
//
//       if (latestOpen == null ||
//           entry.startTime!.isAfter(latestOpen.startTime!)) {
//         latestOpen = entry;
//       }
//     }
//
//     return latestOpen;
//   }
//
//   Future<void> _restoreMotorSessionFromKhata() async {
//     if (!hasDevice || isRestoringMotorSession) return;
//
//     isRestoringMotorSession = true;
//
//     try {
//       final restoredEntry = _latestOpenKhataForCurrentDevice();
//       final latest = ref.read(telemetryViewModelProvider).latest;
//
//       final hasFreshTelemetry = isDeviceOnline(latest);
//       final vfdSaysRunning =
//       hasFreshTelemetry ? isMotorRunning(latest) : false;
//
//       if (restoredEntry != null) {
//         activeKhataEntry = restoredEntry;
//
//         final restoredCustomer = restoredEntry.customerName.trim();
//         if (restoredCustomer.isNotEmpty &&
//             customerNameController.text.trim().isEmpty) {
//           customerNameController.text = restoredCustomer;
//           customerNameController.selection = TextSelection.collapsed(
//             offset: customerNameController.text.length,
//           );
//         }
//
//         // An open backend session is authoritative for elapsed time.
//         // Even if the app was killed or the phone slept, elapsed time is
//         // recalculated from this original timestamp instead of counting ticks.
//         _startLocalTimer(startedAt: restoredEntry.startTime);
//       } else {
//         activeKhataEntry = null;
//
//         // If VFD is already running but there is no open app/Khata session,
//         // we cannot invent an old start time. Start a local fallback from now.
//         // A later backend/open-session refresh can replace this with the
//         // authoritative timestamp.
//         if (vfdSaysRunning && motorStartedAt == null) {
//           _startLocalTimer(startedAt: DateTime.now());
//         }
//       }
//
//       // Fresh OFF telemetry means there is no running motor to display.
//       // Do not let an old/stale timer survive a confirmed OFF state.
//       if (hasFreshTelemetry && !vfdSaysRunning) {
//         _stopLocalTimer();
//
//         if (mounted && runSeconds != 0) {
//           setState(() {
//             runSeconds = 0;
//           });
//         } else {
//           runSeconds = 0;
//         }
//       }
//     } finally {
//       isRestoringMotorSession = false;
//
//       if (mounted) {
//         setState(() {
//           didRestoreMotorSession = true;
//         });
//       } else {
//         didRestoreMotorSession = true;
//       }
//     }
//   }
//
//   void _startLocalTimer({DateTime? startedAt}) {
//     if (startedAt != null) {
//       motorStartedAt = startedAt;
//     } else {
//       motorStartedAt ??= DateTime.now();
//     }
//
//     runTimer?.cancel();
//     _refreshRunSeconds();
//
//     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _refreshRunSeconds();
//     });
//   }
//
//   void _refreshRunSeconds() {
//     final startedAt = motorStartedAt;
//     if (!mounted || startedAt == null) return;
//
//     final elapsed = DateTime.now().difference(startedAt).inSeconds;
//     final safeElapsed = elapsed < 0 ? 0 : elapsed;
//
//     if (safeElapsed != runSeconds) {
//       setState(() {
//         runSeconds = safeElapsed;
//       });
//     }
//   }
//
//   void _stopLocalTimer({bool resetStart = true}) {
//     runTimer?.cancel();
//     runTimer = null;
//
//     if (resetStart) {
//       motorStartedAt = null;
//     }
//   }
//
//   String get runningTime {
//     final seconds = runSeconds < 0 ? 0 : runSeconds;
//     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
//     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
//     final s = (seconds % 60).toString().padLeft(2, "0");
//     return "$h:$m:$s";
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
//         text.contains("connection refused")) {
//       return "No internet connection. Please check Wi-Fi or mobile data.";
//     }
//
//     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
//
//     return error!;
//   }
//
//   String formatValue(
//       double? value,
//       String unit, {
//         int decimals = 1,
//       }) {
//     if (!hasDevice) return "-- $unit";
//     if (value == null) return "-- $unit";
//     return "${value.toStringAsFixed(decimals)} $unit";
//   }
//
//   Future<void> toggleMotor() async {
//     if (!hasDevice) {
//       showMessage("Please select a device first.", true);
//       return;
//     }
//
//     final latest = ref.read(telemetryViewModelProvider).latest;
//
//     final deviceOnline = isDeviceOnline(latest);
//     final motorRunning = isMotorRunning(latest);
//     final telemetryTimestampBeforeCommand = _toInt(latest?.timestamp);
//
//     if (!deviceOnline) {
//       showMessage(
//         "Device is offline. Wait for live telemetry before motor control.",
//         true,
//         seconds: 8,
//       );
//       return;
//     }
//
//     FocusScope.of(context).unfocus();
//     HapticFeedback.mediumImpact();
//
//     final typedCustomerName = customerNameController.text.trim();
//     final motorVm = ref.read(motorViewModelProvider.notifier);
//
//     // Validate before showing the command spinner.
//     if (!motorRunning && typedCustomerName.isEmpty) {
//       showMessage("Customer name is required to start motor.", true);
//       return;
//     }
//
//     if (mounted) {
//       setState(() {
//         motorStateBeforePendingCommand = motorRunning;
//         isWaitingForVfdConfirmation = true;
//       });
//     }
//
//     try {
//       if (motorRunning) {
//         final stoppedLog = await motorVm.stopMotor(
//           deviceId: deviceId!,
//           customerName: activeKhataEntry?.customerName ??
//               (typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName),
//         );
//
//         final updatedMotorState = ref.read(motorViewModelProvider);
//
//         if (updatedMotorState.error != null) {
//           showMessage(updatedMotorState.error!, true, seconds: 10);
//           return;
//         }
//
//         final endTime = stoppedLog?.endTime ?? DateTime.now();
//
//         // Do NOT close Khata or show OFF just because the stop API returned.
//         // Billing/timer stop only after VFD telemetry itself confirms OFF.
//         final vfdConfirmedOff = await _waitForVfdConfirmation(
//           expectedOn: false,
//           telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
//         );
//
//         if (!vfdConfirmedOff) {
//           showMessage(
//             "Stop command was sent, but OFF confirmation was not received from VFD telemetry.",
//             true,
//             seconds: 10,
//           );
//           return;
//         }
//
//         // VFD is physically OFF now. Stop the HOME timer immediately.
//         // Khata finalization is a separate server operation and must never
//         // keep the physical motor timer running.
//         _stopLocalTimer();
//
//         if (mounted) {
//           setState(() {
//             runSeconds = 0;
//           });
//         } else {
//           runSeconds = 0;
//         }
//
//         // Do not rely only on the in-memory activeKhataEntry.
//         // It can be lost after navigation/app resume/rebuild.
//         // Reload from server and recover the real open entry if needed.
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         final entryToClose =
//             activeKhataEntry ?? _latestOpenKhataForCurrentDevice();
//
//         if (entryToClose == null) {
//           activeKhataEntry = null;
//
//           showMessage(
//             "Motor stopped. No open Khata session was found to finalize.",
//             false,
//           );
//           return;
//         }
//
//         final closedEntry =
//         await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
//           entry: entryToClose,
//           endTime: endTime,
//         );
//
//         // IMPORTANT:
//         // Never forget the open entry when the close API failed.
//         // Previous code set activeKhataEntry=null even when ViewModel
//         // returned null, leaving backend is_open=true forever.
//         if (closedEntry == null) {
//           activeKhataEntry = entryToClose;
//
//           final khataError = ref.read(khataViewModelProvider).error;
//
//           showMessage(
//             "Motor is OFF, but Khata finalization failed: "
//                 "${khataError ?? "Unknown Khata close error"}",
//             true,
//             seconds: 14,
//           );
//           return;
//         }
//
//         activeKhataEntry = null;
//
//         // Reload the authoritative finalized values:
//         // ended_at, is_open=false, run_hours and recalculated bill.
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         final stillOpen = _latestOpenKhataForCurrentDevice();
//
//         if (stillOpen != null &&
//             stillOpen.id == closedEntry.id) {
//           activeKhataEntry = stillOpen;
//
//           showMessage(
//             "Motor is OFF, but backend still reports this Khata as open.",
//             true,
//             seconds: 14,
//           );
//           return;
//         }
//
//         showMessage(
//           "Motor stopped. Khata finalized: "
//               "${closedEntry.runHours.toStringAsFixed(2)} hr.",
//           false,
//         );
//         return;
//       }
//
//       final startedLog = await motorVm.startMotor(
//         deviceId: deviceId!,
//         customerName: typedCustomerName,
//       );
//
//       final motorCommandStartedAt = startedLog?.startTime ?? DateTime.now();
//
//       final updatedMotorState = ref.read(motorViewModelProvider);
//
//       if (updatedMotorState.error != null) {
//         showMessage(updatedMotorState.error!, true, seconds: 10);
//         return;
//       }
//
//       // Do NOT open Khata or show ON just because the start API returned.
//       // Billing/timer begin only after VFD telemetry itself confirms ON.
//       final vfdConfirmedOn = await _waitForVfdConfirmation(
//         expectedOn: true,
//         telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
//       );
//
//       if (!vfdConfirmedOn) {
//         showMessage(
//           "Start command was sent, but ON confirmation was not received from VFD telemetry.",
//           true,
//           seconds: 10,
//         );
//         return;
//       }
//
//       // VFD has confirmed ON, so the motor timer must run even if
//       // Khata creation fails. Billing failure must never make the UI
//       // pretend the motor is stopped.
//       if (mounted) {
//         setState(() {
//           runSeconds = 0;
//         });
//       }
//
//       _startLocalTimer(startedAt: motorCommandStartedAt);
//
//       // A real MotorLog UUID is mandatory for an open Khata session.
//       // run_hours is intentionally 0 while the motor is still running.
//       if (startedLog == null) {
//         showMessage(
//           "Motor is ON, but start API returned no MotorLog. Khata was not created.",
//           true,
//           seconds: 12,
//         );
//         return;
//       }
//
//       final motorLogId = startedLog.id?.trim() ?? "";
//
//       if (motorLogId.isEmpty) {
//         showMessage(
//           "Motor is ON, but MotorLog ID is missing from the start response. "
//               "Khata was not created. Check POST /motor/$deviceId/start response.",
//           true,
//           seconds: 14,
//         );
//         return;
//       }
//
//       activeKhataEntry =
//       await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
//         customerName: typedCustomerName,
//         deviceId: deviceId!,
//         motorLogId: motorLogId,
//         startTime: startedLog.startTime ?? motorCommandStartedAt,
//       );
//
//       if (activeKhataEntry == null) {
//         final khataError = ref.read(khataViewModelProvider).error;
//
//         showMessage(
//           "Motor is ON, but Khata was not created: "
//               "${khataError ?? "Unknown Khata API error"}",
//           true,
//           seconds: 14,
//         );
//         return;
//       }
//
//       await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//       showMessage("Motor started. Khata session opened.", false);
//     } catch (e) {
//       showMessage(
//         "Motor action failed: ${friendlyError(e.toString())}",
//         true,
//         seconds: 12,
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           isWaitingForVfdConfirmation = false;
//           motorStateBeforePendingCommand = null;
//         });
//       } else {
//         isWaitingForVfdConfirmation = false;
//         motorStateBeforePendingCommand = null;
//       }
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
//     final names = <String>[];
//     final seen = <String>{};
//
//     // Newest customers first. Duplicate names are removed case-insensitively.
//     for (final entry in khataState.entries.reversed) {
//       final name = entry.customerName?.trim();
//       if (name == null || name.isEmpty) continue;
//
//       final key = name.toLowerCase();
//       if (seen.add(key)) {
//         names.add(name);
//       }
//     }
//
//     return names.take(20).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final latest = ref.watch(
//       telemetryViewModelProvider.select((state) => state.latest),
//     );
//
//     final motorLoading = ref.watch(
//       motorViewModelProvider.select((state) => state.isLoading),
//     );
//
//     final motorButtonLoading =
//         hasDevice && (motorLoading || isWaitingForVfdConfirmation);
//
//     final checkingDevice = hasDevice && !firstTelemetryLoaded;
//
//     final effectiveLatest = hasDevice && firstTelemetryLoaded ? latest : null;
//
//     final deviceOnline = checkingDevice ? false : isDeviceOnline(effectiveLatest);
//     final telemetryMotorRunning =
//     checkingDevice ? false : isMotorRunning(effectiveLatest);
//
//     final motorRunning = isWaitingForVfdConfirmation &&
//         motorStateBeforePendingCommand != null
//         ? motorStateBeforePendingCommand!
//         : telemetryMotorRunning;
//
//     final displayLatest = deviceOnline ? effectiveLatest : null;
//
//     if (motorRunning &&
//         runTimer == null &&
//         !isWaitingForVfdConfirmation &&
//         didRestoreMotorSession) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer == null) {
//           _startLocalTimer(
//             startedAt: activeKhataEntry?.startTime ?? motorStartedAt,
//           );
//         }
//       });
//     }
//
//     // Never reset the run timer just because telemetry becomes stale while
//     // the app is backgrounded. Stop it only when fresh VFD telemetry says OFF.
//     if (deviceOnline &&
//         !telemetryMotorRunning &&
//         runTimer != null &&
//         !isWaitingForVfdConfirmation) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer != null) {
//           _stopLocalTimer();
//           setState(() {
//             runSeconds = 0;
//           });
//         }
//       });
//     }
//
//     final width = MediaQuery.of(context).size.width;
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
//         : "Smart Motor Controller";
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
//       appBar: SmartWellHomeAppBar(
//         hasDevice: hasDevice,
//         deviceOnline: deviceOnline,
//         onSelectDevice: () {
//           Navigator.pushReplacementNamed(context, AppRoutes.devices);
//         },
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: AppColors.primary,
//           backgroundColor: AppColors.cardDark,
//           onRefresh: () async {
//             if (hasDevice) {
//               await loadTelemetry(showError: true);
//               await ref.read(khataViewModelProvider.notifier).loadEntries();
//               await _restoreMotorSessionFromKhata();
//             } else {
//               showMessage("Please select a device first.", true);
//             }
//           },
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
//                     // SmartDeviceHeaderCard(
//                     //   hasDevice: hasDevice,
//                     //   deviceOnline: deviceOnline,
//                     //   motorRunning: motorRunning,
//                     //   displayName: resolvedDisplayName,
//                     //   deviceId: deviceId,
//                     // ),
//                     SmartDeviceHeaderCard(
//                       hasDevice: hasDevice,
//                       deviceOnline: deviceOnline,
//                       motorRunning: motorRunning,
//                       displayName: resolvedDisplayName,
//                       deviceId: deviceId,
//                       triggerType: telemetry.triggerType,
//                     ),
//                     if (!hasDevice) ...[
//                       const SizedBox(height: 12),
//                       NoDeviceProfessionalNotice(
//                         onSelectDevice: () {
//                           Navigator.pushReplacementNamed(
//                             context,
//                             AppRoutes.devices,
//                           );
//                         },
//                       ),
//                     ],
//                     if (hasDevice && !deviceOnline) ...[
//                       const SizedBox(height: 12),
//                       DeviceOfflineNotice(
//                         onRetry: () => loadTelemetry(showError: true),
//                       ),
//                     ],
//                     if (hasDevice && deviceOnline) ...[
//                       const SizedBox(height: 12),
//                       DeviceOnlineNotice(
//                         motorRunning: motorRunning,
//                       ),
//                     ],
//                     const SizedBox(height: 18),
//                     CustomerNameInputCard(
//                       controller: customerNameController,
//                       focusNode: customerNameFocusNode,
//                       suggestions: customerSuggestions(),
//                       enabled: hasDevice && deviceOnline,
//                     ),
//                     const SizedBox(height: 26),
//                     Center(
//                       child: GestureDetector(
//                         onTap: motorButtonLoading ? null : toggleMotor,
//                         child: AnimatedBuilder(
//                           animation: pulseAnimation,
//                           builder: (context, child) {
//                             final scale = motorButtonLoading
//                                 ? 1.0
//                                 : motorRunning
//                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
//                                 : 1.0;
//
//                             return Transform.scale(
//                               scale: scale,
//                               child: child,
//                             );
//                           },
//                           child: MotorCommandButton(
//                             hasDevice: hasDevice,
//                             deviceOnline: deviceOnline,
//                             isOn: motorRunning,
//                             loading: motorButtonLoading,
//                             size: buttonSize,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     MotorRunStatusCard(
//                       hasDevice: hasDevice,
//                       deviceOnline: deviceOnline,
//                       isOn: motorRunning,
//                       waitingForVfd: isWaitingForVfdConfirmation,
//                       runningTime: runningTime,
//                     ),
//                     const SizedBox(height: 22),
//                     ParameterGridSection(
//                       crossAxisCount: crossAxisCount,
//                       childAspectRatio: childAspectRatio,
//                       metrics: [
//                         ParameterMetric(
//                           icon: Icons.sync_rounded,
//                           title: "Frequency",
//                           value: formatValue(displayLatest?.freq, "Hz"),
//                           highlight: true,
//                         ),
//                         ParameterMetric(
//                           icon: Icons.bolt_rounded,
//                           title: "Voltage",
//                           value: formatValue(displayLatest?.voltage, "V"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.flash_on_rounded,
//                           title: "Current",
//                           value: formatValue(displayLatest?.current, "A"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.power_rounded,
//                           title: "Power",
//                           value: formatValue(displayLatest?.power, "kW"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.speed_rounded,
//                           title: "Load",
//                           value: formatValue(
//                             displayLatest?.powerPercent,
//                             "%",
//                           ),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.rotate_right_rounded,
//                           title: "Motor Speed",
//                           value: formatValue(
//                             displayLatest?.motorSpeed,
//                             "RPM",
//                           ),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.battery_charging_full_rounded,
//                           title: "DC Bus",
//                           value: formatValue(displayLatest?.dcbus, "V"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.electric_meter_rounded,
//                           title: "Energy",
//                           value: formatValue(
//                             displayLatest?.energyIn,
//                             "kWh",
//                           ),
//                         ),
//                       ],
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
// class SmartWellHomeAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final VoidCallback onSelectDevice;
//
//   const SmartWellHomeAppBar({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.onSelectDevice,
//   });
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
//
//   @override
//   Widget build(BuildContext context) {
//     final statusText = !hasDevice
//         ? "No device selected"
//         : deviceOnline
//         ? "Device online"
//         : "Waiting for device";
//
//     final statusColor = !hasDevice
//         ? AppColors.white.withOpacity(0.55)
//         : deviceOnline
//         ? AppColors.green
//         : AppColors.warning;
//
//     return AppBar(
//       backgroundColor: AppColors.primaryDark,
//       elevation: 0,
//       centerTitle: false,
//       automaticallyImplyLeading: hasDevice,
//       iconTheme: const IconThemeData(color: AppColors.white),
//       titleSpacing: 18,
//       title: Row(
//         children: [
//           Container(
//             height: 42,
//             width: 42,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(14),
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.darkBgSoft,
//                   AppColors.darkBgSoft.withOpacity(0.72),
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.electric_bolt_rounded,
//               color: AppColors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "AabNex",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   statusText,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontSize: 11.5,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 10),
//           child: IconButton(
//             tooltip: "Select Device",
//             onPressed: onSelectDevice,
//             icon: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: AppColors.cardDark,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: AppColors.borderDark),
//               ),
//               child: const Icon(
//                 Icons.devices_other_rounded,
//                 color: AppColors.primary,
//                 size: 22,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class SmartDeviceHeaderCard extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool motorRunning;
//   final String displayName;
//   final String? deviceId;
//   final String? triggerType;
//
//   const SmartDeviceHeaderCard({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.motorRunning,
//     required this.displayName,
//     required this.deviceId,
//     this.triggerType,
//   });
//
//   String _formatTriggerType(String? value) {
//     switch (value?.toLowerCase().trim()) {
//       case 'physical':
//         return 'Physical Button';
//
//       case 'time':
//       case 'timer':
//         return 'Timer';
//
//       case 'schedule':
//         return 'Schedule';
//
//       case 'app':
//         return 'App';
//
//       default:
//         return 'Unknown';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = !hasDevice
//         ? AppColors.primary
//         : !deviceOnline
//         ? AppColors.warning
//         : motorRunning
//         ? AppColors.green
//         : AppColors.primary;
//
//     final icon = !hasDevice
//         ? Icons.hub_outlined
//         : !deviceOnline
//         ? Icons.wifi_tethering_error_rounded
//         : motorRunning
//         ? Icons.power_settings_new_rounded
//         : Icons.verified_rounded;
//
//     final statusText = !hasDevice
//         ? "Ready to connect"
//         : !deviceOnline
//         ? "Waiting for live telemetry"
//         : motorRunning
//         ? "Device online | Motor ON"
//         : "Device online | Motor OFF";
//
//     final triggerText = _formatTriggerType(triggerType);
//
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(26),
//         border: Border.all(color: AppColors.borderDark),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.10),
//             blurRadius: 28,
//             offset: const Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 62,
//             width: 62,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 32,
//             ),
//           ),
//
//           const SizedBox(width: 14),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   displayName,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//
//                 const SizedBox(height: 6),
//
//                 Text(
//                   statusText,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//
//                 // -----------------------------
//                 // MOTOR TRIGGER TYPE
//                 // -----------------------------
//                 if (motorRunning && triggerType != null) ...[
//                   const SizedBox(height: 5),
//
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.touch_app_rounded,
//                         size: 14,
//                         color: AppColors.white.withOpacity(0.60),
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         "Started by: ",
//                         style: TextStyle(
//                           color: AppColors.white.withOpacity(0.45),
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         triggerText,
//                         style: TextStyle(
//                           color: color,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//
//                 const SizedBox(height: 5),
//
//                 Text(
//                   hasDevice
//                       ? (deviceId ?? "Unknown device")
//                       : "No controller selected",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.45),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
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
// class NoDeviceProfessionalNotice extends StatelessWidget {
//   final VoidCallback onSelectDevice;
//
//   const NoDeviceProfessionalNotice({
//     super.key,
//     required this.onSelectDevice,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: AppColors.borderDark),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 46,
//             width: 46,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.devices_other_rounded,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               "Select a device to enable motor control. Parameters stay empty until a controller is selected.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.68),
//                 fontSize: 13.5,
//                 height: 1.4,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           TextButton(
//             onPressed: onSelectDevice,
//             child: const Text(
//               "Select",
//               style: TextStyle(
//                 color: AppColors.primary,
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
// class DeviceOfflineNotice extends StatelessWidget {
//   final Future<void> Function() onRetry;
//
//   const DeviceOfflineNotice({
//     super.key,
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.warning.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.warning.withOpacity(0.24)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.info_outline_rounded,
//             color: AppColors.warning,
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "Device selected. Waiting for latest live reading.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.78),
//                 fontSize: 12.8,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: onRetry,
//             child: const Text(
//               "Retry",
//               style: TextStyle(
//                 color: AppColors.warning,
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
// class DeviceOnlineNotice extends StatelessWidget {
//   final bool motorRunning;
//
//   const DeviceOnlineNotice({
//     super.key,
//     required this.motorRunning,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final text = motorRunning
//         ? "Live telemetry received. Motor is running."
//         : "Live telemetry received. Motor is stopped.";
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.green.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.green.withOpacity(0.24)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.check_circle_rounded,
//             color: AppColors.green,
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.78),
//                 fontSize: 12.8,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomerNameInputCard extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final List<String> suggestions;
//   final bool enabled;
//
//   const CustomerNameInputCard({
//     super.key,
//     required this.controller,
//     required this.focusNode,
//     required this.suggestions,
//     required this.enabled,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4, bottom: 9),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.account_circle_outlined,
//                 size: 17,
//                 color: AppColors.white.withOpacity(0.48),
//               ),
//               const SizedBox(width: 7),
//               Text(
//                 "CUSTOMER / KHATA",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(0.56),
//                   fontSize: 11,
//                   letterSpacing: 1.1,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         RawAutocomplete<String>(
//           textEditingController: controller,
//           focusNode: focusNode,
//           optionsBuilder: (TextEditingValue value) {
//             if (!enabled) return const Iterable<String>.empty();
//
//             final input = value.text.trim().toLowerCase();
//
//             if (input.isEmpty) {
//               return suggestions.take(8);
//             }
//
//             final startsWith = <String>[];
//             final contains = <String>[];
//
//             for (final name in suggestions) {
//               final lower = name.toLowerCase();
//               if (lower.startsWith(input)) {
//                 startsWith.add(name);
//               } else if (lower.contains(input)) {
//                 contains.add(name);
//               }
//             }
//
//             return [...startsWith, ...contains].take(8);
//           },
//           onSelected: (String value) {
//             controller.text = value;
//             controller.selection = TextSelection.collapsed(
//               offset: controller.text.length,
//             );
//           },
//           fieldViewBuilder: (
//               context,
//               textEditingController,
//               fieldFocusNode,
//               onFieldSubmitted,
//               ) {
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               decoration: BoxDecoration(
//                 color: AppColors.cardDark,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: fieldFocusNode.hasFocus
//                       ? AppColors.primary.withOpacity(0.70)
//                       : AppColors.borderDark,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.16),
//                     blurRadius: 16,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 enabled: enabled,
//                 controller: textEditingController,
//                 focusNode: fieldFocusNode,
//                 keyboardType: TextInputType.name,
//                 textCapitalization: TextCapitalization.words,
//                 autocorrect: false,
//                 style: const TextStyle(
//                   color: AppColors.white,
//                   fontSize: 15.5,
//                   fontWeight: FontWeight.w800,
//                 ),
//                 textInputAction: TextInputAction.done,
//                 decoration: InputDecoration(
//                   hintText: enabled
//                       ? "Enter new or previous customer"
//                       : "Device must be online first",
//                   hintStyle: TextStyle(
//                     color: AppColors.white.withOpacity(0.38),
//                     fontWeight: FontWeight.w600,
//                   ),
//                   prefixIcon: Icon(
//                     enabled
//                         ? Icons.person_search_rounded
//                         : Icons.lock_outline_rounded,
//                     color: AppColors.primary,
//                   ),
//                   suffixIcon: enabled && suggestions.isNotEmpty
//                       ? Tooltip(
//                     message: "Previous customers available",
//                     child: Icon(
//                       Icons.history_rounded,
//                       color: AppColors.white.withOpacity(0.38),
//                     ),
//                   )
//                       : null,
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 18,
//                   ),
//                 ),
//               ),
//             );
//           },
//           optionsViewBuilder: (context, onSelected, options) {
//             final optionList = options.toList();
//
//             return Align(
//               alignment: Alignment.topLeft,
//               child: Material(
//                 color: Colors.transparent,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width - 36,
//                   constraints: const BoxConstraints(
//                     maxHeight: 290,
//                     maxWidth: 560,
//                   ),
//                   margin: const EdgeInsets.only(top: 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.cardDark,
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: AppColors.borderDark),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.28),
//                         blurRadius: 24,
//                         offset: const Offset(0, 12),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.history_rounded,
//                               color: AppColors.primary,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               "Previous customers",
//                               style: TextStyle(
//                                 color: AppColors.white.withOpacity(0.62),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w900,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Flexible(
//                         child: ListView.separated(
//                           padding: const EdgeInsets.only(bottom: 7),
//                           shrinkWrap: true,
//                           itemCount: optionList.length,
//                           separatorBuilder: (_, __) => Divider(
//                             height: 1,
//                             color: AppColors.white.withOpacity(0.06),
//                           ),
//                           itemBuilder: (context, index) {
//                             final option = optionList[index];
//
//                             return ListTile(
//                               dense: true,
//                               leading: Container(
//                                 height: 34,
//                                 width: 34,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primary.withOpacity(0.10),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.person_rounded,
//                                   color: AppColors.primary,
//                                   size: 18,
//                                 ),
//                               ),
//                               title: Text(
//                                 option,
//                                 style: const TextStyle(
//                                   color: AppColors.white,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                               trailing: Icon(
//                                 Icons.north_west_rounded,
//                                 size: 17,
//                                 color: AppColors.white.withOpacity(0.30),
//                               ),
//                               onTap: () => onSelected(option),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         if (enabled)
//           Padding(
//             padding: const EdgeInsets.only(left: 5, top: 8),
//             child: Text(
//               suggestions.isEmpty
//                   ? "New customer names will appear here next time."
//                   : "Type to search, or select a previously used customer.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.38),
//                 fontSize: 11.5,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// class MotorCommandButton extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool isOn;
//   final bool loading;
//   final double size;
//
//   const MotorCommandButton({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.isOn,
//     required this.loading,
//     required this.size,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final activeColor = !hasDevice
//         ? AppColors.primary
//         : !deviceOnline
//         ? AppColors.warning
//         : isOn
//         ? AppColors.green
//         : AppColors.error;
//
//     final label = !hasDevice
//         ? "SELECT"
//         : !deviceOnline
//         ? "WAIT"
//         : isOn
//         ? "ON"
//         : "OFF";
//
//     final icon = !hasDevice
//         ? Icons.devices_other_rounded
//         : !deviceOnline
//         ? Icons.wifi_tethering_error_rounded
//         : isOn
//         ? Icons.power_settings_new_rounded
//         : Icons.power_off_rounded;
//
//     final textColor = !hasDevice ? AppColors.black : AppColors.white;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: size,
//       height: size,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             activeColor,
//             activeColor.withOpacity(0.72),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: activeColor.withOpacity(0.30),
//             blurRadius: 34,
//             offset: const Offset(0, 16),
//           ),
//         ],
//       ),
//       child: loading
//           ? const CircularProgressIndicator(color: AppColors.white)
//           : Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: textColor,
//             size: size < 190 ? 36 : 42,
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: label == "SELECT"
//                     ? 24
//                     : label == "WAIT"
//                     ? 24
//                     : size < 190
//                     ? 26
//                     : 36,
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
// class MotorRunStatusCard extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool isOn;
//   final bool waitingForVfd;
//   final String runningTime;
//
//   const MotorRunStatusCard({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.isOn,
//     required this.waitingForVfd,
//     required this.runningTime,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final active = hasDevice && deviceOnline && isOn;
//
//     final title = !hasDevice
//         ? "NO DEVICE"
//         : !deviceOnline
//         ? "WAITING FOR DEVICE"
//         : waitingForVfd
//         ? "SYNCING WITH VFD"
//         : active
//         ? "MOTOR RUN TIME"
//         : "MOTOR STOPPED";
//
//     final subtitle = !hasDevice
//         ? "Select a controller to start monitoring"
//         : !deviceOnline
//         ? "Waiting for fresh live telemetry"
//         : waitingForVfd
//         ? "Waiting for the VFD to confirm the command"
//         : active
//         ? "Elapsed time since this motor run started"
//         : "Timer starts only after VFD confirms ON";
//
//     final accent = active ? AppColors.green : AppColors.primary;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: active
//               ? AppColors.green.withOpacity(0.28)
//               : AppColors.borderDark,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 44,
//             width: 44,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: accent.withOpacity(0.11),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: waitingForVfd
//                 ? SizedBox(
//               height: 21,
//               width: 21,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.4,
//                 color: accent,
//               ),
//             )
//                 : Icon(
//               active ? Icons.timer_rounded : Icons.timer_off_outlined,
//               color: accent,
//               size: 23,
//             ),
//           ),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.54),
//                     fontSize: 10.5,
//                     letterSpacing: 0.9,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.60),
//                     fontSize: 11.8,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             active ? runningTime : "00:00:00",
//             style: TextStyle(
//               color: active
//                   ? AppColors.green
//                   : AppColors.white.withOpacity(0.42),
//               fontSize: 20,
//               fontWeight: FontWeight.w900,
//               fontFeatures: const [FontFeature.tabularFigures()],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ParameterMetric {
//   final IconData icon;
//   final String title;
//   final String value;
//   final bool highlight;
//
//   const ParameterMetric({
//     required this.icon,
//     required this.title,
//     required this.value,
//     this.highlight = false,
//   });
// }
//
// class ParameterGridSection extends StatelessWidget {
//   final int crossAxisCount;
//   final double childAspectRatio;
//   final List<ParameterMetric> metrics;
//
//   const ParameterGridSection({
//     super.key,
//     required this.crossAxisCount,
//     required this.childAspectRatio,
//     required this.metrics,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: crossAxisCount,
//       crossAxisSpacing: 14,
//       mainAxisSpacing: 14,
//       childAspectRatio: childAspectRatio,
//       children: metrics.map((metric) {
//         return ParameterMetricCard(metric: metric);
//       }).toList(),
//     );
//   }
// }
//
// class ParameterMetricCard extends StatelessWidget {
//   final ParameterMetric metric;
//
//   const ParameterMetricCard({
//     super.key,
//     required this.metric,
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
//           color: metric.highlight
//               ? AppColors.primary.withOpacity(0.38)
//               : AppColors.borderDark,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.20),
//             blurRadius: 18,
//             offset: const Offset(0, 9),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             metric.icon,
//             color: metric.highlight
//                 ? AppColors.primary
//                 : AppColors.white.withOpacity(0.45),
//             size: compact ? 24 : 28,
//           ),
//           const Spacer(),
//           Text(
//             metric.title,
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
//               metric.value,
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
// import "dart:async";
// import "dart:ui" show FontFeature;
//
// import "package:flutter/material.dart";
// import "package:flutter/services.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
//
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/khata/data/models/khata_entry_model.dart";
// import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
//
// import "../../../../app/routes.dart";
// import "../../../khata/presentation/providers/ khata_providers.dart";
// import "../../../motor/presentation/ providers/motor_providers.dart";
// import "../../../telemetry/presentation/providers/telemetry_providers.dart";
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
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late AnimationController pulseController;
//   late Animation<double> pulseAnimation;
//
//   final TextEditingController customerNameController = TextEditingController();
//   final FocusNode customerNameFocusNode = FocusNode();
//
//   KhataEntryModel? activeKhataEntry;
//   String? activeTriggerType;
//
//   Timer? telemetryTimer;
//   Timer? runTimer;
//
//   int runSeconds = 0;
//   DateTime? motorStartedAt;
//
//   String? userId;
//   String? deviceId;
//   String? deviceName;
//
//   bool didSetupDevice = false;
//   bool isTelemetryLoading = false;
//   bool firstTelemetryLoaded = false;
//
//   // Prevents the UI from starting a brand-new timer before we have checked
//   // whether an existing open Khata session already has the real start time.
//   bool didRestoreMotorSession = false;
//   bool isRestoringMotorSession = false;
//
//   // Keeps the motor button in loading state until VFD telemetry confirms
//   // the requested ON/OFF state.
//   bool isWaitingForVfdConfirmation = false;
//
//   // While a command is pending, keep showing the last confirmed state.
//   // This prevents ON -> OFF -> ON / OFF -> ON -> OFF visual flicker.
//   bool? motorStateBeforePendingCommand;
//
//   bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
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
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _refreshRunSeconds();
//
//       if (hasDevice) {
//         Future.microtask(() async {
//           await loadTelemetry(showError: false);
//           await ref.read(khataViewModelProvider.notifier).loadEntries();
//           await _restoreMotorSessionFromKhata();
//         });
//       }
//     }
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
//       final rawDeviceId = args["deviceId"]?.toString().trim();
//       if (rawDeviceId != null && rawDeviceId.isNotEmpty) {
//         deviceId = rawDeviceId;
//       }
//
//       final rawDeviceName = args["deviceName"]?.toString().trim();
//       if (rawDeviceName != null && rawDeviceName.isNotEmpty) {
//         deviceName = rawDeviceName;
//       }
//     }
//
//     final widgetDeviceId = widget.deviceId?.trim();
//
//     if (!hasDevice && widgetDeviceId != null && widgetDeviceId.isNotEmpty) {
//       deviceId = widgetDeviceId;
//     }
//
//     if (hasDevice) {
//       Future.microtask(() async {
//         await loadTelemetry();
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//         await _restoreMotorSessionFromKhata();
//       });
//
//       telemetryTimer?.cancel();
//       telemetryTimer = Timer.periodic(
//         const Duration(seconds: 5),
//             (_) => loadTelemetry(showError: false),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     pulseController.dispose();
//     customerNameController.dispose();
//     customerNameFocusNode.dispose();
//     telemetryTimer?.cancel();
//     runTimer?.cancel();
//     super.dispose();
//   }
//
//   int _toInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is num) return value.toInt();
//     return int.tryParse(value.toString()) ?? 0;
//   }
//
//   bool isDeviceOnline(dynamic latest) {
//     if (!hasDevice) return false;
//     if (latest == null) return false;
//
//     final live = _toInt(latest.isLive) == 1;
//     final fresh = latest.isFresh(withinSeconds: 20);
//
//     return live && fresh;
//   }
//
//
//   bool isMotorRunning(dynamic latest) {
//     if (!hasDevice) return false;
//     if (!isDeviceOnline(latest)) return false;
//
//     final statusCode = _toInt(latest.statusCode);
//
//     return statusCode == 1 || statusCode == 2;
//   }
//
//   Future<void> loadTelemetry({bool showError = false}) async {
//     if (!hasDevice) return;
//     if (isTelemetryLoading) return;
//
//     final isFirstLoad = !firstTelemetryLoaded;
//
//     isTelemetryLoading = true;
//
//     try {
//       await ref.read(telemetryViewModelProvider.notifier).loadLatest(
//         deviceId!,
//         showLoading: isFirstLoad,
//       );
//     } catch (e) {
//       if (showError) {
//         showMessage(
//           "Telemetry failed: ${friendlyError(e.toString())}",
//           true,
//           seconds: 8,
//         );
//       }
//     } finally {
//       isTelemetryLoading = false;
//
//       if (mounted && isFirstLoad) {
//         setState(() {
//           firstTelemetryLoaded = true;
//         });
//       }
//     }
//   }
//
//   Future<bool> _waitForVfdConfirmation({
//     required bool expectedOn,
//     required int telemetryTimestampBeforeCommand,
//   }) async {
//     final deadline = DateTime.now().add(
//       const Duration(seconds: 20),
//     );
//
//     int lastCheckedTimestamp = telemetryTimestampBeforeCommand;
//
//     while (mounted && DateTime.now().isBefore(deadline)) {
//       await loadTelemetry(showError: false);
//
//       if (!mounted) return false;
//
//       final latest = ref.read(telemetryViewModelProvider).latest;
//
//       if (!isDeviceOnline(latest)) {
//         await Future.delayed(
//           const Duration(milliseconds: 400),
//         );
//         continue;
//       }
//
//       final telemetryTimestamp = _toInt(latest?.timestamp);
//
//       // Old telemetry ko confirmation ke liye use nahi karna.
//       if (telemetryTimestamp <= telemetryTimestampBeforeCommand ||
//           telemetryTimestamp <= lastCheckedTimestamp) {
//         await Future.delayed(
//           const Duration(milliseconds: 400),
//         );
//         continue;
//       }
//
//       lastCheckedTimestamp = telemetryTimestamp;
//
//       final confirmedMotorState = isMotorRunning(latest);
//
//       // First NEW VFD response is enough.
//       if (confirmedMotorState == expectedOn) {
//         return true;
//       }
//
//       await Future.delayed(
//         const Duration(milliseconds: 400),
//       );
//     }
//
//     return false;
//   }
//
//   KhataEntryModel? _latestOpenKhataForCurrentDevice() {
//     if (!hasDevice) return null;
//
//     final entries = ref.read(khataViewModelProvider).entries;
//
//     KhataEntryModel? latestOpen;
//
//     for (final entry in entries) {
//       if (entry.deviceId.trim() != deviceId!.trim()) continue;
//       if (!entry.isOpen) continue;
//       if (entry.startTime == null) continue;
//       if (entry.endTime != null) continue;
//
//       if (latestOpen == null ||
//           entry.startTime!.isAfter(latestOpen.startTime!)) {
//         latestOpen = entry;
//       }
//     }
//
//     return latestOpen;
//   }
//
//   Future<void> _restoreMotorSessionFromKhata() async {
//     if (!hasDevice || isRestoringMotorSession) return;
//
//     isRestoringMotorSession = true;
//
//     try {
//       final restoredEntry = _latestOpenKhataForCurrentDevice();
//       final latest = ref.read(telemetryViewModelProvider).latest;
//
//       final hasFreshTelemetry = isDeviceOnline(latest);
//       final vfdSaysRunning =
//       hasFreshTelemetry ? isMotorRunning(latest) : false;
//
//       if (restoredEntry != null) {
//         activeKhataEntry = restoredEntry;
//
//         final restoredCustomer = (restoredEntry.customerName ?? "").trim();
//         if (restoredCustomer.isNotEmpty &&
//             customerNameController.text.trim().isEmpty) {
//           customerNameController.text = restoredCustomer;
//           customerNameController.selection = TextSelection.collapsed(
//             offset: customerNameController.text.length,
//           );
//         }
//
//         // An open backend session is authoritative for elapsed time.
//         // Even if the app was killed or the phone slept, elapsed time is
//         // recalculated from this original timestamp instead of counting ticks.
//         _startLocalTimer(startedAt: restoredEntry.startTime);
//       } else {
//         activeKhataEntry = null;
//
//         // If VFD is already running but there is no open app/Khata session,
//         // we cannot invent an old start time. Start a local fallback from now.
//         // A later backend/open-session refresh can replace this with the
//         // authoritative timestamp.
//         if (vfdSaysRunning && motorStartedAt == null) {
//           _startLocalTimer(startedAt: DateTime.now());
//         }
//       }
//
//       // Fresh OFF telemetry means there is no running motor to display.
//       // Do not let an old/stale timer survive a confirmed OFF state.
//       if (hasFreshTelemetry && !vfdSaysRunning) {
//         _stopLocalTimer();
//
//         if (mounted && runSeconds != 0) {
//           setState(() {
//             runSeconds = 0;
//           });
//         } else {
//           runSeconds = 0;
//         }
//       }
//     } finally {
//       isRestoringMotorSession = false;
//
//       if (mounted) {
//         setState(() {
//           didRestoreMotorSession = true;
//         });
//       } else {
//         didRestoreMotorSession = true;
//       }
//     }
//   }
//
//   void _startLocalTimer({DateTime? startedAt}) {
//     if (startedAt != null) {
//       motorStartedAt = startedAt;
//     } else {
//       motorStartedAt ??= DateTime.now();
//     }
//
//     runTimer?.cancel();
//     _refreshRunSeconds();
//
//     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _refreshRunSeconds();
//     });
//   }
//
//   void _refreshRunSeconds() {
//     final startedAt = motorStartedAt;
//     if (!mounted || startedAt == null) return;
//
//     final elapsed = DateTime.now().difference(startedAt).inSeconds;
//     final safeElapsed = elapsed < 0 ? 0 : elapsed;
//
//     if (safeElapsed != runSeconds) {
//       setState(() {
//         runSeconds = safeElapsed;
//       });
//     }
//   }
//
//   void _stopLocalTimer({bool resetStart = true}) {
//     runTimer?.cancel();
//     runTimer = null;
//
//     if (resetStart) {
//       motorStartedAt = null;
//     }
//   }
//
//   String get runningTime {
//     final seconds = runSeconds < 0 ? 0 : runSeconds;
//     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
//     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
//     final s = (seconds % 60).toString().padLeft(2, "0");
//     return "$h:$m:$s";
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
//         text.contains("connection refused")) {
//       return "No internet connection. Please check Wi-Fi or mobile data.";
//     }
//
//     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
//
//     return error!;
//   }
//
//   String formatValue(
//       double? value,
//       String unit, {
//         int decimals = 1,
//       }) {
//     if (!hasDevice) return "-- $unit";
//     if (value == null) return "-- $unit";
//     return "${value.toStringAsFixed(decimals)} $unit";
//   }
//
//   Future<void> toggleMotor() async {
//     if (!hasDevice) {
//       showMessage("Please select a device first.", true);
//       return;
//     }
//
//     final latest = ref.read(telemetryViewModelProvider).latest;
//
//     final deviceOnline = isDeviceOnline(latest);
//     final motorRunning = isMotorRunning(latest);
//     final telemetryTimestampBeforeCommand = _toInt(latest?.timestamp);
//
//     if (!deviceOnline) {
//       showMessage(
//         "Device is offline. Wait for live telemetry before motor control.",
//         true,
//         seconds: 8,
//       );
//       return;
//     }
//
//     FocusScope.of(context).unfocus();
//     HapticFeedback.mediumImpact();
//
//     final typedCustomerName = customerNameController.text.trim();
//     final motorVm = ref.read(motorViewModelProvider.notifier);
//
//     // Validate before showing the command spinner.
//     if (!motorRunning && typedCustomerName.isEmpty) {
//       showMessage("Customer name is required to start motor.", true);
//       return;
//     }
//
//     if (mounted) {
//       setState(() {
//         motorStateBeforePendingCommand = motorRunning;
//         isWaitingForVfdConfirmation = true;
//       });
//     }
//
//     try {
//       if (motorRunning) {
//         final stoppedLog = await motorVm.stopMotor(
//           deviceId: deviceId!,
//           customerName: activeKhataEntry?.customerName ??
//               (typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName),
//         );
//
//         final updatedMotorState = ref.read(motorViewModelProvider);
//
//         if (updatedMotorState.error != null) {
//           showMessage(updatedMotorState.error!, true, seconds: 10);
//           return;
//         }
//
//         final endTime = stoppedLog?.endTime ?? DateTime.now();
//
//         // Do NOT close Khata or show OFF just because the stop API returned.
//         // Billing/timer stop only after VFD telemetry itself confirms OFF.
//         final vfdConfirmedOff = await _waitForVfdConfirmation(
//           expectedOn: false,
//           telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
//         );
//
//         if (!vfdConfirmedOff) {
//           showMessage(
//             "Stop command was sent, but OFF confirmation was not received from VFD telemetry.",
//             true,
//             seconds: 10,
//           );
//           return;
//         }
//
//         // VFD is physically OFF now. Stop the HOME timer immediately.
//         // Khata finalization is a separate server operation and must never
//         // keep the physical motor timer running.
//         _stopLocalTimer();
//
//         if (mounted) {
//           setState(() {
//             runSeconds = 0;
//           });
//         } else {
//           runSeconds = 0;
//         }
//
//         // Do not rely only on the in-memory activeKhataEntry.
//         // It can be lost after navigation/app resume/rebuild.
//         // Reload from server and recover the real open entry if needed.
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         final entryToClose =
//             activeKhataEntry ?? _latestOpenKhataForCurrentDevice();
//
//         if (entryToClose == null) {
//           activeKhataEntry = null;
//
//           showMessage(
//             "Motor stopped. No open Khata session was found to finalize.",
//             false,
//           );
//           return;
//         }
//
//         final closedEntry =
//         await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
//           entry: entryToClose,
//           endTime: endTime,
//         );
//
//         // IMPORTANT:
//         // Never forget the open entry when the close API failed.
//         // Previous code set activeKhataEntry=null even when ViewModel
//         // returned null, leaving backend is_open=true forever.
//         if (closedEntry == null) {
//           activeKhataEntry = entryToClose;
//
//           final khataError = ref.read(khataViewModelProvider).error;
//
//           showMessage(
//             "Motor is OFF, but Khata finalization failed: "
//                 "${khataError ?? "Unknown Khata close error"}",
//             true,
//             seconds: 14,
//           );
//           return;
//         }
//
//         activeKhataEntry = null;
//
//         // Reload the authoritative finalized values:
//         // ended_at, is_open=false, run_hours and recalculated bill.
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         final stillOpen = _latestOpenKhataForCurrentDevice();
//
//         if (stillOpen != null &&
//             stillOpen.id == closedEntry.id) {
//           activeKhataEntry = stillOpen;
//
//           showMessage(
//             "Motor is OFF, but backend still reports this Khata as open.",
//             true,
//             seconds: 14,
//           );
//           return;
//         }
//
//         showMessage(
//           "Motor stopped. Khata finalized: "
//               "${closedEntry.runHours.toStringAsFixed(2)} hr.",
//           false,
//         );
//         return;
//       }
//
//       final startedLog = await motorVm.startMotor(
//         deviceId: deviceId!,
//         customerName: typedCustomerName,
//       );
//       if (startedLog != null && mounted) {
//         setState(() {
//           activeTriggerType = startedLog.triggerType;
//         });
//       }
//
//       final motorCommandStartedAt = startedLog?.startTime ?? DateTime.now();
//
//       final updatedMotorState = ref.read(motorViewModelProvider);
//
//       if (updatedMotorState.error != null) {
//         showMessage(updatedMotorState.error!, true, seconds: 10);
//         return;
//       }
//
//       // Do NOT open Khata or show ON just because the start API returned.
//       // Billing/timer begin only after VFD telemetry itself confirms ON.
//       final vfdConfirmedOn = await _waitForVfdConfirmation(
//         expectedOn: true,
//         telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
//       );
//
//       if (!vfdConfirmedOn) {
//         showMessage(
//           "Start command was sent, but ON confirmation was not received from VFD telemetry.",
//           true,
//           seconds: 10,
//         );
//         return;
//       }
//
//       // VFD has confirmed ON, so the motor timer must run even if
//       // Khata creation fails. Billing failure must never make the UI
//       // pretend the motor is stopped.
//       if (mounted) {
//         setState(() {
//           runSeconds = 0;
//         });
//       }
//
//       _startLocalTimer(startedAt: motorCommandStartedAt);
//
//       // A real MotorLog UUID is mandatory for an open Khata session.
//       // run_hours is intentionally 0 while the motor is still running.
//       if (startedLog == null) {
//         showMessage(
//           "Motor is ON, but start API returned no MotorLog. Khata was not created.",
//           true,
//           seconds: 12,
//         );
//         return;
//       }
//
//       final motorLogId = startedLog.id?.trim() ?? "";
//
//       if (motorLogId.isEmpty) {
//         showMessage(
//           "Motor is ON, but MotorLog ID is missing from the start response. "
//               "Khata was not created. Check POST /motor/$deviceId/start response.",
//           true,
//           seconds: 14,
//         );
//         return;
//       }
//
//       activeKhataEntry =
//       await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
//         customerName: typedCustomerName,
//         deviceId: deviceId!,
//         motorLogId: motorLogId,
//         startTime: startedLog.startTime ?? motorCommandStartedAt,
//       );
//
//       if (activeKhataEntry == null) {
//         final khataError = ref.read(khataViewModelProvider).error;
//
//         showMessage(
//           "Motor is ON, but Khata was not created: "
//               "${khataError ?? "Unknown Khata API error"}",
//           true,
//           seconds: 14,
//         );
//         return;
//       }
//
//       await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//       showMessage("Motor started. Khata session opened.", false);
//     } catch (e) {
//       showMessage(
//         "Motor action failed: ${friendlyError(e.toString())}",
//         true,
//         seconds: 12,
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           isWaitingForVfdConfirmation = false;
//           motorStateBeforePendingCommand = null;
//         });
//       } else {
//         isWaitingForVfdConfirmation = false;
//         motorStateBeforePendingCommand = null;
//       }
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
//     final names = <String>[];
//     final seen = <String>{};
//
//     // Newest customers first. Duplicate names are removed case-insensitively.
//     for (final entry in khataState.entries.reversed) {
//       final name = entry.customerName?.trim();
//       if (name == null || name.isEmpty) continue;
//
//       final key = name.toLowerCase();
//       if (seen.add(key)) {
//         names.add(name);
//       }
//     }
//
//     return names.take(20).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final latest = ref.watch(
//       telemetryViewModelProvider.select((state) => state.latest),
//     );
//
//     final motorLoading = ref.watch(
//       motorViewModelProvider.select((state) => state.isLoading),
//     );
//
//     final motorButtonLoading =
//         hasDevice && (motorLoading || isWaitingForVfdConfirmation);
//
//     final checkingDevice = hasDevice && !firstTelemetryLoaded;
//
//     final effectiveLatest = hasDevice && firstTelemetryLoaded ? latest : null;
//
//     final deviceOnline = checkingDevice ? false : isDeviceOnline(effectiveLatest);
//     final telemetryMotorRunning =
//     checkingDevice ? false : isMotorRunning(effectiveLatest);
//
//     final motorRunning = isWaitingForVfdConfirmation &&
//         motorStateBeforePendingCommand != null
//         ? motorStateBeforePendingCommand!
//         : telemetryMotorRunning;
//
//     final displayLatest = deviceOnline ? effectiveLatest : null;
//
//     if (motorRunning &&
//         runTimer == null &&
//         !isWaitingForVfdConfirmation &&
//         didRestoreMotorSession) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer == null) {
//           _startLocalTimer(
//             startedAt: activeKhataEntry?.startTime ?? motorStartedAt,
//           );
//         }
//       });
//     }
//
//     // Never reset the run timer just because telemetry becomes stale while
//     // the app is backgrounded. Stop it only when fresh VFD telemetry says OFF.
//     if (deviceOnline &&
//         !telemetryMotorRunning &&
//         runTimer != null &&
//         !isWaitingForVfdConfirmation) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer != null) {
//           _stopLocalTimer();
//           setState(() {
//             runSeconds = 0;
//           });
//         }
//       });
//     }
//
//     final width = MediaQuery.of(context).size.width;
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
//         : "Smart Motor Controller";
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
//       appBar: SmartWellHomeAppBar(
//         hasDevice: hasDevice,
//         deviceOnline: deviceOnline,
//         onSelectDevice: () {
//           Navigator.pushReplacementNamed(context, AppRoutes.devices);
//         },
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: AppColors.primary,
//           backgroundColor: AppColors.cardDark,
//           onRefresh: () async {
//             if (hasDevice) {
//               await loadTelemetry(showError: true);
//               await ref.read(khataViewModelProvider.notifier).loadEntries();
//               await _restoreMotorSessionFromKhata();
//             } else {
//               showMessage("Please select a device first.", true);
//             }
//           },
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
//                     // SmartDeviceHeaderCard(
//                     //   hasDevice: hasDevice,
//                     //   deviceOnline: deviceOnline,
//                     //   motorRunning: motorRunning,
//                     //   displayName: resolvedDisplayName,
//                     //   deviceId: deviceId,
//                     // ),
//                     SmartDeviceHeaderCard(
//                       hasDevice: hasDevice,
//                       deviceOnline: deviceOnline,
//                       motorRunning: motorRunning,
//                       displayName: resolvedDisplayName,
//                       deviceId: deviceId,
//                       triggerType: activeTriggerType,
//                     ),
//                     if (!hasDevice) ...[
//                       const SizedBox(height: 12),
//                       NoDeviceProfessionalNotice(
//                         onSelectDevice: () {
//                           Navigator.pushReplacementNamed(
//                             context,
//                             AppRoutes.devices,
//                           );
//                         },
//                       ),
//                     ],
//                     if (hasDevice && !deviceOnline) ...[
//                       const SizedBox(height: 12),
//                       DeviceOfflineNotice(
//                         onRetry: () => loadTelemetry(showError: true),
//                       ),
//                     ],
//                     if (hasDevice && deviceOnline) ...[
//                       const SizedBox(height: 12),
//                       DeviceOnlineNotice(
//                         motorRunning: motorRunning,
//                       ),
//                     ],
//                     const SizedBox(height: 18),
//                     CustomerNameInputCard(
//                       controller: customerNameController,
//                       focusNode: customerNameFocusNode,
//                       suggestions: customerSuggestions(),
//                       enabled: hasDevice && deviceOnline,
//                     ),
//                     const SizedBox(height: 26),
//                     Center(
//                       child: GestureDetector(
//                         onTap: motorButtonLoading ? null : toggleMotor,
//                         child: AnimatedBuilder(
//                           animation: pulseAnimation,
//                           builder: (context, child) {
//                             final scale = motorButtonLoading
//                                 ? 1.0
//                                 : motorRunning
//                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
//                                 : 1.0;
//
//                             return Transform.scale(
//                               scale: scale,
//                               child: child,
//                             );
//                           },
//                           child: MotorCommandButton(
//                             hasDevice: hasDevice,
//                             deviceOnline: deviceOnline,
//                             isOn: motorRunning,
//                             loading: motorButtonLoading,
//                             size: buttonSize,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     MotorRunStatusCard(
//                       hasDevice: hasDevice,
//                       deviceOnline: deviceOnline,
//                       isOn: motorRunning,
//                       waitingForVfd: isWaitingForVfdConfirmation,
//                       runningTime: runningTime,
//                     ),
//                     const SizedBox(height: 22),
//                     ParameterGridSection(
//                       crossAxisCount: crossAxisCount,
//                       childAspectRatio: childAspectRatio,
//                       metrics: [
//                         ParameterMetric(
//                           icon: Icons.sync_rounded,
//                           title: "Frequency",
//                           value: formatValue(displayLatest?.freq, "Hz"),
//                           highlight: true,
//                         ),
//                         ParameterMetric(
//                           icon: Icons.bolt_rounded,
//                           title: "Voltage",
//                           value: formatValue(displayLatest?.voltage, "V"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.flash_on_rounded,
//                           title: "Current",
//                           value: formatValue(displayLatest?.current, "A"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.power_rounded,
//                           title: "Power",
//                           value: formatValue(displayLatest?.power, "kW"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.speed_rounded,
//                           title: "Load",
//                           value: formatValue(
//                             displayLatest?.powerPercent,
//                             "%",
//                           ),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.rotate_right_rounded,
//                           title: "Motor Speed",
//                           value: formatValue(
//                             displayLatest?.motorSpeed,
//                             "RPM",
//                           ),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.battery_charging_full_rounded,
//                           title: "DC Bus",
//                           value: formatValue(displayLatest?.dcbus, "V"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.electric_meter_rounded,
//                           title: "Energy",
//                           value: formatValue(
//                             displayLatest?.energyIn,
//                             "kWh",
//                           ),
//                         ),
//                       ],
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
// class SmartWellHomeAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final VoidCallback onSelectDevice;
//
//   const SmartWellHomeAppBar({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.onSelectDevice,
//   });
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
//
//   @override
//   Widget build(BuildContext context) {
//     final statusText = !hasDevice
//         ? "No device selected"
//         : deviceOnline
//         ? "Device online"
//         : "Waiting for device";
//
//     final statusColor = !hasDevice
//         ? AppColors.white.withOpacity(0.55)
//         : deviceOnline
//         ? AppColors.green
//         : AppColors.warning;
//
//     return AppBar(
//       backgroundColor: AppColors.primaryDark.withOpacity(0.96),
//       elevation: 2,
//       shadowColor: Colors.black.withOpacity(0.18),
//       centerTitle: false,
//       automaticallyImplyLeading: hasDevice,
//       iconTheme: const IconThemeData(color: AppColors.white),
//       titleSpacing: 18,
//       title: Row(
//         children: [
//           Container(
//             height: 42,
//             width: 42,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(14),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primaryDark,
//                   AppColors.primary,
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.electric_bolt_rounded,
//               color: AppColors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "AabNex",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   statusText,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontSize: 11.5,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 10),
//           child: IconButton(
//             tooltip: "Select Device",
//             onPressed: onSelectDevice,
//             icon: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: AppColors.cardDark.withOpacity(0.94),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: AppColors.white.withOpacity(0.14)),
//               ),
//               child: const Icon(
//                 Icons.devices_other_rounded,
//                 color: AppColors.primary,
//                 size: 22,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class SmartDeviceHeaderCard extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool motorRunning;
//   final String displayName;
//   final String? deviceId;
//   final String? triggerType;
//
//   const SmartDeviceHeaderCard({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.motorRunning,
//     required this.displayName,
//     required this.deviceId,
//     this.triggerType,
//   });
//
//   String _formatTriggerType(String? value) {
//     switch (value?.toLowerCase().trim()) {
//       case 'physical':
//         return 'Physical Button';
//
//       case 'time':
//       case 'timer':
//         return 'Timer';
//
//       case 'schedule':
//         return 'Schedule';
//
//       case 'app':
//         return 'App';
//
//       default:
//         return 'Unknown';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = !hasDevice
//         ? AppColors.primary
//         : !deviceOnline
//         ? AppColors.warning
//         : motorRunning
//         ? AppColors.greenDark
//         : AppColors.primary;
//
//     final icon = !hasDevice
//         ? Icons.hub_outlined
//         : !deviceOnline
//         ? Icons.wifi_tethering_error_rounded
//         : motorRunning
//         ? Icons.power_settings_new_rounded
//         : Icons.verified_rounded;
//
//     final statusText = !hasDevice
//         ? "Ready to connect"
//         : !deviceOnline
//         ? "Waiting for live telemetry"
//         : motorRunning
//         ? "Device online | Motor ON"
//         : "Device online | Motor OFF";
//
//     final triggerText = _formatTriggerType(triggerType);
//
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(26),
//         border: Border.all(color: AppColors.white.withOpacity(0.14)),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.10),
//             blurRadius: 28,
//             offset: const Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 62,
//             width: 62,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 32,
//             ),
//           ),
//
//           const SizedBox(width: 14),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   displayName,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 17,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//
//                 const SizedBox(height: 6),
//
//                 Text(
//                   statusText,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//
//                 // -----------------------------
//                 // MOTOR TRIGGER TYPE
//                 // -----------------------------
//                 if (motorRunning && triggerType != null) ...[
//                   const SizedBox(height: 5),
//
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.touch_app_rounded,
//                         size: 14,
//                         color: AppColors.white.withOpacity(0.60),
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         "Started by: ",
//                         style: TextStyle(
//                           color: AppColors.white.withOpacity(0.45),
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         triggerText,
//                         style: TextStyle(
//                           color: color,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//
//                 const SizedBox(height: 5),
//
//                 Text(
//                   hasDevice
//                       ? (deviceId ?? "Unknown device")
//                       : "No controller selected",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.45),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
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
// class NoDeviceProfessionalNotice extends StatelessWidget {
//   final VoidCallback onSelectDevice;
//
//   const NoDeviceProfessionalNotice({
//     super.key,
//     required this.onSelectDevice,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: AppColors.white.withOpacity(0.14)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 46,
//             width: 46,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.devices_other_rounded,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               "Select a device to enable motor control. Parameters stay empty until a controller is selected.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.68),
//                 fontSize: 13.5,
//                 height: 1.4,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           TextButton(
//             onPressed: onSelectDevice,
//             child: const Text(
//               "Select",
//               style: TextStyle(
//                 color: AppColors.primary,
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
// class DeviceOfflineNotice extends StatelessWidget {
//   final Future<void> Function() onRetry;
//
//   const DeviceOfflineNotice({
//     super.key,
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.warning.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.warning.withOpacity(0.24)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.info_outline_rounded,
//             color: AppColors.warning,
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               "Device selected. Waiting for latest live reading.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.78),
//                 fontSize: 12.8,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: onRetry,
//             child: const Text(
//               "Retry",
//               style: TextStyle(
//                 color: AppColors.warning,
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
// class DeviceOnlineNotice extends StatelessWidget {
//   final bool motorRunning;
//
//   const DeviceOnlineNotice({
//     super.key,
//     required this.motorRunning,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // final text = motorRunning
//     //     ? "Live telemetry received. Motor is running."
//     //     : "Live telemetry received. Motor is stopped.";
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.darkBorderSoft,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.green.withOpacity(0.24)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.check_circle_rounded,
//             color: AppColors.green,
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           // Expanded(
//           //   child: Text(
//           //     text,
//           //     style: TextStyle(
//           //       color: AppColors.white.withOpacity(0.78),
//           //       fontSize: 12.8,
//           //       fontWeight: FontWeight.w700,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomerNameInputCard extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final List<String> suggestions;
//   final bool enabled;
//
//   const CustomerNameInputCard({
//     super.key,
//     required this.controller,
//     required this.focusNode,
//     required this.suggestions,
//     required this.enabled,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4, bottom: 9),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.account_circle_outlined,
//                 size: 17,
//                 color: AppColors.white.withOpacity(0.48),
//               ),
//               const SizedBox(width: 7),
//               Text(
//                 "CUSTOMER / KHATA",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(1),
//                   fontSize: 11,
//                   letterSpacing: 1.1,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         RawAutocomplete<String>(
//           textEditingController: controller,
//           focusNode: focusNode,
//           optionsBuilder: (TextEditingValue value) {
//             if (!enabled) return const Iterable<String>.empty();
//
//             final input = value.text.trim().toLowerCase();
//
//             if (input.isEmpty) {
//               return suggestions.take(8);
//             }
//
//             final startsWith = <String>[];
//             final contains = <String>[];
//
//             for (final name in suggestions) {
//               final lower = name.toLowerCase();
//               if (lower.startsWith(input)) {
//                 startsWith.add(name);
//               } else if (lower.contains(input)) {
//                 contains.add(name);
//               }
//             }
//
//             return [...startsWith, ...contains].take(8);
//           },
//           onSelected: (String value) {
//             controller.text = value;
//             controller.selection = TextSelection.collapsed(
//               offset: controller.text.length,
//             );
//           },
//           fieldViewBuilder: (
//               context,
//               textEditingController,
//               fieldFocusNode,
//               onFieldSubmitted,
//               ) {
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               decoration: BoxDecoration(
//                 color: AppColors.cardDark.withOpacity(0.94),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: fieldFocusNode.hasFocus
//                       ? AppColors.primary.withOpacity(0.70)
//                       : AppColors.white.withOpacity(0.14),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.16),
//                     blurRadius: 16,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 enabled: enabled,
//                 controller: textEditingController,
//                 focusNode: fieldFocusNode,
//                 keyboardType: TextInputType.name,
//                 textCapitalization: TextCapitalization.words,
//                 autocorrect: false,
//                 style: const TextStyle(
//                   color: AppColors.white,
//                   fontSize: 15.5,
//                   fontWeight: FontWeight.w800,
//                 ),
//                 textInputAction: TextInputAction.done,
//                 decoration: InputDecoration(
//                   hintText: enabled
//                       ? "Enter new or previous customer"
//                       : "Device must be online first",
//                   hintStyle: TextStyle(
//                     color: AppColors.white.withOpacity(1),
//                     fontWeight: FontWeight.w600,
//                   ),
//                   prefixIcon: Icon(
//                     enabled
//                         ? Icons.person_search_rounded
//                         : Icons.lock_outline_rounded,
//                     color: AppColors.white,
//                   ),
//                   suffixIcon: enabled && suggestions.isNotEmpty
//                       ? Tooltip(
//                     message: "Previous customers available",
//                     child: Icon(
//                       Icons.history_rounded,
//                       color: AppColors.white.withOpacity(1),
//                     ),
//                   )
//                       : null,
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 18,
//                   ),
//                 ),
//               ),
//             );
//           },
//           optionsViewBuilder: (context, onSelected, options) {
//             final optionList = options.toList();
//
//             return Align(
//               alignment: Alignment.topLeft,
//               child: Material(
//                 color: Colors.transparent,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width - 36,
//                   constraints: const BoxConstraints(
//                     maxHeight: 290,
//                     maxWidth: 560,
//                   ),
//                   margin: const EdgeInsets.only(top: 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.cardDark.withOpacity(0.94),
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: AppColors.white.withOpacity(0.14)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.28),
//                         blurRadius: 24,
//                         offset: const Offset(0, 12),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.history_rounded,
//                               color: AppColors.primary,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               "Previous customers",
//                               style: TextStyle(
//                                 color: AppColors.white.withOpacity(0.62),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w900,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Flexible(
//                         child: ListView.separated(
//                           padding: const EdgeInsets.only(bottom: 7),
//                           shrinkWrap: true,
//                           itemCount: optionList.length,
//                           separatorBuilder: (_, __) => Divider(
//                             height: 1,
//                             color: AppColors.white.withOpacity(0.06),
//                           ),
//                           itemBuilder: (context, index) {
//                             final option = optionList[index];
//
//                             return ListTile(
//                               dense: true,
//                               leading: Container(
//                                 height: 34,
//                                 width: 34,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primary.withOpacity(0.10),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.person_rounded,
//                                   color: AppColors.primary,
//                                   size: 18,
//                                 ),
//                               ),
//                               title: Text(
//                                 option,
//                                 style: const TextStyle(
//                                   color: AppColors.white,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                               trailing: Icon(
//                                 Icons.north_west_rounded,
//                                 size: 17,
//                                 color: AppColors.white.withOpacity(0.30),
//                               ),
//                               onTap: () => onSelected(option),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         if (enabled)
//           Padding(
//             padding: const EdgeInsets.only(left: 5, top: 8),
//             child: Text(
//               suggestions.isEmpty
//                   ? "New customer names will appear here next time."
//                   : "Type to search, or select a previously used customer.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(1),
//                 fontSize: 11.5,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// class MotorCommandButton extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool isOn;
//   final bool loading;
//   final double size;
//
//   const MotorCommandButton({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.isOn,
//     required this.loading,
//     required this.size,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final activeColor = !hasDevice
//         ? AppColors.primary
//         : !deviceOnline
//         ? AppColors.warning
//         : isOn
//         ? AppColors.green
//         : AppColors.error;
//
//     final label = !hasDevice
//         ? "SELECT"
//         : !deviceOnline
//         ? "WAIT"
//         : isOn
//         ? "ON"
//         : "OFF";
//
//     final icon = !hasDevice
//         ? Icons.devices_other_rounded
//         : !deviceOnline
//         ? Icons.wifi_tethering_error_rounded
//         : isOn
//         ? Icons.power_settings_new_rounded
//         : Icons.power_off_rounded;
//
//     final textColor = !hasDevice ? AppColors.black : AppColors.white;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: size,
//       height: size,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             activeColor,
//             activeColor.withOpacity(0.72),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: activeColor.withOpacity(0.30),
//             blurRadius: 34,
//             offset: const Offset(0, 16),
//           ),
//         ],
//       ),
//       child: loading
//           ? const CircularProgressIndicator(color: AppColors.white)
//           : Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: textColor,
//             size: size < 190 ? 36 : 42,
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: label == "SELECT"
//                     ? 24
//                     : label == "WAIT"
//                     ? 24
//                     : size < 190
//                     ? 26
//                     : 36,
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
// class MotorRunStatusCard extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool isOn;
//   final bool waitingForVfd;
//   final String runningTime;
//
//   const MotorRunStatusCard({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.isOn,
//     required this.waitingForVfd,
//     required this.runningTime,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final active = hasDevice && deviceOnline && isOn;
//
//     final title = !hasDevice
//         ? "NO DEVICE"
//         : !deviceOnline
//         ? "WAITING FOR DEVICE"
//         : waitingForVfd
//         ? "SYNCING WITH VFD"
//         : active
//         ? "MOTOR RUN TIME"
//         : "MOTOR STOPPED";
//
//     final subtitle = !hasDevice
//         ? "Select a controller to start monitoring"
//         : !deviceOnline
//         ? "Waiting for fresh live telemetry"
//         : waitingForVfd
//         ? "Waiting for the VFD to confirm the command"
//         : active
//         ? "Elapsed time since this motor run started"
//         : "Timer starts only after VFD confirms ON";
//
//     final accent = active ? AppColors.green : AppColors.primary;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: active
//               ? AppColors.green.withOpacity(0.28)
//               : AppColors.white.withOpacity(0.14),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 44,
//             width: 44,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: accent.withOpacity(0.11),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: waitingForVfd
//                 ? SizedBox(
//               height: 21,
//               width: 21,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.4,
//                 color: accent,
//               ),
//             )
//                 : Icon(
//               active ? Icons.timer_rounded : Icons.timer_off_outlined,
//               color: accent,
//               size: 23,
//             ),
//           ),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.54),
//                     fontSize: 10.5,
//                     letterSpacing: 0.9,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.60),
//                     fontSize: 11.8,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             active ? runningTime : "00:00:00",
//             style: TextStyle(
//               color: active
//                   ? AppColors.green
//                   : AppColors.white.withOpacity(0.42),
//               fontSize: 20,
//               fontWeight: FontWeight.w900,
//               fontFeatures: const [FontFeature.tabularFigures()],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ParameterMetric {
//   final IconData icon;
//   final String title;
//   final String value;
//   final bool highlight;
//
//   const ParameterMetric({
//     required this.icon,
//     required this.title,
//     required this.value,
//     this.highlight = false,
//   });
// }
//
// class ParameterGridSection extends StatelessWidget {
//   final int crossAxisCount;
//   final double childAspectRatio;
//   final List<ParameterMetric> metrics;
//
//   const ParameterGridSection({
//     super.key,
//     required this.crossAxisCount,
//     required this.childAspectRatio,
//     required this.metrics,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: crossAxisCount,
//       crossAxisSpacing: 14,
//       mainAxisSpacing: 14,
//       childAspectRatio: childAspectRatio,
//       children: metrics.map((metric) {
//         return ParameterMetricCard(metric: metric);
//       }).toList(),
//     );
//   }
// }
//
// class ParameterMetricCard extends StatelessWidget {
//   final ParameterMetric metric;
//
//   const ParameterMetricCard({
//     super.key,
//     required this.metric,
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
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: metric.highlight
//               ? AppColors.primary
//               : AppColors.white,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.20),
//             blurRadius: 18,
//             offset: const Offset(0, 9),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             metric.icon,
//             color: metric.highlight
//                 ? AppColors.primary
//                 : AppColors.white.withOpacity(0.45),
//             size: compact ? 24 : 28,
//           ),
//           const Spacer(),
//           Text(
//             metric.title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: AppColors.white,
//               fontSize: compact ? 12.5 : 14,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             alignment: Alignment.centerLeft,
//             fit: BoxFit.scaleDown,
//             child: Text(
//               metric.value,
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
//     with SingleTickerProviderStateMixin, WidgetsBindingObserver {
//   late AnimationController pulseController;
//   late Animation<double> pulseAnimation;
//
//   final TextEditingController customerNameController = TextEditingController();
//   final FocusNode customerNameFocusNode = FocusNode();
//
//   KhataEntryModel? activeKhataEntry;
//   String? activeTriggerType;
//
//   Timer? telemetryTimer;
//   Timer? runTimer;
//
//   int runSeconds = 0;
//   DateTime? motorStartedAt;
//
//   // Authoritative MotorLog timestamps returned by the server/database.
//   DateTime? serverMotorStartedAt;
//   DateTime? serverMotorStoppedAt;
//
//   String? userId;
//   String? deviceId;
//   String? deviceName;
//
//   bool didSetupDevice = false;
//   bool isTelemetryLoading = false;
//   bool firstTelemetryLoaded = false;
//
//   // Prevents the UI from starting a brand-new timer before we have checked
//   // whether an existing open Khata session already has the real start time.
//   bool didRestoreMotorSession = false;
//   bool isRestoringMotorSession = false;
//
//   // Keeps the motor button in loading state until VFD telemetry confirms
//   // the requested ON/OFF state.
//   bool isWaitingForVfdConfirmation = false;
//
//   // While a command is pending, keep showing the last confirmed state.
//   // This prevents ON -> OFF -> ON / OFF -> ON -> OFF visual flicker.
//   bool? motorStateBeforePendingCommand;
//
//   // Track physical VFD transitions separately from app commands.
//   // If VFD turns OFF unexpectedly, the current run is frozen.
//   // If it later comes ON by itself, the old timer is NOT resumed because
//   // that would incorrectly include the OFF period in runtime/billing.
//   bool? _lastFreshVfdRunning;
//   bool _vfdSessionInterrupted = false;
//   bool _vfdRestartedAfterInterruption = false;
//
//   bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
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
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _refreshRunSeconds();
//
//       if (hasDevice) {
//         Future.microtask(() async {
//           await loadTelemetry(showError: false);
//           await ref.read(khataViewModelProvider.notifier).loadEntries();
//           await _restoreMotorSessionFromKhata();
//         });
//       }
//     }
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
//       final rawDeviceId = args["deviceId"]?.toString().trim();
//       if (rawDeviceId != null && rawDeviceId.isNotEmpty) {
//         deviceId = rawDeviceId;
//       }
//
//       final rawDeviceName = args["deviceName"]?.toString().trim();
//       if (rawDeviceName != null && rawDeviceName.isNotEmpty) {
//         deviceName = rawDeviceName;
//       }
//     }
//
//     final widgetDeviceId = widget.deviceId?.trim();
//
//     if (!hasDevice && widgetDeviceId != null && widgetDeviceId.isNotEmpty) {
//       deviceId = widgetDeviceId;
//     }
//
//     if (hasDevice) {
//       Future.microtask(() async {
//         await loadTelemetry();
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//         await _restoreMotorSessionFromKhata();
//       });
//
//       telemetryTimer?.cancel();
//       telemetryTimer = Timer.periodic(
//         const Duration(seconds: 5),
//             (_) => loadTelemetry(showError: false),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     pulseController.dispose();
//     customerNameController.dispose();
//     customerNameFocusNode.dispose();
//     telemetryTimer?.cancel();
//     runTimer?.cancel();
//     super.dispose();
//   }
//
//   int _toInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is num) return value.toInt();
//     return int.tryParse(value.toString()) ?? 0;
//   }
//
//   bool isDeviceOnline(dynamic latest) {
//     if (!hasDevice) return false;
//     if (latest == null) return false;
//
//     final live = _toInt(latest.isLive) == 1;
//     final fresh = latest.isFresh(withinSeconds: 20);
//
//     return live && fresh;
//   }
//
//
//   bool isMotorRunning(dynamic latest) {
//     if (!hasDevice) return false;
//     if (!isDeviceOnline(latest)) return false;
//
//     final statusCode = _toInt(latest.statusCode);
//
//     return statusCode == 1 || statusCode == 2;
//   }
//
//   Future<void> loadTelemetry({bool showError = false}) async {
//     if (!hasDevice) return;
//     if (isTelemetryLoading) return;
//
//     final isFirstLoad = !firstTelemetryLoaded;
//
//     isTelemetryLoading = true;
//
//     try {
//       await ref.read(telemetryViewModelProvider.notifier).loadLatest(
//         deviceId!,
//         showLoading: isFirstLoad,
//       );
//
//       if (mounted) {
//         final latest = ref.read(telemetryViewModelProvider).latest;
//         _handleFreshVfdTransition(latest);
//       }
//     } catch (e) {
//       if (showError) {
//         showMessage(
//           "Telemetry failed: ${friendlyError(e.toString())}",
//           true,
//           seconds: 8,
//         );
//       }
//     } finally {
//       isTelemetryLoading = false;
//
//       if (mounted && isFirstLoad) {
//         setState(() {
//           firstTelemetryLoaded = true;
//         });
//       }
//     }
//   }
//
//   void _handleFreshVfdTransition(dynamic latest) {
//     if (!mounted) return;
//     if (!isDeviceOnline(latest)) return;
//
//     final currentRunning = isMotorRunning(latest);
//     final previousRunning = _lastFreshVfdRunning;
//
//     // Always keep the latest fresh physical state as the baseline.
//     _lastFreshVfdRunning = currentRunning;
//
//     // First fresh reading only establishes the baseline.
//     if (previousRunning == null) {
//       return;
//     }
//
//     // Same physical state: nothing changed.
//     if (previousRunning == currentRunning) {
//       return;
//     }
//
//     // ON/OFF changes caused by our own pending command are handled by the
//     // existing VFD confirmation flow, not as unexpected interruptions.
//     if (isWaitingForVfdConfirmation) {
//       return;
//     }
//
//     // ---------------------------------------------------------------
//     // Unexpected physical ON -> OFF
//     // ---------------------------------------------------------------
//     if (previousRunning && !currentRunning) {
//       _stopLocalTimer(resetStart: false);
//
//       setState(() {
//         _vfdSessionInterrupted = true;
//         _vfdRestartedAfterInterruption = false;
//       });
//
//       return;
//     }
//
//     // ---------------------------------------------------------------
//     // Unexpected physical OFF -> ON
//     // ---------------------------------------------------------------
//     if (!previousRunning &&
//         currentRunning &&
//         _vfdSessionInterrupted) {
//       // Do not restart the old timer. The old session has been interrupted
//       // and resuming it would count VFD downtime as motor runtime.
//       _stopLocalTimer(resetStart: false);
//
//       setState(() {
//         _vfdRestartedAfterInterruption = true;
//       });
//     }
//   }
//
//   Future<bool> _waitForVfdConfirmation({
//     required bool expectedOn,
//     required int telemetryTimestampBeforeCommand,
//   }) async {
//     final deadline = DateTime.now().add(
//       const Duration(seconds: 20),
//     );
//
//     int lastCheckedTimestamp = telemetryTimestampBeforeCommand;
//
//     while (mounted && DateTime.now().isBefore(deadline)) {
//       await loadTelemetry(showError: false);
//
//       if (!mounted) return false;
//
//       final latest = ref.read(telemetryViewModelProvider).latest;
//
//       if (!isDeviceOnline(latest)) {
//         await Future.delayed(
//           const Duration(milliseconds: 400),
//         );
//         continue;
//       }
//
//       final telemetryTimestamp = _toInt(latest?.timestamp);
//
//       // Old telemetry ko confirmation ke liye use nahi karna.
//       if (telemetryTimestamp <= telemetryTimestampBeforeCommand ||
//           telemetryTimestamp <= lastCheckedTimestamp) {
//         await Future.delayed(
//           const Duration(milliseconds: 400),
//         );
//         continue;
//       }
//
//       lastCheckedTimestamp = telemetryTimestamp;
//
//       final confirmedMotorState = isMotorRunning(latest);
//
//       // First NEW VFD response is enough.
//       if (confirmedMotorState == expectedOn) {
//         return true;
//       }
//
//       await Future.delayed(
//         const Duration(milliseconds: 400),
//       );
//     }
//
//     return false;
//   }
//
//   KhataEntryModel? _latestOpenKhataForCurrentDevice() {
//     if (!hasDevice) return null;
//
//     final entries = ref.read(khataViewModelProvider).entries;
//
//     KhataEntryModel? latestOpen;
//
//     for (final entry in entries) {
//       if (entry.deviceId.trim() != deviceId!.trim()) continue;
//       if (!entry.isOpen) continue;
//       if (entry.startTime == null) continue;
//       if (entry.endTime != null) continue;
//
//       if (latestOpen == null ||
//           entry.startTime!.isAfter(latestOpen.startTime!)) {
//         latestOpen = entry;
//       }
//     }
//
//     return latestOpen;
//   }
//
//   Future<void> _restoreMotorSessionFromKhata() async {
//     if (!hasDevice || isRestoringMotorSession) return;
//
//     isRestoringMotorSession = true;
//
//     try {
//       final restoredEntry = _latestOpenKhataForCurrentDevice();
//       final latest = ref.read(telemetryViewModelProvider).latest;
//
//       final hasFreshTelemetry = isDeviceOnline(latest);
//       final vfdSaysRunning =
//       hasFreshTelemetry ? isMotorRunning(latest) : false;
//
//       if (restoredEntry != null) {
//         activeKhataEntry = restoredEntry;
//
//         serverMotorStartedAt = restoredEntry.startTime;
//         serverMotorStoppedAt = restoredEntry.endTime;
//
//         final restoredCustomer = (restoredEntry.customerName ?? "").trim();
//         if (restoredCustomer.isNotEmpty &&
//             customerNameController.text.trim().isEmpty) {
//           customerNameController.text = restoredCustomer;
//           customerNameController.selection = TextSelection.collapsed(
//             offset: customerNameController.text.length,
//           );
//         }
//
//         // An open backend session is authoritative for elapsed time.
//         // Even if the app was killed or the phone slept, elapsed time is
//         // recalculated from this ORIGINAL database timestamp. The periodic
//         // Timer object is recreated, but the elapsed motor time never starts
//         // again from zero.
//         if (!hasFreshTelemetry || vfdSaysRunning) {
//           _startLocalTimer(startedAt: restoredEntry.startTime);
//         }
//       } else {
//         activeKhataEntry = null;
//
//         // If VFD is already running but there is no open app/Khata session,
//         // do not invent an ON timestamp from the phone clock.
//         // Wait for an authoritative server/database startTime.
//         if (vfdSaysRunning && motorStartedAt == null) {
//           _stopLocalTimer();
//         }
//       }
//
//       // Fresh OFF telemetry with an OPEN server/Khata session means the
//       // physical VFD stopped without the normal app OFF finalization.
//       // Freeze the displayed runtime; do not reset it to 00:00:00.
//       if (hasFreshTelemetry && !vfdSaysRunning) {
//         _stopLocalTimer(resetStart: false);
//
//         if (restoredEntry != null) {
//           if (mounted) {
//             setState(() {
//               _vfdSessionInterrupted = true;
//               _vfdRestartedAfterInterruption = false;
//             });
//           } else {
//             _vfdSessionInterrupted = true;
//             _vfdRestartedAfterInterruption = false;
//           }
//         }
//       }
//     } finally {
//       isRestoringMotorSession = false;
//
//       if (mounted) {
//         setState(() {
//           didRestoreMotorSession = true;
//         });
//       } else {
//         didRestoreMotorSession = true;
//       }
//     }
//   }
//
//   void _startLocalTimer({DateTime? startedAt}) {
//     // Never create an ON timestamp from the phone clock.
//     if (startedAt == null) {
//       return;
//     }
//
//     motorStartedAt = startedAt;
//
//     runTimer?.cancel();
//     _refreshRunSeconds();
//
//     runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       _refreshRunSeconds();
//     });
//   }
//
//   void _refreshRunSeconds() {
//     final startedAt = motorStartedAt;
//     if (!mounted || startedAt == null) return;
//
//     final elapsed =
//         DateTime.now().toUtc().difference(startedAt.toUtc()).inSeconds;
//     final safeElapsed = elapsed < 0 ? 0 : elapsed;
//
//     if (safeElapsed != runSeconds) {
//       setState(() {
//         runSeconds = safeElapsed;
//       });
//     }
//   }
//
//   void _stopLocalTimer({bool resetStart = true}) {
//     runTimer?.cancel();
//     runTimer = null;
//
//     if (resetStart) {
//       motorStartedAt = null;
//     }
//   }
//
//   String get runningTime {
//     final seconds = runSeconds < 0 ? 0 : runSeconds;
//     final h = (seconds ~/ 3600).toString().padLeft(2, "0");
//     final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
//     final s = (seconds % 60).toString().padLeft(2, "0");
//     return "$h:$m:$s";
//   }
//   DateTime _toPakistanServerTime(DateTime value) {
//     DateTime utcTime;
//
//     if (value.isUtc) {
//       // Server value already contains proper UTC information.
//       utcTime = value;
//     } else {
//       // Server returned UTC date/time without Z or timezone offset.
//       // Rebuild the same components as UTC instead of converting local time.
//       utcTime = DateTime.utc(
//         value.year,
//         value.month,
//         value.day,
//         value.hour,
//         value.minute,
//         value.second,
//         value.millisecond,
//         value.microsecond,
//       );
//     }
//
//     return utcTime.add(
//       const Duration(hours: 5),
//     );
//   }
//
//   String _formatServerDateTime(DateTime? value) {
//     if (value == null) return "--";
//
//     final pakistanTime = _toPakistanServerTime(value);
//
//     final year =
//     pakistanTime.year.toString().padLeft(4, "0");
//
//     final month =
//     pakistanTime.month.toString().padLeft(2, "0");
//
//     final day =
//     pakistanTime.day.toString().padLeft(2, "0");
//
//     final hour24 = pakistanTime.hour;
//
//     final hour12 = hour24 == 0
//         ? 12
//         : hour24 > 12
//         ? hour24 - 12
//         : hour24;
//
//     final hour =
//     hour12.toString().padLeft(2, "0");
//
//     final minute =
//     pakistanTime.minute.toString().padLeft(2, "0");
//
//     final second =
//     pakistanTime.second.toString().padLeft(2, "0");
//
//     final period =
//     hour24 >= 12 ? "PM" : "AM";
//
//     return "$year-$month-$day  "
//         "$hour:$minute:$second $period PKT";
//   }
//
//   int _serverRunDurationSeconds({
//     required DateTime? startTime,
//     required DateTime? endTime,
//   }) {
//     if (startTime == null || endTime == null) {
//       return 0;
//     }
//
//     final seconds = endTime
//         .toUtc()
//         .difference(startTime.toUtc())
//         .inSeconds;
//
//     return seconds < 0 ? 0 : seconds;
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
//         text.contains("connection refused")) {
//       return "No internet connection. Please check Wi-Fi or mobile data.";
//     }
//
//     if (text.trim().isEmpty) return "Unable to connect. Please try again.";
//
//     return error!;
//   }
//
//   String formatValue(
//       double? value,
//       String unit, {
//         int decimals = 1,
//       }) {
//     if (!hasDevice) return "-- $unit";
//     if (value == null) return "-- $unit";
//     return "${value.toStringAsFixed(decimals)} $unit";
//   }
//
//   Future<void> toggleMotor() async {
//     if (!hasDevice) {
//       showMessage("Please select a device first.", true);
//       return;
//     }
//
//     final latest = ref.read(telemetryViewModelProvider).latest;
//
//     final deviceOnline = isDeviceOnline(latest);
//     final motorRunning = isMotorRunning(latest);
//     final telemetryTimestampBeforeCommand = _toInt(latest?.timestamp);
//
//     if (!deviceOnline) {
//       showMessage(
//         "Device is offline. Wait for live telemetry before motor control.",
//         true,
//         seconds: 8,
//       );
//       return;
//     }
//
//     FocusScope.of(context).unfocus();
//     HapticFeedback.mediumImpact();
//
//     final typedCustomerName = customerNameController.text.trim();
//     final motorVm = ref.read(motorViewModelProvider.notifier);
//
//     // Validate before showing the command spinner.
//     if (!motorRunning && typedCustomerName.isEmpty) {
//       showMessage("Customer name is required to start motor.", true);
//       return;
//     }
//
//     if (mounted) {
//       setState(() {
//         motorStateBeforePendingCommand = motorRunning;
//         isWaitingForVfdConfirmation = true;
//       });
//     }
//
//     try {
//       if (motorRunning) {
//         final stoppedLog = await motorVm.stopMotor(
//           deviceId: deviceId!,
//           customerName: activeKhataEntry?.customerName ??
//               (typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName),
//         );
//
//         final updatedMotorState = ref.read(motorViewModelProvider);
//
//         if (updatedMotorState.error != null) {
//           showMessage(updatedMotorState.error!, true, seconds: 10);
//           return;
//         }
//
//         final endTime = stoppedLog?.endTime;
//
//         if (endTime != null) {
//           if (mounted) {
//             setState(() {
//               serverMotorStoppedAt = endTime;
//             });
//           } else {
//             serverMotorStoppedAt = endTime;
//           }
//         }
//
//         // Do NOT close Khata or show OFF just because the stop API returned.
//         // Billing/timer stop only after VFD telemetry itself confirms OFF.
//         final vfdConfirmedOff = await _waitForVfdConfirmation(
//           expectedOn: false,
//           telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
//         );
//
//         if (!vfdConfirmedOff) {
//           showMessage(
//             "Stop command was sent, but OFF confirmation was not received from VFD telemetry.",
//             true,
//             seconds: 10,
//           );
//           return;
//         }
//
//         // VFD is physically OFF now. Stop the HOME timer immediately.
//         // Khata finalization is a separate server operation and must never
//         // keep the physical motor timer running.
//         _stopLocalTimer();
//
//         if (endTime == null) {
//           showMessage(
//             "Motor is OFF, but server end time is missing.",
//             true,
//             seconds: 12,
//           );
//           return;
//         }
//
//         final finalServerDuration = _serverRunDurationSeconds(
//           startTime: serverMotorStartedAt,
//           endTime: endTime,
//         );
//
//         if (mounted) {
//           setState(() {
//             serverMotorStoppedAt = endTime;
//             runSeconds = finalServerDuration;
//           });
//         } else {
//           serverMotorStoppedAt = endTime;
//           runSeconds = finalServerDuration;
//         }
//
//         // Do not rely only on the in-memory activeKhataEntry.
//         // It can be lost after navigation/app resume/rebuild.
//         // Reload from server and recover the real open entry if needed.
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         final entryToClose =
//             activeKhataEntry ?? _latestOpenKhataForCurrentDevice();
//
//         if (entryToClose == null) {
//           activeKhataEntry = null;
//
//           showMessage(
//             "Motor stopped. No open Khata session was found to finalize.",
//             false,
//           );
//           return;
//         }
//
//         final closedEntry =
//         await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
//           entry: entryToClose,
//           endTime: endTime,
//         );
//
//         // IMPORTANT:
//         // Never forget the open entry when the close API failed.
//         // Previous code set activeKhataEntry=null even when ViewModel
//         // returned null, leaving backend is_open=true forever.
//         if (closedEntry == null) {
//           activeKhataEntry = entryToClose;
//
//           final khataError = ref.read(khataViewModelProvider).error;
//
//           showMessage(
//             "Motor is OFF, but Khata finalization failed: "
//                 "${khataError ?? "Unknown Khata close error"}",
//             true,
//             seconds: 14,
//           );
//           return;
//         }
//
//         activeKhataEntry = null;
//
//         if (mounted) {
//           setState(() {
//             _vfdSessionInterrupted = false;
//             _vfdRestartedAfterInterruption = false;
//           });
//         } else {
//           _vfdSessionInterrupted = false;
//           _vfdRestartedAfterInterruption = false;
//         }
//
//         // Reload the authoritative finalized values:
//         // ended_at, is_open=false, run_hours and recalculated bill.
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         final stillOpen = _latestOpenKhataForCurrentDevice();
//
//         if (stillOpen != null &&
//             stillOpen.id == closedEntry.id) {
//           activeKhataEntry = stillOpen;
//
//           showMessage(
//             "Motor is OFF, but backend still reports this Khata as open.",
//             true,
//             seconds: 14,
//           );
//           return;
//         }
//
//         showMessage(
//           "Motor stopped. Khata finalized: "
//               "${closedEntry.runHours.toStringAsFixed(2)} hr.",
//           false,
//         );
//         return;
//       }
//
//       final startedLog = await motorVm.startMotor(
//         deviceId: deviceId!,
//         customerName: typedCustomerName,
//       );
//       if (startedLog != null && mounted) {
//         setState(() {
//           activeTriggerType = startedLog.triggerType;
//         });
//       }
//
//       final motorCommandStartedAt = startedLog?.startTime;
//
//       if (motorCommandStartedAt != null) {
//         if (mounted) {
//           setState(() {
//             serverMotorStartedAt = motorCommandStartedAt;
//             serverMotorStoppedAt = null;
//             _vfdSessionInterrupted = false;
//             _vfdRestartedAfterInterruption = false;
//           });
//         } else {
//           serverMotorStartedAt = motorCommandStartedAt;
//           serverMotorStoppedAt = null;
//           _vfdSessionInterrupted = false;
//           _vfdRestartedAfterInterruption = false;
//         }
//       }
//
//       final updatedMotorState = ref.read(motorViewModelProvider);
//
//       if (updatedMotorState.error != null) {
//         showMessage(updatedMotorState.error!, true, seconds: 10);
//         return;
//       }
//
//       // Do NOT open Khata or show ON just because the start API returned.
//       // Billing/timer begin only after VFD telemetry itself confirms ON.
//       final vfdConfirmedOn = await _waitForVfdConfirmation(
//         expectedOn: true,
//         telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
//       );
//
//       if (!vfdConfirmedOn) {
//         showMessage(
//           "Start command was sent, but ON confirmation was not received from VFD telemetry.",
//           true,
//           seconds: 10,
//         );
//         return;
//       }
//
//       // VFD has confirmed ON, so the motor timer must run even if
//       // Khata creation fails. Billing failure must never make the UI
//       // pretend the motor is stopped.
//       if (mounted) {
//         setState(() {
//           runSeconds = 0;
//         });
//       }
//
//       if (motorCommandStartedAt == null) {
//         showMessage(
//           "Motor is ON, but server start time is missing.",
//           true,
//           seconds: 12,
//         );
//         return;
//       }
//
//       _startLocalTimer(startedAt: motorCommandStartedAt);
//
//       // A real MotorLog UUID is mandatory for an open Khata session.
//       // run_hours is intentionally 0 while the motor is still running.
//       if (startedLog == null) {
//         showMessage(
//           "Motor is ON, but start API returned no MotorLog. Khata was not created.",
//           true,
//           seconds: 12,
//         );
//         return;
//       }
//
//       final motorLogId = startedLog.id?.trim() ?? "";
//
//       if (motorLogId.isEmpty) {
//         showMessage(
//           "Motor is ON, but MotorLog ID is missing from the start response. "
//               "Khata was not created. Check POST /motor/$deviceId/start response.",
//           true,
//           seconds: 14,
//         );
//         return;
//       }
//
//       activeKhataEntry =
//       await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
//         customerName: typedCustomerName,
//         deviceId: deviceId!,
//         motorLogId: motorLogId,
//         startTime: motorCommandStartedAt,
//       );
//
//       if (activeKhataEntry == null) {
//         final khataError = ref.read(khataViewModelProvider).error;
//
//         showMessage(
//           "Motor is ON, but Khata was not created: "
//               "${khataError ?? "Unknown Khata API error"}",
//           true,
//           seconds: 14,
//         );
//         return;
//       }
//
//       await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//       showMessage("Motor started. Khata session opened.", false);
//     } catch (e) {
//       showMessage(
//         "Motor action failed: ${friendlyError(e.toString())}",
//         true,
//         seconds: 12,
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           isWaitingForVfdConfirmation = false;
//           motorStateBeforePendingCommand = null;
//         });
//       } else {
//         isWaitingForVfdConfirmation = false;
//         motorStateBeforePendingCommand = null;
//       }
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
//     final names = <String>[];
//     final seen = <String>{};
//
//     // Newest customers first. Duplicate names are removed case-insensitively.
//     for (final entry in khataState.entries.reversed) {
//       final name = entry.customerName?.trim();
//       if (name == null || name.isEmpty) continue;
//
//       final key = name.toLowerCase();
//       if (seen.add(key)) {
//         names.add(name);
//       }
//     }
//
//     return names.take(20).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final latest = ref.watch(
//       telemetryViewModelProvider.select((state) => state.latest),
//     );
//
//     final motorLoading = ref.watch(
//       motorViewModelProvider.select((state) => state.isLoading),
//     );
//
//     final motorButtonLoading =
//         hasDevice && (motorLoading || isWaitingForVfdConfirmation);
//
//     final checkingDevice = hasDevice && !firstTelemetryLoaded;
//
//     final effectiveLatest = hasDevice && firstTelemetryLoaded ? latest : null;
//
//     final deviceOnline = checkingDevice ? false : isDeviceOnline(effectiveLatest);
//     final telemetryMotorRunning =
//     checkingDevice ? false : isMotorRunning(effectiveLatest);
//
//     final motorRunning = isWaitingForVfdConfirmation &&
//         motorStateBeforePendingCommand != null
//         ? motorStateBeforePendingCommand!
//         : telemetryMotorRunning;
//
//     final displayLatest = deviceOnline ? effectiveLatest : null;
//
//     if (motorRunning &&
//         runTimer == null &&
//         !isWaitingForVfdConfirmation &&
//         didRestoreMotorSession &&
//         !_vfdSessionInterrupted &&
//         !_vfdRestartedAfterInterruption) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer == null) {
//           _startLocalTimer(
//             startedAt: activeKhataEntry?.startTime ?? motorStartedAt,
//           );
//         }
//       });
//     }
//
//     // Never reset the run timer just because telemetry becomes stale while
//     // the app is backgrounded. Stop it only when fresh VFD telemetry says OFF.
//     if (deviceOnline &&
//         !telemetryMotorRunning &&
//         runTimer != null &&
//         !isWaitingForVfdConfirmation) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && runTimer != null) {
//           // Physical VFD is OFF. Freeze the timer at its last displayed
//           // value. Do not reset and do not invent a server end timestamp.
//           _stopLocalTimer(resetStart: false);
//
//           if (!_vfdSessionInterrupted) {
//             setState(() {
//               _vfdSessionInterrupted = true;
//               _vfdRestartedAfterInterruption = false;
//             });
//           }
//         }
//       });
//     }
//
//     final width = MediaQuery.of(context).size.width;
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
//         : "Smart Motor Controller";
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
//       appBar: SmartWellHomeAppBar(
//         hasDevice: hasDevice,
//         deviceOnline: deviceOnline,
//         onSelectDevice: () {
//           Navigator.pushReplacementNamed(context, AppRoutes.devices);
//         },
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: AppColors.primary,
//           backgroundColor: AppColors.cardDark,
//           onRefresh: () async {
//             if (hasDevice) {
//               await loadTelemetry(showError: true);
//               await ref.read(khataViewModelProvider.notifier).loadEntries();
//               await _restoreMotorSessionFromKhata();
//             } else {
//               showMessage("Please select a device first.", true);
//             }
//           },
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
//                     // SmartDeviceHeaderCard(
//                     //   hasDevice: hasDevice,
//                     //   deviceOnline: deviceOnline,
//                     //   motorRunning: motorRunning,
//                     //   displayName: resolvedDisplayName,
//                     //   deviceId: deviceId,
//                     // ),
//                     SmartDeviceHeaderCard(
//                       hasDevice: hasDevice,
//                       deviceOnline: deviceOnline,
//                       motorRunning: motorRunning,
//                       displayName: resolvedDisplayName,
//                       deviceId: deviceId,
//                       triggerType: activeTriggerType,
//                     ),
//                     // if (!hasDevice) ...[
//                     //   const SizedBox(height: 12),
//                     //   NoDeviceProfessionalNotice(
//                     //     onSelectDevice: () {
//                     //       Navigator.pushReplacementNamed(
//                     //         context,
//                     //         AppRoutes.devices,
//                     //       );
//                     //     },
//                     //   ),
//                     // ],
//                     // if (hasDevice && !deviceOnline) ...[
//                     //   const SizedBox(height: 12),
//                     //   // DeviceOfflineNotice(
//                     //   //   onRetry: () => loadTelemetry(showError: true),
//                     //   // ),
//                     // ],
//                     // if (hasDevice && deviceOnline) ...[
//                     //   const SizedBox(height: 12),
//                     //   DeviceOnlineNotice(
//                     //     motorRunning: motorRunning,
//                     //   ),
//                     // ],
//                     const SizedBox(height: 18),
//                     CustomerNameInputCard(
//                       controller: customerNameController,
//                       focusNode: customerNameFocusNode,
//                       suggestions: customerSuggestions(),
//                       enabled: hasDevice && deviceOnline,
//                     ),
//                     const SizedBox(height: 26),
//                     Center(
//                       child: GestureDetector(
//                         onTap: motorButtonLoading ? null : toggleMotor,
//                         child: AnimatedBuilder(
//                           animation: pulseAnimation,
//                           builder: (context, child) {
//                             final scale = motorButtonLoading
//                                 ? 1.0
//                                 : motorRunning
//                                 ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
//                                 : 1.0;
//
//                             return Transform.scale(
//                               scale: scale,
//                               child: child,
//                             );
//                           },
//                           child: MotorCommandButton(
//                             hasDevice: hasDevice,
//                             deviceOnline: deviceOnline,
//                             isOn: motorRunning,
//                             loading: motorButtonLoading,
//                             size: buttonSize,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     MotorRunStatusCard(
//                       hasDevice: hasDevice,
//                       deviceOnline: deviceOnline,
//                       isOn: motorRunning,
//                       waitingForVfd: isWaitingForVfdConfirmation,
//                       runningTime: runningTime,
//                       serverStartTime:
//                       _formatServerDateTime(serverMotorStartedAt),
//                       serverEndTime:
//                       _formatServerDateTime(serverMotorStoppedAt),
//                       hasServerStartTime: serverMotorStartedAt != null,
//                       hasServerEndTime: serverMotorStoppedAt != null,
//                       vfdSessionInterrupted: _vfdSessionInterrupted,
//                       vfdRestartedAfterInterruption:
//                       _vfdRestartedAfterInterruption,
//                     ),
//                     const SizedBox(height: 22),
//                     ParameterGridSection(
//                       crossAxisCount: crossAxisCount,
//                       childAspectRatio: childAspectRatio,
//                       metrics: [
//                         ParameterMetric(
//                           icon: Icons.sync_rounded,
//                           title: "Frequency",
//                           value: formatValue(displayLatest?.freq, "Hz"),
//                           highlight: true,
//                         ),
//                         ParameterMetric(
//                           icon: Icons.bolt_rounded,
//                           title: "Voltage",
//                           value: formatValue(displayLatest?.voltage, "V"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.flash_on_rounded,
//                           title: "Current",
//                           value: formatValue(displayLatest?.current, "A"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.power_rounded,
//                           title: "Power",
//                           value: formatValue(displayLatest?.power, "kW"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.speed_rounded,
//                           title: "Load",
//                           value: formatValue(
//                             displayLatest?.powerPercent,
//                             "%",
//                           ),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.rotate_right_rounded,
//                           title: "Motor Speed",
//                           value: formatValue(
//                             displayLatest?.motorSpeed,
//                             "RPM",
//                           ),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.battery_charging_full_rounded,
//                           title: "DC Bus",
//                           value: formatValue(displayLatest?.dcbus, "V"),
//                         ),
//                         ParameterMetric(
//                           icon: Icons.electric_meter_rounded,
//                           title: "Energy",
//                           value: formatValue(
//                             displayLatest?.energyIn,
//                             "kWh",
//                           ),
//                         ),
//                       ],
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
// class SmartWellHomeAppBar extends StatelessWidget
//     implements PreferredSizeWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final VoidCallback onSelectDevice;
//
//   const SmartWellHomeAppBar({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.onSelectDevice,
//   });
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
//
//   @override
//   Widget build(BuildContext context) {
//     final statusText = !hasDevice
//         ? "No device selected"
//         : deviceOnline
//         ? "Device online"
//         : "Waiting for device";
//
//     final statusColor = !hasDevice
//         ? AppColors.white.withOpacity(0.55)
//         : deviceOnline
//         ? AppColors.green
//         : AppColors.warning;
//
//     return AppBar(
//       backgroundColor: AppColors.primaryDark.withOpacity(0.96),
//       elevation: 2,
//       shadowColor: Colors.black.withOpacity(0.18),
//       centerTitle: false,
//       automaticallyImplyLeading: hasDevice,
//       iconTheme: const IconThemeData(color: AppColors.white),
//       titleSpacing: 18,
//       title: Row(
//         children: [
//           Container(
//             height: 42,
//             width: 42,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(14),
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primaryDark,
//                   AppColors.primary,
//                 ],
//               ),
//             ),
//             child: const Icon(
//               Icons.electric_bolt_rounded,
//               color: AppColors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   "AabNex",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   statusText,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontSize: 11.5,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 10),
//           child: IconButton(
//             tooltip: "Select Device",
//             onPressed: onSelectDevice,
//             icon: Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: AppColors.cardDark.withOpacity(0.94),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: AppColors.white.withOpacity(0.14)),
//               ),
//               child: const Icon(
//                 Icons.devices_other_rounded,
//                 color: AppColors.primary,
//                 size: 22,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class SmartDeviceHeaderCard extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool motorRunning;
//   final String displayName;
//   final String? deviceId;
//   final String? triggerType;
//
//   const SmartDeviceHeaderCard({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.motorRunning,
//     required this.displayName,
//     required this.deviceId,
//     this.triggerType,
//   });
//
//   String _formatTriggerType(String? value) {
//     switch (value?.toLowerCase().trim()) {
//       case 'physical':
//         return 'Physical Button';
//
//       case 'time':
//       case 'timer':
//         return 'Timer';
//
//       case 'schedule':
//         return 'Schedule';
//
//       case 'app':
//         return 'App';
//
//       default:
//         return 'Unknown';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final color = !hasDevice
//         ? AppColors.primary
//         : !deviceOnline
//         ? AppColors.warning
//         : motorRunning
//         ? AppColors.greenDark
//         : AppColors.primary;
//
//     final icon = !hasDevice
//         ? Icons.hub_outlined
//         : !deviceOnline
//         ? Icons.wifi_tethering_error_rounded
//         : motorRunning
//         ? Icons.power_settings_new_rounded
//         : Icons.verified_rounded;
//
//     final statusText = !hasDevice
//         ? "Ready to connect"
//         : !deviceOnline
//         ? "Waiting for live telemetry"
//         : motorRunning
//         ? "Device online | Motor ON"
//         : "Device online | Motor OFF";
//
//     final triggerText = _formatTriggerType(triggerType);
//
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(26),
//         border: Border.all(color: AppColors.white.withOpacity(0.14)),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.10),
//             blurRadius: 28,
//             offset: const Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 62,
//             width: 62,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 32,
//             ),
//           ),
//
//           const SizedBox(width: 14),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (!hasDevice || deviceId != displayName)
//                   Text(
//                     hasDevice
//                         ? (deviceId ?? "Unknown device")
//                         : "No controller selected",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: AppColors.white.withOpacity(1),
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//                 const SizedBox(height: 6),
//
//                 Text(
//                   statusText,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//
//                 // -----------------------------
//                 // MOTOR TRIGGER TYPE
//                 // -----------------------------
//                 if (motorRunning && triggerType != null) ...[
//                   const SizedBox(height: 5),
//
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.touch_app_rounded,
//                         size: 14,
//                         color: AppColors.white.withOpacity(0.60),
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         "Started by: ",
//                         style: TextStyle(
//                           color: AppColors.white.withOpacity(0.45),
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       Text(
//                         triggerText,
//                         style: TextStyle(
//                           color: color,
//                           fontSize: 11,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//
//                 const SizedBox(height: 5),
//
//                 Text(
//                   hasDevice
//                       ? (deviceId ?? "Unknown device")
//                       : "No controller selected",
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.45),
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
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
// class NoDeviceProfessionalNotice extends StatelessWidget {
//   final VoidCallback onSelectDevice;
//
//   const NoDeviceProfessionalNotice({
//     super.key,
//     required this.onSelectDevice,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: AppColors.white.withOpacity(0.14)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 46,
//             width: 46,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.devices_other_rounded,
//               color: AppColors.primary,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               "Select a device to enable motor control. Parameters stay empty until a controller is selected.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.68),
//                 fontSize: 13.5,
//                 height: 1.4,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           TextButton(
//             onPressed: onSelectDevice,
//             child: const Text(
//               "Select",
//               style: TextStyle(
//                 color: AppColors.primary,
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
// // class DeviceOfflineNotice extends StatelessWidget {
// //   final Future<void> Function() onRetry;
// //
// //   const DeviceOfflineNotice({
// //     super.key,
// //     required this.onRetry,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: AppColors.warning.withOpacity(0.10),
// //         borderRadius: BorderRadius.circular(18),
// //         border: Border.all(color: AppColors.warning.withOpacity(0.24)),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(
// //             Icons.info_outline_rounded,
// //             color: AppColors.warning,
// //             size: 22,
// //           ),
// //           const SizedBox(width: 10),
// //           // Expanded(
// //           //   child: Text(
// //           //     "Device selected. Waiting for latest live reading.",
// //           //     style: TextStyle(
// //           //       color: AppColors.white.withOpacity(0.78),
// //           //       fontSize: 12.8,
// //           //       fontWeight: FontWeight.w700,
// //           //     ),
// //           //   ),
// //           // ),
// //           // TextButton(
// //           //   onPressed: onRetry,
// //           //   child: const Text(
// //           //     "Retry",
// //           //     style: TextStyle(
// //           //       color: AppColors.warning,
// //           //       fontWeight: FontWeight.w900,
// //           //     ),
// //           //   ),
// //           // ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// class DeviceOnlineNotice extends StatelessWidget {
//   final bool motorRunning;
//
//   const DeviceOnlineNotice({
//     super.key,
//     required this.motorRunning,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // final text = motorRunning
//     //     ? "Live telemetry received. Motor is running."
//     //     : "Live telemetry received. Motor is stopped.";
//
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.darkBorderSoft,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.green.withOpacity(0.24)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.check_circle_rounded,
//             color: AppColors.green,
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           // Expanded(
//           //   child: Text(
//           //     text,
//           //     style: TextStyle(
//           //       color: AppColors.white.withOpacity(0.78),
//           //       fontSize: 12.8,
//           //       fontWeight: FontWeight.w700,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomerNameInputCard extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final List<String> suggestions;
//   final bool enabled;
//
//   const CustomerNameInputCard({
//     super.key,
//     required this.controller,
//     required this.focusNode,
//     required this.suggestions,
//     required this.enabled,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 4, bottom: 9),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.account_circle_outlined,
//                 size: 17,
//                 color: AppColors.white.withOpacity(0.48),
//               ),
//               const SizedBox(width: 7),
//               Text(
//                 "CUSTOMER / KHATA",
//                 style: TextStyle(
//                   color: AppColors.white.withOpacity(1),
//                   fontSize: 11,
//                   letterSpacing: 1.1,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         RawAutocomplete<String>(
//           textEditingController: controller,
//           focusNode: focusNode,
//           optionsBuilder: (TextEditingValue value) {
//             if (!enabled) return const Iterable<String>.empty();
//
//             final input = value.text.trim().toLowerCase();
//
//             if (input.isEmpty) {
//               return suggestions.take(8);
//             }
//
//             final startsWith = <String>[];
//             final contains = <String>[];
//
//             for (final name in suggestions) {
//               final lower = name.toLowerCase();
//               if (lower.startsWith(input)) {
//                 startsWith.add(name);
//               } else if (lower.contains(input)) {
//                 contains.add(name);
//               }
//             }
//
//             return [...startsWith, ...contains].take(8);
//           },
//           onSelected: (String value) {
//             controller.text = value;
//             controller.selection = TextSelection.collapsed(
//               offset: controller.text.length,
//             );
//           },
//           fieldViewBuilder: (
//               context,
//               textEditingController,
//               fieldFocusNode,
//               onFieldSubmitted,
//               ) {
//             return AnimatedContainer(
//               duration: const Duration(milliseconds: 180),
//               decoration: BoxDecoration(
//                 color: AppColors.cardDark.withOpacity(0.94),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: fieldFocusNode.hasFocus
//                       ? AppColors.primary.withOpacity(0.70)
//                       : AppColors.white.withOpacity(0.14),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.16),
//                     blurRadius: 16,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 enabled: enabled,
//                 controller: textEditingController,
//                 focusNode: fieldFocusNode,
//                 keyboardType: TextInputType.name,
//                 textCapitalization: TextCapitalization.words,
//                 autocorrect: false,
//                 style: const TextStyle(
//                   color: AppColors.white,
//                   fontSize: 15.5,
//                   fontWeight: FontWeight.w800,
//                 ),
//                 textInputAction: TextInputAction.done,
//                 decoration: InputDecoration(
//                   hintText: enabled
//                       ? "Enter new or previous customer"
//                       : "Device must be online first",
//                   hintStyle: TextStyle(
//                     color: AppColors.white.withOpacity(1),
//                     fontWeight: FontWeight.w600,
//                   ),
//                   prefixIcon: Icon(
//                     enabled
//                         ? Icons.person_search_rounded
//                         : Icons.lock_outline_rounded,
//                     color: AppColors.white,
//                   ),
//                   suffixIcon: enabled && suggestions.isNotEmpty
//                       ? Tooltip(
//                     message: "Previous customers available",
//                     child: Icon(
//                       Icons.history_rounded,
//                       color: AppColors.white.withOpacity(1),
//                     ),
//                   )
//                       : null,
//                   border: InputBorder.none,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 18,
//                   ),
//                 ),
//               ),
//             );
//           },
//           optionsViewBuilder: (context, onSelected, options) {
//             final optionList = options.toList();
//
//             return Align(
//               alignment: Alignment.topLeft,
//               child: Material(
//                 color: Colors.transparent,
//                 child: Container(
//                   width: MediaQuery.of(context).size.width - 36,
//                   constraints: const BoxConstraints(
//                     maxHeight: 290,
//                     maxWidth: 560,
//                   ),
//                   margin: const EdgeInsets.only(top: 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.cardDark.withOpacity(0.94),
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: AppColors.white.withOpacity(0.14)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.28),
//                         blurRadius: 24,
//                         offset: const Offset(0, 12),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.history_rounded,
//                               color: AppColors.primary,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               "Previous customers",
//                               style: TextStyle(
//                                 color: AppColors.white.withOpacity(0.62),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w900,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Flexible(
//                         child: ListView.separated(
//                           padding: const EdgeInsets.only(bottom: 7),
//                           shrinkWrap: true,
//                           itemCount: optionList.length,
//                           separatorBuilder: (_, __) => Divider(
//                             height: 1,
//                             color: AppColors.white.withOpacity(0.06),
//                           ),
//                           itemBuilder: (context, index) {
//                             final option = optionList[index];
//
//                             return ListTile(
//                               dense: true,
//                               leading: Container(
//                                 height: 34,
//                                 width: 34,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primary.withOpacity(0.10),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.person_rounded,
//                                   color: AppColors.primary,
//                                   size: 18,
//                                 ),
//                               ),
//                               title: Text(
//                                 option,
//                                 style: const TextStyle(
//                                   color: AppColors.white,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                               trailing: Icon(
//                                 Icons.north_west_rounded,
//                                 size: 17,
//                                 color: AppColors.white.withOpacity(0.30),
//                               ),
//                               onTap: () => onSelected(option),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//         if (enabled)
//           Padding(
//             padding: const EdgeInsets.only(left: 5, top: 8),
//             child: Text(
//               suggestions.isEmpty
//                   ? "New customer names will appear here next time."
//                   : "Type to search, or select a previously used customer.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(1),
//                 fontSize: 11.5,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// class MotorCommandButton extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool isOn;
//   final bool loading;
//   final double size;
//
//   const MotorCommandButton({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.isOn,
//     required this.loading,
//     required this.size,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final activeColor = !hasDevice
//         ? AppColors.primary
//         : !deviceOnline
//         ? AppColors.warning
//         : isOn
//         ? AppColors.green
//         : AppColors.error;
//
//     final label = !hasDevice
//         ? "SELECT"
//         : !deviceOnline
//         ? "WAIT"
//         : isOn
//         ? "ON"
//         : "OFF";
//
//     final icon = !hasDevice
//         ? Icons.devices_other_rounded
//         : !deviceOnline
//         ? Icons.wifi_tethering_error_rounded
//         : isOn
//         ? Icons.power_settings_new_rounded
//         : Icons.power_off_rounded;
//
//     final textColor = !hasDevice ? AppColors.black : AppColors.white;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: size,
//       height: size,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             activeColor,
//             activeColor.withOpacity(0.72),
//           ],
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: activeColor.withOpacity(0.30),
//             blurRadius: 34,
//             offset: const Offset(0, 16),
//           ),
//         ],
//       ),
//       child: loading
//           ? const CircularProgressIndicator(color: AppColors.white)
//           : Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: textColor,
//             size: size < 190 ? 36 : 42,
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: label == "SELECT"
//                     ? 24
//                     : label == "WAIT"
//                     ? 24
//                     : size < 190
//                     ? 26
//                     : 36,
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
// class MotorRunStatusCard extends StatelessWidget {
//   final bool hasDevice;
//   final bool deviceOnline;
//   final bool isOn;
//   final bool waitingForVfd;
//   final String runningTime;
//   final String serverStartTime;
//   final String serverEndTime;
//   final bool hasServerStartTime;
//   final bool hasServerEndTime;
//   final bool vfdSessionInterrupted;
//   final bool vfdRestartedAfterInterruption;
//
//   const MotorRunStatusCard({
//     super.key,
//     required this.hasDevice,
//     required this.deviceOnline,
//     required this.isOn,
//     required this.waitingForVfd,
//     required this.runningTime,
//     required this.serverStartTime,
//     required this.serverEndTime,
//     required this.hasServerStartTime,
//     required this.hasServerEndTime,
//     required this.vfdSessionInterrupted,
//     required this.vfdRestartedAfterInterruption,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final active = hasDevice && deviceOnline && isOn;
//
//     final title = !hasDevice
//         ? "NO DEVICE"
//         : !deviceOnline
//         ? "WAITING FOR DEVICE"
//         : waitingForVfd
//         ? "SYNCING WITH VFD"
//         : vfdRestartedAfterInterruption
//         ? "VFD RESTARTED"
//         : vfdSessionInterrupted
//         ? "VFD SESSION INTERRUPTED"
//         : active
//         ? "MOTOR RUN TIME"
//         : "MOTOR STOPPED";
//
//     final subtitle = !hasDevice
//         ? "Select a controller to start monitoring"
//         : !deviceOnline
//         ? "Waiting for fresh live telemetry"
//         : waitingForVfd
//         ? "Waiting for the VFD to confirm the command"
//         : vfdRestartedAfterInterruption
//         ? "Motor is physically ON, but old runtime stays frozen. OFF then ON to start a clean new server session."
//         : vfdSessionInterrupted
//         ? "VFD stopped outside the normal app OFF flow. Runtime is frozen and will not restart automatically."
//         : active
//         ? "Elapsed time from the original server/database start time"
//         : "Timer starts only after VFD confirms ON";
//
//     final accent = active ? AppColors.green : AppColors.primary;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: active
//               ? AppColors.green.withOpacity(0.28)
//               : AppColors.white.withOpacity(0.14),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             height: 44,
//             width: 44,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: accent.withOpacity(0.11),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: waitingForVfd
//                 ? SizedBox(
//               height: 21,
//               width: 21,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2.4,
//                 color: accent,
//               ),
//             )
//                 : Icon(
//               active ? Icons.timer_rounded : Icons.timer_off_outlined,
//               color: accent,
//               size: 23,
//             ),
//           ),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.54),
//                     fontSize: 10.5,
//                     letterSpacing: 0.9,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.60),
//                     fontSize: 11.8,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 if (hasServerStartTime) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     "ON: $serverStartTime",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: AppColors.green.withOpacity(0.88),
//                       fontSize: 10.8,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ],
//                 if (hasServerStartTime) ...[
//                   const SizedBox(height: 3),
//                   Text(
//                     hasServerEndTime
//                         ? "OFF: $serverEndTime"
//                         : "OFF: Running",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: hasServerEndTime
//                           ? AppColors.error.withOpacity(0.88)
//                           : AppColors.white.withOpacity(0.52),
//                       fontSize: 10.8,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             active ||
//                 hasServerEndTime ||
//                 vfdSessionInterrupted ||
//                 vfdRestartedAfterInterruption
//                 ? runningTime
//                 : "00:00:00",
//             style: TextStyle(
//               color: active && !vfdRestartedAfterInterruption
//                   ? AppColors.green
//                   : vfdSessionInterrupted ||
//                   vfdRestartedAfterInterruption
//                   ? AppColors.warning
//                   : hasServerEndTime
//                   ? AppColors.primary
//                   : AppColors.white.withOpacity(0.42),
//               fontSize: 20,
//               fontWeight: FontWeight.w900,
//               fontFeatures: const [FontFeature.tabularFigures()],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ParameterMetric {
//   final IconData icon;
//   final String title;
//   final String value;
//   final bool highlight;
//
//   const ParameterMetric({
//     required this.icon,
//     required this.title,
//     required this.value,
//     this.highlight = false,
//   });
// }
//
// class ParameterGridSection extends StatelessWidget {
//   final int crossAxisCount;
//   final double childAspectRatio;
//   final List<ParameterMetric> metrics;
//
//   const ParameterGridSection({
//     super.key,
//     required this.crossAxisCount,
//     required this.childAspectRatio,
//     required this.metrics,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: crossAxisCount,
//       crossAxisSpacing: 14,
//       mainAxisSpacing: 14,
//       childAspectRatio: childAspectRatio,
//       children: metrics.map((metric) {
//         return ParameterMetricCard(metric: metric);
//       }).toList(),
//     );
//   }
// }
//
// class ParameterMetricCard extends StatelessWidget {
//   final ParameterMetric metric;
//
//   const ParameterMetricCard({
//     super.key,
//     required this.metric,
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
//         color: AppColors.cardDark.withOpacity(0.94),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: metric.highlight
//               ? AppColors.primary
//               : AppColors.white,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.20),
//             blurRadius: 18,
//             offset: const Offset(0, 9),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             metric.icon,
//             color: metric.highlight
//                 ? AppColors.primary
//                 : AppColors.white.withOpacity(0.45),
//             size: compact ? 24 : 28,
//           ),
//           const Spacer(),
//           Text(
//             metric.title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: AppColors.white,
//               fontSize: compact ? 12.5 : 14,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           FittedBox(
//             alignment: Alignment.centerLeft,
//             fit: BoxFit.scaleDown,
//             child: Text(
//               metric.value,
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
import "package:smart_iot_app/src/features/motor/data/models/motor_log_response.dart";

import "../../../logs/data/presentation/providers/motor_log_providers.dart";
import "../../../telemetry/presentation/providers/telemetry_providers.dart";
import "dart:async";
// // //
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
// // //
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/khata/data/models/khata_entry_model.dart";
import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
// // //
import "../../../../app/routes.dart";
import "../../../khata/presentation/providers/ khata_providers.dart";
import "../../../motor/presentation/ providers/motor_providers.dart";



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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController pulseController;
  late Animation<double> pulseAnimation;

  final TextEditingController customerNameController = TextEditingController();
  final FocusNode customerNameFocusNode = FocusNode();

  KhataEntryModel? activeKhataEntry;
  String? activeTriggerType;

  Timer? telemetryTimer;
  Timer? runTimer;

  int runSeconds = 0;
  DateTime? motorStartedAt;

  // Authoritative MotorLog timestamps returned by the server/database.
  DateTime? serverMotorStartedAt;
  DateTime? serverMotorStoppedAt;

  String? userId;
  String? deviceId;
  String? deviceName;

  bool didSetupDevice = false;
  bool isTelemetryLoading = false;
  bool firstTelemetryLoaded = false;

  // Prevents the UI from starting a brand-new timer before we have checked
  // whether an existing open Khata session already has the real start time.
  bool didRestoreMotorSession = false;
  bool isRestoringMotorSession = false;

  // Keeps the motor button in loading state until VFD telemetry confirms
  // the requested ON/OFF state.
  bool isWaitingForVfdConfirmation = false;

  // While a command is pending, keep showing the last confirmed state.
  // This prevents ON -> OFF -> ON / OFF -> ON -> OFF visual flicker.
  bool? motorStateBeforePendingCommand;

  // Track physical VFD transitions separately from app commands.
  // If VFD turns OFF unexpectedly, the current run is frozen.
  // If it later comes ON by itself, the old timer is NOT resumed because
  // that would incorrectly include the OFF period in runtime/billing.
  bool? _lastFreshVfdRunning;
  bool _vfdSessionInterrupted = false;
  bool _vfdRestartedAfterInterruption = false;

  // Prevent overlapping server-log syncs when the motor was started
  // externally by Schedule / Timer instead of the Home ON button.
  bool _syncingExternalMotorSession = false;

  bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 0.82, end: 1.12).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRunSeconds();

      if (hasDevice) {
        Future.microtask(() async {
          await loadTelemetry(showError: false);
          await ref.read(khataViewModelProvider.notifier).loadEntries();
          await _restoreMotorSessionFromKhata();
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (didSetupDevice) return;
    didSetupDevice = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      userId = args["userId"]?.toString();

      final rawDeviceId = args["deviceId"]?.toString().trim();
      if (rawDeviceId != null && rawDeviceId.isNotEmpty) {
        deviceId = rawDeviceId;
      }

      final rawDeviceName = args["deviceName"]?.toString().trim();
      if (rawDeviceName != null && rawDeviceName.isNotEmpty) {
        deviceName = rawDeviceName;
      }
    }

    final widgetDeviceId = widget.deviceId?.trim();

    if (!hasDevice && widgetDeviceId != null && widgetDeviceId.isNotEmpty) {
      deviceId = widgetDeviceId;
    }

    if (hasDevice) {
      Future.microtask(() async {
        await loadTelemetry();
        await ref.read(khataViewModelProvider.notifier).loadEntries();
        await _restoreMotorSessionFromKhata();
      });

      telemetryTimer?.cancel();
      telemetryTimer = Timer.periodic(
        const Duration(seconds: 5),
            (_) => loadTelemetry(showError: false),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pulseController.dispose();
    customerNameController.dispose();
    customerNameFocusNode.dispose();
    telemetryTimer?.cancel();
    runTimer?.cancel();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  bool isDeviceOnline(dynamic latest) {
    if (!hasDevice) return false;
    if (latest == null) return false;

    final live = _toInt(latest.isLive) == 1;
    final fresh = latest.isFresh(withinSeconds: 20);

    return live && fresh;
  }


  bool isMotorRunning(dynamic latest) {
    if (!hasDevice) return false;
    if (!isDeviceOnline(latest)) return false;

    final statusCode = _toInt(latest.statusCode);

    return statusCode == 1 || statusCode == 2;
  }

  Future<void> loadTelemetry({bool showError = false}) async {
    if (!hasDevice) return;
    if (isTelemetryLoading) return;

    final isFirstLoad = !firstTelemetryLoaded;

    isTelemetryLoading = true;

    try {
      await ref.read(telemetryViewModelProvider.notifier).loadLatest(
        deviceId!,
        showLoading: isFirstLoad,
      );

      if (mounted) {
        final latest = ref.read(telemetryViewModelProvider).latest;
        _handleFreshVfdTransition(latest);

        // Schedule/Timer starts happen on the backend, so toggleMotor()
        // is never called. Recover the authoritative MotorLog start time
        // and trigger so the Home header + timer update automatically.
        await _syncExternalMotorSessionFromServer(latest);
      }
    } catch (e) {
      if (showError) {
        showMessage(
          "Telemetry failed: ${friendlyError(e.toString())}",
          true,
          seconds: 8,
        );
      }
    } finally {
      isTelemetryLoading = false;

      if (mounted && isFirstLoad) {
        setState(() {
          firstTelemetryLoaded = true;
        });
      }
    }
  }

  Future<void> _syncExternalMotorSessionFromServer(dynamic latest) async {
    if (!mounted || !hasDevice || _syncingExternalMotorSession) return;
    if (!isDeviceOnline(latest)) return;

    final motorRunningNow = isMotorRunning(latest);

    if (!motorRunningNow) {
      return;
    }

    // Normal Home/App ON already receives startTime + triggerType directly
    // from startMotor(). Do not disturb that working flow.
    if (serverMotorStartedAt != null &&
        motorStartedAt != null &&
        activeTriggerType != null) {
      return;
    }

    _syncingExternalMotorSession = true;

    try {
      // Schedule / Timer starts happen on the backend, therefore
      // toggleMotor() is never called. Load the authoritative MotorLog.
      await ref
          .read(motorLogViewModelProvider.notifier)
          .loadLogs(deviceId!);

      if (!mounted) return;

      final logs = ref.read(motorLogViewModelProvider).logs;

      MotorLogResponse? latestRunningLog;

      for (final log in logs) {
        if (log.endTime != null || log.startTime == null) {
          continue;
        }

        // loadLogs(deviceId) should already be device-scoped, but keep this
        // check so another device can never be used accidentally.
        final logDeviceId = log.deviceId?.trim();

        if (logDeviceId != null &&
            logDeviceId.isNotEmpty &&
            logDeviceId != deviceId!.trim()) {
          continue;
        }

        if (latestRunningLog == null ||
            log.startTime!.isAfter(latestRunningLog.startTime!)) {
          latestRunningLog = log;
        }
      }

      if (latestRunningLog == null) {
        return;
      }

      final authoritativeStart = latestRunningLog.startTime;
      final serverTrigger =
      latestRunningLog.triggerType?.trim().toLowerCase();

      if (authoritativeStart == null) {
        return;
      }

      // Only this recovery path is for starts which can happen without
      // pressing the Home ON button.
      final isExternalAutomation =
          serverTrigger == "schedule" ||
              serverTrigger == "time" ||
              serverTrigger == "timer";

      if (!isExternalAutomation) {
        return;
      }

      setState(() {
        serverMotorStartedAt = authoritativeStart;
        serverMotorStoppedAt = null;

        // triggerType comes from MotorLogResponse, NOT TelemetryModel.
        activeTriggerType = serverTrigger;

        // A newly-created schedule/timer MotorLog is a clean new run.
        _vfdSessionInterrupted = false;
        _vfdRestartedAfterInterruption = false;
      });

      // Start existing Home timer from authoritative DB/server startTime.
      _startLocalTimer(
        startedAt: authoritativeStart,
      );
    } catch (_) {
      // Retry automatically on the next telemetry poll.
      // Do not alter the existing physical telemetry state.
    } finally {
      _syncingExternalMotorSession = false;
    }
  }

  void _handleFreshVfdTransition(dynamic latest) {
    if (!mounted) return;
    if (!isDeviceOnline(latest)) return;

    final currentRunning = isMotorRunning(latest);
    final previousRunning = _lastFreshVfdRunning;

    // Always keep the latest fresh physical state as the baseline.
    _lastFreshVfdRunning = currentRunning;

    // First fresh reading only establishes the baseline.
    if (previousRunning == null) {
      return;
    }

    // Same physical state: nothing changed.
    if (previousRunning == currentRunning) {
      return;
    }

    // ON/OFF changes caused by our own pending command are handled by the
    // existing VFD confirmation flow, not as unexpected interruptions.
    if (isWaitingForVfdConfirmation) {
      return;
    }

    // ---------------------------------------------------------------
    // Unexpected physical ON -> OFF
    // ---------------------------------------------------------------
    if (previousRunning && !currentRunning) {
      _stopLocalTimer(resetStart: false);

      setState(() {
        _vfdSessionInterrupted = true;
        _vfdRestartedAfterInterruption = false;
      });

      return;
    }

    // ---------------------------------------------------------------
    // Unexpected physical OFF -> ON
    // ---------------------------------------------------------------
    if (!previousRunning &&
        currentRunning &&
        _vfdSessionInterrupted) {
      // Do not restart the old timer. The old session has been interrupted
      // and resuming it would count VFD downtime as motor runtime.
      _stopLocalTimer(resetStart: false);

      setState(() {
        _vfdRestartedAfterInterruption = true;
      });
    }
  }

  Future<bool> _waitForVfdConfirmation({
    required bool expectedOn,
    required int telemetryTimestampBeforeCommand,
  }) async {
    final deadline = DateTime.now().add(
      const Duration(seconds: 20),
    );

    int lastCheckedTimestamp = telemetryTimestampBeforeCommand;

    while (mounted && DateTime.now().isBefore(deadline)) {
      await loadTelemetry(showError: false);

      if (!mounted) return false;

      final latest = ref.read(telemetryViewModelProvider).latest;

      if (!isDeviceOnline(latest)) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        continue;
      }

      final telemetryTimestamp = _toInt(latest?.timestamp);

      // Old telemetry ko confirmation ke liye use nahi karna.
      if (telemetryTimestamp <= telemetryTimestampBeforeCommand ||
          telemetryTimestamp <= lastCheckedTimestamp) {
        await Future.delayed(
          const Duration(milliseconds: 400),
        );
        continue;
      }

      lastCheckedTimestamp = telemetryTimestamp;

      final confirmedMotorState = isMotorRunning(latest);

      // First NEW VFD response is enough.
      if (confirmedMotorState == expectedOn) {
        return true;
      }

      await Future.delayed(
        const Duration(milliseconds: 400),
      );
    }

    return false;
  }

  KhataEntryModel? _latestOpenKhataForCurrentDevice() {
    if (!hasDevice) return null;

    final entries = ref.read(khataViewModelProvider).entries;

    KhataEntryModel? latestOpen;

    for (final entry in entries) {
      if (entry.deviceId.trim() != deviceId!.trim()) continue;
      if (!entry.isOpen) continue;
      if (entry.startTime == null) continue;
      if (entry.endTime != null) continue;

      if (latestOpen == null ||
          entry.startTime!.isAfter(latestOpen.startTime!)) {
        latestOpen = entry;
      }
    }

    return latestOpen;
  }

  Future<void> _restoreMotorSessionFromKhata() async {
    if (!hasDevice || isRestoringMotorSession) return;

    isRestoringMotorSession = true;

    try {
      final restoredEntry = _latestOpenKhataForCurrentDevice();
      final latest = ref.read(telemetryViewModelProvider).latest;

      final hasFreshTelemetry = isDeviceOnline(latest);
      final vfdSaysRunning =
      hasFreshTelemetry ? isMotorRunning(latest) : false;

      if (restoredEntry != null) {
        activeKhataEntry = restoredEntry;

        serverMotorStartedAt = restoredEntry.startTime;
        serverMotorStoppedAt = restoredEntry.endTime;

        final restoredCustomer = (restoredEntry.customerName ?? "").trim();
        if (restoredCustomer.isNotEmpty &&
            customerNameController.text.trim().isEmpty) {
          customerNameController.text = restoredCustomer;
          customerNameController.selection = TextSelection.collapsed(
            offset: customerNameController.text.length,
          );
        }

        // An open backend session is authoritative for elapsed time.
        // Even if the app was killed or the phone slept, elapsed time is
        // recalculated from this ORIGINAL database timestamp. The periodic
        // Timer object is recreated, but the elapsed motor time never starts
        // again from zero.
        if (!hasFreshTelemetry || vfdSaysRunning) {
          _startLocalTimer(startedAt: restoredEntry.startTime);
        }
      } else {
        activeKhataEntry = null;

        // If VFD is already running but there is no open app/Khata session,
        // do not invent an ON timestamp from the phone clock.
        // Wait for an authoritative server/database startTime.
        if (vfdSaysRunning && motorStartedAt == null) {
          _stopLocalTimer();
        }
      }

      // Fresh OFF telemetry with an OPEN server/Khata session means the
      // physical VFD stopped without the normal app OFF finalization.
      // Freeze the displayed runtime; do not reset it to 00:00:00.
      if (hasFreshTelemetry && !vfdSaysRunning) {
        _stopLocalTimer(resetStart: false);

        if (restoredEntry != null) {
          if (mounted) {
            setState(() {
              _vfdSessionInterrupted = true;
              _vfdRestartedAfterInterruption = false;
            });
          } else {
            _vfdSessionInterrupted = true;
            _vfdRestartedAfterInterruption = false;
          }
        }
      }
    } finally {
      isRestoringMotorSession = false;

      if (mounted) {
        setState(() {
          didRestoreMotorSession = true;
        });
      } else {
        didRestoreMotorSession = true;
      }
    }
  }

  void _startLocalTimer({DateTime? startedAt}) {
    // Never create an ON timestamp from the phone clock.
    if (startedAt == null) {
      return;
    }

    motorStartedAt = startedAt;

    runTimer?.cancel();
    _refreshRunSeconds();

    runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _refreshRunSeconds();
    });
  }

  void _refreshRunSeconds() {
    final startedAt = motorStartedAt;
    if (!mounted || startedAt == null) return;

    final elapsed =
        DateTime.now().toUtc().difference(startedAt.toUtc()).inSeconds;
    final safeElapsed = elapsed < 0 ? 0 : elapsed;

    if (safeElapsed != runSeconds) {
      setState(() {
        runSeconds = safeElapsed;
      });
    }
  }

  void _stopLocalTimer({bool resetStart = true}) {
    runTimer?.cancel();
    runTimer = null;

    if (resetStart) {
      motorStartedAt = null;
    }
  }

  String get runningTime {
    final seconds = runSeconds < 0 ? 0 : runSeconds;
    final h = (seconds ~/ 3600).toString().padLeft(2, "0");
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
    final s = (seconds % 60).toString().padLeft(2, "0");
    return "$h:$m:$s";
  }
  DateTime _toPakistanServerTime(DateTime value) {
    DateTime utcTime;

    if (value.isUtc) {
      // Server value already contains proper UTC information.
      utcTime = value;
    } else {
      // Server returned UTC date/time without Z or timezone offset.
      // Rebuild the same components as UTC instead of converting local time.
      utcTime = DateTime.utc(
        value.year,
        value.month,
        value.day,
        value.hour,
        value.minute,
        value.second,
        value.millisecond,
        value.microsecond,
      );
    }

    return utcTime.add(
      const Duration(hours: 5),
    );
  }

  String _formatServerDateTime(DateTime? value) {
    if (value == null) return "--";

    final pakistanTime = _toPakistanServerTime(value);

    final year =
    pakistanTime.year.toString().padLeft(4, "0");

    final month =
    pakistanTime.month.toString().padLeft(2, "0");

    final day =
    pakistanTime.day.toString().padLeft(2, "0");

    final hour24 = pakistanTime.hour;

    final hour12 = hour24 == 0
        ? 12
        : hour24 > 12
        ? hour24 - 12
        : hour24;

    final hour =
    hour12.toString().padLeft(2, "0");

    final minute =
    pakistanTime.minute.toString().padLeft(2, "0");

    final second =
    pakistanTime.second.toString().padLeft(2, "0");

    final period =
    hour24 >= 12 ? "PM" : "AM";

    return "$year-$month-$day  "
        "$hour:$minute:$second $period PKT";
  }

  int _serverRunDurationSeconds({
    required DateTime? startTime,
    required DateTime? endTime,
  }) {
    if (startTime == null || endTime == null) {
      return 0;
    }

    final seconds = endTime
        .toUtc()
        .difference(startTime.toUtc())
        .inSeconds;

    return seconds < 0 ? 0 : seconds;
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

    final latest = ref.read(telemetryViewModelProvider).latest;

    final deviceOnline = isDeviceOnline(latest);
    final motorRunning = isMotorRunning(latest);
    final telemetryTimestampBeforeCommand = _toInt(latest?.timestamp);

    if (!deviceOnline) {
      showMessage(
        "Device is offline. Wait for live telemetry before motor control.",
        true,
        seconds: 8,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    final typedCustomerName = customerNameController.text.trim();
    final motorVm = ref.read(motorViewModelProvider.notifier);

    // Validate before showing the command spinner.
    if (!motorRunning && typedCustomerName.isEmpty) {
      showMessage("Customer name is required to start motor.", true);
      return;
    }

    if (mounted) {
      setState(() {
        motorStateBeforePendingCommand = motorRunning;
        isWaitingForVfdConfirmation = true;
      });
    }

    try {
      if (motorRunning) {
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

        final endTime = stoppedLog?.endTime;

        if (endTime != null) {
          if (mounted) {
            setState(() {
              serverMotorStoppedAt = endTime;
            });
          } else {
            serverMotorStoppedAt = endTime;
          }
        }

        // Do NOT close Khata or show OFF just because the stop API returned.
        // Billing/timer stop only after VFD telemetry itself confirms OFF.
        final vfdConfirmedOff = await _waitForVfdConfirmation(
          expectedOn: false,
          telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
        );

        if (!vfdConfirmedOff) {
          showMessage(
            "Stop command was sent, but OFF confirmation was not received from VFD telemetry.",
            true,
            seconds: 10,
          );
          return;
        }

        // VFD is physically OFF now. Stop the HOME timer immediately.
        // Khata finalization is a separate server operation and must never
        // keep the physical motor timer running.
        _stopLocalTimer();

        if (endTime == null) {
          showMessage(
            "Motor is OFF, but server end time is missing.",
            true,
            seconds: 12,
          );
          return;
        }

        final finalServerDuration = _serverRunDurationSeconds(
          startTime: serverMotorStartedAt,
          endTime: endTime,
        );

        if (mounted) {
          setState(() {
            serverMotorStoppedAt = endTime;
            runSeconds = finalServerDuration;
          });
        } else {
          serverMotorStoppedAt = endTime;
          runSeconds = finalServerDuration;
        }

        // Do not rely only on the in-memory activeKhataEntry.
        // It can be lost after navigation/app resume/rebuild.
        // Reload from server and recover the real open entry if needed.
        await ref.read(khataViewModelProvider.notifier).loadEntries();

        final entryToClose =
            activeKhataEntry ?? _latestOpenKhataForCurrentDevice();

        if (entryToClose == null) {
          activeKhataEntry = null;

          showMessage(
            "Motor stopped. No open Khata session was found to finalize.",
            false,
          );
          return;
        }

        final closedEntry =
        await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
          entry: entryToClose,
          endTime: endTime,
        );

        // IMPORTANT:
        // Never forget the open entry when the close API failed.
        // Previous code set activeKhataEntry=null even when ViewModel
        // returned null, leaving backend is_open=true forever.
        if (closedEntry == null) {
          activeKhataEntry = entryToClose;

          final khataError = ref.read(khataViewModelProvider).error;

          showMessage(
            "Motor is OFF, but Khata finalization failed: "
                "${khataError ?? "Unknown Khata close error"}",
            true,
            seconds: 14,
          );
          return;
        }

        activeKhataEntry = null;

        if (mounted) {
          setState(() {
            _vfdSessionInterrupted = false;
            _vfdRestartedAfterInterruption = false;
          });
        } else {
          _vfdSessionInterrupted = false;
          _vfdRestartedAfterInterruption = false;
        }

        // Reload the authoritative finalized values:
        // ended_at, is_open=false, run_hours and recalculated bill.
        await ref.read(khataViewModelProvider.notifier).loadEntries();

        final stillOpen = _latestOpenKhataForCurrentDevice();

        if (stillOpen != null &&
            stillOpen.id == closedEntry.id) {
          activeKhataEntry = stillOpen;

          showMessage(
            "Motor is OFF, but backend still reports this Khata as open.",
            true,
            seconds: 14,
          );
          return;
        }

        showMessage(
          "Motor stopped. Khata finalized: "
              "${closedEntry.runHours.toStringAsFixed(2)} hr.",
          false,
        );
        return;
      }

      final startedLog = await motorVm.startMotor(
        deviceId: deviceId!,
        customerName: typedCustomerName,
      );
      if (startedLog != null && mounted) {
        setState(() {
          activeTriggerType = startedLog.triggerType;
        });
      }

      final motorCommandStartedAt = startedLog?.startTime;

      if (motorCommandStartedAt != null) {
        if (mounted) {
          setState(() {
            serverMotorStartedAt = motorCommandStartedAt;
            serverMotorStoppedAt = null;
            _vfdSessionInterrupted = false;
            _vfdRestartedAfterInterruption = false;
          });
        } else {
          serverMotorStartedAt = motorCommandStartedAt;
          serverMotorStoppedAt = null;
          _vfdSessionInterrupted = false;
          _vfdRestartedAfterInterruption = false;
        }
      }

      final updatedMotorState = ref.read(motorViewModelProvider);

      if (updatedMotorState.error != null) {
        showMessage(updatedMotorState.error!, true, seconds: 10);
        return;
      }

      // Do NOT open Khata or show ON just because the start API returned.
      // Billing/timer begin only after VFD telemetry itself confirms ON.
      final vfdConfirmedOn = await _waitForVfdConfirmation(
        expectedOn: true,
        telemetryTimestampBeforeCommand: telemetryTimestampBeforeCommand,
      );

      if (!vfdConfirmedOn) {
        showMessage(
          "Start command was sent, but ON confirmation was not received from VFD telemetry.",
          true,
          seconds: 10,
        );
        return;
      }

      // VFD has confirmed ON, so the motor timer must run even if
      // Khata creation fails. Billing failure must never make the UI
      // pretend the motor is stopped.
      if (mounted) {
        setState(() {
          runSeconds = 0;
        });
      }

      if (motorCommandStartedAt == null) {
        showMessage(
          "Motor is ON, but server start time is missing.",
          true,
          seconds: 12,
        );
        return;
      }

      _startLocalTimer(startedAt: motorCommandStartedAt);

      // A real MotorLog UUID is mandatory for an open Khata session.
      // run_hours is intentionally 0 while the motor is still running.
      if (startedLog == null) {
        showMessage(
          "Motor is ON, but start API returned no MotorLog. Khata was not created.",
          true,
          seconds: 12,
        );
        return;
      }

      final motorLogId = startedLog.id?.trim() ?? "";

      if (motorLogId.isEmpty) {
        showMessage(
          "Motor is ON, but MotorLog ID is missing from the start response. "
              "Khata was not created. Check POST /motor/$deviceId/start response.",
          true,
          seconds: 14,
        );
        return;
      }

      activeKhataEntry =
      await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
        customerName: typedCustomerName,
        deviceId: deviceId!,
        motorLogId: motorLogId,
        startTime: motorCommandStartedAt,
      );

      if (activeKhataEntry == null) {
        final khataError = ref.read(khataViewModelProvider).error;

        showMessage(
          "Motor is ON, but Khata was not created: "
              "${khataError ?? "Unknown Khata API error"}",
          true,
          seconds: 14,
        );
        return;
      }

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      showMessage("Motor started. Khata session opened.", false);
    } catch (e) {
      showMessage(
        "Motor action failed: ${friendlyError(e.toString())}",
        true,
        seconds: 12,
      );
    } finally {
      if (mounted) {
        setState(() {
          isWaitingForVfdConfirmation = false;
          motorStateBeforePendingCommand = null;
        });
      } else {
        isWaitingForVfdConfirmation = false;
        motorStateBeforePendingCommand = null;
      }
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
    final names = <String>[];
    final seen = <String>{};

    // Newest customers first. Duplicate names are removed case-insensitively.
    for (final entry in khataState.entries.reversed) {
      final name = entry.customerName?.trim();
      if (name == null || name.isEmpty) continue;

      final key = name.toLowerCase();
      if (seen.add(key)) {
        names.add(name);
      }
    }

    return names.take(20).toList();
  }

  @override
  Widget build(BuildContext context) {
    final latest = ref.watch(
      telemetryViewModelProvider.select((state) => state.latest),
    );

    final motorLoading = ref.watch(
      motorViewModelProvider.select((state) => state.isLoading),
    );

    final motorButtonLoading =
        hasDevice && (motorLoading || isWaitingForVfdConfirmation);

    final checkingDevice = hasDevice && !firstTelemetryLoaded;

    final effectiveLatest = hasDevice && firstTelemetryLoaded ? latest : null;

    final deviceOnline = checkingDevice ? false : isDeviceOnline(effectiveLatest);
    final telemetryMotorRunning =
    checkingDevice ? false : isMotorRunning(effectiveLatest);

    final motorRunning = isWaitingForVfdConfirmation &&
        motorStateBeforePendingCommand != null
        ? motorStateBeforePendingCommand!
        : telemetryMotorRunning;

    final displayLatest = deviceOnline ? effectiveLatest : null;

    if (motorRunning &&
        runTimer == null &&
        !isWaitingForVfdConfirmation &&
        didRestoreMotorSession &&
        !_vfdSessionInterrupted &&
        !_vfdRestartedAfterInterruption) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && runTimer == null) {
          _startLocalTimer(
            startedAt: activeKhataEntry?.startTime ?? motorStartedAt,
          );
        }
      });
    }

    // Never reset the run timer just because telemetry becomes stale while
    // the app is backgrounded. Stop it only when fresh VFD telemetry says OFF.
    if (deviceOnline &&
        !telemetryMotorRunning &&
        runTimer != null &&
        !isWaitingForVfdConfirmation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && runTimer != null) {
          // Physical VFD is OFF. Freeze the timer at its last displayed
          // value. Do not reset and do not invent a server end timestamp.
          _stopLocalTimer(resetStart: false);

          if (!_vfdSessionInterrupted) {
            setState(() {
              _vfdSessionInterrupted = true;
              _vfdRestartedAfterInterruption = false;
            });
          }
        }
      });
    }

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
        //hasDevice: hasDevice,

        onSelectDevice: () {
          Navigator.pushReplacementNamed(context, AppRoutes.devices);
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.cardDark,
          onRefresh: () async {
            if (hasDevice) {
              await loadTelemetry(showError: true);
              await ref.read(khataViewModelProvider.notifier).loadEntries();
              await _restoreMotorSessionFromKhata();
            } else {
              showMessage("Please select a device first.", true);
            }
          },
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
                      deviceOnline: deviceOnline,
                      motorRunning: motorRunning,
                      displayName: resolvedDisplayName,
                      deviceId: deviceId,
                      triggerType: activeTriggerType,
                      runningTime: runningTime,
                    ),

                    const SizedBox(height: 18),
                    CustomerNameInputCard(
                      controller: customerNameController,
                      focusNode: customerNameFocusNode,
                      suggestions: customerSuggestions(),
                      enabled: hasDevice && deviceOnline,
                    ),
                    const SizedBox(height: 26),
                    Center(
                      child: GestureDetector(
                        onTap: motorButtonLoading ? null : toggleMotor,
                        child: AnimatedBuilder(
                          animation: pulseAnimation,
                          builder: (context, child) {
                            final scale = motorButtonLoading
                                ? 1.0
                                : motorRunning
                                ? 1.0 + ((pulseAnimation.value - 1.0) * 0.28)
                                : 1.0;

                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: MotorCommandButton(
                            hasDevice: hasDevice,
                            deviceOnline: deviceOnline,
                            isOn: motorRunning,
                            loading: motorButtonLoading,
                            size: buttonSize,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    MotorRunStatusCard(
                      hasDevice: hasDevice,
                      deviceOnline: deviceOnline,
                      isOn: motorRunning,
                      waitingForVfd: isWaitingForVfdConfirmation,
                      runningTime: runningTime,
                      serverStartTime:
                      _formatServerDateTime(serverMotorStartedAt),
                      serverEndTime:
                      _formatServerDateTime(serverMotorStoppedAt),
                      hasServerStartTime: serverMotorStartedAt != null,
                      hasServerEndTime: serverMotorStoppedAt != null,
                      vfdSessionInterrupted: _vfdSessionInterrupted,
                      vfdRestartedAfterInterruption:
                      _vfdRestartedAfterInterruption,
                    ),
                    const SizedBox(height: 22),
                    ParameterGridSection(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      metrics: [
                        ParameterMetric(
                          icon: Icons.sync_rounded,
                          title: "Frequency",
                          value: formatValue(displayLatest?.freq, "Hz"),
                          highlight: true,
                        ),
                        ParameterMetric(
                          icon: Icons.bolt_rounded,
                          title: "Voltage",
                          value: formatValue(displayLatest?.voltage, "V"),
                        ),
                        ParameterMetric(
                          icon: Icons.flash_on_rounded,
                          title: "Current",
                          value: formatValue(displayLatest?.current, "A"),
                        ),
                        ParameterMetric(
                          icon: Icons.power_rounded,
                          title: "Power",
                          value: formatValue(displayLatest?.power, "kW"),
                        ),
                        ParameterMetric(
                          icon: Icons.speed_rounded,
                          title: "Load",
                          value: formatValue(
                            displayLatest?.powerPercent,
                            "%",
                          ),
                        ),
                        ParameterMetric(
                          icon: Icons.rotate_right_rounded,
                          title: "Motor Speed",
                          value: formatValue(
                            displayLatest?.motorSpeed,
                            "RPM",
                          ),
                        ),
                        ParameterMetric(
                          icon: Icons.battery_charging_full_rounded,
                          title: "DC Bus",
                          value: formatValue(displayLatest?.dcbus, "V"),
                        ),
                        ParameterMetric(
                          icon: Icons.electric_meter_rounded,
                          title: "Energy",
                          value: formatValue(
                            displayLatest?.energyIn,
                            "kWh",
                          ),
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
 // final bool hasDevice;
 // final bool deviceOnline;
  final VoidCallback onSelectDevice;

  const SmartWellHomeAppBar({
    super.key,
   // required this.hasDevice,
    //required this.deviceOnline,
    required this.onSelectDevice,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // final statusText = !hasDevice
    //     ? "No device selected"
    //     : "Waiting for device";
    //
    // final statusColor = !hasDevice
    //     ? AppColors.white.withOpacity(0.55)
    //     : AppColors.warning;

    return AppBar(
      backgroundColor: AppColors.primaryDark.withOpacity(1),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.18),
      centerTitle: false,
      //automaticallyImplyLeading: hasDevice,
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
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
                const SizedBox(height: 2),
                // Text(
                // //  statusText,
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(
                //   //  color: statusColor,
                //     fontSize: 11.5,
                //     fontWeight: FontWeight.w800,
                //   ),
                // ),
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
                color: AppColors.cardDark.withOpacity(0.94),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.white.withOpacity(0.14)),
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
  final bool deviceOnline;
  final bool motorRunning;
  final String displayName;
  final String? deviceId;
  final String? triggerType;
  final String runningTime;

  const SmartDeviceHeaderCard({
    super.key,
    required this.hasDevice,
    required this.deviceOnline,
    required this.motorRunning,
    required this.displayName,
    required this.deviceId,
    this.triggerType,
    required this.runningTime,
  });

  String _formatTriggerType(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'physical':
        return 'Physical';

      case 'time':
      case 'timer':
        return 'Timer';

      case 'schedule':
        return 'Schedule';

      case 'app':
        return 'App';

      default:
        return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = !hasDevice
        ? AppColors.primary
        : !deviceOnline
        ? AppColors.warning
        : motorRunning
        ? AppColors.greenDark
        : AppColors.primary;

    final icon = !hasDevice
        ? Icons.hub_outlined
        : !deviceOnline
        ? Icons.wifi_tethering_error_rounded
        : motorRunning
        ? Icons.power_settings_new_rounded
        : Icons.verified_rounded;

    final deviceStatusText = !hasDevice
        ? "No Device"
        : deviceOnline
        ? "Device Online"
        : "Device Offline";

    final tubeWellStatusText = !hasDevice
        ? "TubeWell --"
        : motorRunning
        ? "TubeWell ON"
        : "TubeWell OFF";

    final triggerText = _formatTriggerType(triggerType);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.white.withOpacity(0.14)),
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
                // -------------------------------------------------
                // ROW 1:
                // Device ID | Device Online / Offline
                // -------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasDevice
                            ? (deviceId ?? "Unknown device")
                            : "No controller selected",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      deviceStatusText,
                      maxLines: 1,
                      style: TextStyle(
                        color: deviceOnline
                            ? AppColors.green
                            : AppColors.warning,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // -------------------------------------------------
                // ROW 2:
                // TubeWell ON/OFF | Run Time
                // -------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tubeWellStatusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: motorRunning
                              ? AppColors.green
                              : AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppColors.white.withOpacity(0.55),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Run Time: ",
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.50),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          motorRunning ? runningTime : "00:00:00",
                          style: TextStyle(
                            color: motorRunning
                                ? AppColors.green
                                : AppColors.white.withOpacity(0.62),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // -------------------------------------------------
                // ROW 3:
                // Run By: Schedule / Physical / App / Timer
                // -------------------------------------------------
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: AppColors.white.withOpacity(0.60),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Run By: ",
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      motorRunning ? triggerText : "--",
                      style: TextStyle(
                        color: motorRunning
                            ? color
                            : AppColors.white.withOpacity(0.50),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
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
        color: AppColors.cardDark.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withOpacity(0.14)),
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
              "Select a device to enable motor control. Parameters stay empty until a controller is selected.",
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

// class DeviceOfflineNotice extends StatelessWidget {
//   final Future<void> Function() onRetry;
//
//   const DeviceOfflineNotice({
//     super.key,
//     required this.onRetry,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.warning.withOpacity(0.10),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.warning.withOpacity(0.24)),
//       ),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.info_outline_rounded,
//             color: AppColors.warning,
//             size: 22,
//           ),
//           const SizedBox(width: 10),
//           // Expanded(
//           //   child: Text(
//           //     "Device selected. Waiting for latest live reading.",
//           //     style: TextStyle(
//           //       color: AppColors.white.withOpacity(0.78),
//           //       fontSize: 12.8,
//           //       fontWeight: FontWeight.w700,
//           //     ),
//           //   ),
//           // ),
//           // TextButton(
//           //   onPressed: onRetry,
//           //   child: const Text(
//           //     "Retry",
//           //     style: TextStyle(
//           //       color: AppColors.warning,
//           //       fontWeight: FontWeight.w900,
//           //     ),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

class DeviceOnlineNotice extends StatelessWidget {
  final bool motorRunning;

  const DeviceOnlineNotice({
    super.key,
    required this.motorRunning,
  });

  @override
  Widget build(BuildContext context) {
    // final text = motorRunning
    //     ? "Live telemetry received. Motor is running."
    //     : "Live telemetry received. Motor is stopped.";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkBorderSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.green.withOpacity(0.24)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.green,
            size: 22,
          ),
          const SizedBox(width: 10),
          // Expanded(
          //   child: Text(
          //     text,
          //     style: TextStyle(
          //       color: AppColors.white.withOpacity(0.78),
          //       fontSize: 12.8,
          //       fontWeight: FontWeight.w700,
          //     ),
          //   ),
          // ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 17,
                color: AppColors.white.withOpacity(0.48),
              ),
              const SizedBox(width: 7),
              Text(
                "CUSTOMER / KHATA",
                style: TextStyle(
                  color: AppColors.white.withOpacity(1),
                  fontSize: 11,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          optionsBuilder: (TextEditingValue value) {
            if (!enabled) return const Iterable<String>.empty();

            final input = value.text.trim().toLowerCase();

            if (input.isEmpty) {
              return suggestions.take(8);
            }

            final startsWith = <String>[];
            final contains = <String>[];

            for (final name in suggestions) {
              final lower = name.toLowerCase();
              if (lower.startsWith(input)) {
                startsWith.add(name);
              } else if (lower.contains(input)) {
                contains.add(name);
              }
            }

            return [...startsWith, ...contains].take(8);
          },
          onSelected: (String value) {
            controller.text = value;
            controller.selection = TextSelection.collapsed(
              offset: controller.text.length,
            );
          },
          fieldViewBuilder: (
              context,
              textEditingController,
              fieldFocusNode,
              onFieldSubmitted,
              ) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: AppColors.cardDark.withOpacity(0.94),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: fieldFocusNode.hasFocus
                      ? AppColors.primary.withOpacity(0.70)
                      : AppColors.white.withOpacity(0.14),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                enabled: enabled,
                controller: textEditingController,
                focusNode: fieldFocusNode,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                autocorrect: false,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: enabled
                      ? "Enter new or previous customer"
                      : "Device must be online first",
                  hintStyle: TextStyle(
                    color: AppColors.white.withOpacity(1),
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    enabled
                        ? Icons.person_search_rounded
                        : Icons.lock_outline_rounded,
                    color: AppColors.white,
                  ),
                  suffixIcon: enabled && suggestions.isNotEmpty
                      ? Tooltip(
                    message: "Previous customers available",
                    child: Icon(
                      Icons.history_rounded,
                      color: AppColors.white.withOpacity(1),
                    ),
                  )
                      : null,
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
            final optionList = options.toList();

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width - 36,
                  constraints: const BoxConstraints(
                    maxHeight: 290,
                    maxWidth: 560,
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark.withOpacity(0.94),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.white.withOpacity(0.14)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Previous customers",
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.62),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 7),
                          shrinkWrap: true,
                          itemCount: optionList.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColors.white.withOpacity(0.06),
                          ),
                          itemBuilder: (context, index) {
                            final option = optionList[index];

                            return ListTile(
                              dense: true,
                              leading: Container(
                                height: 34,
                                width: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                option,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              trailing: Icon(
                                Icons.north_west_rounded,
                                size: 17,
                                color: AppColors.white.withOpacity(0.30),
                              ),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (enabled)
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 8),
            child: Text(
              suggestions.isEmpty
                  ? "New customer names will appear here next time."
                  : "Type to search, or select a previously used customer.",
              style: TextStyle(
                color: AppColors.white.withOpacity(1),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class MotorCommandButton extends StatelessWidget {
  final bool hasDevice;
  final bool deviceOnline;
  final bool isOn;
  final bool loading;
  final double size;

  const MotorCommandButton({
    super.key,
    required this.hasDevice,
    required this.deviceOnline,
    required this.isOn,
    required this.loading,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = !hasDevice
        ? AppColors.primary
        : !deviceOnline
        ? AppColors.warning
        : isOn
        ? AppColors.green
        : AppColors.error;

    final label = !hasDevice
        ? "SELECT"
        : !deviceOnline
        ? "WAIT"
        : isOn
        ? "ON"
        : "OFF";

    final icon = !hasDevice
        ? Icons.devices_other_rounded
        : !deviceOnline
        ? Icons.wifi_tethering_error_rounded
        : isOn
        ? Icons.power_settings_new_rounded
        : Icons.power_off_rounded;

    final textColor = !hasDevice ? AppColors.black : AppColors.white;

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
            color: textColor,
            size: size < 190 ? 36 : 42,
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: label == "SELECT"
                    ? 24
                    : label == "WAIT"
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

class MotorRunStatusCard extends StatelessWidget {
  final bool hasDevice;
  final bool deviceOnline;
  final bool isOn;
  final bool waitingForVfd;
  final String runningTime;
  final String serverStartTime;
  final String serverEndTime;
  final bool hasServerStartTime;
  final bool hasServerEndTime;
  final bool vfdSessionInterrupted;
  final bool vfdRestartedAfterInterruption;

  const MotorRunStatusCard({
    super.key,
    required this.hasDevice,
    required this.deviceOnline,
    required this.isOn,
    required this.waitingForVfd,
    required this.runningTime,
    required this.serverStartTime,
    required this.serverEndTime,
    required this.hasServerStartTime,
    required this.hasServerEndTime,
    required this.vfdSessionInterrupted,
    required this.vfdRestartedAfterInterruption,
  });

  @override
  Widget build(BuildContext context) {
    final active = hasDevice && deviceOnline && isOn;

    final title = !hasDevice
        ? "NO DEVICE"
        : !deviceOnline
        ? "WAITING FOR DEVICE"
        : waitingForVfd
        ? "SYNCING WITH VFD"
        : vfdRestartedAfterInterruption
        ? "VFD RESTARTED"
        : vfdSessionInterrupted
        ? "VFD SESSION INTERRUPTED"
        : active
        ? "MOTOR RUN TIME"
        : "MOTOR STOPPED";

    final subtitle = !hasDevice
        ? "Select a controller to start monitoring"
        : !deviceOnline
        ? "Waiting for fresh live telemetry"
        : waitingForVfd
        ? "Waiting for the VFD to confirm the command"
        : vfdRestartedAfterInterruption
        ? "Motor is physically ON, but old runtime stays frozen. OFF then ON to start a clean new server session."
        : vfdSessionInterrupted
        ? "VFD stopped outside the normal app OFF flow. Runtime is frozen and will not restart automatically."
        : active
        ? "Elapsed time from the original server/database start time"
        : "Timer starts only after VFD confirms ON";

    final accent = active ? AppColors.green : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.cardDark.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? AppColors.green.withOpacity(0.28)
              : AppColors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: waitingForVfd
                ? SizedBox(
              height: 21,
              width: 21,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: accent,
              ),
            )
                : Icon(
              active ? Icons.timer_rounded : Icons.timer_off_outlined,
              color: accent,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.54),
                    fontSize: 10.5,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.60),
                    fontSize: 11.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasServerStartTime) ...[
                  const SizedBox(height: 6),
                  Text(
                    "ON: $serverStartTime",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.green.withOpacity(0.88),
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (hasServerStartTime) ...[
                  const SizedBox(height: 3),
                  Text(
                    hasServerEndTime
                        ? "OFF: $serverEndTime"
                        : "OFF: Running",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasServerEndTime
                          ? AppColors.error.withOpacity(0.88)
                          : AppColors.white.withOpacity(0.52),
                      fontSize: 10.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            active ||
                hasServerEndTime ||
                vfdSessionInterrupted ||
                vfdRestartedAfterInterruption
                ? runningTime
                : "00:00:00",
            style: TextStyle(
              color: active && !vfdRestartedAfterInterruption
                  ? AppColors.green
                  : vfdSessionInterrupted ||
                  vfdRestartedAfterInterruption
                  ? AppColors.warning
                  : hasServerEndTime
                  ? AppColors.primary
                  : AppColors.white.withOpacity(0.42),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
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
        color: AppColors.cardDark.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: metric.highlight
              ? AppColors.primary
              : AppColors.white,
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
            color: metric.highlight
                ? AppColors.primary
                : AppColors.white.withOpacity(0.45),
            size: compact ? 24 : 28,
          ),
          const Spacer(),
          Text(
            metric.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white,
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

