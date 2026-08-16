// import "dart:async";
//
// import "package:flutter/material.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
// import "package:smart_iot_app/src/features/telemetry/presentation/providers/telemetry_providers.dart";
//
// import "../../../../core/utils/app_theme_colours.dart";
// import "../../data/models/khata_entry_model.dart";
// import "../providers/ khata_providers.dart";
// import "../state/khata_state.dart";
//
// // TODO: update this import path according to your project structure.
//
//
// import "../../data/models/khata_entry_model.dart";
// import "../providers/ khata_providers.dart";
// import "../state/khata_state.dart";
//
// class KhataScreen extends ConsumerStatefulWidget {
//   final String deviceId;
//
//   const KhataScreen({
//     super.key,
//     required this.deviceId,
//   });
//
//   @override
//   ConsumerState<KhataScreen> createState() => _KhataScreenState();
// }
//
// class _KhataScreenState extends ConsumerState<KhataScreen> {
//   final TextEditingController searchController = TextEditingController();
//
//   Timer? _runningTimer;
//   Timer? _telemetrySyncTimer;
//
//   String query = "";
//   String selectedStatus = "all";
//
//   bool _checkingTelemetry = false;
//   bool _hasFreshTelemetry = false;
//   bool _motorConfirmedRunning = false;
//   bool _finalizingKhataFromTelemetry = false;
//
//   // Freeze the visible Khata timer at the first fresh VFD OFF confirmation.
//   DateTime? _confirmedMotorStopAt;
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() async {
//       await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//       if (!mounted) return;
//
//       await _syncMotorStateAndKhata();
//     });
//
//     // UI timer. It advances only for the current device while the VFD is
//     // not positively confirming OFF.
//     _runningTimer = Timer.periodic(
//       const Duration(seconds: 1),
//           (_) {
//         if (!mounted) return;
//
//         final currentDeviceId = widget.deviceId.trim();
//
//         final hasOpenSession = ref
//             .read(khataViewModelProvider)
//             .entries
//             .any(
//               (entry) =>
//           entry.deviceId.trim() == currentDeviceId &&
//               entry.isOpen &&
//               entry.startTime != null &&
//               entry.endTime == null,
//         );
//
//         if (!hasOpenSession) return;
//
//         // Fresh VFD OFF is authoritative for the visible Khata clock.
//         if (_hasFreshTelemetry && !_motorConfirmedRunning) {
//           return;
//         }
//
//         setState(() {});
//       },
//     );
//
//     // Keep the Khata screen synchronized with VFD state.
//     // The guard in _syncMotorStateAndKhata prevents overlapping requests.
//     _telemetrySyncTimer = Timer.periodic(
//       const Duration(seconds: 1),
//           (_) => _syncMotorStateAndKhata(),
//     );
//   }
//
//   @override
//   void dispose() {
//     _runningTimer?.cancel();
//     _telemetrySyncTimer?.cancel();
//     searchController.dispose();
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
//   bool _isDeviceOnline(dynamic latest) {
//     if (latest == null) return false;
//
//     final live = _toInt(latest.isLive) == 1;
//     final fresh = latest.isFresh(withinSeconds: 20);
//
//     return live && fresh;
//   }
//
//   bool _isMotorRunning(dynamic latest) {
//     if (!_isDeviceOnline(latest)) return false;
//
//     final statusCode = _toInt(latest.statusCode);
//
//     return statusCode == 1 || statusCode == 2;
//   }
//
//   KhataEntryModel? _latestOpenKhataForCurrentDevice() {
//     final currentDeviceId = widget.deviceId.trim();
//
//     if (currentDeviceId.isEmpty) return null;
//
//     final entries = ref.read(khataViewModelProvider).entries;
//
//     KhataEntryModel? latestOpen;
//
//     for (final entry in entries) {
//       if (entry.deviceId.trim() != currentDeviceId) continue;
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
//   Future<void> _syncMotorStateAndKhata() async {
//     if (_checkingTelemetry) return;
//
//     final currentDeviceId = widget.deviceId.trim();
//
//     if (currentDeviceId.isEmpty) return;
//
//     _checkingTelemetry = true;
//
//     try {
//       await ref
//           .read(telemetryViewModelProvider.notifier)
//           .loadLatest(
//         currentDeviceId,
//         showLoading: false,
//       );
//
//       if (!mounted) return;
//
//       final latest = ref.read(telemetryViewModelProvider).latest;
//       final hasFreshTelemetry = _isDeviceOnline(latest);
//
//       // Missing/stale telemetry is NOT a confirmed OFF state.
//       if (!hasFreshTelemetry) {
//         if (_hasFreshTelemetry) {
//           setState(() {
//             _hasFreshTelemetry = false;
//           });
//         }
//         return;
//       }
//
//       final motorRunning = _isMotorRunning(latest);
//
//       setState(() {
//         _hasFreshTelemetry = true;
//         _motorConfirmedRunning = motorRunning;
//
//         if (motorRunning) {
//           _confirmedMotorStopAt = null;
//         } else {
//           _confirmedMotorStopAt ??= DateTime.now();
//         }
//       });
//
//       // Fresh VFD OFF: first let HomeScreen/backend state catch up.
//       if (!motorRunning) {
//         await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//         if (!mounted) return;
//
//         final openEntry = _latestOpenKhataForCurrentDevice();
//
//         // Fallback: VFD is definitely OFF but Khata still says open.
//         // Finalize it once so billing cannot continue indefinitely.
//         if (openEntry != null && !_finalizingKhataFromTelemetry) {
//           _finalizingKhataFromTelemetry = true;
//
//           try {
//             final stopAt = _confirmedMotorStopAt ?? DateTime.now();
//
//             final closedEntry = await ref
//                 .read(khataViewModelProvider.notifier)
//                 .closeMotorKhataSession(
//               entry: openEntry,
//               endTime: stopAt,
//             );
//
//             if (closedEntry != null) {
//               await ref
//                   .read(khataViewModelProvider.notifier)
//                   .loadEntries();
//             }
//           } finally {
//             _finalizingKhataFromTelemetry = false;
//           }
//         }
//       }
//     } catch (_) {
//       // Never convert a connectivity/telemetry error into a fake OFF state.
//     } finally {
//       _checkingTelemetry = false;
//     }
//   }
//
//   Future<void> _refresh() async {
//     await ref.read(khataViewModelProvider.notifier).loadEntries();
//
//     if (!mounted) return;
//
//     await _syncMotorStateAndKhata();
//   }
//
//   List<KhataEntryModel> _filteredEntries(List<KhataEntryModel> entries) {
//     final search = query.trim().toLowerCase();
//
//     var result = entries;
//
//     if (selectedStatus != "all") {
//       result = result.where((entry) {
//         return entry.paymentStatus.toLowerCase() == selectedStatus;
//       }).toList();
//     }
//
//     if (search.isEmpty) return result;
//
//     return result.where((entry) {
//       return entry.customerName.toLowerCase().contains(search) ||
//           entry.deviceId.toLowerCase().contains(search) ||
//           entry.paymentStatus.toLowerCase().contains(search) ||
//           entry.date.toLowerCase().contains(search);
//     }).toList();
//   }
//
//   void _showSnack(
//       String message,
//       bool isError, {
//         int seconds = 8,
//       }) {
//     if (!mounted) return;
//
//     // Do not mutate Scaffold/Overlay while a bottom-sheet/dialog route is
//     // being deactivated. Schedule the snackbar for the next safe frame.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//
//       final messenger = ScaffoldMessenger.maybeOf(context);
//       if (messenger == null) return;
//
//       messenger.hideCurrentSnackBar();
//
//       messenger.showSnackBar(
//         SnackBar(
//           duration: Duration(seconds: isError ? seconds : 4),
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//           elevation: 10,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           backgroundColor: isError ? AppColors.error : AppColors.success,
//           content: Text(
//             message,
//             style: const TextStyle(
//               color: AppColors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//       );
//     });
//   }
//
//   Future<void> _showPriceSheet(KhataEntryModel entry) async {
//     final priceController = TextEditingController(
//       text: entry.pricePerHour > 0 ? entry.pricePerHour.toString() : "",
//     );
//
//     final cashController = TextEditingController(
//       text: entry.cashReceived > 0 ? entry.cashReceived.toString() : "0",
//     );
//
//     final result = await showModalBottomSheet<_BillInput>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         final bottom = MediaQuery.of(context).viewInsets.bottom;
//
//         return _KhataBottomSheet(
//           bottom: bottom,
//           title: "Calculate Bill",
//           subtitle: entry.isOpen
//               ? "Running time: ${_displayRunTime(
//             entry,
//             hasFreshTelemetry: _hasFreshTelemetry,
//             motorConfirmedRunning: _motorConfirmedRunning,
//             confirmedMotorStopAt: _confirmedMotorStopAt,
//           )}"
//               : "Run hours: ${entry.runHours.toStringAsFixed(2)}",
//           children: [
//             _SheetField(
//               controller: priceController,
//               label: "Price per hour",
//               icon: Icons.price_change_outlined,
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 12),
//             _SheetField(
//               controller: cashController,
//               label: "Cash received",
//               icon: Icons.payments_outlined,
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16),
//             _PrimarySheetButton(
//               icon: Icons.calculate_rounded,
//               label: "Calculate Bill",
//               onPressed: () {
//                 final price = double.tryParse(priceController.text.trim()) ?? 0;
//                 final cash = double.tryParse(cashController.text.trim()) ?? 0;
//
//                 Navigator.pop(
//                   context,
//                   _BillInput(
//                     pricePerHour: price,
//                     cashReceived: cash,
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//
//     if (result == null) {
//       await Future<void>.delayed(const Duration(milliseconds: 250));
//       priceController.dispose();
//       cashController.dispose();
//       return;
//     }
//
//     // Allow the modal route/keyboard overlay to finish deactivating before
//     // Riverpod updates the screen and the snackbar is shown.
//     await Future<void>.delayed(const Duration(milliseconds: 250));
//
//     if (!mounted) {
//       priceController.dispose();
//       cashController.dispose();
//       return;
//     }
//
//     await ref.read(khataViewModelProvider.notifier).updatePriceAndBill(
//       entry: entry,
//       pricePerHour: result.pricePerHour,
//       cashReceived: result.cashReceived,
//     );
//
//     priceController.dispose();
//     cashController.dispose();
//   }
//
//   Future<void> _showPaymentSheet(KhataEntryModel entry) async {
//     final amountController = TextEditingController();
//
//     final amount = await showModalBottomSheet<double>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         final bottom = MediaQuery.of(context).viewInsets.bottom;
//
//         return _KhataBottomSheet(
//           bottom: bottom,
//           title: "Add Payment",
//           subtitle: entry.customerName,
//           children: [
//             _SheetField(
//               controller: amountController,
//               label: "Amount received",
//               icon: Icons.payments_outlined,
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16),
//             _PrimarySheetButton(
//               icon: Icons.check_rounded,
//               label: "Save Payment",
//               color: AppColors.green,
//               foregroundColor: AppColors.white,
//               onPressed: () {
//                 final value = double.tryParse(amountController.text.trim()) ?? 0;
//                 Navigator.pop(context, value);
//               },
//             ),
//           ],
//         );
//       },
//     );
//
//     if (amount == null) {
//       await Future<void>.delayed(const Duration(milliseconds: 250));
//       amountController.dispose();
//       return;
//     }
//
//     await Future<void>.delayed(const Duration(milliseconds: 250));
//
//     if (!mounted) {
//       amountController.dispose();
//       return;
//     }
//
//     await ref.read(khataViewModelProvider.notifier).addPayment(
//       entry: entry,
//       amount: amount,
//     );
//
//     amountController.dispose();
//   }
//
//   Future<void> _showEditSheet(KhataEntryModel entry) async {
//     final nameController = TextEditingController(text: entry.customerName);
//     final hoursController = TextEditingController(
//       text: entry.runHours.toStringAsFixed(2),
//     );
//     final priceController = TextEditingController(
//       text: entry.pricePerHour.toString(),
//     );
//     final cashController = TextEditingController(
//       text: entry.cashReceived.toString(),
//     );
//
//     final updated = await showModalBottomSheet<KhataEntryModel>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         final bottom = MediaQuery.of(context).viewInsets.bottom;
//
//         return _KhataBottomSheet(
//           bottom: bottom,
//           title: "Update Khata Entry",
//           subtitle: "Edit customer, hours, rate, and received cash",
//           children: [
//             _SheetField(
//               controller: nameController,
//               label: "Customer name",
//               icon: Icons.person_outline_rounded,
//             ),
//             const SizedBox(height: 12),
//             _SheetField(
//               controller: hoursController,
//               label: "Run hours",
//               icon: Icons.timer_outlined,
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 12),
//             _SheetField(
//               controller: priceController,
//               label: "Price per hour",
//               icon: Icons.price_change_outlined,
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 12),
//             _SheetField(
//               controller: cashController,
//               label: "Cash received",
//               icon: Icons.payments_outlined,
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16),
//             _PrimarySheetButton(
//               icon: Icons.save_rounded,
//               label: "Update Entry",
//               onPressed: () {
//                 final name = nameController.text.trim();
//                 final hours = double.tryParse(hoursController.text.trim()) ?? 0;
//                 final price = double.tryParse(priceController.text.trim()) ?? 0;
//                 final cash = double.tryParse(cashController.text.trim()) ?? 0;
//
//                 final totalBill = hours * price;
//                 final remaining = totalBill - cash;
//
//                 Navigator.pop(
//                   context,
//                   entry.copyWith(
//                     customerName: name.isEmpty ? entry.customerName : name,
//                     runHours: hours,
//                     pricePerHour: price,
//                     cashReceived: cash,
//                     totalBill: totalBill,
//                     remainingBalance: remaining <= 0 ? 0 : remaining,
//                     paymentStatus: _paymentStatus(
//                       cashReceived: cash,
//                       totalBill: totalBill,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//
//     if (updated == null) {
//       await Future<void>.delayed(const Duration(milliseconds: 250));
//       nameController.dispose();
//       hoursController.dispose();
//       priceController.dispose();
//       cashController.dispose();
//       return;
//     }
//
//     await Future<void>.delayed(const Duration(milliseconds: 250));
//
//     if (!mounted) {
//       nameController.dispose();
//       hoursController.dispose();
//       priceController.dispose();
//       cashController.dispose();
//       return;
//     }
//
//     await ref.read(khataViewModelProvider.notifier).updateEntry(updated);
//
//     nameController.dispose();
//     hoursController.dispose();
//     priceController.dispose();
//     cashController.dispose();
//   }
//
//   Future<void> _confirmDelete(KhataEntryModel entry) async {
//     final id = entry.id;
//
//     if (id == null || id.isEmpty) {
//       _showSnack("Khata entry ID missing", true);
//       return;
//     }
//
//     if (entry.isOpen) {
//       _showSnack(
//         "Stop the motor and finalize this Khata session before deleting it.",
//         true,
//       );
//       return;
//     }
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: AppThemeColors.card(context),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(22),
//           ),
//           title: Text(
//             "Delete Khata entry?",
//             style: TextStyle(
//               color: AppThemeColors.text(context),
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           content: Text(
//             entry.isOpen
//                 ? "This motor session is still open and cannot be deleted until it stops."
//                 : "This will permanently delete the entry for ${entry.customerName}, including any unpaid balance.",
//             style: TextStyle(
//               color: AppThemeColors.subText(context),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text(
//                 "Cancel",
//                 style: TextStyle(color: AppThemeColors.subText(context)),
//               ),
//             ),
//             FilledButton.icon(
//               style: FilledButton.styleFrom(
//                 backgroundColor: AppColors.error,
//                 foregroundColor: AppColors.white,
//               ),
//               onPressed: () => Navigator.pop(context, true),
//               icon: const Icon(Icons.delete_outline_rounded),
//               label: const Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirmed != true) return;
//
//     await ref.read(khataViewModelProvider.notifier).deleteEntry(id);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<KhataState>(
//       khataViewModelProvider,
//           (previous, next) {
//         if (next.error != null && previous?.error != next.error) {
//           _showSnack(next.error!, true, seconds: 12);
//         }
//
//         if (next.message != null && previous?.message != next.message) {
//           _showSnack(next.message!, false);
//         }
//       },
//     );
//
//     final state = ref.watch(khataViewModelProvider);
//
//     // final deviceEntries = state.entries;
//     // final entries = _filteredEntries(state.entries);
//     final safeDeviceId = widget.deviceId.trim();
//
//     final deviceEntries = state.entries.where((entry) {
//       return entry.deviceId.trim() == safeDeviceId;
//     }).toList();
//
//     final entries = _filteredEntries(deviceEntries);
//
//     final totalBill = entries.fold<double>(
//       0,
//           (sum, item) => sum + item.totalBill,
//     );
//
//     final totalReceived = entries.fold<double>(
//       0,
//           (sum, item) => sum + item.cashReceived,
//     );
//
//     final totalRemaining = entries.fold<double>(
//       0,
//           (sum, item) => sum + item.remainingBalance,
//     );
//
//     final width = MediaQuery.of(context).size.width;
//     final isWide = width >= 850;
//
//     return Scaffold(
//       backgroundColor: AppThemeColors.background(context),
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryDark,
//         foregroundColor: AppThemeColors.appBarText(context),
//         elevation: 0,
//         centerTitle: false,
//         titleSpacing: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               "Khata",
//               style: TextStyle(
//                 color: AppThemeColors.appBarText(context),
//                 fontWeight: FontWeight.w900,
//                 fontSize: 21,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Center(
//               child: Text(
//                 "Customer billing and balances",
//                 style: TextStyle(
//                   color: AppThemeColors.subText(context),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             tooltip: "Refresh",
//             onPressed: state.isLoading ? null : _refresh,
//             icon: const Icon(Icons.refresh_rounded),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: AppColors.primary,
//           backgroundColor: AppThemeColors.surface(context),
//           onRefresh: _refresh,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(
//               parent: BouncingScrollPhysics(),
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: isWide ? 32 : 16,
//               vertical: 18,
//             ),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 1120),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _DeviceHeader(
//                       deviceId: widget.deviceId,
//                       count: deviceEntries.length,
//                     ),
//                     const SizedBox(height: 16),
//                     _SummaryGrid(
//                       totalBill: totalBill,
//                       totalReceived: totalReceived,
//                       totalRemaining: totalRemaining,
//                       count: entries.length,
//                     ),
//                     const SizedBox(height: 16),
//                     _SearchAndFilters(
//                       searchController: searchController,
//                       selectedStatus: selectedStatus,
//                       onSearchChanged: (value) {
//                         setState(() => query = value);
//                       },
//                       onStatusChanged: (value) {
//                         setState(() => selectedStatus = value);
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     if (state.isLoading && entries.isEmpty)
//                       const Padding(
//                         padding: EdgeInsets.all(34),
//                         child: Center(
//                           child: CircularProgressIndicator(
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       )
//                     else if (widget.deviceId.trim().isEmpty)
//                       const _EmptyKhata(
//                         title: "Device ID missing",
//                         message: "Please select a device first.",
//                       )
//                     else if (deviceEntries.isEmpty)
//                         _EmptyKhata(
//                           title: "No Khata entries for this device",
//                           message:
//                           "Entries for ${widget.deviceId} will appear after motor runs are billed.",
//                         )
//                       else if (entries.isEmpty)
//                           const _EmptyKhata(
//                             title: "No matching entries",
//                             message: "Try changing search text or payment filter.",
//                           )
//                         else
//                           _KhataList(
//                             entries: entries,
//                             hasFreshTelemetry: _hasFreshTelemetry,
//                             motorConfirmedRunning: _motorConfirmedRunning,
//                             confirmedMotorStopAt: _confirmedMotorStopAt,
//                             onSetPrice: _showPriceSheet,
//                             onPayment: _showPaymentSheet,
//                             onEdit: _showEditSheet,
//                             onDelete: _confirmDelete,
//                             onSharePdf: (entry) {
//                               ref.read(khataPdfServiceProvider).shareEntryPdf(entry);
//                             },
//                             onPreviewPdf: (entry) {
//                               ref
//                                   .read(khataPdfServiceProvider)
//                                   .previewEntryPdf(entry);
//                             },
//                           ),
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
// class _KhataList extends StatelessWidget {
//   final List<KhataEntryModel> entries;
//   final bool hasFreshTelemetry;
//   final bool motorConfirmedRunning;
//   final DateTime? confirmedMotorStopAt;
//   final ValueChanged<KhataEntryModel> onSetPrice;
//   final ValueChanged<KhataEntryModel> onPayment;
//   final ValueChanged<KhataEntryModel> onEdit;
//   final ValueChanged<KhataEntryModel> onDelete;
//   final ValueChanged<KhataEntryModel> onSharePdf;
//   final ValueChanged<KhataEntryModel> onPreviewPdf;
//
//   const _KhataList({
//     required this.entries,
//     required this.hasFreshTelemetry,
//     required this.motorConfirmedRunning,
//     required this.confirmedMotorStopAt,
//     required this.onSetPrice,
//     required this.onPayment,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onSharePdf,
//     required this.onPreviewPdf,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final twoColumns = constraints.maxWidth >= 840;
//
//         if (!twoColumns) {
//           return Column(
//             children: entries.map((entry) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 14),
//                 child: _KhataCard(
//                   entry: entry,
//                   hasFreshTelemetry: hasFreshTelemetry,
//                   motorConfirmedRunning: motorConfirmedRunning,
//                   confirmedMotorStopAt: confirmedMotorStopAt,
//                   onSetPrice: () => onSetPrice(entry),
//                   onPayment: () => onPayment(entry),
//                   onEdit: () => onEdit(entry),
//                   onDelete: () => onDelete(entry),
//                   onSharePdf: () => onSharePdf(entry),
//                   onPreviewPdf: () => onPreviewPdf(entry),
//                 ),
//               );
//             }).toList(),
//           );
//         }
//
//         return Wrap(
//           spacing: 16,
//           runSpacing: 16,
//           children: entries.map((entry) {
//             return SizedBox(
//               width: (constraints.maxWidth - 16) / 2,
//               child: _KhataCard(
//                 entry: entry,
//                 hasFreshTelemetry: hasFreshTelemetry,
//                 motorConfirmedRunning: motorConfirmedRunning,
//                 confirmedMotorStopAt: confirmedMotorStopAt,
//                 onSetPrice: () => onSetPrice(entry),
//                 onPayment: () => onPayment(entry),
//                 onEdit: () => onEdit(entry),
//                 onDelete: () => onDelete(entry),
//                 onSharePdf: () => onSharePdf(entry),
//                 onPreviewPdf: () => onPreviewPdf(entry),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
//
// class _DeviceHeader extends StatelessWidget {
//   final String deviceId;
//   final int count;
//
//   const _DeviceHeader({
//     required this.deviceId,
//     required this.count,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             AppColors.primaryDark,
//             AppColors.mintAccentDark,
//           ],
//         ),
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.18),
//             blurRadius: 26,
//             offset: const Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 58,
//             height: 58,
//             decoration: BoxDecoration(
//               color: AppColors.white.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: const Icon(
//               Icons.receipt_long_rounded,
//               color: AppColors.primary,
//               size: 30,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Device Khata Ledger",
//                   style: TextStyle(
//                     color: AppColors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   deviceId.isEmpty ? "No device selected" : deviceId,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     color: AppColors.gray300,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
//             decoration: BoxDecoration(
//               color: AppColors.white.withOpacity(0.10),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: AppColors.white.withOpacity(0.12),
//               ),
//             ),
//             child: Text(
//               "$count entries",
//               style: const TextStyle(
//                 color: AppColors.white,
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
// class _SearchAndFilters extends StatelessWidget {
//   final TextEditingController searchController;
//   final String selectedStatus;
//   final ValueChanged<String> onSearchChanged;
//   final ValueChanged<String> onStatusChanged;
//
//   const _SearchAndFilters({
//     required this.searchController,
//     required this.selectedStatus,
//     required this.onSearchChanged,
//     required this.onStatusChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: AppThemeColors.cardDecoration(context),
//       child: Column(
//         children: [
//           TextField(
//             controller: searchController,
//             onChanged: onSearchChanged,
//             style: TextStyle(
//               color: AppThemeColors.text(context),
//               fontWeight: FontWeight.w700,
//             ),
//             decoration: InputDecoration(
//               hintText: "Search customer, date, device, or status",
//               hintStyle: TextStyle(color: AppThemeColors.subText(context)),
//               prefixIcon: const Icon(
//                 Icons.search_rounded,
//                 color: AppColors.primary,
//               ),
//               filled: true,
//               fillColor: AppThemeColors.input(context),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(18),
//                 borderSide: BorderSide(color: AppThemeColors.border(context)),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(18),
//                 borderSide: BorderSide(color: AppThemeColors.border(context)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(18),
//                 borderSide: const BorderSide(
//                   color: AppColors.primary,
//                   width: 1.4,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _StatusChip(
//                   label: "All",
//                   value: "all",
//                   selectedStatus: selectedStatus,
//                   onChanged: onStatusChanged,
//                 ),
//                 _StatusChip(
//                   label: "Unpaid",
//                   value: "unpaid",
//                   selectedStatus: selectedStatus,
//                   onChanged: onStatusChanged,
//                 ),
//                 _StatusChip(
//                   label: "Partial",
//                   value: "partial",
//                   selectedStatus: selectedStatus,
//                   onChanged: onStatusChanged,
//                 ),
//                 _StatusChip(
//                   label: "Paid",
//                   value: "paid",
//                   selectedStatus: selectedStatus,
//                   onChanged: onStatusChanged,
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
// class _StatusChip extends StatelessWidget {
//   final String label;
//   final String value;
//   final String selectedStatus;
//   final ValueChanged<String> onChanged;
//
//   const _StatusChip({
//     required this.label,
//     required this.value,
//     required this.selectedStatus,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final selected = selectedStatus == value;
//     final selectedColor = _statusColor(value);
//
//     return ChoiceChip(
//       selected: selected,
//       label: Text(label),
//       onSelected: (_) => onChanged(value),
//       selectedColor: selectedColor,
//       backgroundColor: AppThemeColors.input(context),
//       side: BorderSide(
//         color: selected ? selectedColor : AppThemeColors.border(context),
//       ),
//       labelStyle: TextStyle(
//         color: selected ? AppColors.white : AppThemeColors.text(context),
//         fontWeight: FontWeight.w800,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(18),
//       ),
//     );
//   }
// }
//
// class _SummaryGrid extends StatelessWidget {
//   final double totalBill;
//   final double totalReceived;
//   final double totalRemaining;
//   final int count;
//
//   const _SummaryGrid({
//     required this.totalBill,
//     required this.totalReceived,
//     required this.totalRemaining,
//     required this.count,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final columns = constraints.maxWidth >= 760 ? 4 : 2;
//
//         return GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: columns,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: columns == 4 ? 1.72 : 1.38,
//           children: [
//             _SummaryCard(
//               label: "Entries",
//               value: "$count",
//               icon: Icons.receipt_long_rounded,
//               accent: AppColors.primary,
//             ),
//             _SummaryCard(
//               label: "Total Bill",
//               value: _money(totalBill),
//               icon: Icons.account_balance_wallet_rounded,
//               accent: AppColors.info,
//             ),
//             _SummaryCard(
//               label: "Received",
//               value: _money(totalReceived),
//               icon: Icons.payments_rounded,
//               accent: AppColors.success,
//             ),
//             _SummaryCard(
//               label: "Remaining",
//               value: _money(totalRemaining),
//               icon: Icons.warning_amber_rounded,
//               accent: totalRemaining > 0 ? AppColors.error : AppColors.success,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _SummaryCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color accent;
//
//   const _SummaryCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.accent,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: AppThemeColors.cardDecoration(context),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             height: 38,
//             width: 38,
//             decoration: BoxDecoration(
//               color: accent.withOpacity(0.16),
//               borderRadius: BorderRadius.circular(13),
//             ),
//             child: Icon(
//               icon,
//               color: accent,
//               size: 22,
//             ),
//           ),
//           const Spacer(),
//           Text(
//             label,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: AppThemeColors.subText(context),
//               fontWeight: FontWeight.w700,
//               fontSize: 12.5,
//             ),
//           ),
//           const SizedBox(height: 5),
//           FittedBox(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: AppThemeColors.text(context),
//                 fontWeight: FontWeight.w900,
//                 fontSize: 20,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _KhataCard extends StatelessWidget {
//   final KhataEntryModel entry;
//   final bool hasFreshTelemetry;
//   final bool motorConfirmedRunning;
//   final DateTime? confirmedMotorStopAt;
//   final VoidCallback onSetPrice;
//   final VoidCallback onPayment;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onSharePdf;
//   final VoidCallback onPreviewPdf;
//
//   const _KhataCard({
//     required this.entry,
//     required this.hasFreshTelemetry,
//     required this.motorConfirmedRunning,
//     required this.confirmedMotorStopAt,
//     required this.onSetPrice,
//     required this.onPayment,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onSharePdf,
//     required this.onPreviewPdf,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _statusColor(entry.paymentStatus);
//     final canAddPayment = entry.totalBill > 0 && entry.remainingBalance > 0;
//
//     final sessionActuallyRunning =
//         entry.isOpen &&
//             entry.endTime == null &&
//             (!hasFreshTelemetry || motorConfirmedRunning);
//
//     final motorConfirmedOffWhileEntryOpen =
//         entry.isOpen &&
//             entry.endTime == null &&
//             hasFreshTelemetry &&
//             !motorConfirmedRunning;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: AppThemeColors.cardDecoration(context),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 22,
//                 backgroundColor: AppColors.primary.withOpacity(0.14),
//                 child: const Icon(
//                   Icons.person_rounded,
//                   color: AppColors.primary,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   entry.customerName.isEmpty ? "-" : entry.customerName,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppThemeColors.text(context),
//                     fontSize: 17,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 color: AppThemeColors.card(context),
//                 iconColor: AppThemeColors.subText(context),
//                 onSelected: (value) {
//                   if (value == "edit") onEdit();
//                   if (value == "delete") onDelete();
//                   if (value == "preview") onPreviewPdf();
//                   if (value == "share") onSharePdf();
//                 },
//                 itemBuilder: (context) {
//                   return [
//                     PopupMenuItem(
//                       value: "edit",
//                       child: Text(
//                         "Update",
//                         style: TextStyle(color: AppThemeColors.text(context)),
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "preview",
//                       child: Text(
//                         "Preview PDF",
//                         style: TextStyle(color: AppThemeColors.text(context)),
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: "share",
//                       child: Text(
//                         "Share PDF",
//                         style: TextStyle(color: AppThemeColors.text(context)),
//                       ),
//                     ),
//                     const PopupMenuDivider(),
//                     const PopupMenuItem(
//                       value: "delete",
//                       child: Text(
//                         "Delete",
//                         style: TextStyle(color: AppColors.error),
//                       ),
//                     ),
//                   ];
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               if (sessionActuallyRunning)
//                 const _StatusBadge(
//                   label: "RUNNING",
//                   color: AppColors.success,
//                 ),
//               if (motorConfirmedOffWhileEntryOpen)
//                 const _StatusBadge(
//                   label: "STOPPED",
//                   color: AppColors.error,
//                 ),
//               _StatusBadge(
//                 label: entry.paymentStatus.toUpperCase(),
//                 color: statusColor,
//               ),
//               _SoftBadge(
//                 icon: Icons.calendar_today_rounded,
//                 label: entry.date.isEmpty ? "-" : entry.date,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _InfoRow(label: "Device", value: entry.deviceId),
//           _InfoRow(
//             label: sessionActuallyRunning
//                 ? "Running Time"
//                 : motorConfirmedOffWhileEntryOpen
//                 ? "Stopped Time"
//                 : "Run Hours",
//             value: (entry.isOpen || entry.endTime != null)
//                 ? _displayRunTime(
//               entry,
//               hasFreshTelemetry: hasFreshTelemetry,
//               motorConfirmedRunning: motorConfirmedRunning,
//               confirmedMotorStopAt: confirmedMotorStopAt,
//             )
//                 : "${entry.runHours.toStringAsFixed(2)} hr",
//             strong:
//             sessionActuallyRunning || motorConfirmedOffWhileEntryOpen,
//             strongColor: sessionActuallyRunning
//                 ? AppColors.success
//                 : motorConfirmedOffWhileEntryOpen
//                 ? AppColors.error
//                 : null,
//           ),
//           _InfoRow(
//             label: "Price Per Hour",
//             value: _money(entry.pricePerHour),
//           ),
//           _InfoRow(
//             label: "Total Bill",
//             value: _money(entry.totalBill),
//           ),
//           _InfoRow(
//             label: "Cash Received",
//             value: _money(entry.cashReceived),
//           ),
//           _InfoRow(
//             label: "Remaining",
//             value: _money(entry.remainingBalance),
//             strong: true,
//             strongColor:
//             entry.remainingBalance > 0
//                 ? AppColors.error
//                 : AppColors.success,
//           ),
//
//           // Show overpayment as customer credit/advance.
//           if (entry.advanceAmount > 0)
//             _InfoRow(
//               label: "Advance / Credit",
//               value: _money(entry.advanceAmount),
//               strong: true,
//               strongColor: AppColors.success,
//             ),
//
//           const SizedBox(height: 14),
//           Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: _ActionButton(
//                       label: entry.pricePerHour <= 0 ? "Set Rate" : "Rate",
//                       icon: Icons.calculate_rounded,
//                       color: AppColors.primary,
//                       textColor: AppColors.black,
//                       filled: true,
//                       onTap: onSetPrice,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: _ActionButton(
//                       label: "Add Payment",
//                       icon: Icons.add_card_rounded,
//                       color: AppColors.green,
//                       textColor: AppColors.white,
//                       filled: true,
//                       onTap: canAddPayment ? onPayment : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _ActionButton(
//                       label: "Update",
//                       icon: Icons.edit_rounded,
//                       color: AppColors.primary,
//                       textColor: AppColors.primary,
//                       filled: false,
//                       onTap: onEdit,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: _ActionButton(
//                       label: "Delete",
//                       icon: Icons.delete_outline_rounded,
//                       color: AppColors.error,
//                       textColor: AppColors.error,
//                       filled: false,
//                       onTap: onDelete,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final String label;
//   final Color color;
//
//   const _StatusBadge({
//     required this.label,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.18),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: color.withOpacity(0.22)),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: color,
//           fontSize: 11,
//           fontWeight: FontWeight.w900,
//         ),
//       ),
//     );
//   }
// }
//
// class _SoftBadge extends StatelessWidget {
//   final IconData icon;
//   final String label;
//
//   const _SoftBadge({
//     required this.icon,
//     required this.label,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//       decoration: BoxDecoration(
//         color: AppThemeColors.input(context),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: AppThemeColors.border(context)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: AppThemeColors.subText(context)),
//           const SizedBox(width: 5),
//           Text(
//             label,
//             style: TextStyle(
//               color: AppThemeColors.subText(context),
//               fontSize: 11,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ActionButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final Color textColor;
//   final bool filled;
//   final VoidCallback? onTap;
//
//   const _ActionButton({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.textColor,
//     required this.filled,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final enabled = onTap != null;
//
//     return SizedBox(
//       height: 44,
//       child: filled
//           ? ElevatedButton.icon(
//         onPressed: onTap,
//         icon: Icon(icon, size: 17),
//         label: FittedBox(child: Text(label)),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: enabled ? color : AppColors.disabledDark,
//           foregroundColor: enabled ? textColor : AppColors.gray500,
//           disabledBackgroundColor: AppColors.disabledDark,
//           disabledForegroundColor: AppColors.gray500,
//           elevation: enabled ? 4 : 0,
//           shadowColor: color.withOpacity(0.25),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//       )
//           : OutlinedButton.icon(
//         onPressed: onTap,
//         icon: Icon(icon, size: 17),
//         label: FittedBox(child: Text(label)),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: enabled ? textColor : AppColors.gray500,
//           side: BorderSide(
//             color: enabled ? color.withOpacity(0.55) : AppColors.gray600,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool strong;
//   final Color? strongColor;
//
//   const _InfoRow({
//     required this.label,
//     required this.value,
//     this.strong = false,
//     this.strongColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 7),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: AppThemeColors.subText(context),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Flexible(
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(
//                 color: strong
//                     ? (strongColor ?? AppColors.primary)
//                     : AppThemeColors.text(context),
//                 fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _KhataBottomSheet extends StatelessWidget {
//   final double bottom;
//   final String title;
//   final String subtitle;
//   final List<Widget> children;
//
//   const _KhataBottomSheet({
//     required this.bottom,
//     required this.title,
//     required this.subtitle,
//     required this.children,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppThemeColors.card(context),
//         borderRadius: const BorderRadius.vertical(
//           top: Radius.circular(28),
//         ),
//         border: Border(
//           top: BorderSide(color: AppThemeColors.border(context)),
//         ),
//       ),
//       padding: EdgeInsets.fromLTRB(20, 18, 20, bottom + 20),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 48,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: AppThemeColors.border(context),
//                 borderRadius: BorderRadius.circular(99),
//               ),
//             ),
//             const SizedBox(height: 18),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppThemeColors.text(context),
//                 fontSize: 20,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               subtitle,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppThemeColors.subText(context),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 18),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _SheetField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final TextInputType keyboardType;
//
//   const _SheetField({
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.keyboardType = TextInputType.text,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       style: TextStyle(
//         color: AppThemeColors.text(context),
//         fontWeight: FontWeight.w700,
//       ),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: AppThemeColors.subText(context)),
//         prefixIcon: Icon(icon, color: AppColors.primary),
//         filled: true,
//         fillColor: AppThemeColors.input(context),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppThemeColors.border(context)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: AppThemeColors.border(context)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(16)),
//           borderSide: BorderSide(
//             color: AppColors.primary,
//             width: 1.4,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _PrimarySheetButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onPressed;
//   final Color? color;
//   final Color? foregroundColor;
//
//   const _PrimarySheetButton({
//     required this.icon,
//     required this.label,
//     required this.onPressed,
//     this.color,
//     this.foregroundColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final bg = color ?? AppColors.primary;
//     final fg = foregroundColor ?? AppColors.black;
//
//     return SizedBox(
//       width: double.infinity,
//       height: 54,
//       child: ElevatedButton.icon(
//         onPressed: onPressed,
//         icon: Icon(icon),
//         label: Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w900),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: bg,
//           foregroundColor: fg,
//           elevation: 4,
//           shadowColor: bg.withOpacity(0.28),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _EmptyKhata extends StatelessWidget {
//   final String title;
//   final String message;
//
//   const _EmptyKhata({
//     required this.title,
//     required this.message,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(30),
//       decoration: AppThemeColors.cardDecoration(context),
//       child: Column(
//         children: [
//           Container(
//             height: 58,
//             width: 58,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.14),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: const Icon(
//               Icons.receipt_long_rounded,
//               color: AppColors.primary,
//               size: 34,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: AppThemeColors.text(context),
//               fontWeight: FontWeight.w900,
//               fontSize: 18,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: AppThemeColors.subText(context),
//               height: 1.35,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _BillInput {
//   final double pricePerHour;
//   final double cashReceived;
//
//   const _BillInput({
//     required this.pricePerHour,
//     required this.cashReceived,
//   });
// }
//
// Color _statusColor(String value) {
//   switch (value.toLowerCase()) {
//     case "paid":
//       return AppColors.success;
//     case "partial":
//       return AppColors.warning;
//     case "all":
//       return AppColors.primary;
//     default:
//       return AppColors.error;
//   }
// }
//
// String _paymentStatus({
//   required double cashReceived,
//   required double totalBill,
// }) {
//   if (totalBill <= 0) return "unpaid";
//   if (cashReceived >= totalBill) return "paid";
//   if (cashReceived > 0) return "partial";
//   return "unpaid";
// }
//
// String _displayRunTime(
//     KhataEntryModel entry, {
//       required bool hasFreshTelemetry,
//       required bool motorConfirmedRunning,
//       required DateTime? confirmedMotorStopAt,
//     }) {
//   final startTime = entry.startTime;
//
//   if (startTime == null) {
//     final totalSeconds = (entry.runHours * 3600).round();
//     return _formatDuration(totalSeconds < 0 ? 0 : totalSeconds);
//   }
//
//   // Persisted backend endTime is always authoritative.
//   if (entry.endTime != null) {
//     final seconds = entry.endTime!.difference(startTime).inSeconds;
//     return _formatDuration(seconds < 0 ? 0 : seconds);
//   }
//
//   if (entry.isOpen) {
//     // Fresh VFD OFF freezes the clock immediately, before isOpen changes.
//     if (hasFreshTelemetry && !motorConfirmedRunning) {
//       final stopAt = confirmedMotorStopAt ?? DateTime.now();
//       final seconds = stopAt.difference(startTime).inSeconds;
//       return _formatDuration(seconds < 0 ? 0 : seconds);
//     }
//
//     final seconds = DateTime.now().difference(startTime).inSeconds;
//     return _formatDuration(seconds < 0 ? 0 : seconds);
//   }
//
//   final totalSeconds = (entry.runHours * 3600).round();
//   return _formatDuration(totalSeconds < 0 ? 0 : totalSeconds);
// }
//
// String _formatDuration(int totalSeconds) {
//   final hours = totalSeconds ~/ 3600;
//   final minutes = (totalSeconds % 3600) ~/ 60;
//   final seconds = totalSeconds % 60;
//
//   return "${hours.toString().padLeft(2, "0")}:"
//       "${minutes.toString().padLeft(2, "0")}:"
//       "${seconds.toString().padLeft(2, "0")}";
// }
//
// String _money(double value) {
//   return value.toStringAsFixed(2);
// }
import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";
import "package:smart_iot_app/src/features/telemetry/presentation/providers/telemetry_providers.dart";

import "../../../../core/utils/app_theme_colours.dart";
import "../../data/models/khata_entry_model.dart";
import "../providers/ khata_providers.dart";
import "../state/khata_state.dart";

// TODO: update this import path according to your project structure.

import "dart:async";

import "package:flutter/foundation.dart" show ValueListenable, ValueNotifier;

class KhataScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const KhataScreen({super.key, required this.deviceId});

  @override
  ConsumerState<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends ConsumerState<KhataScreen> {
  final TextEditingController searchController = TextEditingController();

  Timer? _runningTimer;
  Timer? _telemetrySyncTimer;

  // Only the live running-time text rebuilds every second.
  final ValueNotifier<int> _clockTick = ValueNotifier<int>(0);

  // Only the Khata list rebuilds when the real motor state changes.
  final ValueNotifier<int> _motorUiTick = ValueNotifier<int>(0);

  String query = "";
  String selectedStatus = "all";

  bool _initialLoadComplete = false;
  bool _checkingTelemetry = false;
  bool _hasFreshTelemetry = false;
  bool _motorConfirmedRunning = false;
  bool _offStateHandled = false;
  bool _finalizingKhataFromTelemetry = false;
  int _lastTelemetryTimestamp = 0;

  // Freeze the visible Khata timer at the first fresh VFD OFF confirmation.
  DateTime? _confirmedMotorStopAt;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      try {
        await ref.read(khataViewModelProvider.notifier).loadEntries();
      } finally {
        if (mounted) {
          setState(() {
            _initialLoadComplete = true;
          });
        } else {
          _initialLoadComplete = true;
        }
      }

      if (!mounted) return;

      await _syncMotorStateAndKhata();
    });

    // Update ONLY the live timer text once per second.
    // The complete Khata screen is not rebuilt.
    _runningTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      final currentDeviceId = widget.deviceId.trim();

      final hasOpenSession = ref
          .read(khataViewModelProvider)
          .entries
          .any(
            (entry) =>
                entry.deviceId.trim() == currentDeviceId &&
                entry.isOpen &&
                entry.startTime != null &&
                entry.endTime == null,
          );

      if (!hasOpenSession) return;

      // Fresh VFD OFF freezes the live clock.
      if (_hasFreshTelemetry && !_motorConfirmedRunning) {
        return;
      }

      _clockTick.value++;
    });

    // Silent VFD polling. It does not show a loader and does not rebuild
    // the whole page. Only a REAL motor state change updates the Khata list.
    _telemetrySyncTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncMotorStateAndKhata(),
    );
  }

  @override
  void dispose() {
    _runningTimer?.cancel();
    _telemetrySyncTimer?.cancel();
    _clockTick.dispose();
    _motorUiTick.dispose();
    searchController.dispose();
    super.dispose();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  bool _isDeviceOnline(dynamic latest) {
    if (latest == null) return false;

    final live = _toInt(latest.isLive) == 1;
    final fresh = latest.isFresh(withinSeconds: 20);

    return live && fresh;
  }

  bool _isMotorRunning(dynamic latest) {
    if (!_isDeviceOnline(latest)) return false;

    final statusCode = _toInt(latest.statusCode);

    return statusCode == 1 || statusCode == 2;
  }

  KhataEntryModel? _latestOpenKhataForCurrentDevice() {
    final currentDeviceId = widget.deviceId.trim();

    if (currentDeviceId.isEmpty) return null;

    final entries = ref.read(khataViewModelProvider).entries;

    KhataEntryModel? latestOpen;

    for (final entry in entries) {
      if (entry.deviceId.trim() != currentDeviceId) continue;
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

  Future<void> _syncMotorStateAndKhata() async {
    if (_checkingTelemetry) return;

    final currentDeviceId = widget.deviceId.trim();

    if (currentDeviceId.isEmpty) return;

    _checkingTelemetry = true;

    try {
      await ref
          .read(telemetryViewModelProvider.notifier)
          .loadLatest(currentDeviceId, showLoading: false);

      if (!mounted) return;

      final latest = ref.read(telemetryViewModelProvider).latest;

      // Stale/missing telemetry is ignored.
      // It must NOT cause a fake OFF state or a screen rebuild.
      if (!_isDeviceOnline(latest)) {
        return;
      }

      final telemetryTimestamp = _toInt(latest?.timestamp);

      // Ignore the same telemetry record.
      if (telemetryTimestamp > 0 &&
          telemetryTimestamp <= _lastTelemetryTimestamp) {
        return;
      }

      if (telemetryTimestamp > 0) {
        _lastTelemetryTimestamp = telemetryTimestamp;
      }

      final motorRunning = _isMotorRunning(latest);

      final stateChanged =
          !_hasFreshTelemetry || _motorConfirmedRunning != motorRunning;

      // New telemetry with the SAME motor state causes no UI refresh.
      if (!stateChanged) {
        return;
      }

      _hasFreshTelemetry = true;
      _motorConfirmedRunning = motorRunning;

      if (motorRunning) {
        _confirmedMotorStopAt = null;
        _offStateHandled = false;
      } else {
        // Do not create a local/phone OFF timestamp here.
        // HomeScreen / backend will close the MotorLog/Khata using the
        // authoritative server/database endTime.
        _confirmedMotorStopAt = null;
      }

      // Rebuild ONLY the Khata list, not the full screen.
      _motorUiTick.value++;

      if (!motorRunning && !_offStateHandled) {
        _offStateHandled = true;
        await _handleConfirmedMotorOff();
      }
    } catch (_) {
      // Connectivity problems are ignored.
      // Never turn a network error into a fake motor OFF.
    } finally {
      _checkingTelemetry = false;
    }
  }

  Future<void> _handleConfirmedMotorOff() async {
    if (!mounted || _finalizingKhataFromTelemetry) return;

    _finalizingKhataFromTelemetry = true;

    try {
      // IMPORTANT:
      // Do not close Khata here with DateTime.now().
      //
      // The ON/OFF button flow in HomeScreen is responsible for:
      //   ON  -> server/database startTime
      //   OFF -> server/database endTime
      //
      // KhataScreen only reloads that authoritative saved record.
      // This keeps HomeScreen, Motor Logs and Khata on the same time source.
      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      await ref.read(khataViewModelProvider.notifier).loadEntries();

      if (!mounted) return;

      _motorUiTick.value++;
    } finally {
      _finalizingKhataFromTelemetry = false;
    }
  }

  Future<void> _refresh() async {
    await ref.read(khataViewModelProvider.notifier).loadEntries();

    if (!mounted) return;

    _initialLoadComplete = true;
    await _syncMotorStateAndKhata();
  }

  List<KhataEntryModel> _filteredEntries(List<KhataEntryModel> entries) {
    final search = query.trim().toLowerCase();

    var result = entries;

    if (selectedStatus != "all") {
      result = result.where((entry) {
        return entry.paymentStatus.toLowerCase() == selectedStatus;
      }).toList();
    }

    if (search.isEmpty) return result;

    return result.where((entry) {
      return entry.customerName.toLowerCase().contains(search) ||
          entry.deviceId.toLowerCase().contains(search) ||
          entry.paymentStatus.toLowerCase().contains(search) ||
          entry.date.toLowerCase().contains(search);
    }).toList();
  }

  void _showSnack(String message, bool isError, {int seconds = 8}) {
    if (!mounted) return;

    // Do not mutate Scaffold/Overlay while a bottom-sheet/dialog route is
    // being deactivated. Schedule the snackbar for the next safe frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger.hideCurrentSnackBar();

      messenger.showSnackBar(
        SnackBar(
          duration: Duration(seconds: isError ? seconds : 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          content: Text(
            message,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    });
  }

  Future<void> _showPriceSheet(KhataEntryModel entry) async {
    final priceController = TextEditingController(
      text: entry.pricePerHour > 0 ? entry.pricePerHour.toString() : "",
    );

    final cashController = TextEditingController(
      text: entry.cashReceived > 0 ? entry.cashReceived.toString() : "0",
    );

    final result = await showModalBottomSheet<_BillInput>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _KhataBottomSheet(
          bottom: bottom,
          title: "Calculate Bill",
          subtitle: entry.isOpen
              ? "Running time: ${_displayRunTime(entry, hasFreshTelemetry: _hasFreshTelemetry, motorConfirmedRunning: _motorConfirmedRunning, confirmedMotorStopAt: _confirmedMotorStopAt)}"
              : "Run hours: ${entry.runHours.toStringAsFixed(2)}",
          children: [
            _SheetField(
              controller: priceController,
              label: "Price per hour",
              icon: Icons.price_change_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: cashController,
              label: "Cash received",
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _PrimarySheetButton(
              icon: Icons.calculate_rounded,
              label: "Calculate Bill",
              onPressed: () {
                final price = double.tryParse(priceController.text.trim()) ?? 0;
                final cash = double.tryParse(cashController.text.trim()) ?? 0;

                Navigator.pop(
                  context,
                  _BillInput(pricePerHour: price, cashReceived: cash),
                );
              },
            ),
          ],
        );
      },
    );

    if (result == null) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      priceController.dispose();
      cashController.dispose();
      return;
    }

    // Allow the modal route/keyboard overlay to finish deactivating before
    // Riverpod updates the screen and the snackbar is shown.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) {
      priceController.dispose();
      cashController.dispose();
      return;
    }

    await ref
        .read(khataViewModelProvider.notifier)
        .updatePriceAndBill(
          entry: entry,
          pricePerHour: result.pricePerHour,
          cashReceived: result.cashReceived,
        );

    priceController.dispose();
    cashController.dispose();
  }

  Future<void> _showPaymentSheet(KhataEntryModel entry) async {
    final amountController = TextEditingController();

    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _KhataBottomSheet(
          bottom: bottom,
          title: "Add Payment",
          subtitle: entry.customerName,
          children: [
            _SheetField(
              controller: amountController,
              label: "Amount received",
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _PrimarySheetButton(
              icon: Icons.check_rounded,
              label: "Save Payment",
              color: AppColors.green,
              foregroundColor: AppColors.white,
              onPressed: () {
                final value =
                    double.tryParse(amountController.text.trim()) ?? 0;
                Navigator.pop(context, value);
              },
            ),
          ],
        );
      },
    );

    if (amount == null) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      amountController.dispose();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) {
      amountController.dispose();
      return;
    }

    await ref
        .read(khataViewModelProvider.notifier)
        .addPayment(entry: entry, amount: amount);

    amountController.dispose();
  }

  Future<void> _showEditSheet(KhataEntryModel entry) async {
    final nameController = TextEditingController(text: entry.customerName);
    final hoursController = TextEditingController(
      text: entry.runHours.toStringAsFixed(2),
    );
    final priceController = TextEditingController(
      text: entry.pricePerHour.toString(),
    );
    final cashController = TextEditingController(
      text: entry.cashReceived.toString(),
    );

    final updated = await showModalBottomSheet<KhataEntryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;

        return _KhataBottomSheet(
          bottom: bottom,
          title: "Update Khata Entry",
          subtitle: "Edit customer, hours, rate, and received cash",
          children: [
            _SheetField(
              controller: nameController,
              label: "Customer name",
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: hoursController,
              label: "Run hours",
              icon: Icons.timer_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: priceController,
              label: "Price per hour",
              icon: Icons.price_change_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: cashController,
              label: "Cash received",
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _PrimarySheetButton(
              icon: Icons.save_rounded,
              label: "Update Entry",
              onPressed: () {
                final name = nameController.text.trim();
                final hours = double.tryParse(hoursController.text.trim()) ?? 0;
                final price = double.tryParse(priceController.text.trim()) ?? 0;
                final cash = double.tryParse(cashController.text.trim()) ?? 0;

                final totalBill = hours * price;
                final remaining = totalBill - cash;

                Navigator.pop(
                  context,
                  entry.copyWith(
                    customerName: name.isEmpty ? entry.customerName : name,
                    runHours: hours,
                    pricePerHour: price,
                    cashReceived: cash,
                    totalBill: totalBill,
                    remainingBalance: remaining <= 0 ? 0 : remaining,
                    paymentStatus: _paymentStatus(
                      cashReceived: cash,
                      totalBill: totalBill,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    if (updated == null) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      nameController.dispose();
      hoursController.dispose();
      priceController.dispose();
      cashController.dispose();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) {
      nameController.dispose();
      hoursController.dispose();
      priceController.dispose();
      cashController.dispose();
      return;
    }

    await ref.read(khataViewModelProvider.notifier).updateEntry(updated);

    nameController.dispose();
    hoursController.dispose();
    priceController.dispose();
    cashController.dispose();
  }

  Future<void> _confirmDelete(KhataEntryModel entry) async {
    final id = entry.id;

    if (id == null || id.isEmpty) {
      _showSnack("Khata entry ID missing", true);
      return;
    }

    if (entry.isOpen) {
      _showSnack(
        "Stop the motor and finalize this Khata session before deleting it.",
        true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppThemeColors.card(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            "Delete Khata entry?",
            style: TextStyle(
              color: AppThemeColors.text(context),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            entry.isOpen
                ? "This motor session is still open and cannot be deleted until it stops."
                : "This will permanently delete the entry for ${entry.customerName}, including any unpaid balance.",
            style: TextStyle(
              color: AppThemeColors.subText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppThemeColors.subText(context)),
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(khataViewModelProvider.notifier).deleteEntry(id);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<KhataState>(khataViewModelProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        _showSnack(next.error!, true, seconds: 12);
      }

      if (next.message != null && previous?.message != next.message) {
        _showSnack(next.message!, false);
      }
    });

    // Watch ONLY actual Khata entries.
    // Background isLoading/message changes do not rebuild the whole screen.
    final allEntries = ref.watch(
      khataViewModelProvider.select((state) => state.entries),
    );

    // final deviceEntries = state.entries;
    // final entries = _filteredEntries(state.entries);
    final safeDeviceId = widget.deviceId.trim();

    final deviceEntries = allEntries.where((entry) {
      return entry.deviceId.trim() == safeDeviceId;
    }).toList();

    final entries = _filteredEntries(deviceEntries);

    final totalBill = entries.fold<double>(
      0,
      (sum, item) => sum + item.totalBill,
    );

    final totalReceived = entries.fold<double>(
      0,
      (sum, item) => sum + item.cashReceived,
    );

    final totalRemaining = entries.fold<double>(
      0,
      (sum, item) => sum + item.remainingBalance,
    );

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 850;

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppThemeColors.appBarText(context),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Khata",
              style: TextStyle(
                color: AppThemeColors.appBarText(context),
                fontWeight: FontWeight.w900,
                fontSize: 21,
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                "Customer billing and balances",
                style: TextStyle(
                  color: AppThemeColors.subText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppThemeColors.surface(context),
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 32 : 16,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DeviceHeader(
                      deviceId: widget.deviceId,
                      count: deviceEntries.length,
                    ),
                    const SizedBox(height: 16),
                    _SummaryGrid(
                      totalBill: totalBill,
                      totalReceived: totalReceived,
                      totalRemaining: totalRemaining,
                      count: entries.length,
                    ),
                    const SizedBox(height: 16),
                    _SearchAndFilters(
                      searchController: searchController,
                      selectedStatus: selectedStatus,
                      onSearchChanged: (value) {
                        setState(() => query = value);
                      },
                      onStatusChanged: (value) {
                        setState(() => selectedStatus = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!_initialLoadComplete && entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(34),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (widget.deviceId.trim().isEmpty)
                      const _EmptyKhata(
                        title: "Device ID missing",
                        message: "Please select a device first.",
                      )
                    else if (deviceEntries.isEmpty)
                      _EmptyKhata(
                        title: "No Khata entries for this device",
                        message:
                            "Entries for ${widget.deviceId} will appear after motor runs are billed.",
                      )
                    else if (entries.isEmpty)
                      const _EmptyKhata(
                        title: "No matching entries",
                        message: "Try changing search text or payment filter.",
                      )
                    else
                      ValueListenableBuilder<int>(
                        valueListenable: _motorUiTick,
                        builder: (context, _, __) {
                          return _KhataList(
                            entries: entries,
                            hasFreshTelemetry: _hasFreshTelemetry,
                            motorConfirmedRunning: _motorConfirmedRunning,
                            confirmedMotorStopAt: _confirmedMotorStopAt,
                            clockTick: _clockTick,
                            onSetPrice: _showPriceSheet,
                            onPayment: _showPaymentSheet,
                            onEdit: _showEditSheet,
                            onDelete: _confirmDelete,
                            onSharePdf: (entry) {
                              ref
                                  .read(khataPdfServiceProvider)
                                  .shareEntryPdf(entry);
                            },
                            onPreviewPdf: (entry) {
                              ref
                                  .read(khataPdfServiceProvider)
                                  .previewEntryPdf(entry);
                            },
                          );
                        },
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

class _KhataList extends StatelessWidget {
  final List<KhataEntryModel> entries;
  final bool hasFreshTelemetry;
  final bool motorConfirmedRunning;
  final DateTime? confirmedMotorStopAt;
  final ValueListenable<int> clockTick;
  final ValueChanged<KhataEntryModel> onSetPrice;
  final ValueChanged<KhataEntryModel> onPayment;
  final ValueChanged<KhataEntryModel> onEdit;
  final ValueChanged<KhataEntryModel> onDelete;
  final ValueChanged<KhataEntryModel> onSharePdf;
  final ValueChanged<KhataEntryModel> onPreviewPdf;

  const _KhataList({
    required this.entries,
    required this.hasFreshTelemetry,
    required this.motorConfirmedRunning,
    required this.confirmedMotorStopAt,
    required this.clockTick,
    required this.onSetPrice,
    required this.onPayment,
    required this.onEdit,
    required this.onDelete,
    required this.onSharePdf,
    required this.onPreviewPdf,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 840;

        if (!twoColumns) {
          return Column(
            children: entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _KhataCard(
                  entry: entry,
                  hasFreshTelemetry: hasFreshTelemetry,
                  motorConfirmedRunning: motorConfirmedRunning,
                  confirmedMotorStopAt: confirmedMotorStopAt,
                  clockTick: clockTick,
                  onSetPrice: () => onSetPrice(entry),
                  onPayment: () => onPayment(entry),
                  onEdit: () => onEdit(entry),
                  onDelete: () => onDelete(entry),
                  onSharePdf: () => onSharePdf(entry),
                  onPreviewPdf: () => onPreviewPdf(entry),
                ),
              );
            }).toList(),
          );
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: entries.map((entry) {
            return SizedBox(
              width: (constraints.maxWidth - 16) / 2,
              child: _KhataCard(
                entry: entry,
                hasFreshTelemetry: hasFreshTelemetry,
                motorConfirmedRunning: motorConfirmedRunning,
                confirmedMotorStopAt: confirmedMotorStopAt,
                clockTick: clockTick,
                onSetPrice: () => onSetPrice(entry),
                onPayment: () => onPayment(entry),
                onEdit: () => onEdit(entry),
                onDelete: () => onDelete(entry),
                onSharePdf: () => onSharePdf(entry),
                onPreviewPdf: () => onPreviewPdf(entry),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DeviceHeader extends StatelessWidget {
  final String deviceId;
  final int count;

  const _DeviceHeader({required this.deviceId, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.mintAccentDark],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Device Khata Ledger",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deviceId.isEmpty ? "No device selected" : deviceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray300,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white.withOpacity(0.12)),
            ),
            child: Text(
              "$count entries",
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;

  const _SearchAndFilters({
    required this.searchController,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: TextStyle(
              color: AppThemeColors.text(context),
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: "Search customer, date, device, or status",
              hintStyle: TextStyle(color: AppThemeColors.subText(context)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              filled: true,
              fillColor: AppThemeColors.input(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppThemeColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppThemeColors.border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label: "All",
                  value: "all",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  label: "Unpaid",
                  value: "unpaid",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  label: "Partial",
                  value: "partial",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
                _StatusChip(
                  label: "Paid",
                  value: "paid",
                  selectedStatus: selectedStatus,
                  onChanged: onStatusChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedStatus;
  final ValueChanged<String> onChanged;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedStatus == value;
    final selectedColor = _statusColor(value);

    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onChanged(value),
      selectedColor: selectedColor,
      backgroundColor: AppThemeColors.input(context),
      side: BorderSide(
        color: selected ? selectedColor : AppThemeColors.border(context),
      ),
      labelStyle: TextStyle(
        color: selected ? AppColors.white : AppThemeColors.text(context),
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final double totalBill;
  final double totalReceived;
  final double totalRemaining;
  final int count;

  const _SummaryGrid({
    required this.totalBill,
    required this.totalReceived,
    required this.totalRemaining,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.72 : 1.38,
          children: [
            _SummaryCard(
              label: "Entries",
              value: "$count",
              icon: Icons.receipt_long_rounded,
              accent: AppColors.primary,
            ),
            _SummaryCard(
              label: "Total Bill",
              value: _money(totalBill),
              icon: Icons.account_balance_wallet_rounded,
              accent: AppColors.info,
            ),
            _SummaryCard(
              label: "Received",
              value: _money(totalReceived),
              icon: Icons.payments_rounded,
              accent: AppColors.success,
            ),
            _SummaryCard(
              label: "Remaining",
              value: _money(totalRemaining),
              icon: Icons.warning_amber_rounded,
              accent: totalRemaining > 0 ? AppColors.error : AppColors.success,
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isVerySmall = screenWidth < 360;
    final bool isSmall = screenWidth >= 360 && screenWidth < 500;
    final bool isTablet = screenWidth >= 500 && screenWidth < 900;

    final double cardPadding = isVerySmall
        ? 8
        : isSmall
        ? 10
        : isTablet
        ? 12
        : 14;

    final double iconBoxSize = isVerySmall
        ? 30
        : isSmall
        ? 34
        : 38;

    final double iconSize = isVerySmall
        ? 17
        : isSmall
        ? 19
        : 22;

    final double labelFontSize = isVerySmall
        ? 10
        : isSmall
        ? 11
        : 12.5;

    final double valueFontSize = isVerySmall
        ? 15
        : isSmall
        ? 17
        : 20;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: iconBoxSize,
            width: iconBoxSize,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(isVerySmall ? 10 : 13),
            ),
            child: Icon(icon, color: accent, size: iconSize),
          ),

          const Spacer(),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppThemeColors.subText(context),
              fontWeight: FontWeight.w700,
              fontSize: labelFontSize,
            ),
          ),

          SizedBox(height: isVerySmall ? 3 : 5),

          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: AppThemeColors.text(context),
                  fontWeight: FontWeight.w900,
                  fontSize: valueFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhataCard extends StatelessWidget {
  final KhataEntryModel entry;
  final bool hasFreshTelemetry;
  final bool motorConfirmedRunning;
  final DateTime? confirmedMotorStopAt;
  final ValueListenable<int> clockTick;
  final VoidCallback onSetPrice;
  final VoidCallback onPayment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSharePdf;
  final VoidCallback onPreviewPdf;

  const _KhataCard({
    required this.entry,
    required this.hasFreshTelemetry,
    required this.motorConfirmedRunning,
    required this.confirmedMotorStopAt,
    required this.clockTick,
    required this.onSetPrice,
    required this.onPayment,
    required this.onEdit,
    required this.onDelete,
    required this.onSharePdf,
    required this.onPreviewPdf,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(entry.paymentStatus);
    final canAddPayment = entry.totalBill > 0 && entry.remainingBalance > 0;

    final sessionActuallyRunning =
        entry.isOpen &&
        entry.endTime == null &&
        (!hasFreshTelemetry || motorConfirmedRunning);

    final motorConfirmedOffWhileEntryOpen =
        entry.isOpen &&
        entry.endTime == null &&
        hasFreshTelemetry &&
        !motorConfirmedRunning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary.withOpacity(0.14),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.customerName.isEmpty ? "-" : entry.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppThemeColors.text(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                color: AppThemeColors.card(context),
                iconColor: AppThemeColors.subText(context),
                onSelected: (value) {
                  if (value == "edit") onEdit();
                  if (value == "delete") onDelete();
                  if (value == "preview") onPreviewPdf();
                  if (value == "share") onSharePdf();
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: "edit",
                      child: Text(
                        "Update",
                        style: TextStyle(color: AppThemeColors.text(context)),
                      ),
                    ),
                    PopupMenuItem(
                      value: "preview",
                      child: Text(
                        "Preview PDF",
                        style: TextStyle(color: AppThemeColors.text(context)),
                      ),
                    ),
                    PopupMenuItem(
                      value: "share",
                      child: Text(
                        "Share PDF",
                        style: TextStyle(color: AppThemeColors.text(context)),
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: "delete",
                      child: Text(
                        "Delete",
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (sessionActuallyRunning)
                const _StatusBadge(label: "RUNNING", color: AppColors.success),
              if (motorConfirmedOffWhileEntryOpen)
                const _StatusBadge(label: "STOPPED", color: AppColors.error),
              _StatusBadge(
                label: entry.paymentStatus.toUpperCase(),
                color: statusColor,
              ),
              _SoftBadge(
                icon: Icons.calendar_today_rounded,
                label: entry.date.isEmpty ? "-" : entry.date,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: "Device", value: entry.deviceId),
          _InfoRow(
            label: "ON Time",
            value: _formatPakistanDateTime(entry.startTime),
            strong: entry.startTime != null,
            strongColor: entry.startTime != null ? AppColors.success : null,
          ),
          _InfoRow(
            label: "OFF Time",
            value: entry.endTime == null
                ? (entry.isOpen ? "Running" : "-")
                : _formatPakistanDateTime(entry.endTime),
            strong: entry.endTime != null,
            strongColor: entry.endTime != null ? AppColors.error : null,
          ),
          if (sessionActuallyRunning)
            ValueListenableBuilder<int>(
              valueListenable: clockTick,
              builder: (context, _, __) {
                return _InfoRow(
                  label: "Running Time",
                  value: _displayRunTime(
                    entry,
                    hasFreshTelemetry: hasFreshTelemetry,
                    motorConfirmedRunning: motorConfirmedRunning,
                    confirmedMotorStopAt: confirmedMotorStopAt,
                  ),
                  strong: true,
                  strongColor: AppColors.success,
                );
              },
            )
          else
            _InfoRow(
              label: motorConfirmedOffWhileEntryOpen
                  ? "Stopped Time"
                  : "Run Hours",
              value: (entry.isOpen || entry.endTime != null)
                  ? _displayRunTime(
                      entry,
                      hasFreshTelemetry: hasFreshTelemetry,
                      motorConfirmedRunning: motorConfirmedRunning,
                      confirmedMotorStopAt: confirmedMotorStopAt,
                    )
                  : "${entry.runHours.toStringAsFixed(2)} hr",
              strong: motorConfirmedOffWhileEntryOpen,
              strongColor: motorConfirmedOffWhileEntryOpen
                  ? AppColors.error
                  : null,
            ),
          _InfoRow(label: "Price Per Hour", value: _money(entry.pricePerHour)),
          _InfoRow(label: "Total Bill", value: _money(entry.totalBill)),
          _InfoRow(label: "Cash Received", value: _money(entry.cashReceived)),
          _InfoRow(
            label: "Remaining",
            value: _money(entry.remainingBalance),
            strong: true,
            strongColor: entry.remainingBalance > 0
                ? AppColors.error
                : AppColors.success,
          ),

          // Show overpayment as customer credit/advance.
          if (entry.advanceAmount > 0)
            _InfoRow(
              label: "Advance / Credit",
              value: _money(entry.advanceAmount),
              strong: true,
              strongColor: AppColors.success,
            ),

          const SizedBox(height: 14),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: entry.pricePerHour <= 0 ? "Set Rate" : "Rate",
                      icon: Icons.calculate_rounded,
                      color: AppColors.primary,
                      textColor: AppColors.black,
                      filled: true,
                      onTap: onSetPrice,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: "Add Payment",
                      icon: Icons.add_card_rounded,
                      color: AppColors.green,
                      textColor: AppColors.white,
                      filled: true,
                      onTap: canAddPayment ? onPayment : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "Update",
                      icon: Icons.edit_rounded,
                      color: AppColors.primary,
                      textColor: AppColors.primary,
                      filled: false,
                      onTap: onEdit,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: "Delete",
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.error,
                      textColor: AppColors.error,
                      filled: false,
                      onTap: onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SoftBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppThemeColors.input(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppThemeColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppThemeColors.subText(context)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: AppThemeColors.subText(context),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return SizedBox(
      height: 44,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 17),
              label: FittedBox(child: Text(label)),
              style: ElevatedButton.styleFrom(
                backgroundColor: enabled ? color : AppColors.disabledDark,
                foregroundColor: enabled ? textColor : AppColors.gray500,
                disabledBackgroundColor: AppColors.disabledDark,
                disabledForegroundColor: AppColors.gray500,
                elevation: enabled ? 4 : 0,
                shadowColor: color.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 17),
              label: FittedBox(child: Text(label)),
              style: OutlinedButton.styleFrom(
                foregroundColor: enabled ? textColor : AppColors.gray500,
                side: BorderSide(
                  color: enabled ? color.withOpacity(0.55) : AppColors.gray600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  final Color? strongColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.strongColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppThemeColors.subText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: strong
                    ? (strongColor ?? AppColors.primary)
                    : AppThemeColors.text(context),
                fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhataBottomSheet extends StatelessWidget {
  final double bottom;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _KhataBottomSheet({
    required this.bottom,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeColors.card(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppThemeColors.border(context))),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppThemeColors.border(context),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeColors.text(context),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppThemeColors.subText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppThemeColors.text(context),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppThemeColors.subText(context)),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppThemeColors.input(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppThemeColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppThemeColors.border(context)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _PrimarySheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? foregroundColor;

  const _PrimarySheetButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    final fg = foregroundColor ?? AppColors.black;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 4,
          shadowColor: bg.withOpacity(0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _EmptyKhata extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyKhata({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: AppThemeColors.cardDecoration(context),
      child: Column(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.text(context),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppThemeColors.subText(context),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillInput {
  final double pricePerHour;
  final double cashReceived;

  const _BillInput({required this.pricePerHour, required this.cashReceived});
}

Color _statusColor(String value) {
  switch (value.toLowerCase()) {
    case "paid":
      return AppColors.success;
    case "partial":
      return AppColors.warning;
    case "all":
      return AppColors.primary;
    default:
      return AppColors.error;
  }
}

String _paymentStatus({
  required double cashReceived,
  required double totalBill,
}) {
  if (totalBill <= 0) return "unpaid";
  if (cashReceived >= totalBill) return "paid";
  if (cashReceived > 0) return "partial";
  return "unpaid";
}

String _displayRunTime(
  KhataEntryModel entry, {
  required bool hasFreshTelemetry,
  required bool motorConfirmedRunning,
  required DateTime? confirmedMotorStopAt,
}) {
  final startTime = entry.startTime;

  if (startTime == null) {
    final totalSeconds = (entry.runHours * 3600).round();
    return _formatDuration(totalSeconds < 0 ? 0 : totalSeconds);
  }

  // Persisted backend/database endTime is always authoritative.
  // Duration math uses UTC instants so Pakistan display conversion does
  // not change the real elapsed duration.
  if (entry.endTime != null) {
    final seconds = entry.endTime!
        .toUtc()
        .difference(startTime.toUtc())
        .inSeconds;

    return _formatDuration(seconds < 0 ? 0 : seconds);
  }

  if (entry.isOpen) {
    // If VFD is confirmed OFF but the server endTime has not arrived yet,
    // do not invent an OFF timestamp from the phone. Keep the last visible
    // value frozen until loadEntries() receives the saved database endTime.
    if (hasFreshTelemetry && !motorConfirmedRunning) {
      return "Waiting for server...";
    }

    // The session always starts from the original SERVER/DATABASE startTime.
    // If the app is killed and reopened, this recomputes from the same
    // startTime instead of restarting the Khata timer from zero.
    final seconds = DateTime.now()
        .toUtc()
        .difference(startTime.toUtc())
        .inSeconds;

    return _formatDuration(seconds < 0 ? 0 : seconds);
  }

  final totalSeconds = (entry.runHours * 3600).round();
  return _formatDuration(totalSeconds < 0 ? 0 : totalSeconds);
}

DateTime _toPakistanTime(DateTime value) {
  return value.toUtc().add(const Duration(hours: 5));
}

String _formatPakistanDateTime(DateTime? value) {
  if (value == null) return "-";

  final pakistanTime = _toPakistanTime(value);

  final year = pakistanTime.year.toString().padLeft(4, "0");
  final month = pakistanTime.month.toString().padLeft(2, "0");
  final day = pakistanTime.day.toString().padLeft(2, "0");

  final hour24 = pakistanTime.hour;
  final hour12 = hour24 == 0
      ? 12
      : hour24 > 12
      ? hour24 - 12
      : hour24;

  final hour = hour12.toString().padLeft(2, "0");
  final minute = pakistanTime.minute.toString().padLeft(2, "0");
  final second = pakistanTime.second.toString().padLeft(2, "0");
  final period = hour24 >= 12 ? "PM" : "AM";

  return "$year-$month-$day  $hour:$minute:$second $period PKT";
}

String _formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  return "${hours.toString().padLeft(2, "0")}:"
      "${minutes.toString().padLeft(2, "0")}:"
      "${seconds.toString().padLeft(2, "0")}";
}

String _money(double value) {
  return value.toStringAsFixed(2);
}
