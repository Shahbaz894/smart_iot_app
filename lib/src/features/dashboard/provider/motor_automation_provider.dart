import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/api_services/automation_api_service.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/motor_automation_view_model.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/motor_automation_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/motor_automation_repository.dart';


final automationApiProvider = Provider(
      (ref) => AutomationApiService(),
);

final automationRepositoryProvider = Provider(
      (ref) => MotorAutomationRepository(ref.read(automationApiProvider)),
);

final automationViewModelProvider =
StateNotifierProvider<MotorAutomationViewModel, MotorAutomationState>(
      (ref) => MotorAutomationViewModel(
    ref.read(automationRepositoryProvider),
  ),
);