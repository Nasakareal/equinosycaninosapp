import '../core/api_config.dart';

class ServicioRelacionado {
  final int id;
  final String label;
  final String? subtitle;

  const ServicioRelacionado({
    required this.id,
    required this.label,
    this.subtitle,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory ServicioRelacionado.fromJson(
    Map<String, dynamic> json, {
    List<String> labelKeys = const ['nombre', 'name'],
    List<String> subtitleKeys = const ['descripcion', 'email'],
    String fallback = 'Sin dato',
  }) {
    String label = '';
    for (final key in labelKeys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        label = value;
        break;
      }
    }

    String? subtitle;
    for (final key in subtitleKeys) {
      final value = json[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        subtitle = value;
        break;
      }
    }

    return ServicioRelacionado(
      id: _toInt(json['id']),
      label: label.isEmpty ? fallback : label,
      subtitle: subtitle,
    );
  }
}

class ServicioEstadoFuerza {
  final int id;
  final int totalPersonal;
  final int totalCaninos;
  final int totalEquinos;
  final int totalPatrullas;
  final String? observaciones;

  const ServicioEstadoFuerza({
    required this.id,
    required this.totalPersonal,
    required this.totalCaninos,
    required this.totalEquinos,
    required this.totalPatrullas,
    this.observaciones,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory ServicioEstadoFuerza.fromJson(Map<String, dynamic> json) {
    return ServicioEstadoFuerza(
      id: _toInt(json['id']),
      totalPersonal: _toInt(json['total_personal']),
      totalCaninos: _toInt(json['total_caninos']),
      totalEquinos: _toInt(json['total_equinos']),
      totalPatrullas: _toInt(json['total_patrullas']),
      observaciones: json['observaciones']?.toString(),
    );
  }
}

class ServicioMovimiento {
  final int id;
  final String? fecha;
  final String? hora;
  final String? lugar;
  final String? descripcion;

  const ServicioMovimiento({
    required this.id,
    this.fecha,
    this.hora,
    this.lugar,
    this.descripcion,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory ServicioMovimiento.fromJson(Map<String, dynamic> json) {
    return ServicioMovimiento(
      id: _toInt(json['id']),
      fecha: json['fecha']?.toString(),
      hora: json['hora']?.toString(),
      lugar: json['lugar']?.toString(),
      descripcion: json['descripcion']?.toString(),
    );
  }
}

class ServicioParticipante {
  final int id;
  final String? nombre;
  final String? cargo;
  final String? observaciones;

  const ServicioParticipante({
    required this.id,
    this.nombre,
    this.cargo,
    this.observaciones,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory ServicioParticipante.fromJson(Map<String, dynamic> json) {
    return ServicioParticipante(
      id: _toInt(json['id']),
      nombre: json['nombre']?.toString(),
      cargo: json['cargo']?.toString(),
      observaciones: json['observaciones']?.toString(),
    );
  }
}

class ServicioCoordenada {
  final int id;
  final int orden;
  final String? lat;
  final String? lng;
  final String? referencia;

  const ServicioCoordenada({
    required this.id,
    required this.orden,
    this.lat,
    this.lng,
    this.referencia,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory ServicioCoordenada.fromJson(Map<String, dynamic> json) {
    return ServicioCoordenada(
      id: _toInt(json['id']),
      orden: _toInt(json['orden']),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      referencia: json['referencia']?.toString(),
    );
  }
}

class ServicioRecurso {
  final int id;
  final String? tipo;
  final String? descripcion;
  final String? cantidad;

  const ServicioRecurso({
    required this.id,
    this.tipo,
    this.descripcion,
    this.cantidad,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory ServicioRecurso.fromJson(Map<String, dynamic> json) {
    return ServicioRecurso(
      id: _toInt(json['id']),
      tipo: json['tipo']?.toString(),
      descripcion: json['descripcion']?.toString(),
      cantidad: json['cantidad']?.toString(),
    );
  }
}

class ServicioReporteFoto {
  final int id;
  final String? ruta;
  final String? nombreOriginal;
  final String? mime;
  final int size;
  final String? descripcion;
  final String? url;
  final String? createdAt;
  final String? updatedAt;

  const ServicioReporteFoto({
    required this.id,
    required this.size,
    this.ruta,
    this.nombreOriginal,
    this.mime,
    this.descripcion,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory ServicioReporteFoto.fromJson(Map<String, dynamic> json) {
    final ruta = json['ruta']?.toString();
    final rawUrl = json['url']?.toString();
    final resolvedUrl = (rawUrl != null && rawUrl.trim().isNotEmpty)
        ? rawUrl.trim()
        : ((ruta ?? '').trim().isEmpty ? null : ApiConfig.storageUrl(ruta!));

    return ServicioReporteFoto(
      id: _toInt(json['id']),
      ruta: ruta,
      nombreOriginal: json['nombre_original']?.toString(),
      mime: json['mime']?.toString(),
      size: _toInt(json['size']),
      descripcion: json['descripcion']?.toString(),
      url: resolvedUrl,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class ServicioReporte {
  final int id;
  final int? servicioId;
  final int? createdBy;
  final String? tipoReporte;
  final String? fecha;
  final String? hora;
  final String? municipio;
  final String? lugar;
  final String? asunto;
  final String? descripcion;
  final String? narrativa;
  final String? estadoFuerzaTexto;
  final String? accionesARealizar;
  final String? accionesRealizadas;
  final String? resultados;
  final String? datosPersonaAsegurada;
  final String? conclusion;
  final String? lat;
  final String? lng;
  final String? whatsappTexto;
  final String? createdAt;
  final String? updatedAt;
  final ServicioRelacionado? creador;
  final List<ServicioReporteFoto> fotos;

  const ServicioReporte({
    required this.id,
    this.servicioId,
    this.createdBy,
    this.tipoReporte,
    this.fecha,
    this.hora,
    this.municipio,
    this.lugar,
    this.asunto,
    this.descripcion,
    this.narrativa,
    this.estadoFuerzaTexto,
    this.accionesARealizar,
    this.accionesRealizadas,
    this.resultados,
    this.datosPersonaAsegurada,
    this.conclusion,
    this.lat,
    this.lng,
    this.whatsappTexto,
    this.createdAt,
    this.updatedAt,
    this.creador,
    this.fotos = const [],
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static int? _toNullableInt(dynamic v) {
    final x = _toInt(v);
    return x <= 0 ? null : x;
  }

  static List<T> _listOf<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = (raw as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  factory ServicioReporte.fromJson(Map<String, dynamic> json) {
    return ServicioReporte(
      id: _toInt(json['id']),
      servicioId: _toNullableInt(json['servicio_id']),
      createdBy: _toNullableInt(json['created_by']),
      tipoReporte: json['tipo_reporte']?.toString(),
      fecha: json['fecha']?.toString(),
      hora: json['hora']?.toString(),
      municipio: json['municipio']?.toString(),
      lugar: json['lugar']?.toString(),
      asunto: json['asunto']?.toString(),
      descripcion: json['descripcion']?.toString(),
      narrativa: json['narrativa']?.toString(),
      estadoFuerzaTexto: json['estado_fuerza_texto']?.toString(),
      accionesARealizar: json['acciones_a_realizar']?.toString(),
      accionesRealizadas: json['acciones_realizadas']?.toString(),
      resultados: json['resultados']?.toString(),
      datosPersonaAsegurada: json['datos_persona_asegurada']?.toString(),
      conclusion: json['conclusion']?.toString(),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      whatsappTexto: json['whatsapp_texto']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      creador: json['creador'] is Map
          ? ServicioRelacionado.fromJson(
              Map<String, dynamic>.from(json['creador'] as Map),
              labelKeys: const ['name', 'nombre'],
              subtitleKeys: const ['email'],
              fallback: 'Usuario',
            )
          : null,
      fotos: _listOf(json['fotos'], ServicioReporteFoto.fromJson),
    );
  }

  String get resumen {
    for (final value in [
      narrativa,
      descripcion,
      accionesRealizadas,
      resultados,
      conclusion,
    ]) {
      final clean = value?.trim() ?? '';
      if (clean.isNotEmpty) return clean;
    }
    return '';
  }
}

class Servicio {
  final int id;
  final int? createdBy;
  final int? personalId;
  final int? caninoId;
  final int? equinoId;
  final int? patrullaId;
  final String categoriaRegistro;
  final String tipoServicio;
  final String estatusServicio;
  final String? oficioReferencia;
  final String? memorandumReferencia;
  final String? unidadClave;
  final String? crp;
  final String? objetivoServicio;
  final String? folioOperativo;
  final String? fecha;
  final String? hora;
  final String? horaFin;
  final bool cumplio;
  final bool seguridad;
  final bool barridoSeguridad;
  final bool desfiles;
  final bool proximidadSocial;
  final bool actosCivicos;
  final String? tipoBusqueda;
  final String? asunto;
  final String? municipio;
  final String? lugar;
  final String? descripcion;
  final String? accionesRealizadas;
  final String? resultados;
  final String? conclusionOperativa;
  final String? comandanteResponsable;
  final String? cargoResponsable;
  final String? observaciones;
  final String? lat;
  final String? lng;
  final String? archivo;
  final String? archivoNombreOriginal;
  final String? archivoMime;
  final int archivoSize;
  final String? createdAt;
  final String? updatedAt;
  final ServicioRelacionado? creador;
  final ServicioRelacionado? personal;
  final ServicioRelacionado? canino;
  final ServicioRelacionado? equino;
  final ServicioRelacionado? patrulla;
  final ServicioEstadoFuerza? estadoFuerza;
  final List<ServicioMovimiento> movimientos;
  final List<ServicioParticipante> participantes;
  final List<ServicioCoordenada> coordenadas;
  final List<ServicioRecurso> recursos;
  final List<ServicioReporte> reportes;

  const Servicio({
    required this.id,
    required this.categoriaRegistro,
    required this.tipoServicio,
    required this.estatusServicio,
    required this.cumplio,
    required this.seguridad,
    required this.barridoSeguridad,
    required this.desfiles,
    required this.proximidadSocial,
    required this.actosCivicos,
    required this.archivoSize,
    this.createdBy,
    this.personalId,
    this.caninoId,
    this.equinoId,
    this.patrullaId,
    this.oficioReferencia,
    this.memorandumReferencia,
    this.unidadClave,
    this.crp,
    this.objetivoServicio,
    this.folioOperativo,
    this.fecha,
    this.hora,
    this.horaFin,
    this.tipoBusqueda,
    this.asunto,
    this.municipio,
    this.lugar,
    this.descripcion,
    this.accionesRealizadas,
    this.resultados,
    this.conclusionOperativa,
    this.comandanteResponsable,
    this.cargoResponsable,
    this.observaciones,
    this.lat,
    this.lng,
    this.archivo,
    this.archivoNombreOriginal,
    this.archivoMime,
    this.createdAt,
    this.updatedAt,
    this.creador,
    this.personal,
    this.canino,
    this.equino,
    this.patrulla,
    this.estadoFuerza,
    this.movimientos = const [],
    this.participantes = const [],
    this.coordenadas = const [],
    this.recursos = const [],
    this.reportes = const [],
  });

  static int _toInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  static int? _toNullableInt(dynamic v) {
    final x = _toInt(v, -1);
    return x < 0 ? null : x;
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == '1' || s == 'true' || s == 'si' || s == 'sí';
    }
    return false;
  }

  static List<T> _listOf<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = (raw as List?) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static ServicioRelacionado? _related(
    dynamic raw, {
    required List<String> labelKeys,
    List<String> subtitleKeys = const [],
    required String fallback,
  }) {
    if (raw is! Map) return null;
    return ServicioRelacionado.fromJson(
      Map<String, dynamic>.from(raw),
      labelKeys: labelKeys,
      subtitleKeys: subtitleKeys,
      fallback: fallback,
    );
  }

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: _toInt(json['id']),
      createdBy: _toNullableInt(json['created_by']),
      personalId: _toNullableInt(json['personal_id']),
      caninoId: _toNullableInt(json['canino_id']),
      equinoId: _toNullableInt(json['equino_id']),
      patrullaId: _toNullableInt(json['patrulla_id']),
      categoriaRegistro: (json['categoria_registro'] ?? '').toString(),
      tipoServicio: (json['tipo_servicio'] ?? '').toString(),
      estatusServicio: (json['estatus_servicio'] ?? '').toString(),
      oficioReferencia: json['oficio_referencia']?.toString(),
      memorandumReferencia: json['memorandum_referencia']?.toString(),
      unidadClave: json['unidad_clave']?.toString(),
      crp: json['crp']?.toString(),
      objetivoServicio: json['objetivo_servicio']?.toString(),
      folioOperativo: json['folio_operativo']?.toString(),
      fecha: json['fecha']?.toString(),
      hora: json['hora']?.toString(),
      horaFin: json['hora_fin']?.toString(),
      cumplio: _toBool(json['cumplio']),
      seguridad: _toBool(json['seguridad']),
      barridoSeguridad: _toBool(json['barrido_seguridad']),
      desfiles: _toBool(json['desfiles']),
      proximidadSocial: _toBool(json['proximidad_social']),
      actosCivicos: _toBool(json['actos_civicos']),
      tipoBusqueda: json['tipo_busqueda']?.toString(),
      asunto: json['asunto']?.toString(),
      municipio: json['municipio']?.toString(),
      lugar: json['lugar']?.toString(),
      descripcion: json['descripcion']?.toString(),
      accionesRealizadas: json['acciones_realizadas']?.toString(),
      resultados: json['resultados']?.toString(),
      conclusionOperativa: json['conclusion_operativa']?.toString(),
      comandanteResponsable: json['comandante_responsable']?.toString(),
      cargoResponsable: json['cargo_responsable']?.toString(),
      observaciones: json['observaciones']?.toString(),
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      archivo: json['archivo']?.toString(),
      archivoNombreOriginal: json['archivo_nombre_original']?.toString(),
      archivoMime: json['archivo_mime']?.toString(),
      archivoSize: _toInt(json['archivo_size']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      creador: _related(
        json['creador'],
        labelKeys: const ['name', 'nombre'],
        subtitleKeys: const ['email'],
        fallback: 'Usuario',
      ),
      personal: _related(
        json['personal'],
        labelKeys: const ['nombres', 'nombre', 'name'],
        subtitleKeys: const ['cargo', 'grado', 'crp'],
        fallback: 'Personal',
      ),
      canino: _related(
        json['canino'],
        labelKeys: const ['nombre'],
        subtitleKeys: const ['especialidad', 'raza'],
        fallback: 'Canino',
      ),
      equino: _related(
        json['equino'],
        labelKeys: const ['nombre'],
        subtitleKeys: const ['especialidad', 'raza'],
        fallback: 'Equino',
      ),
      patrulla: _related(
        json['patrulla'],
        labelKeys: const ['numero_economico', 'nombre'],
        subtitleKeys: const ['placas'],
        fallback: 'Patrulla',
      ),
      estadoFuerza: json['estado_fuerza'] is Map
          ? ServicioEstadoFuerza.fromJson(
              Map<String, dynamic>.from(json['estado_fuerza'] as Map),
            )
          : null,
      movimientos: _listOf(json['movimientos'], ServicioMovimiento.fromJson),
      participantes: _listOf(
        json['participantes'],
        ServicioParticipante.fromJson,
      ),
      coordenadas: _listOf(json['coordenadas'], ServicioCoordenada.fromJson),
      recursos: _listOf(json['recursos'], ServicioRecurso.fromJson),
      reportes: _listOf(json['reportes'], ServicioReporte.fromJson),
    );
  }
}
