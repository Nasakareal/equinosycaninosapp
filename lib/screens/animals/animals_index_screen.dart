import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../models/animal.dart';
import '../../models/paginated.dart';
import '../../services/animals_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'animal_detail_screen.dart';

class AnimalsIndexScreen extends StatefulWidget {
  const AnimalsIndexScreen({super.key});

  @override
  State<AnimalsIndexScreen> createState() => _AnimalsIndexScreenState();
}

class _AnimalsIndexScreenState extends State<AnimalsIndexScreen> {
  final AnimalsService _service = AnimalsService();

  String _tipo = '';
  String _estatus = '';
  final TextEditingController _buscarCtrl = TextEditingController();

  bool _loading = true;
  String? _error;

  int _page = 1;
  final int _perPage = 20;
  Paginated<Animal>? _data;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
    _buscarCtrl.addListener(_onBuscarChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _buscarCtrl.removeListener(_onBuscarChanged);
    _buscarCtrl.dispose();
    super.dispose();
  }

  void _onBuscarChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _page = 1;
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _service.index(
        tipo: _tipo.isEmpty ? null : _tipo,
        estatus: _estatus.isEmpty ? null : _estatus,
        buscar: _buscarCtrl.text.trim().isEmpty
            ? null
            : _buscarCtrl.text.trim(),
        perPage: _perPage,
        page: _page,
      );

      if (!mounted) return;

      setState(() {
        _data = res;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _confirmDelete(Animal a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('¿Eliminar registro?'),
          content: Text('Se eliminará: ${a.nombre}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await _service.destroy(a.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Eliminado correctamente')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _openDetail(Animal a) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnimalDetailScreen(animalId: a.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _data?.items ?? const <Animal>[];

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x24FFFFFF)),
                            color: const Color(0x0AFFFFFF),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFFF3F7FF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Listado de Animales',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFF3F7FF),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, Routes.animalCreate),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x24FFFFFF)),
                            gradient: const LinearGradient(
                              colors: [Color(0x297C4DFF), Color(0x2900E5FF)],
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Color(0xFFF3F7FF),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Agregar',
                                style: TextStyle(
                                  color: Color(0xFFF3F7FF),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _Select(
                              value: _tipo,
                              label: 'Tipo',
                              items: const [
                                _SelectItem('', 'Todos'),
                                _SelectItem('EQUINO', 'Equinos'),
                                _SelectItem('CANINO', 'Caninos'),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _tipo = v;
                                  _page = 1;
                                });
                                _load();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Select(
                              value: _estatus,
                              label: 'Estatus',
                              items: const [
                                _SelectItem('', 'Todos'),
                                _SelectItem('ACTIVO', 'Activo'),
                                _SelectItem('BAJA', 'Baja'),
                                _SelectItem('RESGUARDO', 'Resguardo'),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _estatus = v;
                                  _page = 1;
                                });
                                _load();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _buscarCtrl,
                        decoration: InputDecoration(
                          labelText: 'Buscar (nombre, raza, especialidad)',
                          border: const OutlineInputBorder(),
                          suffixIcon: _buscarCtrl.text.trim().isEmpty
                              ? const Icon(Icons.search_rounded)
                              : IconButton(
                                  onPressed: () {
                                    _buscarCtrl.clear();
                                    _page = 1;
                                    _load();
                                  },
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(12),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFFFD6D6),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : items.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin registros',
                              style: TextStyle(
                                color: Color(0xB6FFFFFF),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (ctx, i) {
                                    final a = items[i];
                                    return _AnimalRow(
                                      index: ((_page - 1) * _perPage) + i + 1,
                                      animal: a,
                                      onView: () => _openDetail(a),
                                      onEdit: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Editar próximamente',
                                            ),
                                          ),
                                        );
                                      },
                                      onDelete: () => _confirmDelete(a),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              _PaginationBar(
                                currentPage: _data?.currentPage ?? 1,
                                lastPage: _data?.lastPage ?? 1,
                                total: _data?.total ?? items.length,
                                onPrev: (_data?.hasPrev ?? false)
                                    ? () {
                                        setState(() => _page = _page - 1);
                                        _load();
                                      }
                                    : null,
                                onNext: (_data?.hasNext ?? false)
                                    ? () {
                                        setState(() => _page = _page + 1);
                                        _load();
                                      }
                                    : null,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectItem {
  final String value;
  final String label;
  const _SelectItem(this.value, this.label);
}

class _Select extends StatelessWidget {
  final String value;
  final String label;
  final List<_SelectItem> items;
  final ValueChanged<String> onChanged;

  const _Select({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (x) =>
                DropdownMenuItem<String>(value: x.value, child: Text(x.label)),
          )
          .toList(),
      onChanged: (v) => onChanged(v ?? ''),
    );
  }
}

class _AnimalRow extends StatelessWidget {
  final int index;
  final Animal animal;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnimalRow({
    required this.index,
    required this.animal,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  Color _badgeColorTipo() {
    if (animal.tipo == 'EQUINO') return const Color(0xFF00E5FF);
    return const Color(0xFF00D084);
  }

  Color _badgeColorEstatus() {
    if (animal.estatus == 'ACTIVO') return const Color(0xFF00D084);
    if (animal.estatus == 'BAJA') return const Color(0xFFFF6B6B);
    return const Color(0xFFFFD166);
  }

  String _labelTipo() {
    if (animal.tipo == 'EQUINO') return 'Equino';
    if (animal.tipo == 'CANINO') return 'Canino';
    return animal.tipo;
  }

  String _labelEstatus() {
    if (animal.estatus == 'ACTIVO') return 'Activo';
    if (animal.estatus == 'BAJA') return 'Baja';
    if (animal.estatus == 'RESGUARDO') return 'Resguardo';
    return animal.estatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x24FFFFFF)),
        color: const Color(0x0AFFFFFF),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x24FFFFFF)),
                  color: const Color(0x0AFFFFFF),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: Color(0xFFF3F7FF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  animal.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFF3F7FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 14.6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _Badge(text: _labelTipo(), color: _badgeColorTipo()),
              const SizedBox(width: 8),
              _Badge(text: _labelEstatus(), color: _badgeColorEstatus()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Meta(
                  title: 'Raza',
                  value: (animal.raza == null || animal.raza!.trim().isEmpty)
                      ? '-'
                      : animal.raza!,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Meta(
                  title: 'Especialidad',
                  value:
                      (animal.especialidad == null ||
                          animal.especialidad!.trim().isEmpty)
                      ? '-'
                      : animal.especialidad!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _ActionIcon(icon: Icons.visibility_rounded, onTap: onView),
              const SizedBox(width: 8),
              _ActionIcon(icon: Icons.edit_rounded, onTap: onEdit),
              const SizedBox(width: 8),
              _ActionIcon(
                icon: Icons.delete_rounded,
                onTap: onDelete,
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String title;
  final String value;

  const _Meta({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x24FFFFFF)),
        color: const Color(0x0AFFFFFF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0x88FFFFFF),
              fontWeight: FontWeight.w800,
              fontSize: 11.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF3F7FF),
              fontWeight: FontWeight.w800,
              fontSize: 13.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
        color: color.withValues(alpha: 0.16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color c = danger ? const Color(0xFFFF6B6B) : const Color(0xFFF3F7FF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 46,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: danger ? const Color(0x26FF6B6B) : const Color(0x24FFFFFF),
          ),
          color: danger ? const Color(0x14FF6B6B) : const Color(0x0AFFFFFF),
        ),
        child: Icon(icon, color: c),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int currentPage;
  final int lastPage;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _PaginationBar({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Página $currentPage de $lastPage • Total $total',
            style: const TextStyle(
              color: Color(0xB6FFFFFF),
              fontWeight: FontWeight.w800,
              fontSize: 12.6,
            ),
          ),
        ),
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left_rounded),
          color: const Color(0xFFF3F7FF),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          color: const Color(0xFFF3F7FF),
        ),
      ],
    );
  }
}
