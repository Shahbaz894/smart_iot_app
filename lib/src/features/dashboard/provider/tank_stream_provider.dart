import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/tank_state.dart';



final tankStreamProvider = StreamProvider<TankState>((ref) {
  // Replace this with your actual database stream
  // e.g., FirebaseDatabase.instance.ref('tank').onValue.map(...)
  return Stream.periodic(const Duration(seconds: 2), (count) {
    final randomLevel = 20.0 + Random().nextDouble() * 60; // 20% to 80%

    // ViewModel Logic: Determine status based on level
    TankStatus currentStatus = TankStatus.stable;
    if (randomLevel < 25) currentStatus = TankStatus.critical;

    return TankState(
      levelPercentage: randomLevel,
      volumeLitres: randomLevel * 50,
      status: currentStatus,
    );
  });
});