import "package:dio/dio.dart";
import "package:smart_iot_app/src/features/auth/data/%20models/login_response.dart";

import "../../../../core/constant/api_endpoints.dart";
import "../../../../core/error/app_exception.dart";
import "../../../../core/network/api_client.dart";


class AuthApiService {
  final ApiClient apiClient;

  AuthApiService(this.apiClient);

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          "email": email.trim(),
          "password": password.trim(),
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw AppException(message: "Invalid login response");
      }

      return LoginResponse.fromJson(data);
    } on DioException catch (e) {
      throw apiClient.handleError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        message: "Login failed: ${e.toString()}",
      );
    }
  }
}