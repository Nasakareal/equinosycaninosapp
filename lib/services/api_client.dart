import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
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

  Map<String, dynamic> _decodeMap(String body) {
    try {
      final j = jsonDecode(body);
      if (j is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida');
      }
      return j;
    } on FormatException {
      final preview = body.trimLeft();
      if (preview.startsWith('<!DOCTYPE html') || preview.startsWith('<html')) {
        throw Exception(
          'El servidor devolvio HTML en lugar de JSON. Revisa sesion, permisos o la ruta del endpoint.',
        );
      }
      throw Exception('Respuesta inválida del servidor');
    }
  }

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final res = await _sendWithFallback(
      uri,
      (candidate) async =>
          http.get(candidate, headers: await _headers(json: false)),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    return _decodeMap(res.body);
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final res = await _sendWithFallback(
      uri,
      (candidate) async => http.post(
        candidate,
        headers: await _headers(json: true),
        body: jsonEncode(body),
      ),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    return _decodeMap(res.body);
  }

  Future<Map<String, dynamic>> putJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final res = await _sendWithFallback(
      uri,
      (candidate) async => http.put(
        candidate,
        headers: await _headers(json: true),
        body: jsonEncode(body),
      ),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    return _decodeMap(res.body);
  }

  Future<Map<String, dynamic>> deleteJson(Uri uri) async {
    final res = await _sendWithFallback(
      uri,
      (candidate) async =>
          http.delete(candidate, headers: await _headers(json: false)),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _asException(res);
    }
    return _decodeMap(res.body);
  }

  Future<http.Response> _sendWithFallback(
    Uri uri,
    Future<http.Response> Function(Uri candidate) sender,
  ) async {
    final candidates = <Uri>[uri, ...ApiConfig.alternativeUrisFor(uri)];
    Object? lastError;

    for (final candidate in candidates) {
      try {
        return await sender(candidate);
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

  bool _isTransportException(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('failed host lookup') ||
        message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('connection closed') ||
        message.contains('connection refused');
  }

  String _friendlyTransportMessage(Object? error) {
    if (_isTransportException(error ?? '')) {
      return 'No se pudo conectar con el servidor. Verifica internet, DNS o la URL del API.';
    }
    return (error?.toString() ?? 'Error de conexion').replaceFirst(
      'Exception: ',
      '',
    );
  }
}
