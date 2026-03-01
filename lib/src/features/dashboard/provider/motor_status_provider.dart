// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/timer_view_model.dart';
// import 'package:smart_iot_app/src/features/dashboard/domain/time_state.dart';
// import 'package:smart_iot_app/src/features/dashboard/model/motor_status_model.dart';
//
//
// // final motorStatusProvider = StreamProvider<MotorStatus>((ref) {
// //   final dbRef = FirebaseDatabase.instance.ref("motor/liveStatus");
// //
// //   return dbRef.onValue.map((event) {
// //     final data = event.snapshot.value as Map<dynamic, dynamic>?;
// //
// //     if (data == null) {
// //       return MotorStatus(inputVoltage: 0,outputVoltage: 0, current: 0, frequency: 0, running: false);
// //     }
// //
// //     return MotorStatus.fromMap(data);
// //   });
// // });
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../repository/automation_repository.dart';
//
// final automationViewModelProvider =
// StateNotifierProvider<AutomationViewModel, AutomationState>(
//       (ref) {
//     final repo = AutomationRepository(ref.read(automationFirebaseServiceProvider));
//     return AutomationViewModel(repo);
//   },
// );
