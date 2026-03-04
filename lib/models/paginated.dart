class Paginated<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  bool get hasPrev => currentPage > 1;
  bool get hasNext => currentPage < lastPage;

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  factory Paginated.fromLaravel(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final data = (json['data'] as List?) ?? const [];
    final items = data
        .whereType<Map>()
        .map((e) => fromItem(Map<String, dynamic>.from(e)))
        .toList();

    return Paginated<T>(
      items: items,
      currentPage: _toInt(json['current_page'], fallback: 1),
      lastPage: _toInt(json['last_page'], fallback: 1),
      total: _toInt(json['total'], fallback: items.length),
      perPage: _toInt(json['per_page'], fallback: items.length),
    );
  }
}
