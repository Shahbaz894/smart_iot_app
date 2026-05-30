import "../../data/models/device_model.dart";

const Object _unset = Object();

class DeviceSelectionState {
  final bool isLoading;
  final List<DeviceModel> devices;
  final String? selectedDeviceId;
  final String? error;
  final String? message;

  const DeviceSelectionState({
    this.isLoading = false,
    this.devices = const [],
    this.selectedDeviceId,
    this.error,
    this.message,
  });

  DeviceSelectionState copyWith({
    bool? isLoading,
    List<DeviceModel>? devices,
    Object? selectedDeviceId = _unset,
    Object? error = _unset,
    Object? message = _unset,
  }) {
    return DeviceSelectionState(
      isLoading: isLoading ?? this.isLoading,
      devices: devices ?? this.devices,
      selectedDeviceId: selectedDeviceId == _unset
          ? this.selectedDeviceId
          : selectedDeviceId as String?,
      error: error == _unset ? this.error : error as String?,
      message: message == _unset ? this.message : message as String?,
    );
  }
}