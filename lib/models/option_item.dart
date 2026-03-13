class OptionItem {
  final int id;
  final String label;
  final String? subtitle;

  const OptionItem({required this.id, required this.label, this.subtitle});

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  factory OptionItem.fromPersonalJson(Map<String, dynamic> json) {
    final nombres = (json['nombres'] ?? '').toString().trim();
    final apellidos = (json['apellidos'] ?? '').toString().trim();
    final nombre = [nombres, apellidos].where((x) => x.isNotEmpty).join(' ');
    return OptionItem(
      id: _toInt(json['id']),
      label: nombre.isEmpty ? 'Sin nombre' : nombre,
      subtitle: json['numero_empleado']?.toString(),
    );
  }

  factory OptionItem.fromPatrolJson(Map<String, dynamic> json) {
    return OptionItem(
      id: _toInt(json['id']),
      label: (json['numero_economico'] ?? 'Sin patrulla').toString(),
      subtitle: json['placas']?.toString(),
    );
  }

  factory OptionItem.fromTurnoJson(Map<String, dynamic> json) {
    return OptionItem(
      id: _toInt(json['id']),
      label: (json['nombre'] ?? 'Sin turno').toString(),
      subtitle: json['descripcion']?.toString(),
    );
  }

  factory OptionItem.fromIncidenceTypeJson(Map<String, dynamic> json) {
    return OptionItem(
      id: _toInt(json['id']),
      label: (json['nombre'] ?? 'Sin tipo').toString(),
      subtitle: json['entidad']?.toString(),
    );
  }
}
