import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/equinoterapia.dart';
import '../../services/equinoterapias_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'equinoterapia_create_screen.dart';
import 'equinoterapia_detail_screen.dart';

class EquinoterapiasIndexScreen extends StatefulWidget {
  const EquinoterapiasIndexScreen({super.key});

  @override
  State<EquinoterapiasIndexScreen> createState() => _EquinoterapiasIndexScreenState();
}

class _EquinoterapiasIndexScreenState extends State<EquinoterapiasIndexScreen> {
  final EquinoterapiasService _service = EquinoterapiasService();
  final TextEditingController _fechaInicioCtrl = TextEditingController();
  final TextEditingController _fechaFinCtrl = TextEditingController();
  final TextEditingController _semanaCtrl = TextEditingController();

  bool _loading = true;
  bool _working = false;
  String? _error;
  int _page = 1;
  EquinoterapiaIndexData? _data;

  @override
  void initState() {
    super.initState();
    _semanaCtrl.text = _rawDate(_startOfWeek(DateTime.now()));
    _load();
  }

  @override
  void dispose() {
    _fechaInicioCtrl.dispose();
    _fechaFinCtrl.dispose();
    _semanaCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.index(
        page: _page,
        fechaInicio: _fechaInicioCtrl.text,
        fechaFin: _fechaFinCtrl.text,
        semanaInicio: _semanaCtrl.text,
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

  Future<void> _pickDate(TextEditingController ctrl) async {
    final initial = DateTime.tryParse(ctrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => ctrl.text = _rawDate(picked));
    }
  }

  Future<void> _openCreate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EquinoterapiaCreateScreen()),
    );
    _load();
  }

  void _openDetail(EquinoterapiaReporte item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EquinoterapiaDetailScreen(reporteId: item.id)),
    );
  }

  Future<void> _openEdit(EquinoterapiaReporte item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EquinoterapiaCreateScreen(reporteId: item.id)),
    );
    _load();
  }

  Future<void> _delete(EquinoterapiaReporte item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte?'),
        content: Text('Se eliminara el reporte del ${_fmtDate(item.fecha)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _working = true);
    try {
      await _service.delete(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte eliminado correctamente')),
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
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }

  void _resetFilters() {
    _fechaInicioCtrl.clear();
    _fechaFinCtrl.clear();
    _semanaCtrl.text = _rawDate(_startOfWeek(DateTime.now()));
    _page = 1;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _data?.resumenSemana;

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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      _IconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Equinoterapias',
                          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      if (_working)
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtros rapidos',
                        style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 14.5),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fechaInicioCtrl,
                              readOnly: true,
                              onTap: () => _pickDate(_fechaInicioCtrl),
                              decoration: const InputDecoration(labelText: 'Fecha inicio'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _fechaFinCtrl,
                              readOnly: true,
                              onTap: () => _pickDate(_fechaFinCtrl),
                              decoration: const InputDecoration(labelText: 'Fecha fin'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _semanaCtrl,
                              readOnly: true,
                              onTap: () => _pickDate(_semanaCtrl),
                              decoration: const InputDecoration(labelText: 'Semana base'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.filter_alt_rounded),
                            label: const Text('Filtrar'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _resetFilters,
                            child: const Text('Limpiar'),
                          ),
                        ],
                      ),
                      if (summary != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Resumen semanal ${_fmtDate(_data!.semanaInicio)} al ${_fmtDate(_data!.semanaFin)}',
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800, fontSize: 13.6),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _SummaryBox(title: 'Terapias', value: summary.realizadas.toString(), color: AppColors.brownDeep),
                              const SizedBox(width: 8),
                              _SummaryBox(title: 'Inasistencias', value: summary.inasistencias.toString(), color: AppColors.red),
                              const SizedBox(width: 8),
                              _SummaryBox(title: 'Ninas', value: summary.ninas.toString(), color: const Color(0xFFC05B7B)),
                              const SizedBox(width: 8),
                              _SummaryBox(title: 'Ninos', value: summary.ninos.toString(), color: const Color(0xFF557C9C)),
                              const SizedBox(width: 8),
                              _SummaryBox(title: 'Valoraciones', value: summary.valoraciones.toString(), color: const Color(0xFFBE8759)),
                              const SizedBox(width: 8),
                              _SummaryBox(title: 'Personal', value: summary.personal.toString(), color: AppColors.greenDeep),
                              const SizedBox(width: 8),
                              _SummaryBox(title: 'Equinos', value: summary.equinos.toString(), color: const Color(0xFF7B6B57)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800),
                                ),
                              )
                            : (_data?.items.isEmpty ?? true)
                                ? const Center(
                                    child: Text(
                                      'Sin reportes',
                                      style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                          'Reportes encontrados',
                                          style: const TextStyle(
                                            color: AppColors.text,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: _data!.items.length,
                                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                                          itemBuilder: (_, i) {
                                            final item = _data!.items[i];
                                            return _ReportCard(
                                              item: item,
                                              onTap: () => _openDetail(item),
                                              onEdit: () => _openEdit(item),
                                              onDelete: () => _delete(item),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Pagina ${_data!.currentPage} de ${_data!.lastPage} • Total ${_data!.total}',
                                              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: _data!.currentPage > 1
                                                ? () {
                                                    _page -= 1;
                                                    _load();
                                                  }
                                                : null,
                                            icon: const Icon(Icons.chevron_left_rounded),
                                          ),
                                          IconButton(
                                            onPressed: _data!.currentPage < _data!.lastPage
                                                ? () {
                                                    _page += 1;
                                                    _load();
                                                  }
                                                : null,
                                            icon: const Icon(Icons.chevron_right_rounded),
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
          border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.24)),
          color: AppColors.whiteWarm.withValues(alpha: 0.62),
        ),
        child: Icon(icon, color: AppColors.brownDeep),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _SummaryBox({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 12.4),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final EquinoterapiaReporte item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReportCard({required this.item, required this.onTap, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.22)),
          color: AppColors.whiteWarm.withValues(alpha: 0.60),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reporte ${_fmtDate(item.fecha)}',
                    style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 14.8),
                  ),
                ),
                _MiniAction(icon: Icons.edit_rounded, onTap: onEdit),
                const SizedBox(width: 8),
                _MiniAction(icon: Icons.delete_outline_rounded, onTap: onDelete, danger: true),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Registros: ${item.registrosCount}',
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              'Valoraciones: ${item.valoraciones} • Personal: ${item.personal} • Equinos: ${item.equinos}',
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              'Actividades: ${item.actividadesArea ?? '-'}',
              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  const _MiniAction({required this.icon, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: danger ? AppColors.redSoft.withValues(alpha: 0.72) : AppColors.creamStrong.withValues(alpha: 0.52),
          border: Border.all(
            color: danger ? AppColors.red.withValues(alpha: 0.28) : AppColors.creamStroke.withValues(alpha: 0.20),
          ),
        ),
        child: Icon(icon, size: 18, color: danger ? AppColors.red : AppColors.brownDeep),
      ),
    );
  }
}

DateTime _startOfWeek(DateTime date) {
  final diff = date.weekday - DateTime.monday;
  return DateTime(date.year, date.month, date.day).subtract(Duration(days: diff));
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
