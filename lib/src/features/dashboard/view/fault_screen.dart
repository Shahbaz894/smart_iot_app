// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:smart_iot_app/src/features/dashboard/view/motor_screen.dart';
// import '../../../core/utils/fault_helper.dart';
// import '../provider/fault_provider.dart';
//
// import '../model/fault_model.dart';
//
//
//
//
// class FaultScreen extends ConsumerStatefulWidget {
//   final int deviceId;
//
//   const FaultScreen({super.key, required this.deviceId});
//
//   @override
//   ConsumerState<FaultScreen> createState() => _FaultScreenState();
// }
//
// class _FaultScreenState extends ConsumerState<FaultScreen> {
//   @override
//   void initState() {
//     super.initState();
//
//     Future.microtask(() {
//       ref.read(faultViewModelProvider.notifier).loadFaults(widget.deviceId);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(faultViewModelProvider);
//     final width = MediaQuery.of(context).size.width;
//
//     /// Remove duplicate faults
//     final uniqueFaults = {
//       for (var fault in state.faults) fault.faultCode: fault
//     }.values.toList();
//
//     /// Latest fault = active fault (red LED)
//     int? activeFault =
//     uniqueFaults.isNotEmpty ? uniqueFaults.first.faultCode : null;
//
//     return Scaffold(
//       backgroundColor: const Color(0xff0f172a),
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         elevation: 8,
//         shadowColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => MotorScreen()),
//             );
//           },
//         ),
//         title: Text(
//           "Device ${widget.deviceId} Fault History",
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           ref
//               .read(faultViewModelProvider.notifier)
//               .loadFaults(widget.deviceId);
//         },
//         child: Builder(
//           builder: (context) {
//             if (state.loading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             if (state.error != null) {
//               return Center(
//                 child: Text(
//                   state.error!,
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               );
//             }
//
//             if (uniqueFaults.isEmpty) {
//               return const Center(
//                 child: Text(
//                   "No Fault Data",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               );
//             }
//
//             return ListView.builder(
//               padding: EdgeInsets.symmetric(
//                 horizontal: width * 0.04,
//                 vertical: 16,
//               ),
//               itemCount: uniqueFaults.length,
//               itemBuilder: (context, index) {
//                 final fault = uniqueFaults[index];
//                 final isActive = fault.faultCode == activeFault;
//
//                 return _faultCard(context, fault, isActive);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _faultCard(BuildContext context, FaultModel fault, bool isActive) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xff1e293b),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isActive ? Colors.red : Colors.green,
//           width: 1.3,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.4),
//             blurRadius: 10,
//             offset: const Offset(0, 6),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             /// LED Indicator
//             Container(
//               width: 14,
//               height: 14,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isActive ? Colors.red : Colors.green,
//                 boxShadow: [
//                   BoxShadow(
//                     color: (isActive ? Colors.red : Colors.green)
//                         .withOpacity(0.7),
//                     blurRadius: 8,
//                   )
//                 ],
//               ),
//             ),
//
//             const SizedBox(width: 14),
//
//             Icon(
//               Icons.warning_amber_rounded,
//               color: isActive ? Colors.red : Colors.green,
//               size: 28,
//             ),
//
//             const SizedBox(width: 14),
//
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     FaultHelper.getFaultDescription(fault.faultCode),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     "Fault Code : ${fault.faultCode}",
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   Text(
//                     "Time : ${fault.datetime}",
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   Text(
//                     "Device : ${fault.deviceId}",
//                     style: const TextStyle(color: Colors.white70),
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