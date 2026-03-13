class EquinoterapiaRegistro {
  final int id;
  final String nombreCompleto;
  final String sexo;
  final String? diagnostico;
  final String estatusAsistencia;
  final String? motivoInasistencia;
  final bool esValoracion;

  const EquinoterapiaRegistro({
    required this.id,
    required this.nombreCompleto,
    required this.sexo,
    required this.estatusAsistencia,
    required this.esValoracion,
    this.diagnostico,
    this.motivoInasistencia,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v.trim() == '1' || v.trim().toLowerCase() == 'true';
    return false;
  }

  factory EquinoterapiaRegistro.fromJson(Map<String, dynamic> json) {
    return EquinoterapiaRegistro(
      id: _toInt(json['id']),
      nombreCompleto: (json['nombre_completo'] ?? '').toString(),
      sexo: (json['sexo'] ?? 'NINO').toString(),
      diagnostico: json['diagnostico']?.toString(),
      estatusAsistencia: (json['estatus_asistencia'] ?? 'ASISTIO').toString(),
      motivoInasistencia: json['motivo_inasistencia']?.toString(),
      esValoracion: _toBool(json['es_valoracion']),
    );
  }
}

class EquinoterapiaReporte {
  final int id;
  final String fecha;
  final int valoraciones;
  final int personal;
  final int equinos;
  final String? actividadesArea;
  final String? observaciones;
  final int registrosCount;
  final List<EquinoterapiaRegistro> registros;
  final String? createdAt;
  final String? updatedAt;

  const EquinoterapiaReporte({
    required this.id,
    required this.fecha,
    required this.valoraciones,
    required this.personal,
    required this.equinos,
    required this.registrosCount,
    this.actividadesArea,
    this.observaciones,
    this.registros = const [],
    this.createdAt,
    this.updatedAt,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory EquinoterapiaReporte.fromJson(Map<String, dynamic> json) {
    final registrosJson = (json['registros'] as List?) ?? const [];
    return EquinoterapiaReporte(
      id: _toInt(json['id']),
      fecha: (json['fecha'] ?? '').toString(),
      valoraciones: _toInt(json['valoraciones']),
      personal: _toInt(json['personal']),
      equinos: _toInt(json['equinos']),
      actividadesArea: json['actividades_area']?.toString(),
      observaciones: json['observaciones']?.toString(),
      registrosCount: _toInt(json['registros_count'] ?? registrosJson.length),
      registros: registrosJson
          .whereType<Map>()
          .map((e) => EquinoterapiaRegistro.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class EquinoterapiaTotales {
  final int realizadas;
  final int inasistencias;
  final int ninas;
  final int ninos;
  final int valoraciones;
  final int personal;
  final int equinos;

  const EquinoterapiaTotales({
    required this.realizadas,
    required this.inasistencias,
    required this.ninas,
    required this.ninos,
    required this.valoraciones,
    required this.personal,
    required this.equinos,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory EquinoterapiaTotales.fromJson(Map<String, dynamic> json) {
    return EquinoterapiaTotales(
      realizadas: _toInt(json['realizadas']),
      inasistencias: _toInt(json['inasistencias']),
      ninas: _toInt(json['ninas']),
      ninos: _toInt(json['ninos']),
      valoraciones: _toInt(json['valoraciones']),
      personal: _toInt(json['personal']),
      equinos: _toInt(json['equinos']),
    );
  }
}

class EquinoterapiaIndexData {
  final List<EquinoterapiaReporte> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final String semanaInicio;
  final String semanaFin;
  final EquinoterapiaTotales resumenSemana;

  const EquinoterapiaIndexData({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.semanaInicio,
    required this.semanaFin,
    required this.resumenSemana,
  });
}

class EquinoterapiaShowData {
  final EquinoterapiaReporte reporte;
  final EquinoterapiaTotales totales;
  final String whatsappMensaje;
  final String whatsappUrl;

  const EquinoterapiaShowData({
    required this.reporte,
    required this.totales,
    required this.whatsappMensaje,
    required this.whatsappUrl,
  });
}
