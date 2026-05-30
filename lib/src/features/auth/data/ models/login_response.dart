import "auth_user.dart";

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final AuthUser user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json["access_token"]?.toString() ?? "",
      tokenType: json["token_type"]?.toString() ?? "",
      user: AuthUser.fromJson(
        json["user"] as Map<String, dynamic>,
      ),
    );
  }
}