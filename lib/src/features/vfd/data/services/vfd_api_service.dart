import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";

import "../../../../core/network/api_client.dart";
import "../models/vfd_command_response.dart";
import "../models/vfd_reference_frequency_request.dart";
import "../models/vfd_reset_request.dart";

class VfdApiService {
  final ApiClient apiClient;

  VfdApiService(this.apiClient);

  Future<VfdCommandResponse> resetVfd({
    required String deviceId,
    bool confirm = true,
  }) async {
    try {
      final request = VfdResetRequest(confirm: confirm);

      final response = await apiClient.dio.post(
        ApiEndpoints.vfdReset(deviceId),
        data: request.toJson(),
      );

      return VfdCommandResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    }
  }

  Future<VfdCommandResponse> setReferenceFrequency({
    required String deviceId,
    required double referenceFrequency,
  }) async {
    try {
      final request = VfdReferenceFrequencyRequest(
        referenceFrequency: referenceFrequency,
      );

      final response = await apiClient.dio.post(
        ApiEndpoints.vfdReferenceFrequency(deviceId),
        data: request.toJson(),
      );

      return VfdCommandResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    }
  }
}