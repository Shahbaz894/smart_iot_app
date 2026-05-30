import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "package:smart_iot_app/src/core/constant/storage/auth_storage.dart";
import "package:smart_iot_app/src/features/devices/presentation/state/device_state.dart";
import "package:smart_iot_app/src/features/devices/presentation/viewmodels/device_viewmodel.dart";

import "../../../../core/network/api_client.dart";
import "../../../../core/storage/auth_storage.dart";
import "../../../devices/data/repositories/device_repository.dart";
import "../../../devices/data/services/device_api_service.dart";
import "../../../khata/data/repositories/khata_repository.dart";
import "../../../khata/data/services/khata_api_service.dart";
import "../../../motor/data/repositories/motor_repository.dart";
import "../../../motor/data/services/motor_api_service.dart";
import "../../../schedule/data/repositories/schedule_repository.dart";
import "../../../schedule/data/services/schedule_api_service.dart";
import "../../../telemetry/data/repositories/telemetry_repository.dart";
import "../../../telemetry/data/services/telemetry_api_service.dart";
import "../../../vfd/data/repositories/vfd_repository.dart";
import "../../../vfd/data/services/vfd_api_service.dart";
import "../../data/repositories/auth_repository.dart";
import "../../data/services/auth_api_service.dart";
import "../state/login_state.dart";
import "../viewmodels/login_viewmodel.dart";

final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    authStorage: ref.read(authStorageProvider),
  );
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  return AuthApiService(
    ref.read(apiClientProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authApiService: ref.read(authApiServiceProvider),
    authStorage: ref.read(authStorageProvider),
  );
});

final loginViewModelProvider =
StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(
    authRepository: ref.read(authRepositoryProvider),
  );
});

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

final motorApiServiceProvider = Provider<MotorApiService>((ref) {
  return MotorApiService(
    ref.read(apiClientProvider),
  );
});

final motorRepositoryProvider = Provider<MotorRepository>((ref) {
  return MotorRepository(
    ref.read(motorApiServiceProvider),
  );
});

final vfdApiServiceProvider = Provider<VfdApiService>((ref) {
  return VfdApiService(
    ref.read(apiClientProvider),
  );
});

final vfdRepositoryProvider = Provider<VfdRepository>((ref) {
  return VfdRepository(
    ref.read(vfdApiServiceProvider),
  );
});

final scheduleApiServiceProvider = Provider<ScheduleApiService>((ref) {
  return ScheduleApiService(
    ref.read(apiClientProvider),
  );
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(
    ref.read(scheduleApiServiceProvider),
  );
});

final khataApiServiceProvider = Provider<KhataApiService>((ref) {
  return KhataApiService(
    ref.read(apiClientProvider),
  );
});

final khataRepositoryProvider = Provider<KhataRepository>((ref) {
  return KhataRepository(
    ref.read(khataApiServiceProvider),
  );
});

final telemetryApiServiceProvider = Provider<TelemetryApiService>((ref) {
  return TelemetryApiService(
    ref.read(apiClientProvider),
  );
});

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  return TelemetryRepository(
    ref.read(telemetryApiServiceProvider),
  );
});