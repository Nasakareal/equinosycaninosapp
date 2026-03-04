import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

class AuthService {
  static const String baseUrl = 'https://equinosycaninos.com/api';
  static const String _tokenKey = 'auth_token';

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/login');

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

    return user;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_tokenKey);
    if (t == null || t.trim().isEmpty) return null;
    return t;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
