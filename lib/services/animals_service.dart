import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/animal.dart';
import '../models/paginated.dart';
import 'auth_service.dart';

class AnimalsService {
  static const String baseUrl = 'https://equinosycaninos.com/api';

  Future<Paginated<Animal>> index({
    String? tipo,
    String? estatus,
    String? buscar,
    int perPage = 20,
    int page = 1,
  }) async {
    final token = await AuthService().getToken();

    final qp = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
    };

    if (tipo != null && tipo.trim().isNotEmpty) qp['tipo'] = tipo.trim();
    if (estatus != null && estatus.trim().isNotEmpty)
      qp['estatus'] = estatus.trim();
    if (buscar != null && buscar.trim().isNotEmpty)
      qp['buscar'] = buscar.trim();

    final uri = Uri.parse('$baseUrl/animales').replace(queryParameters: qp);

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'Error al cargar animales';
      try {
        final j = jsonDecode(res.body);
        msg = (j['message'] ?? j['error'] ?? msg).toString();
      } catch (_) {}
      throw Exception(msg);
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(body['data'] as Map);

    return Paginated<Animal>.fromLaravel(data, (m) => Animal.fromJson(m));
  }

  Future<Animal> show(int animalId) async {
    final token = await AuthService().getToken();
    final uri = Uri.parse('$baseUrl/animales/$animalId');

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'Error al cargar detalle';
      try {
        final j = jsonDecode(res.body);
        msg = (j['message'] ?? j['error'] ?? msg).toString();
      } catch (_) {}
      throw Exception(msg);
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = Map<String, dynamic>.from(body['data'] as Map);

    return Animal.fromJson(data);
  }

  Future<void> destroy(int id) async {
    final token = await AuthService().getToken();
    final uri = Uri.parse('$baseUrl/animales/$id');

    final res = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'No se pudo eliminar';
      try {
        final j = jsonDecode(res.body);
        msg = (j['message'] ?? j['error'] ?? msg).toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
