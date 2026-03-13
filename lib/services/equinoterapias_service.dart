import '../core/api_config.dart';
import '../models/equinoterapia.dart';
import 'api_client.dart';

class EquinoterapiasService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
  }

  Future<EquinoterapiaIndexData> index({
    String? fechaInicio,
    String? fechaFin,
    String? semanaInicio,
    int page = 1,
  }) async {
    final query = <String, String>{'page': page.toString()};
    if (fechaInicio != null && fechaInicio.trim().isNotEmpty) {
      query['fecha_inicio'] = fechaInicio.trim();
    }
    if (fechaFin != null && fechaFin.trim().isNotEmpty) {
      query['fecha_fin'] = fechaFin.trim();
    }
    if (semanaInicio != null && semanaInicio.trim().isNotEmpty) {
      query['semana_inicio'] = semanaInicio.trim();
    }

    final body = await _api.getJson(_uri('/equinoterapias', query));
    final data = Map<String, dynamic>.from(body['data'] as Map);
    final resumen = Map<String, dynamic>.from(body['resumen_semana'] as Map);
    final items = ((data['data'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => EquinoterapiaReporte.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return EquinoterapiaIndexData(
      items: items,
      currentPage: _toInt(data['current_page'], 1),
      lastPage: _toInt(data['last_page'], 1),
      total: _toInt(data['total'], items.length),
      semanaInicio: (resumen['inicio'] ?? '').toString(),
      semanaFin: (resumen['fin'] ?? '').toString(),
      resumenSemana: EquinoterapiaTotales.fromJson(
        Map<String, dynamic>.from(resumen['totales'] as Map),
      ),
    );
  }

  Future<EquinoterapiaShowData> show(int id) async {
    final body = await _api.getJson(_uri('/equinoterapias/$id'));
    final data = EquinoterapiaReporte.fromJson(Map<String, dynamic>.from(body['data'] as Map));
    final totales = EquinoterapiaTotales.fromJson(Map<String, dynamic>.from(body['totales'] as Map));
    final whatsapp = Map<String, dynamic>.from(body['whatsapp'] as Map);

    return EquinoterapiaShowData(
      reporte: data,
      totales: totales,
      whatsappMensaje: (whatsapp['mensaje'] ?? '').toString(),
      whatsappUrl: (whatsapp['url'] ?? '').toString(),
    );
  }

  Future<EquinoterapiaReporte> create(Map<String, dynamic> payload) async {
    final body = await _api.postJson(_uri('/equinoterapias'), payload);
    return EquinoterapiaReporte.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<EquinoterapiaReporte> update(int id, Map<String, dynamic> payload) async {
    final body = await _api.putJson(_uri('/equinoterapias/$id'), payload);
    return EquinoterapiaReporte.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<void> delete(int id) async {
    await _api.deleteJson(_uri('/equinoterapias/$id'));
  }

  int _toInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }
}
