import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/motor_viewmodel.dart';
import 'package:smart_iot_app/src/features/dashboard/model/motor_model.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/motor_repository.dart';
import 'package:smart_iot_app/src/features/dashboard/services/motor_rtb_services.dart';



// final motorServiceProvider =
// Provider((ref) => MotorRTDBService());
//
// final motorRepositoryProvider = Provider(
//       (ref) => MotorRepository(
//     ref.read(motorServiceProvider),
//   ),
// );
//
// final motorViewModelProvider =
// StateNotifierProvider<MotorViewModel,
//     AsyncValue<MotorModel>>(
//       (ref) => MotorViewModel(
//     ref.read(motorRepositoryProvider),
//   ),
// );

final motorServiceProvider = Provider((ref) => MotorRTDBService());

final motorRepositoryProvider = Provider(
      (ref) => MotorRepository(ref.read(motorServiceProvider)),
);

final motorViewModelProvider =
StateNotifierProvider<MotorViewModel, AsyncValue<MotorModel>>(
      (ref) => MotorViewModel(ref.read(motorRepositoryProvider)),
);