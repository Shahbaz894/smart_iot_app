class AuthUser {
  final String id;
  final String email;
  final String name;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json["id"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
    );
  }
}