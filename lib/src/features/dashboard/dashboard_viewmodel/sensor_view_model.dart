import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/sensor_state.dart';

class SensorViewModel extends StateNotifier<SensorState> {
  SensorViewModel() : super(SensorState()) {
    _startMockStream();
  }

  // Simulate Firebase Realtime Database updates
  void _startMockStream() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      final random = Random();

      // Update state with mock values
      state = state.copyWith(
        waterLevel: 50 + random.nextDouble() * 30, // Random level between 50-80
        temperature: 24 + random.nextDouble() * 5,
        humidity: 40 + random.nextDouble() * 20,
        waterHistory: [...state.waterHistory, state.waterLevel].takeLast(10),
      );
    });
  }
}

// Extension to keep chart list manageable
extension ListX on List<double> {
  List<double> takeLast(int n) => length <= n ? this : sublist(length - n);
}