import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';
import '../core/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    Object? lastError;

    for (final uri in ApiConfig.uriCandidates('/login')) {
      try {
        final res = await http.post(
          uri,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (res.statusCode < 200 || res.statusCode >= 300) {
          String msg = 'Credenciales inválidas';
          try {
            final j = jsonDecode(res.body);
            msg = (j['message'] ?? j['error'] ?? msg).toString();
          } catch (_) {}
          throw Exception(msg);
        }

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final user = AuthUser.fromJson(data);

        if (user.token.isEmpty) {
          throw Exception('No se recibió token');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, user.token);
        await prefs.setString(_userKey, jsonEncode(user.toJson()));

        return user;
      } catch (e) {
        lastError = e;
        if (_isTransportException(e)) {
          continue;
        }
        rethrow;
      }
    }

    throw Exception(_friendlyTransportMessage(lastError));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_tokenKey);
    if (t == null || t.trim().isEmpty) return null;
    return t;
  }

  Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      return AuthUser.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser?> resolveCurrentUser({bool forceRefresh = false}) async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) return null;

    final storedUser = await getCurrentUser();
    if (!forceRefresh &&
        storedUser != null &&
        (storedUser.roles.isNotEmpty || storedUser.permissions.isNotEmpty)) {
      return storedUser;
    }

    for (final endpoint in const ['/user', '/me', '/auth/me']) {
      for (final uri in ApiConfig.uriCandidates(endpoint)) {
        try {
          final res = await http.get(uri, headers: await _headers(json: false));

          if (res.statusCode < 200 || res.statusCode >= 300) {
            continue;
          }

          final body = jsonDecode(res.body);
          if (body is! Map<String, dynamic>) {
            continue;
          }

          final user = AuthUser.fromJson({...body, 'token': token});

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(user.toJson()));
          return user;
        } catch (_) {
          continue;
        }
      }
    }

    return storedUser;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await getToken();
    final h = <String, String>{'Accept': 'application/json'};
    if (json) {
      h['Content-Type'] = 'application/json';
    }
    if (token != null && token.trim().isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  bool _isTransportException(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('failed host lookup') ||
        message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('connection closed') ||
        message.contains('connection refused');
  }

  String _friendlyTransportMessage(Object? error) {
    final message = error?.toString() ?? '';
    if (_isTransportException(error ?? '')) {
      return 'No se pudo conectar con el servidor. Verifica internet, DNS o la URL del API.';
    }
    return message.replaceFirst('Exception: ', '');
  }
}
