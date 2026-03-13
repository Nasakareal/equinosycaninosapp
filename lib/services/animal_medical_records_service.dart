import '../core/api_config.dart';
import '../models/animal_medical_record.dart';
import 'api_client.dart';

class AnimalMedicalRecordsService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  List<T> _listOf<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    final list = (raw as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<AnimalMedicalRecord>> index(int animalId) async {
    final body = await _api.getJson(_uri('/animales/$animalId/medico'));
    return _listOf(body['data'], AnimalMedicalRecord.fromJson);
  }

  Future<AnimalMedicalRecord> create(
    int animalId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(_uri('/animales/$animalId/medico'), payload);
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalMedicalRecord.fromJson(data);
  }

  Future<AnimalMedicalRecord> update(
    int animalId,
    int recordId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.putJson(
      _uri('/animales/$animalId/medico/$recordId'),
      payload,
    );
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return AnimalMedicalRecord.fromJson(data);
  }

  Future<void> delete(int animalId, int recordId) async {
    await _api.deleteJson(_uri('/animales/$animalId/medico/$recordId'));
  }
}
