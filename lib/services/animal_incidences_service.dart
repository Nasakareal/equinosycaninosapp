import '../core/api_config.dart';
import '../models/animal_incidence.dart';
import '../models/option_item.dart';
import 'api_client.dart';

class AnimalIncidenceCatalogs {
  final List<OptionItem> incidenceTypes;

  const AnimalIncidenceCatalogs({required this.incidenceTypes});
}

class AnimalIncidencesService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  List<T> _listOf<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    final list = (raw as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AnimalIncidence>> index(int animalId) async {
    final body = await _api.getJson(_uri('/animales/$animalId/incidencias'));
    return _listOf(body['data'], AnimalIncidence.fromJson);
  }

  Future<AnimalIncidenceCatalogs> catalogs(int animalId) async {
    final body = await _api.getJson(_uri('/animales/$animalId/incidencias/catalogos'));
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalIncidenceCatalogs(
      incidenceTypes: _listOf(
        data['incidence_types'],
        OptionItem.fromIncidenceTypeJson,
      ),
    );
  }

  Future<AnimalIncidence> create(int animalId, Map<String, dynamic> payload) async {
    final body = await _api.postJson(_uri('/animales/$animalId/incidencias'), payload);
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalIncidence.fromJson(data);
  }

  Future<AnimalIncidence> update(
    int animalId,
    int incidenceId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.putJson(
      _uri('/animales/$animalId/incidencias/$incidenceId'),
      payload,
    );
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalIncidence.fromJson(data);
  }

  Future<void> delete(int animalId, int incidenceId) async {
    await _api.deleteJson(_uri('/animales/$animalId/incidencias/$incidenceId'));
  }
}
