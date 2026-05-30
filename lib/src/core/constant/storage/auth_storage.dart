import "package:shared_preferences/shared_preferences.dart";

class AuthSession {
  final String? token;
  final String? userId;
  final String? email;
  final String? name;
  final String? deviceId;

  const AuthSession({
    this.token,
    this.userId,
    this.email,
    this.name,
    this.deviceId,
  });

  bool get hasValidLogin {
    return token != null &&
        token!.trim().isNotEmpty &&
        userId != null &&
        userId!.trim().isNotEmpty;
  }
}

class AuthStorage {
  static const String _tokenKey = "access_token";
  static const String _userIdKey = "user_id";
  static const String _emailKey = "email";
  static const String _nameKey = "name";
  static const String _deviceIdKey = "selected_device_id";

  Future<void> saveAuth({
    required String token,
    required String userId,
    required String email,
    String? name,
    String? deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_emailKey, email);

    if (name != null && name.trim().isNotEmpty) {
      await prefs.setString(_nameKey, name);
    }

    if (deviceId != null && deviceId.trim().isNotEmpty) {
      await prefs.setString(_deviceIdKey, deviceId);
    }
  }

  Future<void> saveSelectedDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<String?> getSelectedDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  Future<AuthSession> getSession() async {
    final prefs = await SharedPreferences.getInstance();

    return AuthSession(
      token: prefs.getString(_tokenKey),
      userId: prefs.getString(_userIdKey),
      email: prefs.getString(_emailKey),
      name: prefs.getString(_nameKey),
      deviceId: prefs.getString(_deviceIdKey),
    );
  }

  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session.hasValidLogin;
  }

  Future<void> clearSelectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_deviceIdKey);
  }
}