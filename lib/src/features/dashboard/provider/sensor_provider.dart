import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/sensor_view_model.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/sensor_state.dart';
import 'package:smart_iot_app/src/features/dashboard/model/sensor_model.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/sensor_repository.dart';
//
// final sensorRepoProvider = Provider((ref) => SensorRepository());
//
// final sensorStreamProvider = StreamProvider<SensorData>((ref) {
//   final repo = ref.watch(sensorRepoProvider);
//   return repo.getSensorStream();
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/sensor_repository.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';

// Extension to keep chart list manageable
extension ListX on List<double> {
  List<double> takeLast(int n) => length <= n ? this : sublist(length - n);
}

class SensorViewModel extends StateNotifier<SensorState> {
  final SensorRepository _repository;

  SensorViewModel(this._repository) : super(SensorState()) {
    _listenToSensors();
  }

  void _listenToSensors() {
    _repository.getSensorStream().listen((sensorData) {
      state = state.copyWith(
        waterLevel: sensorData.waterLevel,
        temperature: sensorData.temperature,
        humidity: sensorData.humidity,
        waterHistory: ListX([
          ...state.waterHistory,
          sensorData.waterLevel,
        ]).takeLast(10),
      );
    });
  }
}

/// Provider for SensorViewModel
final sensorViewModelProvider =
StateNotifierProvider<SensorViewModel, SensorState>((ref) {
  final repo = ref.read(sensorRepoProvider); // <-- corrected provider name
  return SensorViewModel(repo);
});
