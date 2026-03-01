import 'dart:async';
import 'dart:math';

import 'package:smart_iot_app/src/features/dashboard/model/sensor_model.dart';
//
// class SensorRepository {
//   // Replace this with: FirebaseDatabase.instance.ref('sensors').onValue
//   Stream<SensorData> getSensorStream() {
//     return Stream.periodic(const Duration(seconds: 2), (count) {
//       final r = Random();
//       return SensorData(
//         waterLevel: 40.0 + r.nextDouble() * 20.0, // Mock 40-60%
//         temperature: 22.0 + r.nextDouble() * 4.0, // Mock 22-26°C
//         humidity: 50.0 + r.nextDouble() * 10.0,   // Mock 50-60%
//       );
//     });
//   }
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_iot_app/src/features/dashboard/services/sensor_firebase_services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the repository
final sensorRepoProvider = Provider((ref) => SensorRepository(ref));

class SensorRepository {
  final Ref ref; // <-- Use Ref instead of Reader

  SensorRepository(this.ref);

  // Access the Firebase service via provider
  FirebaseSensorService get _service => ref.read(firebaseSensorServiceProvider);

  // Stream of sensor data
  Stream<SensorData> getSensorStream() {
    return _service.sensorStream;
  }
}


