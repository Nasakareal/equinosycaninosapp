import 'option_item.dart';

class AnimalIncidenceFile {
  final int id;
  final String? archivo;
  final String? tipo;

  const AnimalIncidenceFile({required this.id, this.archivo, this.tipo});

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory AnimalIncidenceFile.fromJson(Map<String, dynamic> json) {
    return AnimalIncidenceFile(
      id: _toInt(json['id']),
      archivo: json['archivo']?.toString(),
      tipo: json['tipo']?.toString(),
    );
  }
}

class AnimalIncidence {
  final int id;
  final int animalId;
  final String fecha;
  final int? incidenceTypeId;
  final String gravedad;
  final String? descripcion;
  final bool resuelto;
  final String? resueltoEn;
  final OptionItem? incidenceType;
  final String? atendidoPor;
  final List<AnimalIncidenceFile> files;

  const AnimalIncidence({
    required this.id,
    required this.animalId,
    required this.fecha,
    required this.gravedad,
    required this.resuelto,
    this.incidenceTypeId,
    this.descripcion,
    this.resueltoEn,
    this.incidenceType,
    this.atendidoPor,
    this.files = const [],
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static int? _toNullableInt(dynamic v) {
    final x = _toInt(v);
    return x <= 0 ? null : x;
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == '1' || s == 'true' || s == 'si';
    }
    return false;
  }

  static String? _attendedLabel(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final values = [
      (raw['name'] ?? '').toString().trim(),
      (raw['email'] ?? '').toString().trim(),
    ].where((x) => x.isNotEmpty).toList();
    if (values.isEmpty) return null;
    return values.first;
  }

  factory AnimalIncidence.fromJson(Map<String, dynamic> json) {
    final typeJson = json['incidence_type'];
    final filesJson = (json['files'] as List?) ?? const [];

    return AnimalIncidence(
      id: _toInt(json['id']),
      animalId: _toInt(json['animal_id']),
      fecha: (json['fecha'] ?? '').toString(),
      incidenceTypeId: _toNullableInt(json['incidence_type_id']),
      gravedad: (json['gravedad'] ?? '').toString(),
      descripcion: json['descripcion']?.toString(),
      resuelto: _toBool(json['resuelto']),
      resueltoEn: json['resuelto_en']?.toString(),
      incidenceType: typeJson is Map<String, dynamic>
          ? OptionItem.fromIncidenceTypeJson(typeJson)
          : null,
      atendidoPor: _attendedLabel(json['atendido_por']),
      files: filesJson
          .whereType<Map>()
          .map((e) => AnimalIncidenceFile.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
