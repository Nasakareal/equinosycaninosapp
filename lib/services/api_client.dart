import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _auth.getToken();
    final h = <String, String>{'Accept': 'application/json'};
    if (json) {
      h['Content-Type'] = 'application/json';
    }
    if (token != null && token.trim().isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  Exception _asException(http.Response res) {
    String msg = 'Error de servidor';
    try {
      final j = jsonDecode(res.body);
      if (j is Map<String, dynamic>) {
        msg = (j['message'] ?? j['error'] ?? msg).toString();
      }
    } catch (_) {}
    return Exception(msg);
  }

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final res = await http.get(uri, headers: await _headers(json: false));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    final j = jsonDecode(res.body);
    if (j is! Map<String, dynamic>) {
      throw Exception('Respuesta inválida');
    }
    return j;
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      uri,
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    final j = jsonDecode(res.body);
    if (j is! Map<String, dynamic>) {
      throw Exception('Respuesta inválida');
    }
    return j;
  }

  Future<Map<String, dynamic>> putJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final res = await http.put(
      uri,
      headers: await _headers(json: true),
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    final j = jsonDecode(res.body);
    if (j is! Map<String, dynamic>) {
      throw Exception('Respuesta inválida');
    }
    return j;
  }

  Future<Map<String, dynamic>> deleteJson(Uri uri) async {
    final res = await http.delete(uri, headers: await _headers(json: false));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    final j = jsonDecode(res.body);
    if (j is! Map<String, dynamic>) {
      throw Exception('Respuesta inválida');
    }
    return j;
  }
}
