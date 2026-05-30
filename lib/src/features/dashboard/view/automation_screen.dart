// import 'package:flutter/material.dart';
//
//
//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:smart_iot_app/src/core/constant/app_color.dart';
//
// import 'package:smart_iot_app/src/core/exceptions/device_exception.dart';
// import 'package:smart_iot_app/src/features/dashboard/model/time_model.dart';
// import 'package:smart_iot_app/src/features/dashboard/view/motor_screen.dart';
//
// import 'package:smart_iot_app/src/features/dashboard/widget/status_card_automation.dart';
//
// import '../provider/motor_status_provider.dart';
// import '../provider/time_provider.dart';
//
//
// class AutomationScreen extends ConsumerStatefulWidget {
//   const AutomationScreen({super.key});
//
//   @override
//   ConsumerState<AutomationScreen> createState() => _AutomationScreenState();
// }
//
// class _AutomationScreenState extends ConsumerState<AutomationScreen> {
//   // State Variables
//   bool isMotorManualOn = false;
//   bool _isSynced = false;
//   final Set<int> _selectedDays = {};
//   final List<Map<String, TimeOfDay>> _timePulses = [
//     {'on': const TimeOfDay(hour: 8, minute: 0), 'off': const TimeOfDay(hour: 17, minute: 0)},
//   ];
//
//
//
//   // 2. Logic: Time Picker Implementation
//   Future<void> _clearAllSettings() async {
//     final vm = ref.read(automationViewModelProvider.notifier);
//
//     await vm.clearAll();
//
//     setState(() {
//       _selectedDays.clear();
//       _timePulses.clear();
//       isMotorManualOn = false;
//       _isSynced = false;
//     });
//   }
//
//   Future<void> _selectTime(int index, String key) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _timePulses[index][key]!,
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.dark().copyWith(
//             colorScheme: const ColorScheme.dark(
//               primary: AppColors.primary,
//               surface: AppColors.surfaceDark,
//               onSurface: AppColors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         _timePulses[index][key] = picked;
//         _isSynced = false; // Require re-sync because data changed
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Future.microtask(() {
//     //   ref
//     //       .read(automationViewModelProvider.notifier).
//     //       //.loadSchedules(5);
//     // });
//   }
//
//   Future<void> _syncToMotor() async {
//     try {
//       if (_timePulses.isEmpty && !isMotorManualOn) {
//         _showError("Please add at least one time slot or enable manual mode.");
//         return;
//       }
//
//       final vm = ref.read(automationViewModelProvider.notifier);
//
//       // Clear all previous schedules
//       await vm.clearAll();
//
//       // Save each pulse for all selected days
//       for (var day in _selectedDays) {
//         for (var pulse in _timePulses) {
//           await vm.addTimer(
//             TimerDevice(
//               id: DateTime.now().microsecondsSinceEpoch.toString(),
//               title: "Motor Timer",
//               startTime: pulse['on']!,
//               stopTime: pulse['off']!,
//               espPin: 12,
//               isEnabled: true,
//               day: day, // Assign current day
//             ),
//           );
//         }
//       }
//
//       setState(() {
//         _isSynced = true;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: AppColors.success,
//           content: Text(
//             "MOTOR COMMAND SENT SUCCESSFULLY",
//             style: TextStyle(
//                 color: AppColors.white, fontWeight: FontWeight.bold),
//           ),
//         ),
//       );
//     } catch (e) {
//       _showError("Sync failed.");
//     }
//   }
//
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(backgroundColor: AppColors.error, content: Text(msg)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final padding = size.width * 0.05;
//     // final motorStatusAsync = ref.watch(motorStatusProvider)
//     // ;
//     final automationState = ref.watch(automationViewModelProvider);
//
//
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDark,
//       appBar: AppBar(
//         backgroundColor: AppColors.surfaceDark,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => MotorScreen()),
//             );
//           },
//         ),
//
//         centerTitle: true,
//         title: const Column(
//           children: [
//             Text("MOTOR CONTROL CENTER", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.white)),
//             Text("GSM INDUSTRIAL V3", style: TextStyle(fontSize: 10, color: AppColors.primary, letterSpacing: 1.2)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.red),
//             onPressed: _clearAllSettings,
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//
//         StatusHeader(
//         isSynced: automationState.motorStatus.running,
//           inputVoltage: automationState.motorStatus.inputVoltage,
//           outputVoltage: automationState.motorStatus.outputVoltage,
//           current: automationState.motorStatus.current,
//           frequency: automationState.motorStatus.frequency,
//         ),
//             const SizedBox(height: 20),
//
//             _buildManualControlCard(),
//             const SizedBox(height: 25),
//
//             _sectionHeader("OPERATIONAL CALENDAR", Icons.calendar_month,
//                 trailing: "${_selectedDays.length} DAYS SELECTED"),
//             _buildDateGrid(),
//             const SizedBox(height: 25),
//
//             _sectionHeader("ON/OFF SCHEDULES", Icons.more_time_rounded),
//             _buildPulseList(),
//             _addPulseButton(),
//
//             const SizedBox(height: 120), // Spacer for Floating Button
//           ],
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: _buildSyncButton(size.width),
//     );
//   }
//
//
//   Widget _buildManualControlCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: isMotorManualOn ? AppColors.primary : Colors.transparent),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("MANUAL OVERRIDE", style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11)),
//               Text(isMotorManualOn ? "MOTOR RUNNING" : "MOTOR STOPPED",
//                   style: TextStyle(
//                       color: isMotorManualOn ? AppColors.primary : AppColors.red,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold
//                   )),
//             ],
//           ),
//           Switch(
//             value: isMotorManualOn,
//             activeColor: AppColors.primary,
//             activeTrackColor: AppColors.primary.withOpacity(0.3),
//             inactiveTrackColor: AppColors.gray800,
//             onChanged: (val) async {
//               final vm = ref.read(automationViewModelProvider.notifier);
//
//               await vm.setManualMode(val);
//
//               setState(() {
//                 isMotorManualOn = val;
//                 _isSynced = true;
//               });
//             },
//
//
//
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDateGrid() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(15)),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8),
//         itemCount: 31,
//         itemBuilder: (context, index) {
//           int day = index + 1;
//           bool isSelected = _selectedDays.contains(day);
//           return GestureDetector(
//             onTap: () => setState(() {
//               isSelected ? _selectedDays.remove(day) : _selectedDays.add(day);
//               _isSynced = false;
//             }),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               decoration: BoxDecoration(
//                 color: isSelected ? AppColors.primary : AppColors.gray900,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Center(
//                 child: Text("$day",
//                     style: TextStyle(
//                         color: isSelected ? AppColors.black : AppColors.white,
//                         fontWeight: FontWeight.bold
//                     )),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildPulseList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _timePulses.length,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           padding: const EdgeInsets.all(15),
//           decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _timePickerAction("START", _timePulses[index]['on']!, () => _selectTime(index, 'on')),
//               const Icon(Icons.sync_alt, color: AppColors.gray700),
//               _timePickerAction("STOP", _timePulses[index]['off']!, () => _selectTime(index, 'off')),
//               IconButton(
//                 icon: const Icon(Icons.remove_circle_outline, color: AppColors.red),
//                 onPressed: () => setState(() {
//                   _timePulses.removeAt(index);
//                   _isSynced = false;
//                 }),
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _timePickerAction(String label, TimeOfDay time, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Text(label, style: const TextStyle(color: AppColors.gray500, fontSize: 10, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 5),
//           Text(time.format(context),
//               style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   Widget _addPulseButton() {
//     return OutlinedButton.icon(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         side: const BorderSide(color: AppColors.primary),
//         minimumSize: const Size(double.infinity, 50),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//       onPressed: () => setState(() {
//         _timePulses.add({'on': const TimeOfDay(hour: 0, minute: 0), 'off': const TimeOfDay(hour: 0, minute: 0)});
//         _isSynced = false;
//       }),
//       icon: const Icon(Icons.add),
//       label: const Text("ADD NEW TIME SLOT"),
//     );
//   }
//
//   Widget _sectionHeader(String title, IconData icon, {String? trailing}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 16, color: AppColors.primary),
//               const SizedBox(width: 8),
//               Text(title, style: const TextStyle(color: AppColors.gray400, fontSize: 11, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           if (trailing != null)
//             Text(trailing, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSyncButton(double width) {
//     final automationState = ref.watch(automationViewModelProvider);
//     return Container(
//       width: width * 0.9,
//       height: 60,
//       decoration: BoxDecoration(
//         boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
//       ),
//       child: ElevatedButton.icon(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: AppColors.black,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         ),
//         onPressed:  automationState.isLoading ? null : _syncToMotor,
//         icon: const Icon(Icons.bolt_rounded),
//         label: automationState.isLoading
//             ? const CircularProgressIndicator(color: AppColors.black)
//             : const Text(
//           "APPLY & SYNC TO HARDWARE",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//         ),
//
//       ),
//     );
//   }
// }