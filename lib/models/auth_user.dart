class AuthUser {
  final String token;

  const AuthUser({required this.token});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ?? json['access_token'] ?? '').toString();
    return AuthUser(token: token);
  }
}
