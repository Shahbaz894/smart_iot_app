import "../models/device_model.dart";
import "../services/device_api_service.dart";

class DeviceRepository {
  final DeviceApiService deviceApiService;

  DeviceRepository(this.deviceApiService);

  Future<List<DeviceModel>> getDevicesByUserId(String userId) {
    return deviceApiService.getDevicesByUserId(userId);
  }

  Future<DeviceModel> createDevice({
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return deviceApiService.createDevice(
      userId: userId,
      data: data,
    );
  }

  Future<DeviceModel> updateDevice({
    required String userId,
    required String deviceId,
    required Map<String, dynamic> data,
  }) {
    return deviceApiService.updateDevice(
      userId: userId,
      deviceId: deviceId,
      data: data,
    );
  }
}