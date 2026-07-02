import "package:smart_iot_app/src/core/constant/storage/auth_storage.dart";
import "package:smart_iot_app/src/features/auth/data/%20models/login_response.dart";

import "../../../../core/error/app_exception.dart";
import "../../../../core/storage/auth_storage.dart";

import "../services/auth_api_service.dart";

class AuthRepository {
  final AuthApiService authApiService;
  final AuthStorage authStorage;

  AuthRepository({
    required this.authApiService,
    required this.authStorage,
  });

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final loginResponse = await authApiService.login(
      email: email,
      password: password,
    );

    final user = loginResponse.user;

    if (loginResponse.accessToken.trim().isEmpty) {
      throw AppException(message: "Login token missing");
    }

    if (user.id.trim().isEmpty) {
      throw AppException(message: "Invalid user response");
    }

    await authStorage.saveAuth(
      token: loginResponse.accessToken,
      userId: user.id,
      email: user.email,
      name: user.name,
    );

    return loginResponse;
  }

  Future<AuthSession> getSavedSession() {
    return authStorage.getSession();
  }

  Future<void> saveSelectedDevice(String deviceId) async {
    if (deviceId.trim().isEmpty) {
      throw AppException(message: "Device ID missing");
    }

    await authStorage.saveSelectedDeviceId(deviceId.trim());
  }

  Future<void> logout() async {
    await authStorage.clear();
  }
}