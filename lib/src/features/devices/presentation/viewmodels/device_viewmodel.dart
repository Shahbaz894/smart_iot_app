import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/core/constant/storage/auth_storage.dart";
import "package:smart_iot_app/src/features/devices/presentation/state/device_state.dart";

import "../../../../core/error/app_exception.dart";
import "../../../../core/storage/auth_storage.dart";
import "../../data/models/device_model.dart";
import "../../data/repositories/device_repository.dart";

class DeviceSelectionViewModel extends StateNotifier<DeviceSelectionState> {
  final DeviceRepository deviceRepository;
  final AuthStorage authStorage;

  DeviceSelectionViewModel({
    required this.deviceRepository,
    required this.authStorage,
  }) : super(const DeviceSelectionState());

  Future<void> loadDevices() async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        message: null,
      );

      final session = await authStorage.getSession();

      if (!session.hasValidLogin || session.userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: "Session expired. Please login again.",
        );
        return;
      }

      final devices = await deviceRepository.getDevicesByUserId(
        session.userId!,
      );

      state = state.copyWith(
        isLoading: false,
        devices: devices,
        selectedDeviceId: session.deviceId,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Failed to load devices: ${e.toString()}",
      );
    }
  }

  Future<String?> selectDevice(DeviceModel device) async {
    try {
      final deviceId = device.primaryDeviceId;

      if (deviceId.trim().isEmpty) {
        state = state.copyWith(
          error: "Selected device ID missing",
          message: null,
        );
        return null;
      }

      await authStorage.saveSelectedDeviceId(deviceId);

      state = state.copyWith(
        selectedDeviceId: deviceId,
        error: null,
        message: "Device selected",
      );

      return deviceId;
    } catch (e) {
      state = state.copyWith(
        error: "Failed to select device: ${e.toString()}",
      );
      return null;
    }
  }

  Future<void> logout() async {
    await authStorage.clear();
DeviceSelectionState
    state = const DeviceSelectionState(
      message: "Logged out",
    );
  }
}