// import "package:dio/dio.dart";
//
// import "../../../../core/constant/api_endpoints.dart";
// import "../../../../core/error/app_exception.dart";
// import "../../../../core/network/api_client.dart";
// import "../models/khata_entry_model.dart";
//
// class KhataApiService {
//   final ApiClient apiClient;
//
//   KhataApiService(this.apiClient);
//   Future<List<KhataEntryModel>> getEntries() async {
//     try {
//       final response = await apiClient.dio.get(ApiEndpoints.khata);
//
//       final data = response.data;
//
//       if (data is! List) {
//         throw AppException(message: "Invalid Khata response");
//       }
//
//       return data
//           .whereType<Map>()
//           .map(
//             (item) => KhataEntryModel.fromJson(
//           Map<String, dynamic>.from(item),
//         ),
//       )
//           .toList();
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } on AppException {
//       rethrow;
//     } catch (e) {
//       throw AppException(
//         message: "Failed to load Khata: ${e.toString()}",
//       );
//     }
//   }
//
//   Future<KhataEntryModel> createEntry({
//     required KhataEntryModel entry,
//   }) async {
//     try {
//       final response = await apiClient.dio.post(
//         ApiEndpoints.khata,
//         data: entry.toJson(),
//       );
//
//       return KhataEntryModel.fromJson(_asMap(response.data));
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } on AppException {
//       rethrow;
//     } catch (e) {
//       throw AppException(message: "Failed to create Khata: ${e.toString()}");
//     }
//   }
//
//   Future<KhataEntryModel> updateEntry({
//     required KhataEntryModel entry,
//   }) async {
//     try {
//       final id = entry.id;
//
//       if (id == null || id.isEmpty) {
//         throw AppException(message: "Khata entry ID missing");
//       }
//
//       final response = await apiClient.dio.put(
//         ApiEndpoints.khataById(id),
//         data: entry.toJson(),
//       );
//
//       return KhataEntryModel.fromJson(_asMap(response.data));
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } on AppException {
//       rethrow;
//     } catch (e) {
//       throw AppException(message: "Failed to update Khata: ${e.toString()}");
//     }
//   }
//
//   Future<KhataEntryModel> addPayment({
//     required String entryId,
//     required double amount,
//     String? note,
//   }) async {
//     try {
//       final response = await apiClient.dio.post(
//         ApiEndpoints.khataPayment(entryId),
//         data: {
//           "amount": amount,
//           "note": note,
//         },
//       );
//
//       return KhataEntryModel.fromJson(_asMap(response.data));
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } on AppException {
//       rethrow;
//     } catch (e) {
//       throw AppException(message: "Failed to add payment: ${e.toString()}");
//     }
//   }
//
//   Future<void> deleteEntry({
//     required String id,
//   }) async {
//     try {
//       await apiClient.dio.delete(ApiEndpoints.khataById(id));
//     } on DioException catch (e) {
//       throw apiClient.handleError(e);
//     } catch (e) {
//       throw AppException(message: "Failed to delete Khata: ${e.toString()}");
//     }
//   }
//
//   Map<String, dynamic> _asMap(dynamic data) {
//     if (data is Map<String, dynamic>) return data;
//     if (data is Map) return Map<String, dynamic>.from(data);
//
//     throw AppException(message: "Invalid server response");
//   }
// }
import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../models/khata_entry_model.dart";

import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../models/khata_entry_model.dart";

import "package:dio/dio.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";
import "../models/khata_entry_model.dart";

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
      throw AppException(
        message: "Failed to create Khata: ${e.toString()}",
      );
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

      final response = await apiClient.dio.patch(
        ApiEndpoints.khataById(id),
        data: {
          "customer_name": entry.customerName,
          "run_hours": entry.runHours,
          "price_per_hour": entry.pricePerHour,
          "total_bill": entry.totalBill,
          "cash_received": entry.cashReceived,
          "date": entry.date,
        },
      );

      return KhataEntryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to update Khata: ${e.toString()}",
      );
    }
  }

  /// Finalize an OPEN motor-linked Khata session.
  ///
  /// IMPORTANT:
  /// We deliberately send a minimal update payload.
  /// The backend already has motor_log_id on the Khata row and should use
  /// the linked MotorLog start_time/end_time as the authoritative duration.
  Future<KhataEntryModel> finalizeMotorSession({
    required KhataEntryModel entry,
  }) async {
    try {
      final id = entry.id?.trim() ?? "";

      if (id.isEmpty) {
        throw AppException(message: "Khata entry ID missing");
      }

      final response = await apiClient.dio.patch(
        ApiEndpoints.khataById(id),
        data: {
          // These fields are accepted by KhataUpdate.
          // run_hours=0 is valid for the open-session schema and the backend
          // replaces it from the linked MotorLog once end_time exists.
          "run_hours": entry.runHours,
          "price_per_hour": entry.pricePerHour,
          "cash_received": entry.cashReceived,
          "customer_name": entry.customerName,
          "date": entry.date,
        },
      );

      return KhataEntryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to finalize Khata session: ${e.toString()}",
      );
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

        // Backend KhataPayment expects cash_received.
        data: {
          "cash_received": amount,
        },
      );

      return KhataEntryModel.fromJson(_asMap(response.data));
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Failed to add payment: ${e.toString()}",
      );
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
      throw AppException(
        message: "Failed to delete Khata: ${e.toString()}",
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw AppException(message: "Invalid server response");
  }
}


