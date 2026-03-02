import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/timer_view_model.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/time_state.dart';
import 'package:smart_iot_app/src/features/dashboard/repository/automation_repository.dart';
import 'package:smart_iot_app/src/features/dashboard/services/automation_firebase_service.dart';
// 2️⃣ Repository Provider
// final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
//   final service = ref.read(automationFirebaseServiceProvider);
//   return AutomationRepository(service);
// });

// 3️⃣ ViewModel Provider
// final automationViewModelProvider =
// StateNotifierProvider<AutomationViewModel, AutomationState>((ref) {
//   final repo = ref.read(automationRepositoryProvider);
//   return AutomationViewModel(repo);
// });
// 1️⃣ Firebase Service Provider
final automationFirebaseServiceProvider = Provider<AutomationFirebaseService>((ref) {
  return AutomationFirebaseService();
});





final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
  return AutomationRepository(AutomationFirebaseService());
});

final automationViewModelProvider =
StateNotifierProvider<AutomationViewModel, AutomationState>((ref) {
  final repo = ref.read(automationRepositoryProvider);
  return AutomationViewModel(repo);
});