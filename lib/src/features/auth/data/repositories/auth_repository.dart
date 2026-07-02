import "package:flutter/cupertino.dart";
import "package:shared_preferences/shared_preferences.dart";
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



// Aapke AuthRepository ya ViewModel ke login method ke andar:
  Future<void> performLogin(String email, String password) async {
    try {
      // 1. API Call karein
      final LoginResponse response = await authApiService.login(
        email: email,
        password: password,
      );

      // 2. Token ko local storage mein save karein
      // Maan lijiye aapke LoginResponse model ke andar token ka naam 'accessToken' ya 'token' hai
      final String? token = response.accessToken;

      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", token); // INTERCEPTOR IS KEY KO READ KAREGA
        debugPrint("🔒 Token successfully saved to SharedPreferences");
      }

      // 3. Go to HomeScreen...
    } catch (e) {
      debugPrint("❌ Login Error: $e");
    }
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