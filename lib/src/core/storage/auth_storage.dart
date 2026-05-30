// import "package:flutter_secure_storage/flutter_secure_storage.dart";
//
// class AuthStorage {
//   static const String _tokenKey = "smartwell_access_token";
//   static const String _userIdKey = "smartwell_user_id";
//   static const String _userEmailKey = "smartwell_user_email";
//   static const String _userNameKey = "smartwell_user_name";
//   static const String _deviceIdKey = "smartwell_device_id";
//
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//
//   Future<void> saveAuth({
//     required String token,
//     required String userId,
//     required String email,
//     required String name,
//     required String deviceId,
//   }) async {
//     await _storage.write(key: _tokenKey, value: token);
//     await _storage.write(key: _userIdKey, value: userId);
//     await _storage.write(key: _userEmailKey, value: email);
//     await _storage.write(key: _userNameKey, value: name);
//     await _storage.write(key: _deviceIdKey, value: deviceId);
//   }
//
//   Future<String?> getToken() {
//     return _storage.read(key: _tokenKey);
//   }
//
//   Future<String?> getUserId() {
//     return _storage.read(key: _userIdKey);
//   }
//
//   Future<String?> getUserEmail() {
//     return _storage.read(key: _userEmailKey);
//   }
//
//   Future<String?> getUserName() {
//     return _storage.read(key: _userNameKey);
//   }
//
//   Future<String?> getDeviceId() {
//     return _storage.read(key: _deviceIdKey);
//   }
//
//   Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     final deviceId = await getDeviceId();
//
//     return token != null &&
//         token.isNotEmpty &&
//         deviceId != null &&
//         deviceId.isNotEmpty;
//   }
//
//   Future<void> clear() async {
//     await _storage.deleteAll();
//   }
// }