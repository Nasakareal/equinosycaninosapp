import '../core/api_config.dart';
import '../models/admin_user.dart';
import 'api_client.dart';
import 'config_roles_service.dart';

class ConfigUsersService {
  final ApiClient _api = ApiClient();
  final ConfigRolesService _rolesService = ConfigRolesService();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: query);
  }

  Future<List<AdminUser>> index() async {
    final body = await _api.getJson(_uri('/configuracion/usuarios'));
    final raw = body['data'];
    if (raw is! List) {
      throw Exception('Respuesta invalida al cargar usuarios');
    }
    return raw
        .whereType<Map>()
        .map((item) => AdminUser.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<AdminUser> show(int id) async {
    final body = await _api.getJson(_uri('/configuracion/usuarios/$id'));
    final raw = body['data'];
    if (raw is! Map) {
      throw Exception('Respuesta invalida al cargar usuario');
    }
    return AdminUser.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<AdminUser> create(Map<String, dynamic> payload) async {
    final body = await _api.postJson(_uri('/configuracion/usuarios'), payload);
    final raw = body['data'];
    if (raw is! Map) {
      throw Exception('Respuesta invalida al crear usuario');
    }
    return AdminUser.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<AdminUser> update(int id, Map<String, dynamic> payload) async {
    final body = await _api.putJson(
      _uri('/configuracion/usuarios/$id'),
      payload,
    );
    final raw = body['data'];
    if (raw is! Map) {
      throw Exception('Respuesta invalida al actualizar usuario');
    }
    return AdminUser.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> delete(int id) async {
    await _api.deleteJson(_uri('/configuracion/usuarios/$id'));
  }

  Future<List<String>> catalogRoles() async {
    try {
      final body = await _api.getJson(
        _uri('/configuracion/usuarios/catalogos'),
      );
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        final rawRoles = data['roles'];
        if (rawRoles is List) {
          return rawRoles
              .whereType<Map>()
              .map((item) => (item['name'] ?? '').toString().trim())
              .where((item) => item.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {}

    final roles = await _rolesService.index();
    return roles.map((role) => role.name).toList();
  }
}
