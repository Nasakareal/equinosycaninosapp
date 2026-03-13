import 'animal_assignment.dart';
import 'animal_incidence.dart';
import 'animal_medical_record.dart';

class Animal {
  final int id;
  final String tipo;
  final String nombre;
  final String? raza;
  final String? procedencia;
  final String? sexo;
  final String? color;
  final String? caracteristicas;
  final String? marcaje;
  final String? chip;
  final String? especialidad;
  final String estatus;
  final String? observaciones;
  final String? fechaNacimiento;
  final String? edadTexto;
  final double? forrajeKgDiario;
  final double? granoKgDiario;
  final String? fotoUrl;
  final List<AnimalAssignment> assignments;
  final List<AnimalMedicalRecord> medicalRecords;
  final List<AnimalIncidence> incidences;

  const Animal({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.estatus,
    this.raza,
    this.procedencia,
    this.sexo,
    this.color,
    this.caracteristicas,
    this.marcaje,
    this.chip,
    this.especialidad,
    this.observaciones,
    this.fechaNacimiento,
    this.edadTexto,
    this.forrajeKgDiario,
    this.granoKgDiario,
    this.fotoUrl,
    this.assignments = const [],
    this.medicalRecords = const [],
    this.incidences = const [],
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }
    return null;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
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

  factory Animal.fromJson(Map<String, dynamic> json) {
    final edad = json['edad_texto'] ?? json['edad_calculada'];

    return Animal(
      id: _toInt(json['id']),
      tipo: (json['tipo'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      raza: json['raza']?.toString(),
      procedencia: json['procedencia']?.toString(),
      sexo: json['sexo']?.toString(),
      color: json['color']?.toString(),
      caracteristicas: json['caracteristicas']?.toString(),
      marcaje: json['marcaje']?.toString(),
      chip: json['chip']?.toString(),
      especialidad: json['especialidad']?.toString(),
      estatus: (json['estatus'] ?? '').toString(),
      observaciones: json['observaciones']?.toString(),
      fechaNacimiento: json['fecha_nacimiento']?.toString(),
      edadTexto: edad?.toString(),
      forrajeKgDiario: _toDouble(json['forraje_kg_diario']),
      granoKgDiario: _toDouble(json['grano_kg_diario']),
      fotoUrl: json['foto_url']?.toString(),
      assignments: _listOf(json['assignments'], AnimalAssignment.fromJson),
      medicalRecords: _listOf(
        json['medical_records'] ?? json['medicalRecords'],
        AnimalMedicalRecord.fromJson,
      ),
      incidences: _listOf(json['incidences'], AnimalIncidence.fromJson),
    );
  }
}
