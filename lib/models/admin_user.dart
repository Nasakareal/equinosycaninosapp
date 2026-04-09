class AdminUser {
  final int id;
  final String name;
  final String email;
  final String? area;
  final String estado;
  final List<String> roles;
  final String? createdAt;
  final String? updatedAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.area,
    required this.estado,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  String get primaryRole => roles.isEmpty ? '' : roles.first;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      area: json['area']?.toString(),
      estado: (json['estado'] ?? '').toString(),
      roles: _toStringList(json['roles']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
