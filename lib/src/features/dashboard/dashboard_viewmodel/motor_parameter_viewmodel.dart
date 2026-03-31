import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/motor_parameter_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/motor_parameter_repository.dart';


// // ✅ CORRECT - extends StateNotifier not AsyncNotifier
// class MotorParameterViewModel extends StateNotifier<MotorParameterState> {
//   final MotorParameterRepository repository;
//
//   MotorParameterViewModel({required this.repository}) : super(MotorInitial());
//
//   Future<void> fetchMotorParameter(int deviceId) async {
//     try {
//       state = MotorLoading();
//       final motorParam = await repository.getMotorParameter(deviceId);
//       state = MotorLoaded(motorParam);
//     } catch (e) {
//       state = MotorError(e.toString());
//     }
//   }
// }
class MotorParameterViewModel extends StateNotifier<MotorParameterState> {
  final MotorParameterRepository repository;

  MotorParameterViewModel({required this.repository}) : super(MotorInitial());

  Future<void> fetchMotorParameter(int deviceId) async {
    try {
      // ✅ Only show loading on very first fetch
      if (state is MotorInitial) {
        state = MotorLoading();
      }

      final motorParam = await repository.getMotorParameter(deviceId);

      // ✅ Just silently update with new data every time
      state = MotorLoaded(motorParam);

    } catch (e) {
      // ✅ Only show error on first load
      // ✅ On refresh error — keep showing old data silently
      if (state is! MotorLoaded) {
        state = MotorError(e.toString());
      }
    }
  }
}