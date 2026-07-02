import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/features/devices/presentation/viewmodels/device_viewmodel.dart";

import "../../../auth/ presentation/providers/auth_providers.dart";
import "../../data/repositories/device_repository.dart";
import "../../data/services/device_api_service.dart";
import "../state/device_state.dart";


final deviceApiServiceProvider = Provider<DeviceApiService>((ref) {
  return DeviceApiService(
    ref.read(apiClientProvider),
  );
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(
    ref.read(deviceApiServiceProvider),
  );
});

final deviceSelectionViewModelProvider =
StateNotifierProvider<DeviceSelectionViewModel, DeviceSelectionState>((ref) {
  return DeviceSelectionViewModel(
    deviceRepository: ref.read(deviceRepositoryProvider),
    authStorage: ref.read(authStorageProvider),
  );
});