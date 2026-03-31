import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/api_services/motor_parametor_api_service.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/motor_parameter_viewmodel.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/motor_parameter_state.dart';
import 'package:smart_iot_app/src/features/dashboard/model/motor_parameter.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/motor_parameter_repository.dart';

import 'motor_on_off_provider.dart';




final motorServiceProvider = Provider<MotorParameterApiService>(
      (ref) => MotorParameterApiService(),
);

final motorRepositoryProvider = Provider<MotorParameterRepository>(
      (ref) => MotorParameterRepository(
    apiService: ref.read(motorServiceProvider),
  ),
);

// ✅ CORRECT - returns MotorParameterState (your custom state)
final motorParameterViewModelProvider =
StateNotifierProvider<MotorParameterViewModel, MotorParameterState>(
      (ref) => MotorParameterViewModel(
    repository: ref.read(motorRepositoryProvider),
  ),
);