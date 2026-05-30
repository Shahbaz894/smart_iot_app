import "../models/telemetry_model.dart";
import "../services/telemetry_api_service.dart";

class TelemetryRepository {
  final TelemetryApiService telemetryApiService;

  TelemetryRepository(this.telemetryApiService);

  Future<TelemetryModel?> getLatest({
    required String deviceId,
  }) {
    return telemetryApiService.getLatestTelemetry(
      deviceId: deviceId,
    );
  }

  Future<List<TelemetryModel>> getAll({
    required String deviceId,
  }) {
    return telemetryApiService.getAllTelemetry(
      deviceId: deviceId,
    );
  }

  Future<TelemetryModel> sendTelemetry({
    required String deviceId,
    required Map<String, dynamic> data,
  }) {
    return telemetryApiService.sendTelemetry(
      deviceId: deviceId,
      data: data,
    );
  }

  Future<void> delete({
    required String telemetryId,
  }) {
    return telemetryApiService.deleteTelemetry(
      telemetryId: telemetryId,
    );
  }
}