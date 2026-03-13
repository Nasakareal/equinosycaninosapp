import 'option_item.dart';

class AnimalAssignment {
  final int id;
  final int animalId;
  final int? personalId;
  final int? patrolId;
  final int? turnoId;
  final String inicio;
  final String? fin;
  final String? observaciones;
  final OptionItem? personal;
  final OptionItem? patrol;
  final OptionItem? turno;

  const AnimalAssignment({
    required this.id,
    required this.animalId,
    required this.inicio,
    this.personalId,
    this.patrolId,
    this.turnoId,
    this.fin,
    this.observaciones,
    this.personal,
    this.patrol,
    this.turno,
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

  factory AnimalAssignment.fromJson(Map<String, dynamic> json) {
    final personalJson = json['personal'];
    final patrolJson = json['patrol'];
    final turnoJson = json['turno'];

    return AnimalAssignment(
      id: _toInt(json['id']),
      animalId: _toInt(json['animal_id']),
      personalId: _toNullableInt(json['personal_id']),
      patrolId: _toNullableInt(json['patrol_id']),
      turnoId: _toNullableInt(json['turno_id']),
      inicio: (json['inicio'] ?? '').toString(),
      fin: json['fin']?.toString(),
      observaciones: json['observaciones']?.toString(),
      personal: personalJson is Map<String, dynamic>
          ? OptionItem.fromPersonalJson(personalJson)
          : null,
      patrol: patrolJson is Map<String, dynamic>
          ? OptionItem.fromPatrolJson(patrolJson)
          : null,
      turno: turnoJson is Map<String, dynamic>
          ? OptionItem.fromTurnoJson(turnoJson)
          : null,
    );
  }
}
