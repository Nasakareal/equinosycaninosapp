class AnimalMedicalFile {
  final int id;
  final String? archivo;
  final String? tipo;

  const AnimalMedicalFile({required this.id, this.archivo, this.tipo});

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory AnimalMedicalFile.fromJson(Map<String, dynamic> json) {
    return AnimalMedicalFile(
      id: _toInt(json['id']),
      archivo: json['archivo']?.toString(),
      tipo: json['tipo']?.toString(),
    );
  }
}

class AnimalMedicalRecord {
  final int id;
  final int animalId;
  final String fecha;
  final String tipo;
  final String? descripcion;
  final String? veterinario;
  final double? costo;
  final String? proximaCita;
  final List<AnimalMedicalFile> files;

  const AnimalMedicalRecord({
    required this.id,
    required this.animalId,
    required this.fecha,
    required this.tipo,
    this.descripcion,
    this.veterinario,
    this.costo,
    this.proximaCita,
    this.files = const [],
  });

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  factory AnimalMedicalRecord.fromJson(Map<String, dynamic> json) {
    final filesJson = (json['files'] as List?) ?? const [];

    return AnimalMedicalRecord(
      id: _toInt(json['id']),
      animalId: _toInt(json['animal_id']),
      fecha: (json['fecha'] ?? '').toString(),
      tipo: (json['tipo'] ?? '').toString(),
      descripcion: json['descripcion']?.toString(),
      veterinario: json['veterinario']?.toString(),
      costo: _toDouble(json['costo']),
      proximaCita: json['proxima_cita']?.toString(),
      files: filesJson
          .whereType<Map>()
          .map((e) => AnimalMedicalFile.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
