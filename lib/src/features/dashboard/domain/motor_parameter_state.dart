import 'package:smart_iot_app/src/features/dashboard/model/motor_parameter.dart';




// abstract class MotorParameterState {
//   T when<T>({
//     required T Function() initial,       // ✅ must match
//     required T Function() loading,       // ✅ must match
//     required T Function(MotorParameter motor) loaded,  // ✅ must match
//     required T Function(String message) error,          // ✅ must match
//   }) {
//     if (this is MotorInitial) return initial();
//     if (this is MotorLoading) return loading();
//     if (this is MotorLoaded) return loaded((this as MotorLoaded).motorParameter);
//     if (this is MotorError) return error((this as MotorError).message);
//     throw UnimplementedError();
//   }
// }
//
// class MotorInitial extends MotorParameterState {}
// class MotorLoading extends MotorParameterState {}
//
// class MotorLoaded extends MotorParameterState {
//   final MotorParameter motorParameter;
//   MotorLoaded(this.motorParameter);
// }
//
// class MotorError extends MotorParameterState {
//   final String message;
//   MotorError(this.message);
// }
import 'package:smart_iot_app/src/features/dashboard/model/motor_parameter.dart';

abstract class MotorParameterState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(MotorParameter motor) loaded,
    required T Function(String message) error,
  }) {
    if (this is MotorInitial) return initial();
    if (this is MotorLoading) return loading();
    if (this is MotorLoaded) return loaded((this as MotorLoaded).motorParameter);
    if (this is MotorError) return error((this as MotorError).message);
    throw UnimplementedError();
  }
}

class MotorInitial extends MotorParameterState {}
class MotorLoading extends MotorParameterState {}

class MotorLoaded extends MotorParameterState {
  final MotorParameter motorParameter;
  MotorLoaded(this.motorParameter);
}

class MotorError extends MotorParameterState {
  final String message;
  MotorError(this.message);
}