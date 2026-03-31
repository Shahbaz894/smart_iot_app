import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/api_services/motor_api_services.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/motor_on_off_viewmodel.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/motor_on_off_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/motor_on_off_repository.dart';


import '../repository/motor_repository.dart';


// ---------------------------
// API SERVICE
// ---------------------------
final motorApiServiceProvider = Provider<MotorApiService>(
      (ref) => MotorApiService(
    baseUrl: "http://178.128.107.36",
  ),
);

// ---------------------------
// REPOSITORY
// ---------------------------
final motorRepositoryProvider = Provider<MotorOnOffRepository>(
      (ref) => MotorOnOffRepository(
    ref.read(motorApiServiceProvider),
  ),
);

// ---------------------------
// VIEWMODEL
// ---------------------------

final motorOnOffViewModelProvider =
StateNotifierProvider<MotorOnOffViewModel, MotorOnOffState>(
      (ref) => MotorOnOffViewModel(
    ref.read(motorRepositoryProvider),
  ),
);