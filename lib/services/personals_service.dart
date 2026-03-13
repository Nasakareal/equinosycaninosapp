import '../core/api_config.dart';
import '../models/option_item.dart';
import '../models/personal_detail.dart';
import '../models/personal_summary.dart';
import 'api_client.dart';

class PersonalCatalogs {
  final List<OptionItem> areas;
  final List<OptionItem> turnos;

  const PersonalCatalogs({required this.areas, required this.turnos});
}

class PersonalsService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
  }

  List<T> _listOf<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
    final list = (raw as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<PersonalSummary>> index({
    String? search,
    bool? activo,
    int? turnoId,
    String? dependencia,
  }) async {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) query['search'] = search.trim();
    if (activo != null) query['activo'] = activo ? '1' : '0';
    if (turnoId != null) query['turno_id'] = turnoId.toString();
    if (dependencia != null && dependencia.trim().isNotEmpty) {
      query['dependencia'] = dependencia.trim();
    }

    final body = await _api.getJson(_uri('/personal', query.isEmpty ? null : query));
    return _listOf(body['data'], PersonalSummary.fromJson);
  }

  Future<PersonalDetail> show(int personalId) async {
    final body = await _api.getJson(_uri('/personal/$personalId'));
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return PersonalDetail.fromJson(data);
  }

  Future<PersonalCatalogs> catalogs() async {
    final body = await _api.getJson(_uri('/personal/catalogos'));
    final data = Map<String, dynamic>.from(body['data'] as Map);
    return PersonalCatalogs(
      areas: _listOf(data['areas'], (m) => OptionItem(id: _toInt(m['id']), label: (m['nombre'] ?? 'Area').toString())),
      turnos: _listOf(data['turnos'], OptionItem.fromTurnoJson),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }
}
