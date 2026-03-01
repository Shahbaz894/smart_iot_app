import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:smart_iot_app/src/features/dashboard/model/sensor_model.dart';

class FirebaseSensorService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Sensor is directly under shahbaz_iot
  final String _sensorPath = 'shahbaz_iot/sensor';

  // Stream to listen for sensor updates
  Stream<SensorData> get sensorStream {
    return _db.ref(_sensorPath).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return SensorData.fromMap(data);
    });
  }
}

// Provider for the service
final firebaseSensorServiceProvider = Provider((ref) => FirebaseSensorService());

