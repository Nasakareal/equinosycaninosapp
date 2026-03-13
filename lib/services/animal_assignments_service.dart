import '../core/api_config.dart';
import '../models/animal_assignment.dart';
import '../models/option_item.dart';
import 'api_client.dart';

class AnimalAssignmentCatalogs {
  final List<OptionItem> personals;
  final List<OptionItem> patrols;
  final List<OptionItem> turnos;

  const AnimalAssignmentCatalogs({
    required this.personals,
    required this.patrols,
    required this.turnos,
  });
}

class AnimalAssignmentsService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  List<T> _listOf<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    final list = (raw as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AnimalAssignment>> index(int animalId) async {
    final body = await _api.getJson(_uri('/animales/$animalId/asignaciones'));
    return _listOf(body['data'], AnimalAssignment.fromJson);
  }

  Future<AnimalAssignmentCatalogs> catalogs(int animalId) async {
    final body = await _api.getJson(
      _uri('/animales/$animalId/asignaciones/catalogos'),
    );
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalAssignmentCatalogs(
      personals: _listOf(data['personals'], OptionItem.fromPersonalJson),
      patrols: _listOf(data['patrols'], OptionItem.fromPatrolJson),
      turnos: _listOf(data['turnos'], OptionItem.fromTurnoJson),
    );
  }

  Future<AnimalAssignment> create(int animalId, Map<String, dynamic> payload) async {
    final body = await _api.postJson(_uri('/animales/$animalId/asignaciones'), payload);
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalAssignment.fromJson(data);
  }

  Future<AnimalAssignment> update(
    int animalId,
    int assignmentId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.putJson(
      _uri('/animales/$animalId/asignaciones/$assignmentId'),
      payload,
    );
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalAssignment.fromJson(data);
  }

  Future<void> delete(int animalId, int assignmentId) async {
    await _api.deleteJson(_uri('/animales/$animalId/asignaciones/$assignmentId'));
  }
}
