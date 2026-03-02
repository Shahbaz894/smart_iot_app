import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/model/motor_model.dart';

import '../repository/motor_repository.dart';
//
// class MotorViewModel extends StateNotifier<AsyncValue<MotorModel>> {
//   final MotorRepository repository;
//
//   MotorViewModel(this.repository)
//       : super(const AsyncLoading()) {
//     _listen();
//   }
//
//   void _listen() {
//     repository.getMotor().listen((motor) {
//       state = AsyncData(motor);
//     });
//   }
//
//   Future<void> toggle(bool isOn) async {
//     await repository.toggleMotor(isOn);
//   }
// }

class MotorViewModel extends StateNotifier<AsyncValue<MotorModel>> {
  final MotorRepository repository;
  StreamSubscription? _sub;

  MotorViewModel(this.repository) : super(const AsyncLoading()) {
    _listen();
  }

  void _listen() {
    _sub = repository.getMotor().listen((motor) {
      state = AsyncData(motor);
    }, onError: (e, st) {
      state = AsyncError(e, st);
    });
  }

  Future<void> toggle(bool isOn) async {
    await repository.toggleMotor(isOn);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}