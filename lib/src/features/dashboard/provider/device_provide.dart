import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_iot_app/src/features/dashboard/dashboard_viewmodel/device_view_model.dart';
import 'package:smart_iot_app/src/features/dashboard/domain/device_state.dart';

import '../repository/device_repository.dart';


final deviceViewModelProvider = StateNotifierProvider<DeviceViewModel, DeviceState>((ref) {
  // 1. Watch the repository provider
  final repository = ref.watch(deviceRepositoryProvider);

  // 2. Pass it into the ViewModel constructor
  return DeviceViewModel(repository);
});