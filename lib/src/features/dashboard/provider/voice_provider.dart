import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/voice_view_model.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/voice_control_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/voice_repository.dart';
import 'package:smart_iot_app/src/features/dashboard/services/voice_firebase_service.dart';




// -------------------------
// PROVIDERS
// // -------------------------
// // StateNotifierProvider for voice control
// final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>(
//       (ref) => VoiceNotifier(),
// );
//
// // StreamProvider for sound level (optional)
// final soundLevelStreamProvider = StreamProvider<double>((ref) async* {
//   final voiceState = ref.watch(voiceProvider);
//   yield voiceState.soundLevel;
// });
final firebaseDatabaseProvider =
Provider<FirebaseDatabase>((ref) => FirebaseDatabase.instance);

final voiceFirebaseServiceProvider = Provider<VoiceFirebaseService>((ref) {
  final db = ref.read(firebaseDatabaseProvider);
  return VoiceFirebaseService(db);
});

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  final service = ref.read(voiceFirebaseServiceProvider);
  return VoiceRepository(service);
});
