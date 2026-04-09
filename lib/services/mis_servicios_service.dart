import '../core/api_config.dart';
import '../models/servicio.dart';
import 'api_client.dart';

class MisServicioReportesData {
  final Servicio servicio;
  final List<ServicioReporte> reportes;

  const MisServicioReportesData({
    required this.servicio,
    required this.reportes,
  });
}

class ServicioReporteWhatsappData {
  final String texto;
  final String url;

  const ServicioReporteWhatsappData({required this.texto, required this.url});
}

class ServicioReporteCompartirData {
  final String texto;
  final List<String> imagenes;

  const ServicioReporteCompartirData({
    required this.texto,
    required this.imagenes,
  });
}

class MisServiciosService {
  final ApiClient _api = ApiClient();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse(
      '${ApiConfig.baseUrl}$path',
    ).replace(queryParameters: query);
  }

  Future<List<Servicio>> index() async {
    final body = await _api.getJson(_uri('/mis-servicios'));
    final raw = (body['data'] as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Servicio.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Servicio> panel(int servicioId) async {
    final body = await _api.getJson(_uri('/mis-servicios/$servicioId'));
    return Servicio.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<MisServicioReportesData> reportesIndex(int servicioId) async {
    final body = await _api.getJson(
      _uri('/mis-servicios/$servicioId/reportes'),
    );
    return MisServicioReportesData(
      servicio: Servicio.fromJson(
        Map<String, dynamic>.from(body['servicio'] as Map),
      ),
      reportes: ((body['data'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ServicioReporte.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Future<ServicioReporte> reporteShow(int servicioId, int reporteId) async {
    final body = await _api.getJson(
      _uri('/mis-servicios/$servicioId/reportes/$reporteId'),
    );
    return ServicioReporte.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }

  Future<ServicioReporte> createReporte(
    int servicioId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.postJson(
      _uri('/mis-servicios/$servicioId/reportes'),
      payload,
    );
    return ServicioReporte.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }

  Future<ServicioReporte> updateReporte(
    int servicioId,
    int reporteId,
    Map<String, dynamic> payload,
  ) async {
    final body = await _api.putJson(
      _uri('/mis-servicios/$servicioId/reportes/$reporteId'),
      payload,
    );
    return ServicioReporte.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }

  Future<void> deleteReporte(int servicioId, int reporteId) async {
    await _api.deleteJson(
      _uri('/mis-servicios/$servicioId/reportes/$reporteId'),
    );
  }

  Future<void> deleteFoto(int servicioId, int reporteId, int fotoId) async {
    await _api.deleteJson(
      _uri('/mis-servicios/$servicioId/reportes/$reporteId/fotos/$fotoId'),
    );
  }

  Future<ServicioReporteWhatsappData> whatsapp(
    int servicioId,
    int reporteId,
  ) async {
    final body = await _api.getJson(
      _uri('/mis-servicios/$servicioId/reportes/$reporteId/whatsapp'),
    );
    return ServicioReporteWhatsappData(
      texto: (body['texto'] ?? '').toString(),
      url: (body['url'] ?? '').toString(),
    );
  }

  Future<ServicioReporteCompartirData> compartirNativo(
    int servicioId,
    int reporteId,
  ) async {
    final body = await _api.getJson(
      _uri('/mis-servicios/$servicioId/reportes/$reporteId/compartir-nativo'),
    );
    final imagenes = ((body['imagenes'] as List?) ?? const [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return ServicioReporteCompartirData(
      texto: (body['texto'] ?? '').toString(),
      imagenes: imagenes,
    );
  }
}
