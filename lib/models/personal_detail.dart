import 'personal_summary.dart';

class PersonalServicio {
  final int id;
  final String? tipo;
  final String? fechaInicioCiclo;
  final int? horasTrabajo;
  final int? horasDescanso;
  final bool activo;
  final String? observaciones;

  const PersonalServicio({
    required this.id,
    this.tipo,
    this.fechaInicioCiclo,
    this.horasTrabajo,
    this.horasDescanso,
    required this.activo,
    this.observaciones,
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

  factory PersonalServicio.fromJson(Map<String, dynamic> json) {
    return PersonalServicio(
      id: _toInt(json['id']),
      tipo: json['tipo']?.toString(),
      fechaInicioCiclo: json['fecha_inicio_ciclo']?.toString(),
      horasTrabajo: json['horas_trabajo'] == null ? null : _toInt(json['horas_trabajo']),
      horasDescanso: json['horas_descanso'] == null ? null : _toInt(json['horas_descanso']),
      activo: _toBool(json['activo']),
      observaciones: json['observaciones']?.toString(),
    );
  }
}

class PersonalWeaponAssignment {
  final int id;
  final String? status;
  final String? fechaAsignacion;
  final String? fechaDevolucion;
  final String? observaciones;
  final String? weaponTipo;
  final String? weaponMatricula;
  final String? weaponEstado;

  const PersonalWeaponAssignment({
    required this.id,
    this.status,
    this.fechaAsignacion,
    this.fechaDevolucion,
    this.observaciones,
    this.weaponTipo,
    this.weaponMatricula,
    this.weaponEstado,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory PersonalWeaponAssignment.fromJson(Map<String, dynamic> json) {
    final weapon = json['weapon'];
    return PersonalWeaponAssignment(
      id: _toInt(json['id']),
      status: json['status']?.toString(),
      fechaAsignacion: json['fecha_asignacion']?.toString(),
      fechaDevolucion: json['fecha_devolucion']?.toString(),
      observaciones: json['observaciones']?.toString(),
      weaponTipo: weapon is Map<String, dynamic> ? weapon['tipo']?.toString() : null,
      weaponMatricula: weapon is Map<String, dynamic> ? weapon['matricula']?.toString() : null,
      weaponEstado: weapon is Map<String, dynamic> ? weapon['estado']?.toString() : null,
    );
  }
}

class PersonalHorarioDetalle {
  final int id;
  final int? diaSemana;
  final String? horaEntrada;
  final String? horaSalida;
  final bool cruzaDia;
  final String? bloque;
  final String? notas;

  const PersonalHorarioDetalle({
    required this.id,
    this.diaSemana,
    this.horaEntrada,
    this.horaSalida,
    required this.cruzaDia,
    this.bloque,
    this.notas,
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

  factory PersonalHorarioDetalle.fromJson(Map<String, dynamic> json) {
    return PersonalHorarioDetalle(
      id: _toInt(json['id']),
      diaSemana: json['dia_semana'] == null ? null : _toInt(json['dia_semana']),
      horaEntrada: json['hora_entrada']?.toString(),
      horaSalida: json['hora_salida']?.toString(),
      cruzaDia: _toBool(json['cruza_dia']),
      bloque: json['bloque']?.toString(),
      notas: json['notas']?.toString(),
    );
  }
}

class PersonalHorario {
  final int id;
  final String? nombre;
  final String? fechaInicio;
  final String? fechaFin;
  final bool activo;
  final List<PersonalHorarioDetalle> detalles;

  const PersonalHorario({
    required this.id,
    this.nombre,
    this.fechaInicio,
    this.fechaFin,
    required this.activo,
    this.detalles = const [],
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

  factory PersonalHorario.fromJson(Map<String, dynamic> json) {
    final detallesJson = (json['detalles'] as List?) ?? const [];
    return PersonalHorario(
      id: _toInt(json['id']),
      nombre: json['nombre']?.toString(),
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaFin: json['fecha_fin']?.toString(),
      activo: _toBool(json['activo']),
      detalles: detallesJson
          .whereType<Map>()
          .map((e) => PersonalHorarioDetalle.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class PersonalDetail {
  final PersonalSummary personal;
  final List<PersonalWeaponAssignment> armasActivas;
  final List<PersonalWeaponAssignment> historialArmamento;
  final List<PersonalServicio> servicios;
  final PersonalHorario? horario;

  const PersonalDetail({
    required this.personal,
    this.armasActivas = const [],
    this.historialArmamento = const [],
    this.servicios = const [],
    this.horario,
  });

  factory PersonalDetail.fromJson(Map<String, dynamic> json) {
    final personalJson = Map<String, dynamic>.from(json['personal'] as Map);
    final armasActivasJson = (json['armas_activas'] as List?) ?? const [];
    final historialJson = (json['historial_armamento'] as List?) ?? const [];
    final serviciosJson = ((personalJson['servicios'] as List?) ?? const []);
    final horarioJson = json['horario'];

    return PersonalDetail(
      personal: PersonalSummary.fromJson(personalJson),
      armasActivas: armasActivasJson
          .whereType<Map>()
          .map((e) => PersonalWeaponAssignment.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      historialArmamento: historialJson
          .whereType<Map>()
          .map((e) => PersonalWeaponAssignment.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      servicios: serviciosJson
          .whereType<Map>()
          .map((e) => PersonalServicio.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      horario: horarioJson is Map<String, dynamic>
          ? PersonalHorario.fromJson(horarioJson)
          : null,
    );
  }
}
