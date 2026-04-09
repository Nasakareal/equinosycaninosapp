class AdminRole {
  final int id;
  final String name;
  final String guardName;
  final int usersCount;
  final int permissionsCount;
  final String? createdAt;
  final String? updatedAt;

  const AdminRole({
    required this.id,
    required this.name,
    required this.guardName,
    required this.usersCount,
    required this.permissionsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminRole.fromJson(Map<String, dynamic> json) {
    return AdminRole(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      guardName: (json['guard_name'] ?? '').toString(),
      usersCount: _toInt(json['users_count']),
      permissionsCount: _toInt(json['permissions_count']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AdminPermission {
  final int id;
  final String name;

  const AdminPermission({required this.id, required this.name});

  factory AdminPermission.fromJson(Map<String, dynamic> json) {
    return AdminPermission(
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AdminPermissionGroup {
  final String group;
  final List<AdminPermission> permissions;

  const AdminPermissionGroup({required this.group, required this.permissions});

  factory AdminPermissionGroup.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'];
    return AdminPermissionGroup(
      group: (json['group'] ?? 'Otros').toString(),
      permissions: rawPermissions is List
          ? rawPermissions
                .whereType<Map>()
                .map(
                  (item) =>
                      AdminPermission.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }
}

class AdminRolePermissionsPayload {
  final AdminRole role;
  final List<int> rolePermissionIds;
  final List<AdminPermissionGroup> groupedPermissions;

  const AdminRolePermissionsPayload({
    required this.role,
    required this.rolePermissionIds,
    required this.groupedPermissions,
  });
}
