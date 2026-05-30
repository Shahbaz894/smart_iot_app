import "../models/vfd_command_response.dart";
import "../services/vfd_api_service.dart";

class VfdRepository {
  final VfdApiService vfdApiService;

  VfdRepository(this.vfdApiService);

  Future<VfdCommandResponse> reset({
    required String deviceId,
  }) {
    return vfdApiService.resetVfd(
      deviceId: deviceId,
      confirm: true,
    );
  }

  Future<VfdCommandResponse> setReferenceFrequency({
    required String deviceId,
    required double frequency,
  }) {
    return vfdApiService.setReferenceFrequency(
      deviceId: deviceId,
      referenceFrequency: frequency,
    );
  }
}