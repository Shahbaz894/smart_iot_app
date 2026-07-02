
//
// class HomeScreen extends ConsumerStatefulWidget {
//   final String? deviceId;
//   const HomeScreen({super.key, this.deviceId});
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   final TextEditingController customerNameController = TextEditingController();
//   final FocusNode customerNameFocusNode = FocusNode();
//
//   String? deviceId;
//   String? deviceName;
//
//   bool _isProcessingCommand = false;
//   bool? _optimisticRunning; // ⚡ Iske bagair UI 'Stopping' dikhata hai
//
//   String? _lastSeenPacketId;
//   DateTime? _lastPacketReceivedAt;
//   bool _isWaitingForSync = true;
//   Timer? _watchdogTimer;
//   Timer? _uiRefreshTimer;
//
//   static const _staleThreshold = Duration(seconds: 25);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCache();
//     _initDevice();
//     _startWatchdog();
//   }
//
//   @override
//   void dispose() {
//     _watchdogTimer?.cancel();
//     _uiRefreshTimer?.cancel();
//     customerNameController.dispose();
//     customerNameFocusNode.dispose();
//
//     Future.microtask(() {
//       if (mounted) {
//         ref.read(telemetryViewModelProvider.notifier).closeStream();
//       }
//     });
//     super.dispose();
//   }
//
//   Future<void> _loadCache() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (mounted) {
//       setState(() {
//         customerNameController.text = prefs.getString("saved_motor_customer_name") ?? "";
//       });
//     }
//   }
//
//   Future<void> _initDevice() async {
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final args = ModalRoute.of(context)?.settings.arguments;
//       if (args is Map) {
//         deviceId = args["deviceId"]?.toString().trim();
//         deviceName = args["deviceName"]?.toString().trim();
//       }
//
//       if (deviceId == null || deviceId!.isEmpty) deviceId = widget.deviceId?.trim();
//       if (deviceId == null || deviceId!.isEmpty) {
//         deviceId = "ESP32_001_TW";
//         deviceName = "SmartWell Pump 1";
//       }
//
//       // if (deviceId != null && deviceId!.isNotEmpty) {
//       //   await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);
//       //   await ref.read(motorViewModelProvider.notifier).loadInitialMotorState(deviceId: deviceId!);
//       //   ref.read(telemetryViewModelProvider.notifier).startLiveStream(deviceId!);
//       //   _startLiveTicker();
//       // }
//
//       if (mounted) setState(() {});
//     });
//   }
//
//   void _startLiveTicker() {
//     _uiRefreshTimer?.cancel();
//     _uiRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (mounted) setState(() {});
//     });
//   }
//
//   void _startWatchdog() {
//     _watchdogTimer = Timer.periodic(const Duration(seconds: 5), (_) {
//       if (mounted) setState(() {});
//     });
//
//     Future.delayed(const Duration(seconds: 15), () {
//       if (mounted && _isWaitingForSync) setState(() => _isWaitingForSync = false);
//     });
//   }
//
//   DeviceConnectionStatus _computeStatus(dynamic latest) {
//     if (deviceId == null || deviceId!.isEmpty) return DeviceConnectionStatus.noDevice;
//     if (_isProcessingCommand) return DeviceConnectionStatus.connected;
//     if (latest == null) return DeviceConnectionStatus.waitingTelemetry;
//
//     // ⚡ FIX: Direct property call, no maps, no void errors!
//     if (latest.isLive == 1) return DeviceConnectionStatus.connected;
//
//     if (_lastPacketReceivedAt == null) return DeviceConnectionStatus.waitingTelemetry;
//
//     final age = DateTime.now().difference(_lastPacketReceivedAt!);
//     return age > _staleThreshold ? DeviceConnectionStatus.disconnected : DeviceConnectionStatus.connected;
//   }
//
//   Future<void> _toggleMotor(bool currentlyRunning) async {
//     customerNameFocusNode.unfocus();
//     FocusScope.of(context).unfocus();
//
//     if (_isProcessingCommand || deviceId == null) return;
//
//     final name = customerNameController.text.trim();
//
//     if (!currentlyRunning && name.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a customer name")));
//       }
//       return;
//     }
//
//     // ⚡ Yahan pe optimistic logic set kar rahe hain taake UI "Starting..." show kare
//     setState(() {
//       _isProcessingCommand = true;
//       _optimisticRunning = !currentlyRunning;
//     });
//
//     try {
//       final motorVm = ref.read(motorViewModelProvider.notifier);
//       final khataVm = ref.read(khataViewModelProvider.notifier);
//       final prefs = await SharedPreferences.getInstance();
//
//       if (currentlyRunning) {
//         final log = await motorVm.stopMotor(deviceId: deviceId!, customerName: name);
//         if (log != null) {
//           await khataVm.createFromMotorLog(log: log, customerName: name, deviceId: deviceId!, pricePerHour: 50.0);
//           await khataVm.loadEntries();
//         }
//         await prefs.remove("saved_motor_customer_name");
//       } else {
//         await prefs.setString("saved_motor_customer_name", name);
//         await motorVm.startMotor(deviceId: deviceId!, customerName: name);
//       }
//
//       await Future.delayed(const Duration(seconds: 4));
//       await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);
//
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessingCommand = false;
//           _optimisticRunning = null;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final telemetry = ref.watch(telemetryViewModelProvider);
//     final latest = telemetry.latest;
//
//     if (latest != null) {
//       final incomingId = latest.id?.toString() ?? latest.createdAt.toString();
//       if (incomingId != _lastSeenPacketId) {
//         _lastSeenPacketId = incomingId;
//         _lastPacketReceivedAt = DateTime.now();
//         if (_isWaitingForSync) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) setState(() => _isWaitingForSync = false);
//           });
//         }
//       }
//     }
//
//     // ⚡ FIX: Sab se aasan aur error-free tareeqa (No "void" errors here!)
//     bool isActuallyRunning = latest != null && latest.statusCode == 1;
//
//     // Agar hum button daba rahe hain, toh optimistic UI dikhao, warna real hardware state dikhao
//     bool isRunning = (_isProcessingCommand && _optimisticRunning != null)
//         ? _optimisticRunning!
//         : isActuallyRunning;
//
//     String displayRunningTime = "00:00:00";
//     if (isRunning && latest?.createdAt != null) {
//       try {
//         final serverStartTime = DateTime.parse(latest!.createdAt.toString());
//         final durationDifference = DateTime.now().difference(serverStartTime);
//         if (durationDifference.inSeconds > 0) {
//           displayRunningTime =
//           "${durationDifference.inHours.toString().padLeft(2, '0')}:"
//               "${(durationDifference.inMinutes % 60).toString().padLeft(2, '0')}:"
//               "${(durationDifference.inSeconds % 60).toString().padLeft(2, '0')}";
//         }
//       } catch (e) {
//         displayRunningTime = "Running";
//       }
//     }
//
//
//     // ⚡ NEW: Status Label Logic (Trigger Type based)
//     String statusLabel = "Stopped";
//     if (isRunning) {
//       switch (latest?.triggerType?.toLowerCase()) {
//         case 'physical':
//           statusLabel = "Running (Manual)";
//           break;
//         case 'app':
//           statusLabel = "Running (App)";
//           break;
//         case 'timer':
//           statusLabel = "Running (Timer)";
//           break;
//         default:
//           statusLabel = "Running";
//       }
//     }
//
//     final DeviceConnectionStatus status = _computeStatus(latest);
//
//     // final snapshot = MotorSnapshot.fromAppState(
//     //   isRunning: isRunning,
//     //   isSyncing: _isProcessingCommand,
//     //   latest: latest,
//     //   status: status,
//     //
//     // );
//     final snapshot = MotorSnapshot.fromAppState(
//       isRunning: isRunning,
//       isSyncing: _isProcessingCommand,
//       latest: latest,
//       status: status,
//       // ⚡ Yahan pass karein
//     );
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       appBar: SmartWellHomeAppBar(
//         hasDevice: deviceId != null && deviceId!.isNotEmpty,
//         displayName: deviceName ?? "SmartWell Pump",
//         deviceId: deviceId,
//         onSelectDevice: () {
//           Navigator.pushReplacementNamed(context, AppRoutes.devices);
//         },
//       ),
//       drawer: ProfessionalDrawer(deviceId: deviceId ?? "ESP32_001_TW"),
//       body: HomeDashboardContent(
//         isSyncing: _isProcessingCommand,
//         onMotorTap: () => _toggleMotor(isActuallyRunning), // Back-end ko sach batao
//         hasDevice: deviceId != null && deviceId!.isNotEmpty,
//         deviceId: deviceId,
//         displayName: deviceName ?? "SmartWell Pump",
//         latest: latest,
//         telemetryState: telemetry,
//         motorState: ref.watch(motorViewModelProvider),
//         snapshot: snapshot,
//         status: status,
//         pulseAnimation: const AlwaysStoppedAnimation(1.0),
//         customerNameController: customerNameController,
//         customerNameFocusNode: customerNameFocusNode,
//         customerSuggestions: const [],
//         runningTime: displayRunningTime,
//         horizontalPadding: 16,
//         crossAxisCount: 2,
//         childAspectRatio: 1.0,
//         buttonSize: 180,
//         isVerySmall: false,
//         onRefresh: () async {
//           if (deviceId != null && deviceId!.isNotEmpty) {
//             await ref.read(telemetryViewModelProvider.notifier).loadLatest(deviceId!);
//             if (mounted) {
//               setState(() {
//                 _lastPacketReceivedAt = DateTime.now();
//               });
//             }
//           }
//         },
//         formatValue: (val, unit, {decimals = 1, required status}) {
//           return "${val?.toStringAsFixed(decimals) ?? '--'} $unit";
//         },
//       ),
//     );
//   }
// }
import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/khata/data/models/khata_entry_model.dart";
import "package:smart_iot_app/src/features/motor/data/models/motor_log_response.dart";
import "package:smart_iot_app/src/features/widget/custom_drawer.dart";
import "package:smart_iot_app/src/features/widget/home_dashboard_content.dart";
import "package:smart_iot_app/src/features/widget/motor_snapshot.dart";
import "package:smart_iot_app/src/features/widget/smart_well_home_app_bar.dart";

import "../../../../app/routes.dart";
import "../../../khata/presentation/providers/ khata_providers.dart";
import "../../../logs/data/presentation/providers/motor_log_providers.dart";
import "../../../motor/presentation/ providers/motor_providers.dart";
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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController customerNameController = TextEditingController();
  final FocusNode customerNameFocusNode = FocusNode();

  String? deviceId;
  String? deviceName;

  bool _isProcessingCommand = false;
  bool? _optimisticRunning;

  String? _lastSeenPacketId;
  DateTime? _lastPacketReceivedAt;
  bool _isWaitingForSync = true;

  Timer? _watchdogTimer;
  Timer? _uiRefreshTimer;

  String? _activeMotorLogId;
  KhataEntryModel? _activeKhataEntry;
  bool _khataLogBusy = false;

  static const Duration _staleThreshold = Duration(seconds: 25);
  static const double _defaultPricePerHour = 50.0;

  @override
  void initState() {
    super.initState();

    _loadCache();
    _initDevice();
    _startWatchdog();
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    _uiRefreshTimer?.cancel();

    customerNameController.dispose();
    customerNameFocusNode.dispose();

    ref.read(telemetryViewModelProvider.notifier).closeStream();

    super.dispose();
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      customerNameController.text =
          prefs.getString("saved_motor_customer_name") ?? "";
    });
  }

  Future<void> _initDevice() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is Map) {
        deviceId = args["deviceId"]?.toString().trim();
        deviceName = args["deviceName"]?.toString().trim();
      }

      if (deviceId == null || deviceId!.isEmpty) {
        deviceId = widget.deviceId?.trim();
      }

      if (deviceId == null || deviceId!.isEmpty) {
        deviceId = "ESP32_001_TW";
        deviceName = "SmartWell Pump 1";
      }

      if (deviceId != null && deviceId!.isNotEmpty) {
        debugPrint("🚀 INIT DEVICE => ID: $deviceId, NAME: $deviceName");

        await ref
            .read(telemetryViewModelProvider.notifier)
            .loadLatest(deviceId!);

        await ref
            .read(motorViewModelProvider.notifier)
            .loadInitialMotorState(deviceId: deviceId!);

        await ref
            .read(motorLogViewModelProvider.notifier)
            .loadLogs(deviceId!);

        await ref.read(khataViewModelProvider.notifier).loadEntries();

        await _restoreRunningKhataSessionIfNeeded();

        ref.read(telemetryViewModelProvider.notifier).startLiveStream(deviceId!);

        _startLiveTicker();
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  void _startLiveTicker() {
    _uiRefreshTimer?.cancel();

    _uiRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _startWatchdog() {
    _watchdogTimer?.cancel();

    _watchdogTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {});
      }
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isWaitingForSync) {
        setState(() {
          _isWaitingForSync = false;
        });
      }
    });
  }

  DeviceConnectionStatus _computeStatus(dynamic latest) {
    if (deviceId == null || deviceId!.isEmpty) {
      return DeviceConnectionStatus.noDevice;
    }

    if (_isProcessingCommand) {
      return DeviceConnectionStatus.connected;
    }

    if (latest == null) {
      return _isWaitingForSync
          ? DeviceConnectionStatus.waitingTelemetry
          : DeviceConnectionStatus.disconnected;
    }

    if (_lastPacketReceivedAt == null) {
      return DeviceConnectionStatus.waitingTelemetry;
    }

    final age = DateTime.now().difference(_lastPacketReceivedAt!);

    return age > _staleThreshold
        ? DeviceConnectionStatus.disconnected
        : DeviceConnectionStatus.connected;
  }

  Future<void> _restoreRunningKhataSessionIfNeeded() async {
    if (deviceId == null || deviceId!.trim().isEmpty) return;

    final latestNow = ref.read(telemetryViewModelProvider).latest;

    final bool motorRunning = latestNow != null && latestNow.statusCode == 1;

    if (!motorRunning) return;

    final customerName = customerNameController.text.trim().isEmpty
        ? "Unknown Customer"
        : customerNameController.text.trim();

    await _startKhataForLatestOpenLogIfNeeded(
      customerName: customerName,
      deviceId: deviceId!,
    );
  }

  Future<bool> _waitForTelemetryMotorState({
    required bool expectedRunning,
  }) async {
    if (deviceId == null || deviceId!.trim().isEmpty) return false;

    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 700));

      await ref
          .read(telemetryViewModelProvider.notifier)
          .loadLatest(deviceId!);

      final latestNow = ref.read(telemetryViewModelProvider).latest;

      final bool runningNow = latestNow != null && latestNow.statusCode == 1;

      if (runningNow == expectedRunning) {
        return true;
      }
    }

    return false;
  }

  Future<void> _startKhataForLatestOpenLogIfNeeded({
    required String customerName,
    required String deviceId,
  }) async {
    if (_khataLogBusy) return;

    _khataLogBusy = true;

    try {
      MotorLogResponse? openLog;

      for (int i = 0; i < 6; i++) {
        await ref
            .read(motorLogViewModelProvider.notifier)
            .loadLogs(deviceId);

        openLog = _latestOpenMotorLog();

        if (openLog != null) break;

        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (openLog == null) {
        debugPrint("KHATA LOG: No open motor log found.");
        return;
      }

      final logId = openLog.id;

      if (logId == null || logId.trim().isEmpty) {
        debugPrint("KHATA LOG: Open motor log ID missing.");
        return;
      }

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      final existingEntry = _findKhataEntryByMotorLogId(logId);

      if (existingEntry != null) {
        _activeMotorLogId = logId;
        _activeKhataEntry = existingEntry;

        debugPrint("KHATA LOG: Existing Khata session attached.");
        return;
      }

      if (_activeMotorLogId == logId && _activeKhataEntry != null) {
        return;
      }

      final createdEntry =
      await ref.read(khataViewModelProvider.notifier).startMotorKhataSession(
        customerName: customerName,
        deviceId: deviceId,
        motorLogId: logId,
        startTime: openLog.startTime ?? DateTime.now(),
      );

      _activeMotorLogId = logId;
      _activeKhataEntry = createdEntry;

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      debugPrint("KHATA LOG: Khata session started for motor log $logId");
    } catch (e) {
      debugPrint("KHATA LOG START ERROR: $e");
    } finally {
      _khataLogBusy = false;
    }
  }

  Future<void> _closeKhataForStoppedLog({
    required MotorLogResponse? stoppedLog,
    required String customerName,
    required String deviceId,
  }) async {
    if (_khataLogBusy) return;

    _khataLogBusy = true;

    try {
      await ref
          .read(motorLogViewModelProvider.notifier)
          .loadLogs(deviceId);

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      final logId = stoppedLog?.id ?? _activeMotorLogId;

      KhataEntryModel? entryToClose = _activeKhataEntry;

      if (entryToClose == null && logId != null && logId.trim().isNotEmpty) {
        entryToClose = _findKhataEntryByMotorLogId(logId);
      }

      if (entryToClose != null) {
        final closedEntry =
        await ref.read(khataViewModelProvider.notifier).closeMotorKhataSession(
          entry: entryToClose,
          endTime: stoppedLog?.endTime ?? DateTime.now(),
        );

        if (closedEntry != null && closedEntry.runHours > 0) {
          await ref.read(khataViewModelProvider.notifier).updatePriceAndBill(
            entry: closedEntry,
            pricePerHour: _defaultPricePerHour,
            cashReceived: closedEntry.cashReceived,
          );
        }

        debugPrint("KHATA LOG: Khata session closed.");
      } else if (stoppedLog != null) {
        await ref.read(khataViewModelProvider.notifier).createFromMotorLog(
          log: stoppedLog,
          customerName: customerName,
          deviceId: deviceId,
          pricePerHour: _defaultPricePerHour,
          cashReceived: 0,
        );

        debugPrint("KHATA LOG: Khata created from stopped motor log.");
      } else {
        debugPrint("KHATA LOG: No stopped log or active Khata entry found.");
      }

      await ref
          .read(motorLogViewModelProvider.notifier)
          .loadLogs(deviceId);

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      _activeMotorLogId = null;
      _activeKhataEntry = null;
    } catch (e) {
      debugPrint("KHATA LOG CLOSE ERROR: $e");
    } finally {
      _khataLogBusy = false;
    }
  }

  MotorLogResponse? _latestOpenMotorLog() {
    final logs = ref.read(motorLogViewModelProvider).logs;

    final openLogs = logs.where((log) {
      return log.endTime == null && (log.id ?? "").trim().isNotEmpty;
    }).toList();

    if (openLogs.isEmpty) return null;

    openLogs.sort((a, b) {
      final aTime = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bTime.compareTo(aTime);
    });

    return openLogs.first;
  }

  KhataEntryModel? _findKhataEntryByMotorLogId(String motorLogId) {
    final entries = ref.read(khataViewModelProvider).entries;

    for (final entry in entries) {
      final entryMotorLogId = _readKhataMotorLogId(entry);

      if (entryMotorLogId == motorLogId) {
        return entry;
      }
    }

    return null;
  }

  String? _readKhataMotorLogId(KhataEntryModel entry) {
    try {
      final dynamic item = entry;
      final value = item.motorLogId;

      if (value == null) return null;

      final text = value.toString().trim();

      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  Future<void> _toggleMotor(bool currentlyRunning) async {
    customerNameFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    if (_isProcessingCommand || deviceId == null || deviceId!.trim().isEmpty) {
      return;
    }

    final customerName = customerNameController.text.trim();

    if (!currentlyRunning && customerName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a customer name"),
          ),
        );
      }

      return;
    }

    setState(() {
      _isProcessingCommand = true;
      _optimisticRunning = !currentlyRunning;
    });

    try {
      final motorVm = ref.read(motorViewModelProvider.notifier);
      final prefs = await SharedPreferences.getInstance();

      if (currentlyRunning) {
        debugPrint("🔴 EXECUTE STOP MOTOR SYSTEM");

        final MotorLogResponse? stoppedLog = await motorVm.stopMotor(
          deviceId: deviceId!,
          customerName: customerName,
        );

        await _waitForTelemetryMotorState(expectedRunning: false);

        await ref
            .read(telemetryViewModelProvider.notifier)
            .loadLatest(deviceId!);

        await ref
            .read(motorLogViewModelProvider.notifier)
            .loadLogs(deviceId!);

        await _closeKhataForStoppedLog(
          stoppedLog: stoppedLog,
          customerName: customerName,
          deviceId: deviceId!,
        );

        await prefs.remove("saved_motor_customer_name");

        debugPrint("✅ OFF DONE: Motor log closed and Khata saved.");
      } else {
        debugPrint("🟢 EXECUTE START MOTOR SYSTEM");

        await prefs.setString("saved_motor_customer_name", customerName);

        await motorVm.startMotor(
          deviceId: deviceId!,
          customerName: customerName,
        );

        await _waitForTelemetryMotorState(expectedRunning: true);

        await ref
            .read(telemetryViewModelProvider.notifier)
            .loadLatest(deviceId!);

        await ref
            .read(motorLogViewModelProvider.notifier)
            .loadLogs(deviceId!);

        await _startKhataForLatestOpenLogIfNeeded(
          customerName: customerName,
          deviceId: deviceId!,
        );

        debugPrint("✅ ON DONE: Motor log opened and Khata session started.");
      }

      await ref
          .read(motorLogViewModelProvider.notifier)
          .loadLogs(deviceId!);

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      await ref
          .read(telemetryViewModelProvider.notifier)
          .loadLatest(deviceId!);
    } catch (e) {
      debugPrint("MOTOR TOGGLE ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCommand = false;
          _optimisticRunning = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(telemetryViewModelProvider);
    final latest = telemetry.latest;

    if (latest != null) {
      final incomingId = latest.id?.toString() ?? latest.createdAt.toString();

      if (incomingId != _lastSeenPacketId) {
        _lastSeenPacketId = incomingId;
        _lastPacketReceivedAt = DateTime.now();

        if (_isWaitingForSync) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isWaitingForSync = false;
              });
            }
          });
        }
      }
    }

    final bool isActuallyRunning = latest != null && latest.statusCode == 1;

    final bool isRunning =
    (_isProcessingCommand && _optimisticRunning != null)
        ? _optimisticRunning!
        : isActuallyRunning;

    String displayRunningTime = "00:00:00";

    if (isRunning && latest?.createdAt != null) {
      try {
        final serverStartTime = DateTime.parse(latest!.createdAt.toString());
        final durationDifference = DateTime.now().difference(serverStartTime);

        if (durationDifference.inSeconds > 0) {
          displayRunningTime =
          "${durationDifference.inHours.toString().padLeft(2, '0')}:"
              "${(durationDifference.inMinutes % 60).toString().padLeft(2, '0')}:"
              "${(durationDifference.inSeconds % 60).toString().padLeft(2, '0')}";
        }
      } catch (_) {
        displayRunningTime = "Running";
      }
    }

    final DeviceConnectionStatus status = _computeStatus(latest);

    final snapshot = MotorSnapshot.fromAppState(
      isRunning: isRunning,
      isSyncing: _isProcessingCommand,
      latest: latest,
      status: status,
    );

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: SmartWellHomeAppBar(
        hasDevice: deviceId != null && deviceId!.isNotEmpty,
        displayName: deviceName ?? "SmartWell Pump",
        deviceId: deviceId,
        onSelectDevice: () {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.devices,
          );
        },
      ),
      drawer: ProfessionalDrawer(
        deviceId: deviceId ?? "ESP32_001_TW",
      ),
      body: HomeDashboardContent(
        isSyncing: _isProcessingCommand,
        onMotorTap: () => _toggleMotor(isActuallyRunning),
        hasDevice: deviceId != null && deviceId!.isNotEmpty,
        deviceId: deviceId,
        displayName: deviceName ?? "SmartWell Pump",
        latest: latest,
        telemetryState: telemetry,
        motorState: ref.watch(motorViewModelProvider),
        snapshot: snapshot,
        status: status,
        pulseAnimation: const AlwaysStoppedAnimation(1.0),
        customerNameController: customerNameController,
        customerNameFocusNode: customerNameFocusNode,
        customerSuggestions: const [],
        runningTime: displayRunningTime,
        horizontalPadding: 16,
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        buttonSize: 180,
        isVerySmall: false,
        onRefresh: () async {
          if (deviceId != null && deviceId!.isNotEmpty) {
            await ref
                .read(telemetryViewModelProvider.notifier)
                .loadLatest(deviceId!);

            await ref
                .read(motorLogViewModelProvider.notifier)
                .loadLogs(deviceId!);

            await ref.read(khataViewModelProvider.notifier).loadEntries();

            if (mounted) {
              setState(() {
                _lastPacketReceivedAt = DateTime.now();
              });
            }
          }
        },
        formatValue: (
            val,
            unit, {
              decimals = 1,
              required status,
            }) {
          return "${val?.toStringAsFixed(decimals) ?? '--'} $unit";
        },
      ),
    );
  }
}