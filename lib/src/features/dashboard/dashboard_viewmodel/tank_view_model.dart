import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/tank_state.dart';




class TankViewModel extends StateNotifier<AsyncValue<TankState>> {
  TankViewModel() : super(const AsyncValue.loading()) {
    _startListening();
  }

  StreamSubscription? _subscription;

  void _startListening() {
    // Replace this with your actual Database Stream (Firebase, MQTT, etc.)
    final stream = Stream.periodic(const Duration(seconds: 2), (count) {
      final randomLevel = 30.0 + Random().nextDouble() * 40;
      return TankState(
        levelPercentage: randomLevel,
        volumeLitres: randomLevel * 50,
        status: _calculateStatus(randomLevel),
      );
    });

    _subscription = stream.listen(
          (data) => state = AsyncValue.data(data),
      onError: (err, stack) => state = AsyncValue.error(err, stack),
    );
  }

  TankStatus _calculateStatus(double level) {
    if (level < 15) return TankStatus.critical;
    return TankStatus.stable;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}