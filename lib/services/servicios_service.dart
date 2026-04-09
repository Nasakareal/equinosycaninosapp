import '../core/api_config.dart';
import '../models/animal.dart';
import '../models/option_item.dart';
import '../models/paginated.dart';
import '../models/personal_summary.dart';
import '../models/servicio.dart';
import 'animals_service.dart';
import 'api_client.dart';
import 'personals_service.dart';

class ServicioFormCatalogs {
  final List<OptionItem> personals;
  final List<OptionItem> caninos;
  final List<OptionItem> equinos;

  const ServicioFormCatalogs({
    required this.personals,
    required this.caninos,
    required this.equinos,
  });
}

class ServiciosService {
  final ApiClient _api = ApiClient();
  final PersonalsService _personals = PersonalsService();
  final AnimalsService _animals = AnimalsService();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: query);
  }

  Future<Paginated<Servicio>> index({
    String? buscar,
    String? fechaInicio,
    String? fechaFin,
    String? estatusServicio,
    String? categoriaRegistro,
    String? tipoServicio,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (buscar != null && buscar.trim().isNotEmpty) {
      query['buscar'] = buscar.trim();
    }
    if (fechaInicio != null && fechaInicio.trim().isNotEmpty) {
      query['fecha_inicio'] = fechaInicio.trim();
    }
    if (fechaFin != null && fechaFin.trim().isNotEmpty) {
      query['fecha_fin'] = fechaFin.trim();
    }
    if (estatusServicio != null && estatusServicio.trim().isNotEmpty) {
      query['estatus_servicio'] = estatusServicio.trim();
    }
    if (categoriaRegistro != null && categoriaRegistro.trim().isNotEmpty) {
      query['categoria_registro'] = categoriaRegistro.trim();
    }
    if (tipoServicio != null && tipoServicio.trim().isNotEmpty) {
      query['tipo_servicio'] = tipoServicio.trim();
    }

    final body = await _api.getJson(_uri('/servicios', query));
    final raw = body['data'];
    if (raw is Map<String, dynamic>) {
      return Paginated<Servicio>.fromLaravel(raw, Servicio.fromJson);
    }
    if (raw is List) {
      final items = raw
          .whereType<Map>()
          .map((e) => Servicio.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Paginated<Servicio>(
        items: items,
        currentPage: 1,
        lastPage: 1,
        total: items.length,
        perPage: items.length,
      );
    }
    throw Exception('Respuesta inválida');
  }

  Future<Servicio> show(int id) async {
    final body = await _api.getJson(_uri('/servicios/$id'));
    return Servicio.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<Servicio> create(Map<String, dynamic> payload) async {
    final body = await _api.postJson(_uri('/servicios'), payload);
    return Servicio.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<Servicio> update(int id, Map<String, dynamic> payload) async {
    final body = await _api.putJson(_uri('/servicios/$id'), payload);
    return Servicio.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<void> delete(int id) async {
    await _api.deleteJson(_uri('/servicios/$id'));
  }

  Future<ServicioFormCatalogs> catalogs() async {
    final personals = await _safeLoad(
      () async => (await _personals.index()).map(_personalToOption).toList(),
    );
    final caninos = await _safeLoad(
      () async => (await _animals.index(
        tipo: 'CANINO',
        perPage: 100,
      )).items.map(_animalToOption).toList(),
    );
    final equinos = await _safeLoad(
      () async => (await _animals.index(
        tipo: 'EQUINO',
        perPage: 100,
      )).items.map(_animalToOption).toList(),
    );

    return ServicioFormCatalogs(
      personals: personals,
      caninos: caninos,
      equinos: equinos,
    );
  }

  Future<List<OptionItem>> _safeLoad(
    Future<List<OptionItem>> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (_) {
      return const [];
    }
  }

  OptionItem _personalToOption(PersonalSummary item) {
    final subtitle = [item.grado, item.cargo, item.crp]
        .where((x) => x != null && x.trim().isNotEmpty)
        .map((x) => x!.trim())
        .join(' • ');
    return OptionItem(
      id: item.id,
      label: item.nombres,
      subtitle: subtitle.isEmpty ? null : subtitle,
    );
  }

  OptionItem _animalToOption(Animal item) {
    final subtitle = [item.tipo, item.especialidad]
        .where((x) => x != null && x.trim().isNotEmpty)
        .map((x) => x!.trim())
        .join(' • ');
    return OptionItem(
      id: item.id,
      label: item.nombre,
      subtitle: subtitle.isEmpty ? null : subtitle,
    );
  }
}
