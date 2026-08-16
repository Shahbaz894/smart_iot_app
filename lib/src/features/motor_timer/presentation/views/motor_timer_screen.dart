// import "package:flutter/material.dart";
// import "package:flutter/services.dart";
// import "package:flutter_riverpod/flutter_riverpod.dart";
//
// import "../../../../core/constant/app_color.dart";
// import "../providers/motor_timer_providers.dart";
// import "../state/motor_timer_state.dart";
//
// class MotorTimerScreen extends ConsumerStatefulWidget {
//   final String deviceId;
//
//   const MotorTimerScreen({
//     super.key,
//     required this.deviceId,
//   });
//
//   @override
//   ConsumerState<MotorTimerScreen> createState() {
//     return _MotorTimerScreenState();
//   }
// }
//
// class _MotorTimerScreenState extends ConsumerState<MotorTimerScreen> {
//   final TextEditingController customerNameController = TextEditingController();
//
//   @override
//   void dispose() {
//     customerNameController.dispose();
//     super.dispose();
//   }
//
//   void showMessage(String message, bool isError) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context)
//       ..clearSnackBars()
//       ..showSnackBar(
//         SnackBar(
//           duration: Duration(seconds: isError ? 8 : 4),
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//           backgroundColor: isError ? Colors.redAccent : AppColors.green,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           content: Text(
//             message,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//         ),
//       );
//   }
//
//   String _timeText(DateTime? value) {
//     if (value == null) return "-";
//
//     final hour = value.hour.toString().padLeft(2, "0");
//     final minute = value.minute.toString().padLeft(2, "0");
//
//     return "$hour:$minute";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<MotorTimerState>(
//       motorTimerViewModelProvider,
//           (previous, next) {
//         if (next.error != null && previous?.error != next.error) {
//           showMessage(next.error!, true);
//         }
//
//         if (next.message != null && previous?.message != next.message) {
//           showMessage(next.message!, false);
//         }
//       },
//     );
//
//     final state = ref.watch(motorTimerViewModelProvider);
//
//     final width = MediaQuery.of(context).size.width;
//     final isTablet = width >= 650;
//     final isLarge = width >= 1000;
//
//     final horizontalPadding = isLarge
//         ? 34.0
//         : isTablet
//         ? 28.0
//         : 16.0;
//
//     return Scaffold(
//       backgroundColor: AppColors.darkBgSoft,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryDark,
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           "Motor Timer",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.w900,
//           ),
//         ),
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: EdgeInsets.symmetric(
//             horizontal: horizontalPadding,
//             vertical: 18,
//           ),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 980),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _TimerHeaderCard(
//                     deviceId: widget.deviceId,
//                     state: state,
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   _CountdownCard(
//                     state: state,
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   _DurationSelector(
//                     state: state,
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   _QuickDurationChips(),
//
//                   const SizedBox(height: 16),
//
//                   _CustomerField(
//                     controller: customerNameController,
//                     enabled: !state.isRunning && !state.isLoading,
//                   ),
//
//                   const SizedBox(height: 18),
//
//                   _ActionButtons(
//                     state: state,
//                     onStart: () {
//                       HapticFeedback.mediumImpact();
//
//                       ref.read(motorTimerViewModelProvider.notifier).startTimer(
//                         deviceId: widget.deviceId,
//                         customerName: customerNameController.text,
//                       );
//                     },
//                     onStop: () {
//                       HapticFeedback.mediumImpact();
//
//                       ref
//                           .read(motorTimerViewModelProvider.notifier)
//                           .stopNow();
//                     },
//                     onReset: () {
//                       ref
//                           .read(motorTimerViewModelProvider.notifier)
//                           .resetSelection();
//                     },
//                   ),
//
//                   const SizedBox(height: 18),
//
//                   _RunInfoCard(
//                     state: state,
//                     startText: _timeText(state.startedAt),
//                     stopText: _timeText(state.expectedStopAt),
//                   ),
//
//                   const SizedBox(height: 18),
//
//                   const _SafetyNoteCard(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _TimerHeaderCard extends StatelessWidget {
//   final String deviceId;
//   final MotorTimerState state;
//
//   const _TimerHeaderCard({
//     required this.deviceId,
//     required this.state,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final statusColor = state.isRunning
//         ? AppColors.green
//         : state.isLoading
//         ? Colors.orangeAccent
//         : AppColors.primary;
//
//     final statusText = state.isRunning
//         ? "Timer Running"
//         : state.isLoading
//         ? "Sending Command"
//         : "Ready";
//
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(26),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.08),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.12),
//             blurRadius: 26,
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
//               color: statusColor.withOpacity(0.18),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               Icons.timer_rounded,
//               color: statusColor,
//               size: 34,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Timed Motor Run",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 19,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   deviceId,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.60),
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.16),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Text(
//               statusText,
//               style: TextStyle(
//                 color: statusColor,
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
// class _CountdownCard extends StatelessWidget {
//   final MotorTimerState state;
//
//   const _CountdownCard({
//     required this.state,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final progress = state.isRunning ? state.completionProgress : 0.0;
//     final ringColor = state.isRunning ? AppColors.green : AppColors.primary;
//
//     return Container(
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.07),
//         ),
//       ),
//       child: Column(
//         children: [
//           SizedBox(
//             width: 220,
//             height: 220,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 205,
//                   height: 205,
//                   child: CircularProgressIndicator(
//                     value: state.isRunning ? progress : 0,
//                     strokeWidth: 13,
//                     backgroundColor: Colors.white.withOpacity(0.08),
//                     color: ringColor,
//                   ),
//                 ),
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       state.isRunning
//                           ? Icons.power_settings_new_rounded
//                           : Icons.timer_outlined,
//                       color: ringColor,
//                       size: 38,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       state.isRunning
//                           ? state.remainingText
//                           : state.selectedDurationText,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 34,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       state.isRunning ? "Remaining" : "Selected Duration",
//                       style: TextStyle(
//                         color: AppColors.white.withOpacity(0.60),
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             state.isRunning
//                 ? "Motor will stop automatically when timer ends."
//                 : "Select duration, then start timer.",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: AppColors.white.withOpacity(0.64),
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _DurationSelector extends ConsumerWidget {
//   final MotorTimerState state;
//
//   const _DurationSelector({
//     required this.state,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final vm = ref.read(motorTimerViewModelProvider.notifier);
//     final locked = state.isRunning || state.isLoading;
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final twoColumns = constraints.maxWidth >= 560;
//
//         final hourBox = _NumberControlBox(
//           title: "Hours",
//           value: state.selectedHours,
//           locked: locked,
//           onMinus: () {
//             vm.setDuration(
//               hours: state.selectedHours - 1,
//               minutes: state.selectedMinutes,
//             );
//           },
//           onPlus: () {
//             vm.setDuration(
//               hours: state.selectedHours + 1,
//               minutes: state.selectedMinutes,
//             );
//           },
//         );
//
//         final minuteBox = _NumberControlBox(
//           title: "Minutes",
//           value: state.selectedMinutes,
//           locked: locked,
//           onMinus: () {
//             vm.addMinutes(-5);
//           },
//           onPlus: () {
//             vm.addMinutes(5);
//           },
//         );
//
//         if (twoColumns) {
//           return Row(
//             children: [
//               Expanded(child: hourBox),
//               const SizedBox(width: 14),
//               Expanded(child: minuteBox),
//             ],
//           );
//         }
//
//         return Column(
//           children: [
//             hourBox,
//             const SizedBox(height: 14),
//             minuteBox,
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _NumberControlBox extends StatelessWidget {
//   final String title;
//   final int value;
//   final bool locked;
//   final VoidCallback onMinus;
//   final VoidCallback onPlus;
//
//   const _NumberControlBox({
//     required this.title,
//     required this.value,
//     required this.locked,
//     required this.onMinus,
//     required this.onPlus,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.07),
//         ),
//       ),
//       child: Row(
//         children: [
//           _RoundIconButton(
//             icon: Icons.remove_rounded,
//             onTap: locked ? null : onMinus,
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: AppColors.white.withOpacity(0.60),
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   value.toString().padLeft(2, "0"),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 34,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           _RoundIconButton(
//             icon: Icons.add_rounded,
//             onTap: locked ? null : onPlus,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _RoundIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//
//   const _RoundIconButton({
//     required this.icon,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final enabled = onTap != null;
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         width: 46,
//         height: 46,
//         decoration: BoxDecoration(
//           color: enabled
//               ? AppColors.primary.withOpacity(0.20)
//               : Colors.white.withOpacity(0.06),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: enabled
//                 ? AppColors.primary.withOpacity(0.38)
//                 : Colors.white.withOpacity(0.08),
//           ),
//         ),
//         child: Icon(
//           icon,
//           color: enabled ? Colors.white : Colors.white30,
//         ),
//       ),
//     );
//   }
// }
//
// class _QuickDurationChips extends ConsumerWidget {
//   const _QuickDurationChips();
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(motorTimerViewModelProvider);
//     final locked = state.isRunning || state.isLoading;
//
//     final items = <_QuickDuration>[
//       const _QuickDuration("15 min", 15),
//       const _QuickDuration("30 min", 30),
//       const _QuickDuration("1 hour", 60),
//       const _QuickDuration("2 hours", 120),
//       const _QuickDuration("3 hours", 180),
//     ];
//
//     return
//       Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.surfaceDark,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: AppColors.white.withOpacity(0.06),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.black.withOpacity(0.25),
//               blurRadius: 16,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Wrap(
//           spacing: 10,
//           runSpacing: 10,
//           children: items.map((item) {
//             final selected = state.selectedTotalMinutes == item.minutes;
//
//             return ChoiceChip(
//               selected: selected,
//               label: Text(item.label),
//               onSelected: locked
//                   ? null
//                   : (_) {
//                 ref
//                     .read(motorTimerViewModelProvider.notifier)
//                     .setQuickDuration(item.minutes);
//               },
//
//               // Clean dark theme colors
//               selectedColor: AppColors.darkBgSoft,
//               backgroundColor: AppColors.cardDark,
//               disabledColor: AppColors.cardLight.withOpacity(0.4),
//
//               labelStyle: TextStyle(
//                 color: selected
//                     ? AppColors.primary
//                     : AppColors.white.withOpacity(0.75),
//                 fontWeight: FontWeight.w700,
//               ),
//
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//                 side: BorderSide(
//                   color: selected
//                       ? AppColors.primary
//                       : AppColors.white.withOpacity(0.12),
//                   width: selected ? 1.4 : 1,
//                 ),
//               ),
//
//               elevation: selected ? 2 : 0,
//               pressElevation: 0,
//             );
//           }).toList(),
//         ),
//       );
//   }
// }
//
// class _QuickDuration {
//   final String label;
//   final int minutes;
//
//   const _QuickDuration(this.label, this.minutes);
// }
//
// class _CustomerField extends StatelessWidget {
//   final TextEditingController controller;
//   final bool enabled;
//
//   const _CustomerField({
//     required this.controller,
//     required this.enabled,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.07),
//         ),
//       ),
//       child: TextField(
//         enabled: enabled,
//         controller: controller,
//         keyboardType: TextInputType.text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.w700,
//         ),
//         decoration: InputDecoration(
//           hintText: "Run label or customer name optional",
//           hintStyle: TextStyle(
//             color: AppColors.white.withOpacity(0.42),
//           ),
//           prefixIcon: Icon(
//             Icons.person_outline_rounded,
//             color: AppColors.primary,
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 18,
//             vertical: 18,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _ActionButtons extends StatelessWidget {
//   final MotorTimerState state;
//   final VoidCallback onStart;
//   final VoidCallback onStop;
//   final VoidCallback onReset;
//
//   const _ActionButtons({
//     required this.state,
//     required this.onStart,
//     required this.onStop,
//     required this.onReset,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (state.isRunning) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           SizedBox(
//             height: 56,
//             child: ElevatedButton.icon(
//               onPressed: state.isStopping || state.isLoading ? null : onStop,
//               icon: state.isStopping
//                   ? const SizedBox(
//                 width: 22,
//                 height: 22,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2.2,
//                 ),
//               )
//                   : const Icon(Icons.stop_circle_rounded),
//               label: Text(
//                 state.isStopping ? "Stopping..." : "Stop Now",
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 16,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 foregroundColor: Colors.white,
//                 disabledBackgroundColor: Colors.redAccent.withOpacity(0.45),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       );
//     }
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final twoColumns = constraints.maxWidth >= 560;
//
//         final startButton = SizedBox(
//           height: 56,
//           child: ElevatedButton.icon(
//             onPressed: state.isLoading ? null : onStart,
//             icon: state.isLoading
//                 ? const SizedBox(
//               width: 22,
//               height: 22,
//               child: CircularProgressIndicator(
//                 color: Colors.white,
//                 strokeWidth: 2.2,
//               ),
//             )
//                 : const Icon(Icons.play_arrow_rounded),
//             label: Text(
//               state.isLoading ? "Starting..." : "Start Timer",
//               style: const TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontSize: 16,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.green,
//               foregroundColor: Colors.white,
//               disabledBackgroundColor: AppColors.green.withOpacity(0.45),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//             ),
//           ),
//         );
//
//         final resetButton = SizedBox(
//           height: 56,
//           child: OutlinedButton.icon(
//             onPressed: state.isLoading ? null : onReset,
//             icon: const Icon(Icons.refresh_rounded),
//             label: const Text(
//               "Reset",
//               style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontSize: 16,
//               ),
//             ),
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.white,
//               side: BorderSide(
//                 color: Colors.white.withOpacity(0.18),
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//             ),
//           ),
//         );
//
//         if (twoColumns) {
//           return Row(
//             children: [
//               Expanded(child: startButton),
//               const SizedBox(width: 12),
//               Expanded(child: resetButton),
//             ],
//           );
//         }
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             startButton,
//             const SizedBox(height: 12),
//             resetButton,
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _RunInfoCard extends StatelessWidget {
//   final MotorTimerState state;
//   final String startText;
//   final String stopText;
//
//   const _RunInfoCard({
//     required this.state,
//     required this.startText,
//     required this.stopText,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.cardDark,
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: Colors.white.withOpacity(0.07),
//         ),
//       ),
//       child: Column(
//         children: [
//           _InfoRow(
//             label: "Selected Duration",
//             value: state.selectedDurationText,
//           ),
//           const SizedBox(height: 12),
//           _InfoRow(
//             label: "Started At",
//             value: startText,
//           ),
//           const SizedBox(height: 12),
//           _InfoRow(
//             label: "Auto Stop At",
//             value: stopText,
//           ),
//           const SizedBox(height: 12),
//           _InfoRow(
//             label: "Run Label",
//             value: state.customerName ?? "-",
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const _InfoRow({
//     required this.label,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: AppColors.white.withOpacity(0.58),
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         const Spacer(),
//         Flexible(
//           child: Text(
//             value,
//             textAlign: TextAlign.right,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _SafetyNoteCard extends StatelessWidget {
//   const _SafetyNoteCard();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: Colors.orangeAccent.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(
//           color: Colors.orangeAccent.withOpacity(0.30),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(
//             Icons.info_outline_rounded,
//             color: Colors.orangeAccent,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               "This timer uses the app to call motor ON and OFF APIs. Keep the app active for reliable auto stop. For guaranteed stop even if the app is closed, add a backend timer endpoint later.",
//               style: TextStyle(
//                 color: AppColors.white.withOpacity(0.78),
//                 height: 1.35,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../../core/constant/app_color.dart";
import "../providers/motor_timer_providers.dart";
import "../state/motor_timer_state.dart";

class MotorTimerScreen extends ConsumerStatefulWidget {
  final String deviceId;

  const MotorTimerScreen({
    super.key,
    required this.deviceId,
  });

  @override
  ConsumerState<MotorTimerScreen> createState() {
    return _MotorTimerScreenState();
  }
}

class _MotorTimerScreenState extends ConsumerState<MotorTimerScreen>
    with WidgetsBindingObserver {
  final TextEditingController customerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Reconcile an already-restored timer after the first frame.
    // The authoritative timestamps still come from MotorTimerState/server.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reconcileTimerDeadline();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reconcileTimerDeadline();
    }
  }

  void _reconcileTimerDeadline() {
    if (!mounted) return;

    final timerState = ref.read(motorTimerViewModelProvider);

    if (!timerState.isRunning || timerState.expectedStopAt == null) {
      return;
    }

    final expectedStopUtc = timerState.expectedStopAt!.toUtc();
    final nowUtc = DateTime.now().toUtc();

    // If the provider/server has restored a running timer whose deadline
    // already passed while this screen was backgrounded, immediately ask
    // the EXISTING ViewModel stop flow to reconcile it.
    //
    // This does not create a second timer implementation here.
    if (!nowUtc.isBefore(expectedStopUtc) &&
        !timerState.isStopping &&
        !timerState.isLoading) {
      ref.read(motorTimerViewModelProvider.notifier).stopNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    customerNameController.dispose();
    super.dispose();
  }

  void showMessage(String message, bool isError) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: isError ? 8 : 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: isError ? Colors.redAccent : AppColors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
  }

  DateTime _toPakistanTime(DateTime value) {
    return value.toUtc().add(const Duration(hours: 5));
  }

  String _timeText(DateTime? value) {
    if (value == null) return "-";

    // Server timestamp is treated as UTC and displayed in Pakistan UTC+5.
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

  @override
  Widget build(BuildContext context) {
    ref.listen<MotorTimerState>(
      motorTimerViewModelProvider,
          (previous, next) {
        if (next.error != null && previous?.error != next.error) {
          showMessage(next.error!, true);
        }

        if (next.message != null && previous?.message != next.message) {
          showMessage(next.message!, false);
        }
      },
    );

    final state = ref.watch(motorTimerViewModelProvider);

    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 650;
    final isLarge = width >= 1000;

    final horizontalPadding = isLarge
        ? 34.0
        : isTablet
        ? 28.0
        : 16.0;

    return Scaffold(
      backgroundColor: AppColors.darkBgSoft,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Motor Timer",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TimerHeaderCard(
                    deviceId: widget.deviceId,
                    state: state,
                  ),

                  const SizedBox(height: 16),

                  _CountdownCard(
                    state: state,
                  ),

                  const SizedBox(height: 16),

                  _DurationSelector(
                    state: state,
                  ),

                  const SizedBox(height: 16),

                  _QuickDurationChips(),

                  const SizedBox(height: 16),

                  _CustomerField(
                    controller: customerNameController,
                    enabled: !state.isRunning && !state.isLoading,
                  ),

                  const SizedBox(height: 18),

                  _ActionButtons(
                    state: state,
                    onStart: () {
                      HapticFeedback.mediumImpact();

                      ref.read(motorTimerViewModelProvider.notifier).startTimer(
                        deviceId: widget.deviceId,
                        customerName: customerNameController.text,
                      );
                    },
                    onStop: () {
                      HapticFeedback.mediumImpact();

                      ref
                          .read(motorTimerViewModelProvider.notifier)
                          .stopNow();
                    },
                    onReset: () {
                      ref
                          .read(motorTimerViewModelProvider.notifier)
                          .resetSelection();
                    },
                  ),

                  const SizedBox(height: 18),

                  _RunInfoCard(
                    state: state,
                    startText: _timeText(state.startedAt),
                    stopText: _timeText(state.expectedStopAt),
                  ),

                  const SizedBox(height: 18),

                  const _SafetyNoteCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerHeaderCard extends StatelessWidget {
  final String deviceId;
  final MotorTimerState state;

  const _TimerHeaderCard({
    required this.deviceId,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = state.isRunning
        ? AppColors.green
        : state.isLoading
        ? Colors.orangeAccent
        : AppColors.primary;

    final statusText = state.isRunning
        ? "Timer Running"
        : state.isLoading
        ? "Sending Command"
        : "Ready";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 26,
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
              color: statusColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.timer_rounded,
              color: statusColor,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Timed Motor Run",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  deviceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.60),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final MotorTimerState state;

  const _CountdownCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final progress = state.isRunning ? state.completionProgress : 0.0;
    final ringColor = state.isRunning ? AppColors.green : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 205,
                  height: 205,
                  child: CircularProgressIndicator(
                    value: state.isRunning ? progress : 0,
                    strokeWidth: 13,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    color: ringColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.isRunning
                          ? Icons.power_settings_new_rounded
                          : Icons.timer_outlined,
                      color: ringColor,
                      size: 38,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.isRunning
                          ? state.remainingText
                          : state.selectedDurationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.isRunning ? "Remaining" : "Selected Duration",
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.60),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.isRunning
                ? "Motor will stop automatically when timer ends."
                : "Select duration, then start timer.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.64),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationSelector extends ConsumerWidget {
  final MotorTimerState state;

  const _DurationSelector({
    required this.state,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(motorTimerViewModelProvider.notifier);
    final locked = state.isRunning || state.isLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 560;

        final hourBox = _NumberControlBox(
          title: "Hours",
          value: state.selectedHours,
          locked: locked,
          onMinus: () {
            vm.setDuration(
              hours: state.selectedHours - 1,
              minutes: state.selectedMinutes,
            );
          },
          onPlus: () {
            vm.setDuration(
              hours: state.selectedHours + 1,
              minutes: state.selectedMinutes,
            );
          },
        );

        final minuteBox = _NumberControlBox(
          title: "Minutes",
          value: state.selectedMinutes,
          locked: locked,
          onMinus: () {
            vm.addMinutes(-5);
          },
          onPlus: () {
            vm.addMinutes(5);
          },
        );

        if (twoColumns) {
          return Row(
            children: [
              Expanded(child: hourBox),
              const SizedBox(width: 14),
              Expanded(child: minuteBox),
            ],
          );
        }

        return Column(
          children: [
            hourBox,
            const SizedBox(height: 14),
            minuteBox,
          ],
        );
      },
    );
  }
}

class _NumberControlBox extends StatelessWidget {
  final String title;
  final int value;
  final bool locked;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _NumberControlBox({
    required this.title,
    required this.value,
    required this.locked,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.remove_rounded,
            onTap: locked ? null : onMinus,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.60),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value.toString().padLeft(2, "0"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _RoundIconButton(
            icon: Icons.add_rounded,
            onTap: locked ? null : onPlus,
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.20)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withOpacity(0.38)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.white30,
        ),
      ),
    );
  }
}

class _QuickDurationChips extends ConsumerWidget {
  const _QuickDurationChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(motorTimerViewModelProvider);
    final locked = state.isRunning || state.isLoading;

    final items = <_QuickDuration>[
      const _QuickDuration("15 min", 15),
      const _QuickDuration("30 min", 30),
      const _QuickDuration("1 hour", 60),
      const _QuickDuration("2 hours", 120),
      const _QuickDuration("3 hours", 180),
    ];

    return
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.white.withOpacity(0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) {
            final selected = state.selectedTotalMinutes == item.minutes;

            return ChoiceChip(
              selected: selected,
              label: Text(item.label),
              onSelected: locked
                  ? null
                  : (_) {
                ref
                    .read(motorTimerViewModelProvider.notifier)
                    .setQuickDuration(item.minutes);
              },

              // Dark theme colors:
              // selected/disabled quick-duration options must never turn
              // white or washed-out while the timer is running.
              selectedColor: AppColors.primaryDark,
              backgroundColor: AppColors.cardDark,
              disabledColor: AppColors.cardDark,
              showCheckmark: false,
              checkmarkColor: AppColors.primary,

              labelStyle: TextStyle(
                color: selected
                    ? AppColors.primary
                    : locked
                    ? AppColors.white.withOpacity(0.48)
                    : AppColors.white.withOpacity(0.78),
                fontWeight: selected
                    ? FontWeight.w900
                    : FontWeight.w700,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : locked
                      ? AppColors.white.withOpacity(0.08)
                      : AppColors.white.withOpacity(0.12),
                  width: selected ? 1.5 : 1,
                ),
              ),

              elevation: selected ? 2 : 0,
              pressElevation: 0,
            );
          }).toList(),
        ),
      );
  }
}

class _QuickDuration {
  final String label;
  final int minutes;

  const _QuickDuration(this.label, this.minutes);
}

class _CustomerField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _CustomerField({
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: TextField(
        enabled: enabled,
        controller: controller,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: "Run label or customer name optional",
          hintStyle: TextStyle(
            color: AppColors.white.withOpacity(0.42),
          ),
          prefixIcon: Icon(
            Icons.person_outline_rounded,
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
  }
}

class _ActionButtons extends StatelessWidget {
  final MotorTimerState state;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;

  const _ActionButtons({
    required this.state,
    required this.onStart,
    required this.onStop,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isRunning) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: state.isStopping || state.isLoading ? null : onStop,
              icon: state.isStopping
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )
                  : const Icon(Icons.stop_circle_rounded),
              label: Text(
                state.isStopping ? "Stopping..." : "Stop Now",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.redAccent.withOpacity(0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 560;

        final startButton = SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: state.isLoading ? null : onStart,
            icon: state.isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.2,
              ),
            )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(
              state.isLoading ? "Starting..." : "Start Timer",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.green.withOpacity(0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );

        final resetButton = SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: state.isLoading ? null : onReset,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(
              "Reset",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withOpacity(0.18),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );

        if (twoColumns) {
          return Row(
            children: [
              Expanded(child: startButton),
              const SizedBox(width: 12),
              Expanded(child: resetButton),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            startButton,
            const SizedBox(height: 12),
            resetButton,
          ],
        );
      },
    );
  }
}

class _RunInfoCard extends StatelessWidget {
  final MotorTimerState state;
  final String startText;
  final String stopText;

  const _RunInfoCard({
    required this.state,
    required this.startText,
    required this.stopText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: "Selected Duration",
            value: state.selectedDurationText,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: "Started At",
            value: startText,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: "Auto Stop At",
            value: stopText,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: "Run Label",
            value: state.customerName ?? "-",
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.58),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SafetyNoteCard extends StatelessWidget {
  const _SafetyNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.orangeAccent.withOpacity(0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Timer start and auto-stop timestamps are displayed from server time in Pakistan UTC+5. The screen reconciles an existing deadline when the app resumes. The current OFF command still runs through the app ViewModel, so guaranteed auto-stop while the app is fully killed requires the timer deadline to be executed by the backend/server.",
              style: TextStyle(
                color: AppColors.white.withOpacity(0.78),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
