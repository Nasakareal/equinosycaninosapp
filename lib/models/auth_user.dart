class AuthUser {
  final String token;
  final int? id;
  final String? name;
  final String? email;
  final List<String> roles;
  final List<String> permissions;

  const AuthUser({
    required this.token,
    this.id,
    this.name,
    this.email,
    this.roles = const [],
    this.permissions = const [],
  });

  bool hasRole(String role) => roles.any((item) => item == role);

  bool hasPermission(String permission) =>
      permissions.any((item) => item == permission);

  bool get canViewConfiguraciones =>
      hasPermission('ver configuraciones') ||
      hasRole('Superadmin') ||
      hasRole('Administrador');

  bool get canViewUsuarios =>
      hasPermission('ver usuarios') ||
      hasRole('Superadmin') ||
      hasRole('Administrador');

  bool get canViewRoles =>
      hasPermission('ver roles') ||
      hasRole('Superadmin') ||
      hasRole('Administrador');

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final source = _extractUserSource(json);
    final token = (json['token'] ?? json['access_token'] ?? '').toString();

    return AuthUser(
      token: token,
      id: _parseInt(source['id']),
      name: source['name']?.toString(),
      email: source['email']?.toString(),
      roles: _extractNames(source['roles'] ?? json['roles']),
      permissions: _extractNames(source['permissions'] ?? json['permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'name': name,
      'email': email,
      'roles': roles,
      'permissions': permissions,
    };
  }

  static Map<String, dynamic> _extractUserSource(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }
      return data;
    }

    return json;
  }

  static List<String> _extractNames(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) {
          if (item is String) return item.trim();
          if (item is Map<String, dynamic>) {
            return (item['name'] ?? '').toString().trim();
          }
          return item.toString().trim();
        })
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
