import "package:dio/dio.dart";
import "package:smart_iot_app/src/core/constant/api_endpoints.dart";
import "package:smart_iot_app/src/core/constant/storage/auth_storage.dart";


import "../error/app_exception.dart";
import "../storage/auth_storage.dart";

class ApiClient {
  final AuthStorage authStorage;

  late final Dio dio;

  ApiClient({
    required this.authStorage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await authStorage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
      ),
    );
  }

  AppException handleError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = "Something went wrong";

    if (data is Map<String, dynamic>) {
      message = data["detail"]?.toString() ??
          data["message"]?.toString() ??
          error.message ??
          message;
    } else if (data is String && data.isNotEmpty) {
      message = data;
    } else {
      message = error.message ?? message;
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      message = "Connection timeout. Please check your internet.";
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = "Server response timeout.";
    } else if (error.type == DioExceptionType.connectionError) {
      message = "Could not connect to server.";
    }

    return AppException(
      message: message,
      statusCode: statusCode,
    );
  }
}