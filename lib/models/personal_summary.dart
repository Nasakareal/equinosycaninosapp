class PersonalUser {
  final int id;
  final String? name;
  final String? email;

  const PersonalUser({required this.id, this.name, this.email});

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory PersonalUser.fromJson(Map<String, dynamic> json) {
    return PersonalUser(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class PersonalArea {
  final int id;
  final String? nombre;

  const PersonalArea({required this.id, this.nombre});

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory PersonalArea.fromJson(Map<String, dynamic> json) {
    return PersonalArea(
      id: _toInt(json['id']),
      nombre: json['nombre']?.toString(),
    );
  }
}

class PersonalTurno {
  final int id;
  final String? nombre;
  final String? clave;

  const PersonalTurno({required this.id, this.nombre, this.clave});

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory PersonalTurno.fromJson(Map<String, dynamic> json) {
    return PersonalTurno(
      id: _toInt(json['id']),
      nombre: json['nombre']?.toString(),
      clave: json['clave']?.toString(),
    );
  }
}

class PersonalSummary {
  final int id;
  final String nombres;
  final String? grado;
  final String? dependencia;
  final String? crp;
  final String? cargo;
  final String? cuip;
  final bool activo;
  final PersonalTurno? turno;
  final PersonalArea? area;
  final PersonalUser? user;

  const PersonalSummary({
    required this.id,
    required this.nombres,
    required this.activo,
    this.grado,
    this.dependencia,
    this.crp,
    this.cargo,
    this.cuip,
    this.turno,
    this.area,
    this.user,
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
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == '1' || s == 'true';
    }
    return false;
  }

  factory PersonalSummary.fromJson(Map<String, dynamic> json) {
    final turnoJson = json['turno'];
    final areaJson = json['area'];
    final userJson = json['user'];

    return PersonalSummary(
      id: _toInt(json['id']),
      nombres: (json['nombres'] ?? '').toString(),
      grado: json['grado']?.toString(),
      dependencia: json['dependencia']?.toString(),
      crp: json['crp']?.toString(),
      cargo: json['cargo']?.toString(),
      cuip: json['cuip']?.toString(),
      activo: _toBool(json['activo']),
      turno: turnoJson is Map<String, dynamic>
          ? PersonalTurno.fromJson(turnoJson)
          : null,
      area: areaJson is Map<String, dynamic>
          ? PersonalArea.fromJson(areaJson)
          : null,
      user: userJson is Map<String, dynamic>
          ? PersonalUser.fromJson(userJson)
          : null,
    );
  }
}
