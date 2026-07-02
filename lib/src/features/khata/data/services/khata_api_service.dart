import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../models/khata_entry_model.dart";

class KhataApiService {
  final ApiClient apiClient;

  KhataApiService(this.apiClient);
  Future<List<KhataEntryModel>> getEntries() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.khata);

      final data = response.data;

      if (data is! List) {
        throw AppException(message: "Invalid Khata response");
      }

      return data
          .whereType<Map>()
          .map(
            (item) => KhataEntryModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to load Khata: ${e.toString()}",
      );
    }
  }

  Future<KhataEntryModel> createEntry({
    required KhataEntryModel entry,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.khata,
        data: entry.toJson(),
      );

      return KhataEntryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: "Failed to create Khata: ${e.toString()}");
    }
  }

  Future<KhataEntryModel> updateEntry({
    required KhataEntryModel entry,
  }) async {
    try {
      final id = entry.id;

      if (id == null || id.isEmpty) {
        throw AppException(message: "Khata entry ID missing");
      }

      final response = await apiClient.dio.put(
        ApiEndpoints.khataById(id),
        data: entry.toJson(),
      );

      return KhataEntryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: "Failed to update Khata: ${e.toString()}");
    }
  }

  Future<KhataEntryModel> addPayment({
    required String entryId,
    required double amount,
    String? note,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.khataPayment(entryId),
        data: {
          "amount": amount,
          "note": note,
        },
      );

      return KhataEntryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(message: "Failed to add payment: ${e.toString()}");
    }
  }

  Future<void> deleteEntry({
    required String id,
  }) async {
    try {
      await apiClient.dio.delete(ApiEndpoints.khataById(id));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } catch (e) {
      throw AppException(message: "Failed to delete Khata: ${e.toString()}");
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw AppException(message: "Invalid server response");
  }
}