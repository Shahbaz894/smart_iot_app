import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseDeviceService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  // Path for your Shahbaz IoT project
  final String _nodePath = 'shahbaz_iot/devices';

  // Stream to listen for real-time changes from Firebase (e.g., if ESP32 updates it)
  Stream<DatabaseEvent> get deviceStream => _db.ref(_nodePath).onValue;

  // Method to update specific fields in Firebase
  Future<void> updateDeviceData(Map<String, dynamic> data) async {
    await _db.ref(_nodePath).update(data);
  }
}

// Provider for the service
final firebaseServiceProvider = Provider((ref) => FirebaseDeviceService());