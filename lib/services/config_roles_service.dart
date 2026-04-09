import '../core/api_config.dart';
import '../models/admin_role.dart';
import 'api_client.dart';

class ConfigRolesService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: query);
  }

  Future<List<AdminRole>> index() async {
    final body = await _api.getJson(_uri('/configuracion/roles'));
    final raw = body['data'];
    if (raw is! List) {
      throw Exception('Respuesta invalida al cargar roles');
    }
    return raw
        .whereType<Map>()
        .map((item) => AdminRole.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<AdminRole> create(String name) async {
    final body = await _api.postJson(_uri('/configuracion/roles'), {
      'name': name,
    });
    final raw = body['data'];
    if (raw is! Map) {
      throw Exception('Respuesta invalida al crear rol');
    }
    return AdminRole.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<AdminRole> update(int id, String name) async {
    final body = await _api.putJson(_uri('/configuracion/roles/$id'), {
      'name': name,
    });
    final raw = body['data'];
    if (raw is! Map) {
      throw Exception('Respuesta invalida al actualizar rol');
    }
    return AdminRole.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> delete(int id) async {
    await _api.deleteJson(_uri('/configuracion/roles/$id'));
  }

  Future<AdminRolePermissionsPayload> permissions(int id) async {
    final body = await _api.getJson(
      _uri('/configuracion/roles/$id/permissions'),
    );
    final raw = body['data'];
    if (raw is! Map<String, dynamic>) {
      throw Exception('Respuesta invalida al cargar permisos del rol');
    }

    final roleRaw = raw['role'];
    final permissionIdsRaw = raw['role_permissions'];
    final groupedRaw = raw['grouped_permissions'];

    return AdminRolePermissionsPayload(
      role: AdminRole.fromJson(
        roleRaw is Map<String, dynamic>
            ? roleRaw
            : {
                'id': 0,
                'name': '',
                'guard_name': '',
                'users_count': 0,
                'permissions_count': 0,
              },
      ),
      rolePermissionIds: permissionIdsRaw is List
          ? permissionIdsRaw
                .map((item) => int.tryParse(item.toString()) ?? 0)
                .where((item) => item > 0)
                .toList()
          : const [],
      groupedPermissions: groupedRaw is List
          ? groupedRaw
                .whereType<Map>()
                .map(
                  (item) => AdminPermissionGroup.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }

  Future<void> assignPermissions(int id, List<int> permissions) async {
    await _api.postJson(_uri('/configuracion/roles/$id/permissions'), {
      'permissions': permissions,
    });
  }
}
