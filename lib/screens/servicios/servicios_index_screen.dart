import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/paginated.dart';
import '../../models/servicio.dart';
import '../../services/servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'servicio_create_screen.dart';
import 'servicio_detail_screen.dart';

class ServiciosIndexScreen extends StatefulWidget {
  const ServiciosIndexScreen({super.key});

  @override
  State<ServiciosIndexScreen> createState() => _ServiciosIndexScreenState();
}

class _ServiciosIndexScreenState extends State<ServiciosIndexScreen> {
  final ServiciosService _service = ServiciosService();
  final TextEditingController _buscarCtrl = TextEditingController();
  final TextEditingController _fechaInicioCtrl = TextEditingController();
  final TextEditingController _fechaFinCtrl = TextEditingController();

  String _estatus = '';
  String _categoria = '';
  bool _loading = true;
  bool _working = false;
  String? _error;
  int _page = 1;
  final int _perPage = 20;
  Paginated<Servicio>? _data;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
    _buscarCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _buscarCtrl.removeListener(_onSearchChanged);
    _buscarCtrl.dispose();
    _fechaInicioCtrl.dispose();
    _fechaFinCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _page = 1;
      _load();
    });
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(ctrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => ctrl.text = _rawDate(picked));
      _page = 1;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.index(
        page: _page,
        perPage: _perPage,
        buscar: _buscarCtrl.text,
        fechaInicio: _fechaInicioCtrl.text,
        fechaFin: _fechaFinCtrl.text,
        estatusServicio: _estatus,
        categoriaRegistro: _categoria,
      );
      if (!mounted) return;
      setState(() => _data = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServicioCreateScreen()),
    );
    _load();
  }

  Future<void> _openEdit(Servicio item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicioCreateScreen(servicioId: item.id),
      ),
    );
    _load();
  }

  void _openDetail(Servicio item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicioDetailScreen(servicioId: item.id),
      ),
    );
  }

  Future<void> _delete(Servicio item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio?'),
        content: Text(
          'Se eliminara el registro ${item.folioOperativo ?? '#${item.id}'}',
        ),
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
      ),
    );
    if (ok != true) return;

    setState(() => _working = true);
    try {
      await _service.delete(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio eliminado correctamente')),
      );
      if ((_data?.items.length ?? 0) == 1 && _page > 1) {
        _page -= 1;
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _resetFilters() {
    _buscarCtrl.clear();
    _fechaInicioCtrl.clear();
    _fechaFinCtrl.clear();
    _estatus = '';
    _categoria = '';
    _page = 1;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final items = _data?.items ?? const <Servicio>[];

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
                      _IconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Servicios',
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_working)
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _openCreate,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Agregar'),
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
                      TextField(
                        controller: _buscarCtrl,
                        decoration: InputDecoration(
                          labelText:
                              'Buscar por folio, asunto, lugar o responsable',
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
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _estatus,
                              decoration: const InputDecoration(
                                labelText: 'Estatus',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: '',
                                  child: Text('Todos'),
                                ),
                                DropdownMenuItem(
                                  value: 'PROGRAMADO',
                                  child: Text('Programado'),
                                ),
                                DropdownMenuItem(
                                  value: 'EN_CURSO',
                                  child: Text('En curso'),
                                ),
                                DropdownMenuItem(
                                  value: 'CONCLUIDO',
                                  child: Text('Concluido'),
                                ),
                                DropdownMenuItem(
                                  value: 'CANCELADO',
                                  child: Text('Cancelado'),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _estatus = v ?? '';
                                  _page = 1;
                                });
                                _load();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _categoria,
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: '',
                                  child: Text('Todas'),
                                ),
                                DropdownMenuItem(
                                  value: 'CANINO',
                                  child: Text('Canino'),
                                ),
                                DropdownMenuItem(
                                  value: 'EQUINO',
                                  child: Text('Equino'),
                                ),
                                DropdownMenuItem(
                                  value: 'MIXTO',
                                  child: Text('Mixto'),
                                ),
                                DropdownMenuItem(
                                  value: 'GENERAL',
                                  child: Text('General'),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _categoria = v ?? '';
                                  _page = 1;
                                });
                                _load();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fechaInicioCtrl,
                              readOnly: true,
                              onTap: () => _pickDate(_fechaInicioCtrl),
                              decoration: const InputDecoration(
                                labelText: 'Fecha inicio',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _fechaFinCtrl,
                              readOnly: true,
                              onTap: () => _pickDate(_fechaFinCtrl),
                              decoration: const InputDecoration(
                                labelText: 'Fecha fin',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: _resetFilters,
                            child: const Text('Limpiar'),
                          ),
                        ],
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
                              style: const TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : items.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin servicios registrados',
                              style: TextStyle(
                                color: AppColors.muted,
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
                                  itemBuilder: (_, i) {
                                    final item = items[i];
                                    return _ServicioCard(
                                      item: item,
                                      onTap: () => _openDetail(item),
                                      onEdit: () => _openEdit(item),
                                      onDelete: () => _delete(item),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Pagina ${_data?.currentPage ?? 1} de ${_data?.lastPage ?? 1} • Total ${_data?.total ?? items.length}',
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: (_data?.hasPrev ?? false)
                                        ? () {
                                            _page -= 1;
                                            _load();
                                          }
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_left_rounded,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: (_data?.hasNext ?? false)
                                        ? () {
                                            _page += 1;
                                            _load();
                                          }
                                        : null,
                                    icon: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                  ),
                                ],
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

class _ServicioCard extends StatelessWidget {
  final Servicio item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServicioCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.creamStroke.withValues(alpha: 0.22),
          ),
          color: AppColors.whiteWarm.withValues(alpha: 0.60),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.folioOperativo?.trim().isNotEmpty == true
                        ? item.folioOperativo!
                        : 'Servicio #${item.id}',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.8,
                    ),
                  ),
                ),
                _MiniAction(icon: Icons.edit_rounded, onTap: onEdit),
                const SizedBox(width: 8),
                _MiniAction(
                  icon: Icons.delete_outline_rounded,
                  onTap: onDelete,
                  danger: true,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  text: item.categoriaRegistro.isEmpty
                      ? 'Sin categoria'
                      : item.categoriaRegistro,
                ),
                _Tag(
                  text: item.tipoServicio.isEmpty
                      ? 'Sin tipo'
                      : item.tipoServicio,
                  green: true,
                ),
                _Tag(
                  text: item.estatusServicio.isEmpty
                      ? 'Sin estatus'
                      : item.estatusServicio,
                  soft: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${_fmtDate(item.fecha)} • ${_fmtHour(item.hora)} - ${_fmtHour(item.horaFin)}',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Lugar: ${item.lugar ?? '-'}',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Responsable: ${item.comandanteResponsable ?? item.personal?.label ?? '-'}',
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool green;
  final bool soft;

  const _Tag({required this.text, this.green = false, this.soft = false});

  @override
  Widget build(BuildContext context) {
    final color = green
        ? AppColors.greenDeep
        : soft
        ? AppColors.brown
        : AppColors.brownDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.1,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.creamStroke.withValues(alpha: 0.24),
          ),
          color: AppColors.whiteWarm.withValues(alpha: 0.62),
        ),
        child: Icon(icon, color: AppColors.brownDeep),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _MiniAction({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: danger
              ? AppColors.redSoft.withValues(alpha: 0.72)
              : AppColors.creamStrong.withValues(alpha: 0.52),
          border: Border.all(
            color: danger
                ? AppColors.red.withValues(alpha: 0.28)
                : AppColors.creamStroke.withValues(alpha: 0.20),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: danger ? AppColors.red : AppColors.brownDeep,
        ),
      ),
    );
  }
}

String _rawDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

String _fmtDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final dt = DateTime.tryParse(raw.trim());
  if (dt == null) return raw;
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$d/$m/${dt.year}';
}

String _fmtHour(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final clean = raw.trim();
  return clean.length >= 5 ? clean.substring(0, 5) : clean;
}
