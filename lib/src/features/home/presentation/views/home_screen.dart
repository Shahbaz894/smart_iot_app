import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
import "package:smart_iot_app/src/features/widget/home_dashboard_content.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
import "package:smart_iot_app/src/features/widget/smart_well_home_app_bar.dart";

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
  late final AnimationController pulseController;
  late final Animation<double> pulseAnimation;

  final TextEditingController customerNameController = TextEditingController();
  final FocusNode customerNameFocusNode = FocusNode();

  Timer? runTimer;
  Timer? telemetryTimer;
  Timer? motorSyncTimer;

  int runSeconds = 0;
  int telemetryFailures = 0;

  String? userId;
  String? deviceId;
  String? deviceName;

  bool didSetupDevice = false;
  bool isTelemetryLoading = false;
  bool isMotorSyncing = false;
  bool noDeviceSnackShown = false;

  bool? _syncedMotorOn;
  DateTime? _ignoreRemoteMotorSyncUntil;

  bool get hasDevice => deviceId != null && deviceId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(
      begin: 0.82,
      end: 1.12,
    ).animate(
      CurvedAnimation(
        parent: pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _loadSavedMotorState();
  }

  Future<void> _loadSavedMotorState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString("saved_motor_customer_name");
      final wasRunning = prefs.getBool("is_motor_currently_running") ?? false;
      final startTimeMillis = prefs.getInt("motor_start_time_epoch");

      if (mounted) {
        setState(() {
          if (savedName != null && savedName.isNotEmpty) {
            customerNameController.text = savedName;
          }

          if (wasRunning) {
            _syncedMotorOn = true;

            if (startTimeMillis != null) {
              final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
              final difference = DateTime.now().difference(startTime).inSeconds;
              runSeconds = difference > 0 ? difference : 0;
              _startLocalTimer();
            }
          }
        });
        ref.read(khataViewModelProvider.notifier).loadEntries();
      }
    } catch (e) {
      debugPrint("🔴 Error restoring system states: $e");
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
      final rawDeviceId = args["deviceId"]?.toString();
      deviceId = rawDeviceId == null || rawDeviceId.trim().isEmpty ? null : rawDeviceId.trim();
      final rawDeviceName = args["deviceName"]?.toString();
      deviceName = rawDeviceName == null || rawDeviceName.trim().isEmpty ? null : rawDeviceName.trim();
    }

    final widgetDeviceId = widget.deviceId?.trim();
    deviceId ??= widgetDeviceId == null || widgetDeviceId.isEmpty ? null : widgetDeviceId;

    if (hasDevice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(motorViewModelProvider.notifier).listenToLiveHardwareSync(deviceId!);
      });

      Future.microtask(() async {
        await ref.read(motorViewModelProvider.notifier).loadInitialMotorState(deviceId: deviceId!);
        await syncMotorStatus();
        await loadTelemetry(showError: false, showLoading: false);
        await ref.read(khataViewModelProvider.notifier).loadEntries();
      });

      motorSyncTimer?.cancel();
      motorSyncTimer = Timer.periodic(const Duration(seconds: 3), (_) => syncMotorStatus());

      telemetryTimer?.cancel();
      telemetryTimer = Timer.periodic(const Duration(seconds: 5), (_) => loadTelemetry(showError: false, showLoading: false));
    } else {
      Future.microtask(() {
        if (!mounted || noDeviceSnackShown) return;
        noDeviceSnackShown = true;
        showMessage("Device not connected. Opened dashboard safely.", false);
      });
    }
  }

  @override
  void dispose() {
    pulseController.dispose();
    customerNameController.dispose();
    customerNameFocusNode.dispose();
    runTimer?.cancel();
    telemetryTimer?.cancel();
    motorSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> syncMotorStatus() async {
    if (!hasDevice || isMotorSyncing) return;

    final now = DateTime.now();
    if (_ignoreRemoteMotorSyncUntil != null && now.isBefore(_ignoreRemoteMotorSyncUntil!)) {
      return;
    }

    isMotorSyncing = true;
    try {
      final motorState = ref.read(motorViewModelProvider);
      bool? newMotorOn = motorState.isMotorOn ? true : (motorState.isMotorOff ? false : null);

      if (!mounted) return;

      if (_syncedMotorOn != newMotorOn && newMotorOn != null) {
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          _syncedMotorOn = newMotorOn;
        });

        if (newMotorOn == false) {
          await prefs.setBool("is_motor_currently_running", false);
          await prefs.remove("saved_motor_customer_name");
          await prefs.remove("motor_start_time_epoch");
          customerNameController.clear();
          _stopLocalTimer(reset: true);
        }
      }
    } catch (e) {
      debugPrint("🔴 MOTOR SYNC FAILED => $e");
    } finally {
      isMotorSyncing = false;
    }
  }

  DeviceConnectionStatus connectionStatus(dynamic latest) {
    if (!hasDevice) return DeviceConnectionStatus.noDevice;
    if (latest != null && telemetryFailures < 3) return DeviceConnectionStatus.connected;
    if (telemetryFailures >= 3) return DeviceConnectionStatus.disconnected;
    return DeviceConnectionStatus.waitingTelemetry;
  }

  dynamic _readValue(dynamic source, {required List<dynamic Function()> objectReaders, required List<String> mapKeys}) {
    if (source == null) return null;
    if (source is Map) {
      for (final key in mapKeys) {
        if (source.containsKey(key)) return source[key];
      }
    }
    for (final reader in objectReaders) {
      try { final value = reader(); if (value != null) return value; } catch (_) {}
    }
    return null;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  bool isFreshTelemetry(dynamic latest) {
    if (latest == null) return false;
    final rawCreatedAt = _readValue(latest, objectReaders: [() => latest?.createdAt, () => latest?.created_at], mapKeys: const ["createdAt", "created_at"]);
    if (rawCreatedAt == null) return false;
    final createdAt = DateTime.tryParse(rawCreatedAt.toString());
    if (createdAt == null) return false;
    return DateTime.now().toUtc().difference(createdAt.toUtc()).inSeconds.abs() <= 25;
  }

  bool telemetrySaysRunning(dynamic latest) {
    if (latest == null || !isFreshTelemetry(latest)) return false;
    final int? statusCode = _toInt(_readValue(latest, objectReaders: [() => latest?.statusCode, () => latest?.status_code], mapKeys: const ["statusCode", "status_code"]));
    if (statusCode == 0 || statusCode == 4) return false;
    if (statusCode == 1 || statusCode == 2 || statusCode == 3) return true;
    final double current = _toDouble(_readValue(latest, objectReaders: [() => latest?.current], mapKeys: const ["current"])) ?? 0.0;
    final double freq = _toDouble(_readValue(latest, objectReaders: [() => latest?.freq], mapKeys: const ["freq"])) ?? 0.0;
    return current > 0.1 || freq > 0;
  }

  String friendlyError(String? error) {
    final text = (error ?? "").toLowerCase();
    if (text.contains("socket") || text.contains("connection") || text.contains("network") || text.contains("timeout")) {
      return "No internet connection. Please check Wi-Fi or mobile data.";
    }
    return text.trim().isEmpty ? "Unable to connect. Please try again." : error!;
  }

  Future<void> loadTelemetry({bool showError = false, bool showLoading = false}) async {
    if (isTelemetryLoading || !hasDevice) return;
    isTelemetryLoading = true;
    try {
      await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!, showLoading: showLoading);
      if (!mounted) return;
      if (ref.read(telemetryViewModelProvider).latest != null) {
        telemetryFailures = 0;
      } else {
        telemetryFailures++;
      }
    } catch (e) {
      telemetryFailures++;
      if (showError) showMessage(friendlyError(e.toString()), true);
    } finally {
      isTelemetryLoading = false;
    }
  }

  void _startLocalTimer() {
    runTimer?.cancel();
    runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => runSeconds++);
    });
  }

  void _stopLocalTimer({bool reset = false}) {
    runTimer?.cancel();
    runTimer = null;
    if (reset && mounted) setState(() => runSeconds = 0);
  }

  String get runningTime {
    final seconds = runSeconds <= 0 ? 0 : runSeconds;
    final h = (seconds ~/ 3600).toString().padLeft(2, "0");
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, "0");
    final s = (seconds % 60).toString().padLeft(2, "0");
    return "$h:$m:$s";
  }

  String formatValue(double? value, String unit, {int decimals = 1, required DeviceConnectionStatus status}) {
    if (status == DeviceConnectionStatus.noDevice || value == null) return "-- $unit";
    return "${value.toStringAsFixed(decimals)} $unit";
  }

  Future<void> toggleMotor(MotorSnapshot snapshot) async {
    if (!hasDevice) {
      showMessage("Device not connected. Please select a device first.", true);
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    final typedCustomerName = customerNameController.text.trim();
    final customerName = typedCustomerName.isEmpty ? "Mobile App" : typedCustomerName;

    final motorVm = ref.read(motorViewModelProvider.notifier);
    final prefs = await SharedPreferences.getInstance();

    try {
      if (snapshot.isRunning) {
        final stoppedRunSeconds = runSeconds <= 0 ? 1 : runSeconds;
        _ignoreRemoteMotorSyncUntil = DateTime.now().add(const Duration(seconds: 3));

        if (mounted) {
          setState(() => _syncedMotorOn = false);
        }

        // 🛑 Send Stop Request
        final stoppedLog = await motorVm.stopMotor(
          deviceId: deviceId!,
          customerName: customerName,
        );

        // 📝 SAVE KHATA TRANSITION PIPELINE (Guaranteed Execution)
        try {
          if (stoppedLog != null) {
            await ref.read(khataViewModelProvider.notifier).createFromMotorLog(
              log: stoppedLog,
              customerName: customerName,
              deviceId: deviceId!,
              pricePerHour: 0,
              cashReceived: 0,
              fallbackRunSeconds: stoppedRunSeconds,
            );
          } else {
            await ref.read(khataViewModelProvider.notifier).loadEntries();
          }
        } catch (khataError) {
          debugPrint("⚠️ Khata fast-logging processing failed: $khataError");
        }

        // Wipe persistent operational fields
        await prefs.setBool("is_motor_currently_running", false);
        await prefs.remove("saved_motor_customer_name");
        await prefs.remove("motor_start_time_epoch");

        _stopLocalTimer(reset: true);

        if (mounted) {
          customerNameController.clear();
        }

        await loadTelemetry(showError: false, showLoading: false);
        await ref.read(khataViewModelProvider.notifier).loadEntries();

        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          _ignoreRemoteMotorSyncUntil = null;
          syncMotorStatus();
        });

        showMessage("Motor stopped. Khata entry created.", false);
        return;
      }

      // Start validation checks
      if (typedCustomerName.isEmpty) {
        showMessage("Customer name is required to start motor.", true);
        return;
      }

      // 🚨 SAVE TO SHREAD_PREFERENCES FOR APP KILL RECOVERY
      await prefs.setBool("is_motor_currently_running", true);
      await prefs.setString("saved_motor_customer_name", typedCustomerName);
      await prefs.setInt("motor_start_time_epoch", DateTime.now().millisecondsSinceEpoch);

      _ignoreRemoteMotorSyncUntil = DateTime.now().add(const Duration(seconds: 3));

      if (mounted) {
        setState(() {
          _syncedMotorOn = true;
          runSeconds = 0;
        });
      }

      await motorVm.startMotor(
        deviceId: deviceId!,
        customerName: typedCustomerName,
      );

      _startLocalTimer();
      await loadTelemetry(showError: false, showLoading: false);
      await ref.read(khataViewModelProvider.notifier).loadEntries();

      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _ignoreRemoteMotorSyncUntil = null;
        syncMotorStatus();
      });

      showMessage("Motor started successfully", false);
    } catch (e) {
      _ignoreRemoteMotorSyncUntil = null;
      showMessage("Motor action failed: ${friendlyError(e.toString())}", true);
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: isError ? AppColors.error : AppColors.green,
          content: Text(
            isError ? friendlyError(text) : text,
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800),
          ),
        ),
      );
  }
  /// 🎯 Live Running Status Panel Widget
  /// Aap isko `HomeScreen` ke andar jahan dil chahe call kar sakte hain: `_buildActiveMotorCard(snapshot)`
  Widget _buildActiveMotorCard(MotorSnapshot snapshot) {
    if (!snapshot.isRunning) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Premium Dark Slate Tint
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.green.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Zone: Customer Name Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: Colors.white70, size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Customer Name",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  _activeRunningName.isEmpty ? "Mobile App" : _activeRunningName,
                  style: const TextStyle(color: AppColors.green, fontSize: 18, fontWeight: FontWeight.black),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(color: Colors.white10, height: 1, thickness: 1.5),
            ),
            // Bottom Zone: Live Running Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.white70, size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Running Time",
                      style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  runningTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.black,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
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
    return names.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final motorState = ref.watch(motorViewModelProvider);
    final telemetryState = ref.watch(telemetryViewModelProvider);

    final dynamic latest = hasDevice ? telemetryState.latest : null;
    final status = connectionStatus(latest);

    bool finalUiRunningState = false;
    if (_syncedMotorOn != null) {
      finalUiRunningState = _syncedMotorOn!;
    } else if (motorState.commandStatus == MotorCommandStatus.on) {
      finalUiRunningState = true;
    } else if (motorState.commandStatus == MotorCommandStatus.off) {
      finalUiRunningState = false;
    } else if (status != DeviceConnectionStatus.connected) {
      finalUiRunningState = telemetrySaysRunning(latest);
    }

    final snapshot = MotorSnapshot.fromAppState(
      isRunning: hasDevice && finalUiRunningState,
      syncedRunning: hasDevice && finalUiRunningState,
      latest: latest,
      status: status,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (snapshot.isRunning && runTimer == null) _startLocalTimer();
      if (!snapshot.isRunning && runTimer != null) _stopLocalTimer(reset: false);
    });

    final width = MediaQuery.of(context).size.width;
    final isVerySmall = width < 360;
    final isTablet = width >= 650;
    final isLarge = width >= 1000;

    final horizontalPadding = isLarge ? 38.0 : isTablet ? 30.0 : 16.0;
    final crossAxisCount = isLarge ? 4 : isTablet ? 3 : 2;
    final childAspectRatio = isLarge ? 1.36 : isTablet ? 1.22 : 1.02;
    final buttonSize = isLarge ? 238.0 : isTablet ? 226.0 : isVerySmall ? 176.0 : 196.0;

    final resolvedDisplayName = deviceName != null && deviceName!.isNotEmpty
        ? deviceName!
        : (hasDevice ? deviceId! : "Device Not Connected");

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      drawer: hasDevice ? ProfessionalDrawer(deviceId: deviceId!) : null,
      appBar: SmartWellHomeAppBar(
        hasDevice: hasDevice,
        displayName: resolvedDisplayName,
        deviceId: deviceId,
        onSelectDevice: () {
          Navigator.pushReplacementNamed(context, AppRoutes.devices);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🛠️ CONTROL ENGINE: HomeDashboardContent runs safely now
                HomeDashboardContent(
                  hasDevice: hasDevice,
                  deviceId: deviceId,
                  displayName: resolvedDisplayName,
                  latest: latest,
                  telemetryState: telemetryState,
                  motorState: motorState,
                  snapshot: snapshot,
                  status: status,
                  pulseAnimation: pulseAnimation,
                  // 🎯 DYNAMIC HIDDEN FORM CRITERIA: Passing dummy/empty parameters to hide input field inside layout when running
                  customerNameController: snapshot.isRunning ? TextEditingController() : customerNameController,
                  customerNameFocusNode: customerNameFocusNode,
                  customerSuggestions: customerSuggestions(),
                  runningTime: runningTime,
                  horizontalPadding: horizontalPadding,
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  buttonSize: buttonSize,
                  isVerySmall: isVerySmall,
                  onRefresh: () async {
                    if (hasDevice) {
                      await syncMotorStatus();
                      await loadTelemetry(showError: true, showLoading: false);
                    } else {
                      showMessage("Device not connected. Please select a device.", true);
                    }
                  },
                  onMotorTap: () => toggleMotor(snapshot),
                  formatValue: formatValue,
                ),
                _buildActiveMotorCard(),

                // 🎯 ME
              ],
            ),
          ),
        ),
      ),
    );
  }
}