//
//
// import "package:flutter/material.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
//
// import "../../data/models/schedule_model.dart";
// import "../providers/schedule_providers.dart";
// import "../state/schedule_state.dart";
//
// import "package:flutter/material.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
// import "package:smart_iot_app/src/core/constant/app_color.dart";
//
// import "../../data/models/schedule_model.dart";
// import "../providers/schedule_providers.dart";
// import "../state/schedule_state.dart";
//
// class ScheduleScreen extends ConsumerStatefulWidget {
//   final String deviceId;
//
//   const ScheduleScreen({
//     super.key,
//     required this.deviceId,
//   });
//
//   @override
//   ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
// }
//
// class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
//   static final List<String> _dayKeys = List.generate(
//     31,
//         (index) => "${index + 1}",
//   );
//
//   late Map<String, _EditableDay> _days;
//
//   bool _scheduleEnabled = false;
//   bool _isSynced = false;
//   bool _appliedLoadedSchedule = false;
//   String _selectedDay = "1";
//
//   @override
//   void initState() {
//     super.initState();
//     _days = _defaultDays();
//
//     Future.microtask(() {
//       if (widget.deviceId.trim().isEmpty) {
//         _showSnack(
//           message: "Device ID missing. Please open schedule from a device.",
//           success: false,
//         );
//         return;
//       }
//
//       ref.read(scheduleViewModelProvider.notifier).loadSchedule(widget.deviceId);
//     });
//   }
//
//   Map<String, _EditableDay> _defaultDays() {
//     return {
//       for (final day in _dayKeys)
//         day: const _EditableDay(
//           enabled: false,
//           slots: [],
//         ),
//     };
//   }
//
//   bool _isNoScheduleMessage(String value) {
//     final text = value.toLowerCase();
//
//     return text.contains("no schedule") ||
//         text.contains("schedule not found") ||
//         text.contains("not found") ||
//         text.contains("404");
//   }
//
//   String _dayLabel(String day) => day.padLeft(2, "0");
//
//   String _dayFullName(String day) => "Day $day";
//
//   void _applySchedule(ScheduleModel schedule) {
//     final loadedDays = _defaultDays();
//
//     for (final savedDay in schedule.weeklyDays) {
//       final dayKey = savedDay.day;
//
//       if (!loadedDays.containsKey(dayKey)) continue;
//
//       loadedDays[dayKey] = _EditableDay(
//         enabled: savedDay.enabled,
//         slots: savedDay.slots,
//       );
//     }
//
//     final firstEnabled = loadedDays.entries
//         .where((entry) => entry.value.enabled)
//         .map((entry) => entry.key)
//         .firstOrNull;
//
//     setState(() {
//       _scheduleEnabled = schedule.enabled && _hasSelectedDays(loadedDays);
//       _days = loadedDays;
//       _selectedDay = firstEnabled ?? "1";
//       _appliedLoadedSchedule = true;
//       _isSynced = true;
//     });
//   }
//
//   bool _hasSelectedDays(Map<String, _EditableDay> days) {
//     return days.values.any((day) => day.enabled);
//   }
//
//   void _showSnack({
//     required String message,
//     required bool success,
//   }) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).clearSnackBars();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: success ? AppColors.mintAccent : AppColors.error,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         content: Text(
//           message,
//           style: TextStyle(
//             color: success ? AppColors.mintAccentDark : AppColors.white,
//             fontWeight: FontWeight.w800,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _selectTime({
//     required String day,
//     required int index,
//     required bool isStart,
//   }) async {
//     final slot = _days[day]!.slots[index];
//
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _parseTime(isStart ? slot.startTime : slot.endTime),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.dark().copyWith(
//             scaffoldBackgroundColor: AppColors.darkBgSoft,
//             dialogBackgroundColor: AppColors.darkSurfaceSoft,
//             colorScheme: const ColorScheme.dark(
//               primary: AppColors.mintAccent,
//               surface: AppColors.darkSurfaceSoft,
//               onSurface: AppColors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked == null) return;
//
//     final formatted = _formatForApi(picked);
//
//     setState(() {
//       final editableDay = _days[day]!;
//       final slots = List<ScheduleSlot>.from(editableDay.slots);
//       final oldSlot = slots[index];
//
//       slots[index] = oldSlot.copyWith(
//         startTime: isStart ? formatted : oldSlot.startTime,
//         endTime: isStart ? oldSlot.endTime : formatted,
//       );
//
//       _days[day] = editableDay.copyWith(slots: slots);
//       _scheduleEnabled = true;
//       _isSynced = false;
//     });
//   }
//
//   void _toggleCalendarDay(String day) {
//     setState(() {
//       _selectedDay = day;
//
//       final current = _days[day]!;
//       final nextEnabled = !current.enabled;
//
//       _days[day] = current.copyWith(
//         enabled: nextEnabled,
//         slots: nextEnabled && current.slots.isEmpty
//             ? const [
//           ScheduleSlot(
//             startTime: "09:00",
//             endTime: "12:00",
//           ),
//         ]
//             : current.slots,
//       );
//
//       _scheduleEnabled = _enabledDayCount > 0 || nextEnabled;
//       _isSynced = false;
//     });
//   }
//
//   void _addSlot() {
//     setState(() {
//       final editableDay = _days[_selectedDay]!;
//       final slots = List<ScheduleSlot>.from(editableDay.slots);
//
//       slots.add(
//         const ScheduleSlot(
//           startTime: "09:00",
//           endTime: "12:00",
//         ),
//       );
//
//       _days[_selectedDay] = editableDay.copyWith(
//         enabled: true,
//         slots: slots,
//       );
//
//       _scheduleEnabled = true;
//       _isSynced = false;
//     });
//   }
//
//   void _removeSlot(int index) {
//     setState(() {
//       final editableDay = _days[_selectedDay]!;
//       final slots = List<ScheduleSlot>.from(editableDay.slots);
//
//       slots.removeAt(index);
//
//       _days[_selectedDay] = editableDay.copyWith(slots: slots);
//       _scheduleEnabled = _enabledDayCount > 0;
//       _isSynced = false;
//     });
//   }
//
//   void _toggleSelectedDay(bool enabled) {
//     setState(() {
//       final editableDay = _days[_selectedDay]!;
//
//       _days[_selectedDay] = editableDay.copyWith(
//         enabled: enabled,
//         slots: enabled && editableDay.slots.isEmpty
//             ? const [
//           ScheduleSlot(
//             startTime: "09:00",
//             endTime: "12:00",
//           ),
//         ]
//             : editableDay.slots,
//       );
//
//       _scheduleEnabled = enabled || _enabledDayCount > 0;
//       _isSynced = false;
//     });
//   }
//
//   Future<void> _saveSchedule() async {
//     if (widget.deviceId.trim().isEmpty) {
//       _showSnack(
//         message: "Device ID missing. Please open schedule from a device.",
//         success: false,
//       );
//       return;
//     }
//
//     final validationError = _validateSchedule();
//
//     if (validationError != null) {
//       _showSnack(
//         message: validationError,
//         success: false,
//       );
//       return;
//     }
//
//     final hasSelectedDays = _enabledDayCount > 0;
//     final finalScheduleEnabled = _scheduleEnabled && hasSelectedDays;
//
//     final days = _dayKeys.map((day) {
//       final editableDay = _days[day]!;
//       final enabled = finalScheduleEnabled && editableDay.enabled;
//
//       return ScheduleDayConfig(
//         day: day,
//         enabled: enabled,
//         slots: enabled ? editableDay.slots : <ScheduleSlot>[],
//       );
//     }).toList();
//
//     final schedule = ScheduleModel.weekly(
//       deviceId: widget.deviceId,
//       days: days,
//       enabled: finalScheduleEnabled,
//       timezone: "Asia/Karachi",
//       scheduleName: "Monthly Motor Irrigation Schedule",
//     );
//
//     await ref.read(scheduleViewModelProvider.notifier).saveSchedule(schedule);
//
//     final state = ref.read(scheduleViewModelProvider);
//
//     if (state.error == null) {
//       setState(() {
//         _scheduleEnabled = finalScheduleEnabled;
//         _isSynced = true;
//       });
//
//       if (!hasSelectedDays) {
//         _showSnack(
//           message: "No schedule selected. Automation is off for this device.",
//           success: true,
//         );
//       }
//     }
//   }
//
//   Future<void> _deleteSchedule() async {
//     if (widget.deviceId.trim().isEmpty) {
//       _showSnack(
//         message: "Device ID missing. Cannot delete schedule.",
//         success: false,
//       );
//       return;
//     }
//
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: AppColors.darkSurfaceSoft,
//           title: const Text(
//             "Delete schedule?",
//             style: TextStyle(color: AppColors.white),
//           ),
//           content: const Text(
//             "This will remove the saved automation schedule for this device.",
//             style: TextStyle(color: AppColors.textMutedSoft),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text(
//                 "Cancel",
//                 style: TextStyle(color: AppColors.textMutedSoft),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.error,
//                 foregroundColor: AppColors.white,
//               ),
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirmed != true) return;
//
//     await ref
//         .read(scheduleViewModelProvider.notifier)
//         .deleteSchedule(widget.deviceId);
//
//     final state = ref.read(scheduleViewModelProvider);
//
//     if (state.error == null) {
//       setState(() {
//         _days = _defaultDays();
//         _scheduleEnabled = false;
//         _selectedDay = "1";
//         _isSynced = true;
//         _appliedLoadedSchedule = false;
//       });
//     }
//   }
//
//   Future<void> _refreshSchedule() async {
//     if (widget.deviceId.trim().isEmpty) {
//       _showSnack(
//         message: "Device ID missing. Cannot refresh schedule.",
//         success: false,
//       );
//       return;
//     }
//
//     _appliedLoadedSchedule = false;
//
//     await ref
//         .read(scheduleViewModelProvider.notifier)
//         .loadSchedule(widget.deviceId);
//   }
//
//   void _setFullMonthPreset() {
//     setState(() {
//       for (final day in _dayKeys) {
//         final current = _days[day]!;
//
//         _days[day] = current.copyWith(
//           enabled: true,
//           slots: current.slots.isEmpty
//               ? const [
//             ScheduleSlot(
//               startTime: "09:00",
//               endTime: "12:00",
//             ),
//           ]
//               : current.slots,
//         );
//       }
//
//       _selectedDay = "1";
//       _scheduleEnabled = true;
//       _isSynced = false;
//     });
//   }
//
//   void _clearAllDays() {
//     setState(() {
//       _days = _defaultDays();
//       _selectedDay = "1";
//       _scheduleEnabled = false;
//       _isSynced = false;
//     });
//   }
//
//   void _resetSchedule() {
//     _clearAllDays();
//   }
//
//   String? _validateSchedule() {
//     final enabledDays = _days.entries.where((entry) => entry.value.enabled);
//
//     if (enabledDays.isEmpty) {
//       return null;
//     }
//
//     for (final entry in enabledDays) {
//       final fullName = _dayFullName(entry.key);
//       final slots = entry.value.slots;
//
//       if (slots.isEmpty) {
//         return "Add at least one time slot for $fullName.";
//       }
//
//       for (final slot in slots) {
//         if (!slot.isValid) {
//           return "$fullName has an invalid time slot.";
//         }
//       }
//     }
//
//     return null;
//   }
//
//   TimeOfDay _parseTime(String value) {
//     final parts = value.split(":");
//
//     if (parts.length < 2) {
//       return const TimeOfDay(hour: 9, minute: 0);
//     }
//
//     return TimeOfDay(
//       hour: int.tryParse(parts[0]) ?? 9,
//       minute: int.tryParse(parts[1]) ?? 0,
//     );
//   }
//
//   String _formatForApi(TimeOfDay time) {
//     return "${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}";
//   }
//
//   int get _enabledDayCount {
//     return _days.values.where((day) => day.enabled).length;
//   }
//
//   int get _slotCount {
//     return _days.values.fold<int>(
//       0,
//           (total, day) => total + (day.enabled ? day.slots.length : 0),
//     );
//   }
//
//   String get _selectedDayTitle => _dayFullName(_selectedDay);
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<ScheduleState>(
//       scheduleViewModelProvider,
//           (ScheduleState? previous, ScheduleState next) {
//         final error = next.error;
//         final message = next.message;
//         final schedule = next.schedule;
//
//         if (error != null && previous?.error != error) {
//           if (_isNoScheduleMessage(error)) {
//             setState(() {
//               _days = _defaultDays();
//               _scheduleEnabled = false;
//               _selectedDay = "1";
//               _isSynced = true;
//               _appliedLoadedSchedule = true;
//             });
//             return;
//           }
//
//           _showSnack(message: error, success: false);
//         }
//
//         if (message != null && previous?.message != message) {
//           _showSnack(message: message, success: true);
//         }
//
//         if (!_appliedLoadedSchedule && schedule != null) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!mounted) return;
//             _applySchedule(schedule);
//           });
//         }
//       },
//     );
//
//     final state = ref.watch(scheduleViewModelProvider);
//     final size = MediaQuery.of(context).size;
//     final horizontalPadding = size.width < 420 ? 16.0 : size.width * 0.05;
//     final maxButtonWidth = size.width >= 650 ? 620.0 : size.width * 0.92;
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryDark,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: AppColors.white),
//         title: const Column(
//           children: [
//             Text(
//               "Motor Schedule",
//               style: TextStyle(
//                 color: AppColors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             SizedBox(height: 2),
//             Text(
//               "Monthly Automation",
//               style: TextStyle(
//                 color: AppColors.mintAccent,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.8,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             tooltip: "Refresh schedule",
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: state.isLoading ? null : _refreshSchedule,
//           ),
//           IconButton(
//             tooltip: "Delete schedule",
//             icon: const Icon(
//               Icons.delete_sweep_rounded,
//               color: AppColors.error,
//             ),
//             onPressed: state.isLoading ? null : _deleteSchedule,
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: AppColors.mintAccent,
//           backgroundColor: AppColors.darkSurfaceSoft,
//           onRefresh: _refreshSchedule,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(
//               parent: BouncingScrollPhysics(),
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: horizontalPadding,
//               vertical: 20,
//             ),
//             child: Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 920),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _ScheduleStatusHeader(
//                       isSynced: _isSynced,
//                       isEnabled: _scheduleEnabled,
//                       activeDays: _enabledDayCount,
//                       slotCount: _slotCount,
//                       deviceId: widget.deviceId,
//                     ),
//                     const SizedBox(height: 18),
//                     _buildScheduleModeCard(),
//                     const SizedBox(height: 18),
//                     _buildPresetRow(),
//                     const SizedBox(height: 22),
//                     _sectionHeader(
//                       "Operational Calendar",
//                       Icons.calendar_month_rounded,
//                       trailing: "$_enabledDayCount days active",
//                     ),
//                     _buildDayGrid(),
//                     const SizedBox(height: 22),
//                     _sectionHeader(
//                       "On/Off Schedule",
//                       Icons.more_time_rounded,
//                       trailing: _selectedDayTitle,
//                     ),
//                     _buildSelectedDaySchedule(),
//                     _addPulseButton(),
//                     const SizedBox(height: 120),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: SizedBox(
//         width: maxButtonWidth,
//         height: 58,
//         child: ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primaryDark,
//             foregroundColor: AppColors.white,
//             elevation: 0,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(18),
//             ),
//           ),
//           onPressed: state.isLoading ? null : _saveSchedule,
//           icon: state.isLoading
//               ? const SizedBox(
//             width: 22,
//             height: 22,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: AppColors.white,
//             ),
//           )
//               : const Icon(Icons.bolt_rounded),
//           label: Text(
//             state.isLoading ? "Saving Schedule" : "Apply Schedule",
//             style: const TextStyle(
//               fontWeight: FontWeight.w900,
//               fontSize: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildScheduleModeCard() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.darkCardSoft,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.darkBorderSoft),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             _scheduleEnabled
//                 ? Icons.play_circle_fill_rounded
//                 : Icons.pause_circle_filled_rounded,
//             color: _scheduleEnabled
//                 ? AppColors.mintAccent
//                 : AppColors.textMutedSoft,
//             size: 34,
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               _scheduleEnabled
//                   ? "Automation active"
//                   : "No schedule selected",
//               style: const TextStyle(
//                 color: AppColors.white,
//                 fontSize: 17,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),
//           Switch(
//             value: _scheduleEnabled,
//             activeColor: AppColors.mintAccent,
//             inactiveTrackColor: AppColors.gray800,
//             onChanged: (value) {
//               setState(() {
//                 _scheduleEnabled = value && _enabledDayCount > 0;
//                 _isSynced = false;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPresetRow() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: AppColors.darkSurfaceSoft,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.darkBorderSoft),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: _presetButton(
//               label: "Full Month",
//               icon: Icons.calendar_month_rounded,
//               onTap: _setFullMonthPreset,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: _presetButton(
//               label: "Clear",
//               icon: Icons.clear_all_rounded,
//               onTap: _clearAllDays,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: _presetButton(
//               label: "Reset",
//               icon: Icons.restart_alt_rounded,
//               onTap: _resetSchedule,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _presetButton({
//     required String label,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return OutlinedButton.icon(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.mintAccent,
//         side: const BorderSide(color: AppColors.mintAccent),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(14),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
//       ),
//       onPressed: onTap,
//       icon: Icon(icon, size: 17),
//       label: FittedBox(
//         child: Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w900,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDayGrid() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//
//         final crossAxisCount = width < 330
//             ? 4
//             : width < 390
//             ? 5
//             : 7;
//
//         return Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: AppColors.darkSurfaceSoft,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: AppColors.darkBorderSoft),
//           ),
//           child: GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 1.05,
//             ),
//             itemCount: _dayKeys.length,
//             itemBuilder: (context, index) {
//               final day = _dayKeys[index];
//               final isSelected = _selectedDay == day;
//               final isEnabled = _days[day]?.enabled ?? false;
//
//               return InkWell(
//                 borderRadius: BorderRadius.circular(14),
//                 onTap: () => _toggleCalendarDay(day),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 180),
//                   decoration: BoxDecoration(
//                     color: isEnabled
//                         ? AppColors.mintAccent
//                         : AppColors.gray900,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: isSelected
//                           ? AppColors.white
//                           : AppColors.darkBorderSoft,
//                       width: isSelected ? 2 : 1,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _dayLabel(day),
//                       style: TextStyle(
//                         color: isEnabled
//                             ? AppColors.mintAccentDark
//                             : AppColors.offWhite,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildSelectedDaySchedule() {
//     final editableDay = _days[_selectedDay]!;
//     final slots = editableDay.slots;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.darkCardSoft,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.darkBorderSoft),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 46,
//                 height: 46,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: AppColors.mintAccent.withOpacity(0.14),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Text(
//                   _dayLabel(_selectedDay),
//                   style: const TextStyle(
//                     color: AppColors.mintAccent,
//                     fontWeight: FontWeight.w900,
//                     fontSize: 13,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   _selectedDayTitle,
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ),
//               Switch(
//                 value: editableDay.enabled,
//                 activeColor: AppColors.mintAccent,
//                 inactiveTrackColor: AppColors.gray800,
//                 onChanged: _toggleSelectedDay,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (!editableDay.enabled)
//             _emptyStateBox(
//               icon: Icons.pause_circle_outline_rounded,
//               text: "This date is disabled.",
//             )
//           else if (slots.isEmpty)
//             _emptyStateBox(
//               icon: Icons.more_time_rounded,
//               text: "No time slot added for this date.",
//             )
//           else
//             _buildPulseList(slots),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPulseList(List<ScheduleSlot> slots) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: slots.length,
//       itemBuilder: (context, index) {
//         final slot = slots[index];
//         final isValid = slot.isValid;
//
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: AppColors.darkSurfaceSoft,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isValid
//                   ? AppColors.darkBorderSoft
//                   : AppColors.error,
//             ),
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: _timePickerAction(
//                       "Start",
//                       _parseTime(slot.startTime),
//                           () => _selectTime(
//                         day: _selectedDay,
//                         index: index,
//                         isStart: true,
//                       ),
//                     ),
//                   ),
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8),
//                     child: Icon(
//                       Icons.sync_alt_rounded,
//                       color: AppColors.textMutedSoft,
//                     ),
//                   ),
//                   Expanded(
//                     child: _timePickerAction(
//                       "Stop",
//                       _parseTime(slot.endTime),
//                           () => _selectTime(
//                         day: _selectedDay,
//                         index: index,
//                         isStart: false,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.remove_circle_outline,
//                       color: AppColors.error,
//                     ),
//                     onPressed: () => _removeSlot(index),
//                   ),
//                 ],
//               ),
//               if (!isValid) ...[
//                 const SizedBox(height: 8),
//                 const Text(
//                   "Start time must be earlier than stop time.",
//                   style: TextStyle(
//                     color: AppColors.error,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _timePickerAction(
//       String label,
//       TimeOfDay time,
//       VoidCallback onTap,
//       ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         decoration: BoxDecoration(
//           color: AppColors.gray900,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.darkBorderSoft),
//         ),
//         child: Column(
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 color: AppColors.textMutedSoft,
//                 fontSize: 10,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 5),
//             FittedBox(
//               child: Text(
//                 time.format(context),
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: AppColors.white,
//                   fontSize: 17,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _addPulseButton() {
//     final enabled = _days[_selectedDay]?.enabled ?? false;
//
//     return Padding(
//       padding: const EdgeInsets.only(top: 12),
//       child: OutlinedButton.icon(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.mintAccent,
//           disabledForegroundColor: AppColors.textMutedSoft,
//           side: BorderSide(
//             color: enabled
//                 ? AppColors.mintAccent
//                 : AppColors.darkBorderSoft,
//           ),
//           minimumSize: const Size(double.infinity, 52),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         onPressed: enabled ? _addSlot : null,
//         icon: const Icon(Icons.add),
//         label: const Text(
//           "Add Time Slot",
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//     );
//   }
//
//   Widget _sectionHeader(
//       String title,
//       IconData icon, {
//         String? trailing,
//       }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 17, color: AppColors.mintAccent),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: AppColors.textMutedSoft,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//             ],
//           ),
//           if (trailing != null)
//             Text(
//               trailing,
//               style: const TextStyle(
//                 color: AppColors.mintAccent,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _emptyStateBox({
//     required IconData icon,
//     required String text,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.darkSurfaceSoft,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppColors.darkBorderSoft),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: AppColors.textMutedSoft),
//           const SizedBox(height: 8),
//           Text(
//             text,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: AppColors.textMutedSoft,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ScheduleStatusHeader extends StatelessWidget {
//   final bool isSynced;
//   final bool isEnabled;
//   final int activeDays;
//   final int slotCount;
//   final String deviceId;
//
//   const _ScheduleStatusHeader({
//     required this.isSynced,
//     required this.isEnabled,
//     required this.activeDays,
//     required this.slotCount,
//     required this.deviceId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.darkCardSoft,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: AppColors.darkBorderSoft),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               _HeaderMetric(
//                 title: "Status",
//                 value: isEnabled ? "Active" : "Off",
//                 icon: isEnabled
//                     ? Icons.check_circle_rounded
//                     : Icons.pause_circle_filled_rounded,
//                 color: isEnabled ? AppColors.green : AppColors.textMutedSoft,
//               ),
//               const SizedBox(width: 10),
//               _HeaderMetric(
//                 title: "Sync",
//                 value: isSynced ? "Saved" : "Pending",
//                 icon: isSynced
//                     ? Icons.cloud_done_rounded
//                     : Icons.cloud_upload_rounded,
//                 color: isSynced ? AppColors.green : AppColors.mintAccent,
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               _HeaderMetric(
//                 title: "Days",
//                 value: "$activeDays",
//                 icon: Icons.calendar_today_rounded,
//                 color: AppColors.mintAccent,
//               ),
//               const SizedBox(width: 10),
//               _HeaderMetric(
//                 title: "Slots",
//                 value: "$slotCount",
//                 icon: Icons.more_time_rounded,
//                 color: AppColors.mintAccent,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             decoration: BoxDecoration(
//               color: AppColors.darkSurfaceSoft,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: AppColors.darkBorderSoft),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.memory_rounded,
//                   size: 17,
//                   color: AppColors.mintAccent,
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     deviceId.trim().isEmpty
//                         ? "Device ID not available"
//                         : "Device: $deviceId",
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: AppColors.textMutedSoft,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                     ),
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
// class _HeaderMetric extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;
//
//   const _HeaderMetric({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(13),
//         decoration: BoxDecoration(
//           color: AppColors.darkSurfaceSoft,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColors.darkBorderSoft),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 21),
//             const SizedBox(width: 9),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: AppColors.textMutedSoft,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       value,
//                       style: const TextStyle(
//                         color: AppColors.white,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _EditableDay {
//   final bool enabled;
//   final List<ScheduleSlot> slots;
//
//   const _EditableDay({
//     required this.enabled,
//     required this.slots,
//   });
//
//   _EditableDay copyWith({
//     bool? enabled,
//     List<ScheduleSlot>? slots,
//   }) {
//     return _EditableDay(
//       enabled: enabled ?? this.enabled,
//       slots: slots ?? this.slots,
//     );
//   }
// }
//
// extension _FirstOrNullExtension<T> on Iterable<T> {
//   T? get firstOrNull {
//     final iterator = this.iterator;
//
//     if (iterator.moveNext()) {
//       return iterator.current;
//     }
//
//     return null;
//   }
// }

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

import "../../data/models/schedule_model.dart";
import "../providers/schedule_providers.dart";
import "../state/schedule_state.dart";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smart_iot_app/src/core/constant/app_color.dart";

import "../../data/models/schedule_model.dart";
import "../providers/schedule_providers.dart";
import "../state/schedule_state.dart";

class ScheduleScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const ScheduleScreen({super.key, required this.deviceId});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  static final List<String> _dayKeys = List.generate(
    31,
    (index) => "${index + 1}",
  );

  late Map<String, _EditableDay> _days;

  bool _scheduleEnabled = false;
  bool _isSynced = false;
  bool _appliedLoadedSchedule = false;
  String _selectedDay = "1";

  @override
  void initState() {
    super.initState();
    _days = _defaultDays();

    Future.microtask(() {
      if (widget.deviceId.trim().isEmpty) {
        _showSnack(
          message: "Device ID missing. Please open schedule from a device.",
          success: false,
        );
        return;
      }

      ref
          .read(scheduleViewModelProvider.notifier)
          .loadSchedule(widget.deviceId);
    });
  }

  Map<String, _EditableDay> _defaultDays() {
    return {
      for (final day in _dayKeys)
        day: const _EditableDay(enabled: false, slots: []),
    };
  }

  bool _isNoScheduleMessage(String value) {
    final text = value.toLowerCase();

    return text.contains("no schedule") ||
        text.contains("schedule not found") ||
        text.contains("not found") ||
        text.contains("404");
  }

  String _dayLabel(String day) => day.padLeft(2, "0");

  String _dayFullName(String day) => "Day $day";

  void _applySchedule(ScheduleModel schedule) {
    final loadedDays = _defaultDays();

    // ---------------------------------------------------------------
    // NEW / CORRECT MONTHLY FORMAT
    //
    // Backend expects:
    // pattern.days = {
    //   "1":  [{"start_time":"09:00","end_time":"12:00"}],
    //   "15": [{"start_time":"14:00","end_time":"15:00"}]
    // }
    // ---------------------------------------------------------------
    final rawSchedule = schedule.toJson();
    final rawPattern = rawSchedule["pattern"];

    bool loadedMonthlyCustom = false;

    if (rawPattern is Map) {
      final pattern = Map<String, dynamic>.from(rawPattern);
      final rawDays = pattern["days"];

      if (rawDays is Map) {
        for (final entry in rawDays.entries) {
          final dayKey = entry.key.toString();

          if (!loadedDays.containsKey(dayKey)) {
            continue;
          }

          final rawSlots = entry.value;
          final slots = <ScheduleSlot>[];

          if (rawSlots is List) {
            for (final rawSlot in rawSlots) {
              if (rawSlot is! Map) continue;

              final slotMap = Map<String, dynamic>.from(rawSlot);

              final startTime = (slotMap["start_time"] ?? slotMap["startTime"])
                  ?.toString()
                  .trim();

              final endTime = (slotMap["end_time"] ?? slotMap["endTime"])
                  ?.toString()
                  .trim();

              if (startTime == null ||
                  startTime.isEmpty ||
                  endTime == null ||
                  endTime.isEmpty) {
                continue;
              }

              slots.add(ScheduleSlot(startTime: startTime, endTime: endTime));
            }
          }

          loadedDays[dayKey] = _EditableDay(
            enabled: slots.isNotEmpty,
            slots: slots,
          );

          if (slots.isNotEmpty) {
            loadedMonthlyCustom = true;
          }
        }
      }
    }

    // ---------------------------------------------------------------
    // LEGACY FALLBACK
    // Keep support for schedules previously saved through weeklyDays.
    // ---------------------------------------------------------------
    if (!loadedMonthlyCustom) {
      for (final savedDay in schedule.weeklyDays) {
        final dayKey = savedDay.day;

        if (!loadedDays.containsKey(dayKey)) continue;

        loadedDays[dayKey] = _EditableDay(
          enabled: savedDay.enabled,
          slots: savedDay.slots,
        );
      }
    }

    final firstEnabled = loadedDays.entries
        .where((entry) => entry.value.enabled)
        .map((entry) => entry.key)
        .firstOrNull;

    setState(() {
      _scheduleEnabled = schedule.enabled && _hasSelectedDays(loadedDays);
      _days = loadedDays;
      _selectedDay = firstEnabled ?? "1";
      _appliedLoadedSchedule = true;
      _isSynced = true;
    });
  }

  bool _hasSelectedDays(Map<String, _EditableDay> days) {
    return days.values.any((day) => day.enabled);
  }

  void _showSnack({required String message, required bool success}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? AppColors.mintAccent : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          message,
          style: TextStyle(
            color: success ? AppColors.mintAccentDark : AppColors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime({
    required String day,
    required int index,
    required bool isStart,
  }) async {
    final slot = _days[day]!.slots[index];

    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(isStart ? slot.startTime : slot.endTime),
      builder: (context, child) {
        // Always show AM / PM in the schedule picker.
        // Internally TimeOfDay still keeps the correct 24-hour value
        // for the backend (e.g. 1:00 PM -> 13:00).
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: AppColors.darkBgSoft,
              dialogBackgroundColor: AppColors.darkSurfaceSoft,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.mintAccent,
                surface: AppColors.darkSurfaceSoft,
                onSurface: AppColors.white,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked == null) return;

    final formatted = _formatForApi(picked);

    setState(() {
      final editableDay = _days[day]!;
      final slots = List<ScheduleSlot>.from(editableDay.slots);
      final oldSlot = slots[index];

      slots[index] = oldSlot.copyWith(
        startTime: isStart ? formatted : oldSlot.startTime,
        endTime: isStart ? oldSlot.endTime : formatted,
      );

      _days[day] = editableDay.copyWith(slots: slots);
      _scheduleEnabled = true;
      _isSynced = false;
    });
  }

  void _toggleCalendarDay(String day) {
    setState(() {
      _selectedDay = day;

      final current = _days[day]!;
      final nextEnabled = !current.enabled;

      _days[day] = current.copyWith(
        enabled: nextEnabled,
        slots: nextEnabled && current.slots.isEmpty
            ? const [ScheduleSlot(startTime: "09:00", endTime: "12:00")]
            : current.slots,
      );

      _scheduleEnabled = _enabledDayCount > 0 || nextEnabled;
      _isSynced = false;
    });
  }

  void _addSlot() {
    setState(() {
      final editableDay = _days[_selectedDay]!;
      final slots = List<ScheduleSlot>.from(editableDay.slots);

      slots.add(const ScheduleSlot(startTime: "09:00", endTime: "12:00"));

      _days[_selectedDay] = editableDay.copyWith(enabled: true, slots: slots);

      _scheduleEnabled = true;
      _isSynced = false;
    });
  }

  void _removeSlot(int index) {
    setState(() {
      final editableDay = _days[_selectedDay]!;
      final slots = List<ScheduleSlot>.from(editableDay.slots);

      slots.removeAt(index);

      _days[_selectedDay] = editableDay.copyWith(slots: slots);
      _scheduleEnabled = _enabledDayCount > 0;
      _isSynced = false;
    });
  }

  void _toggleSelectedDay(bool enabled) {
    setState(() {
      final editableDay = _days[_selectedDay]!;

      _days[_selectedDay] = editableDay.copyWith(
        enabled: enabled,
        slots: enabled && editableDay.slots.isEmpty
            ? const [ScheduleSlot(startTime: "09:00", endTime: "12:00")]
            : editableDay.slots,
      );

      _scheduleEnabled = enabled || _enabledDayCount > 0;
      _isSynced = false;
    });
  }

  Future<void> _saveSchedule() async {
    if (widget.deviceId.trim().isEmpty) {
      _showSnack(
        message: "Device ID missing. Please open schedule from a device.",
        success: false,
      );
      return;
    }

    final validationError = _validateSchedule();

    if (validationError != null) {
      _showSnack(message: validationError, success: false);
      return;
    }

    final hasSelectedDays = _enabledDayCount > 0;
    final finalScheduleEnabled = _scheduleEnabled && hasSelectedDays;

    final days = _dayKeys.map((day) {
      final editableDay = _days[day]!;
      final enabled = finalScheduleEnabled && editableDay.enabled;

      return ScheduleDayConfig(
        day: day,
        enabled: enabled,
        slots: enabled ? editableDay.slots : <ScheduleSlot>[],
      );
    }).toList();

    // ---------------------------------------------------------------
    // This screen is a MONTHLY calendar (1..31), not a weekday schedule.
    // Send dates using backend monthly_custom structure.
    //
    // Do NOT convert selected clock times to UTC.
    // Backend evaluates them in timezone = Asia/Karachi.
    // ---------------------------------------------------------------
    final monthlyDays = <String, dynamic>{};

    for (final dayConfig in days) {
      if (!dayConfig.enabled) continue;

      monthlyDays[dayConfig.day] = dayConfig.slots.map((slot) {
        return <String, dynamic>{
          "start_time": slot.startTime,
          "end_time": slot.endTime,
        };
      }).toList();
    }

    // Build from the exact backend JSON structure so the existing
    // ScheduleModel/provider/API-service flow remains unchanged.
    final schedule = ScheduleModel.fromJson(<String, dynamic>{
      "device_id": widget.deviceId,
      "schedule_type": "monthly_custom",
      "pattern": <String, dynamic>{
        "enabled": finalScheduleEnabled,
        "timezone": "Asia/Karachi",
        "days": monthlyDays,
      },
      "schedule_name": "Monthly Motor Irrigation Schedule",
    });

    await ref.read(scheduleViewModelProvider.notifier).saveSchedule(schedule);

    final state = ref.read(scheduleViewModelProvider);

    if (state.error == null) {
      setState(() {
        _scheduleEnabled = finalScheduleEnabled;
        _isSynced = true;
      });

      if (!hasSelectedDays) {
        _showSnack(
          message: "No schedule selected. Automation is off for this device.",
          success: true,
        );
      } else {
        _showSnack(
          message:
              "Schedule applied successfully. Timezone: Pakistan (PKT / Asia-Karachi).",
          success: true,
        );
      }
    }
  }

  Future<void> _deleteSchedule() async {
    if (widget.deviceId.trim().isEmpty) {
      _showSnack(
        message: "Device ID missing. Cannot delete schedule.",
        success: false,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurfaceSoft,
          title: const Text(
            "Delete schedule?",
            style: TextStyle(color: AppColors.white),
          ),
          content: const Text(
            "This will remove the saved automation schedule for this device.",
            style: TextStyle(color: AppColors.textMutedSoft),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.textMutedSoft),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref
        .read(scheduleViewModelProvider.notifier)
        .deleteSchedule(widget.deviceId);

    final state = ref.read(scheduleViewModelProvider);

    if (state.error == null) {
      setState(() {
        _days = _defaultDays();
        _scheduleEnabled = false;
        _selectedDay = "1";
        _isSynced = true;
        _appliedLoadedSchedule = false;
      });
    }
  }

  Future<void> _refreshSchedule() async {
    if (widget.deviceId.trim().isEmpty) {
      _showSnack(
        message: "Device ID missing. Cannot refresh schedule.",
        success: false,
      );
      return;
    }

    _appliedLoadedSchedule = false;

    await ref
        .read(scheduleViewModelProvider.notifier)
        .loadSchedule(widget.deviceId);
  }

  void _setFullMonthPreset() {
    setState(() {
      for (final day in _dayKeys) {
        final current = _days[day]!;

        _days[day] = current.copyWith(
          enabled: true,
          slots: current.slots.isEmpty
              ? const [ScheduleSlot(startTime: "09:00", endTime: "12:00")]
              : current.slots,
        );
      }

      _selectedDay = "1";
      _scheduleEnabled = true;
      _isSynced = false;
    });
  }

  void _clearAllDays() {
    setState(() {
      _days = _defaultDays();
      _selectedDay = "1";
      _scheduleEnabled = false;
      _isSynced = false;
    });
  }

  void _resetSchedule() {
    _clearAllDays();
  }

  String? _validateSchedule() {
    final enabledDays = _days.entries.where((entry) => entry.value.enabled);

    if (enabledDays.isEmpty) {
      return null;
    }

    for (final entry in enabledDays) {
      final fullName = _dayFullName(entry.key);
      final slots = entry.value.slots;

      if (slots.isEmpty) {
        return "Add at least one time slot for $fullName.";
      }

      for (final slot in slots) {
        if (!slot.isValid) {
          return "$fullName has an invalid time slot.";
        }
      }
    }

    return null;
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(":");

    if (parts.length < 2) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  String _formatForApi(TimeOfDay time) {
    // Backend expects 24-hour HH:mm in Asia/Karachi.
    //
    // 12:52 AM -> 00:52
    // 12:52 PM -> 12:52
    // 01:00 PM -> 13:00
    //
    // Do not convert to UTC here.
    return "${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}";
  }

  String _formatTimeForDisplay(TimeOfDay time) {
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, "0");
    final period = time.period == DayPeriod.am ? "AM" : "PM";

    return "${hour12.toString().padLeft(2, "0")}:$minute $period";
  }

  int get _enabledDayCount {
    return _days.values.where((day) => day.enabled).length;
  }

  int get _slotCount {
    return _days.values.fold<int>(
      0,
      (total, day) => total + (day.enabled ? day.slots.length : 0),
    );
  }

  String get _selectedDayTitle => _dayFullName(_selectedDay);

  @override
  Widget build(BuildContext context) {
    ref.listen<ScheduleState>(scheduleViewModelProvider, (
      ScheduleState? previous,
      ScheduleState next,
    ) {
      final error = next.error;
      final message = next.message;
      final schedule = next.schedule;

      if (error != null && previous?.error != error) {
        if (_isNoScheduleMessage(error)) {
          setState(() {
            _days = _defaultDays();
            _scheduleEnabled = false;
            _selectedDay = "1";
            _isSynced = true;
            _appliedLoadedSchedule = true;
          });
          return;
        }

        _showSnack(message: error, success: false);
      }

      if (message != null && previous?.message != message) {
        _showSnack(message: message, success: true);
      }

      if (!_appliedLoadedSchedule && schedule != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _applySchedule(schedule);
        });
      }
    });

    final state = ref.watch(scheduleViewModelProvider);
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width < 420 ? 16.0 : size.width * 0.05;
    final maxButtonWidth = size.width >= 650 ? 620.0 : size.width * 0.92;

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Column(
          children: [
            Text(
              "Motor Schedule",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Monthly Automation",
              style: TextStyle(
                color: AppColors.mintAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Refresh schedule",
            icon: const Icon(Icons.refresh_rounded),
            onPressed: state.isLoading ? null : _refreshSchedule,
          ),
          IconButton(
            tooltip: "Delete schedule",
            icon: const Icon(
              Icons.delete_sweep_rounded,
              color: AppColors.error,
            ),
            onPressed: state.isLoading ? null : _deleteSchedule,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.mintAccent,
          backgroundColor: AppColors.darkSurfaceSoft,
          onRefresh: _refreshSchedule,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScheduleStatusHeader(
                      isSynced: _isSynced,
                      isEnabled: _scheduleEnabled,
                      activeDays: _enabledDayCount,
                      slotCount: _slotCount,
                      deviceId: widget.deviceId,
                    ),
                    const SizedBox(height: 18),
                    _buildScheduleModeCard(),
                    const SizedBox(height: 18),
                    _buildPresetRow(),
                    const SizedBox(height: 22),
                    _sectionHeader(
                      "Operational Calendar",
                      Icons.calendar_month_rounded,
                      trailing: "$_enabledDayCount days active",
                    ),
                    _buildDayGrid(),
                    const SizedBox(height: 22),
                    _sectionHeader(
                      "On/Off Schedule",
                      Icons.more_time_rounded,
                      trailing: _selectedDayTitle,
                    ),
                    _buildSelectedDaySchedule(),
                    _addPulseButton(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: maxButtonWidth,
        height: 58,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: state.isLoading ? null : _saveSchedule,
          icon: state.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Icon(Icons.bolt_rounded),
          label: Text(
            state.isLoading ? "Saving Schedule" : "Apply Schedule",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleModeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorderSoft),
      ),
      child: Row(
        children: [
          Icon(
            _scheduleEnabled
                ? Icons.play_circle_fill_rounded
                : Icons.pause_circle_filled_rounded,
            color: _scheduleEnabled
                ? AppColors.mintAccent
                : AppColors.textMutedSoft,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _scheduleEnabled
                  ? (_isSynced
                        ? "Schedule applied • Automation active"
                        : "Automation active • Pending apply")
                  : "No schedule selected",
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Switch(
            value: _scheduleEnabled,
            activeColor: AppColors.mintAccent,
            inactiveTrackColor: AppColors.gray800,
            onChanged: (value) {
              setState(() {
                _scheduleEnabled = value && _enabledDayCount > 0;
                _isSynced = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: _presetButton(
              label: "Full Month",
              icon: Icons.calendar_month_rounded,
              onTap: _setFullMonthPreset,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _presetButton(
              label: "Clear",
              icon: Icons.clear_all_rounded,
              onTap: _clearAllDays,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _presetButton(
              label: "Reset",
              icon: Icons.restart_alt_rounded,
              onTap: _resetSchedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.mintAccent,
        side: const BorderSide(color: AppColors.mintAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: FittedBox(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildDayGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final crossAxisCount = width < 330
            ? 4
            : width < 390
            ? 5
            : 7;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorderSoft),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemCount: _dayKeys.length,
            itemBuilder: (context, index) {
              final day = _dayKeys[index];
              final isSelected = _selectedDay == day;
              final isEnabled = _days[day]?.enabled ?? false;

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _toggleCalendarDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isEnabled ? AppColors.mintAccent : AppColors.gray900,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.darkBorderSoft,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _dayLabel(day),
                      style: TextStyle(
                        color: isEnabled
                            ? AppColors.mintAccentDark
                            : AppColors.offWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedDaySchedule() {
    final editableDay = _days[_selectedDay]!;
    final slots = editableDay.slots;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorderSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mintAccent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _dayLabel(_selectedDay),
                  style: const TextStyle(
                    color: AppColors.mintAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedDayTitle,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Switch(
                value: editableDay.enabled,
                activeColor: AppColors.mintAccent,
                inactiveTrackColor: AppColors.gray800,
                onChanged: _toggleSelectedDay,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!editableDay.enabled)
            _emptyStateBox(
              icon: Icons.pause_circle_outline_rounded,
              text: "This date is disabled.",
            )
          else if (slots.isEmpty)
            _emptyStateBox(
              icon: Icons.more_time_rounded,
              text: "No time slot added for this date.",
            )
          else
            _buildPulseList(slots),
        ],
      ),
    );
  }

  Widget _buildPulseList(List<ScheduleSlot> slots) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isValid = slot.isValid;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isValid ? AppColors.darkBorderSoft : AppColors.error,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _timePickerAction(
                      "Start",
                      _parseTime(slot.startTime),
                      () => _selectTime(
                        day: _selectedDay,
                        index: index,
                        isStart: true,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.sync_alt_rounded,
                      color: AppColors.textMutedSoft,
                    ),
                  ),
                  Expanded(
                    child: _timePickerAction(
                      "Stop",
                      _parseTime(slot.endTime),
                      () => _selectTime(
                        day: _selectedDay,
                        index: index,
                        isStart: false,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () => _removeSlot(index),
                  ),
                ],
              ),
              if (!isValid) ...[
                const SizedBox(height: 8),
                const Text(
                  "Start time must be earlier than stop time.",
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _timePickerAction(String label, TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.gray900,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorderSoft),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMutedSoft,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              child: Text(
                _formatTimeForDisplay(time),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addPulseButton() {
    final enabled = _days[_selectedDay]?.enabled ?? false;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mintAccent,
          disabledForegroundColor: AppColors.textMutedSoft,
          side: BorderSide(
            color: enabled ? AppColors.mintAccent : AppColors.darkBorderSoft,
          ),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: enabled ? _addSlot : null,
        icon: const Icon(Icons.add),
        label: const Text(
          "Add Time Slot",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: AppColors.mintAccent),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMutedSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(
                color: AppColors.mintAccent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyStateBox({required IconData icon, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorderSoft),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMutedSoft),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMutedSoft,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleStatusHeader extends StatelessWidget {
  final bool isSynced;
  final bool isEnabled;
  final int activeDays;
  final int slotCount;
  final String deviceId;

  const _ScheduleStatusHeader({
    required this.isSynced,
    required this.isEnabled,
    required this.activeDays,
    required this.slotCount,
    required this.deviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCardSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorderSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderMetric(
                title: "Status",
                value: isEnabled ? "Active" : "Off",
                icon: isEnabled
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_filled_rounded,
                color: isEnabled ? AppColors.green : AppColors.textMutedSoft,
              ),
              const SizedBox(width: 10),
              _HeaderMetric(
                title: "Sync",
                value: isSynced ? (isEnabled ? "Applied" : "Saved") : "Pending",
                icon: isSynced
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_upload_rounded,
                color: isSynced ? AppColors.green : AppColors.mintAccent,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _HeaderMetric(
                title: "Days",
                value: "$activeDays",
                icon: Icons.calendar_today_rounded,
                color: AppColors.mintAccent,
              ),
              const SizedBox(width: 10),
              _HeaderMetric(
                title: "Slots",
                value: "$slotCount",
                icon: Icons.more_time_rounded,
                color: AppColors.mintAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorderSoft),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.memory_rounded,
                  size: 17,
                  color: AppColors.mintAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deviceId.trim().isEmpty
                        ? "Device ID not available"
                        : "Device: $deviceId",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMutedSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
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

class _HeaderMetric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HeaderMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorderSoft),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMutedSoft,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableDay {
  final bool enabled;
  final List<ScheduleSlot> slots;

  const _EditableDay({required this.enabled, required this.slots});

  _EditableDay copyWith({bool? enabled, List<ScheduleSlot>? slots}) {
    return _EditableDay(
      enabled: enabled ?? this.enabled,
      slots: slots ?? this.slots,
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;

    if (iterator.moveNext()) {
      return iterator.current;
    }

    return null;
  }
}
