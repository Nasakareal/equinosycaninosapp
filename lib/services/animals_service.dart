import '../core/api_config.dart';
import '../models/animal.dart';
import '../models/paginated.dart';
import 'api_client.dart';

class AnimalsService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
  }

  Future<Paginated<Animal>> index({
    String? tipo,
    String? estatus,
    String? buscar,
    int perPage = 20,
    int page = 1,
  }) async {
    final qp = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
    };

    if (tipo != null && tipo.trim().isNotEmpty) {
      qp['tipo'] = tipo.trim();
    }
    if (estatus != null && estatus.trim().isNotEmpty) {
      qp['estatus'] = estatus.trim();
    }
    if (buscar != null && buscar.trim().isNotEmpty) {
      qp['buscar'] = buscar.trim();
    }

    final body = await _api.getJson(_uri('/animales', qp));
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return Paginated<Animal>.fromLaravel(data, Animal.fromJson);
  }

  Future<Animal> show(int animalId) async {
    final body = await _api.getJson(_uri('/animales/$animalId'));
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return Animal.fromJson(data);
  }

  Future<Animal> create(Map<String, dynamic> payload) async {
    final body = await _api.postJson(_uri('/animales'), payload);
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return Animal.fromJson(data);
  }

  Future<Animal> update(int animalId, Map<String, dynamic> payload) async {
    final body = await _api.putJson(_uri('/animales/$animalId'), payload);
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return Animal.fromJson(data);
  }

  Future<void> destroy(int id) async {
    await _api.deleteJson(_uri('/animales/$id'));
  }
}
