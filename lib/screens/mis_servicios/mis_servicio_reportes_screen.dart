import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/servicio.dart';
import '../../services/mis_servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'mis_servicio_reporte_detail_screen.dart';
import 'mis_servicio_reporte_form_screen.dart';

class MisServicioReportesScreen extends StatefulWidget {
  final int servicioId;
  final String? servicioNombre;

  const MisServicioReportesScreen({
    super.key,
    required this.servicioId,
    this.servicioNombre,
  });

  @override
  State<MisServicioReportesScreen> createState() =>
      _MisServicioReportesScreenState();
}

class _MisServicioReportesScreenState extends State<MisServicioReportesScreen> {
  final MisServiciosService _service = MisServiciosService();

  bool _loading = true;
  bool _working = false;
  String? _error;
  Servicio? _servicio;
  List<ServicioReporte> _reportes = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.reportesIndex(widget.servicioId);
      if (!mounted) return;
      setState(() {
        _servicio = data.servicio;
        _reportes = data.reportes;
      });
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
      MaterialPageRoute(
        builder: (_) => MisServicioReporteFormScreen(
          servicioId: widget.servicioId,
          servicioNombre: _resolvedTitle,
          servicioBase: _servicio,
        ),
      ),
    );
    _load();
  }

  Future<void> _openEdit(ServicioReporte reporte) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReporteFormScreen(
          servicioId: widget.servicioId,
          reporteId: reporte.id,
          servicioNombre: _resolvedTitle,
          servicioBase: _servicio,
        ),
      ),
    );
    _load();
  }

  Future<void> _openDetail(ServicioReporte reporte) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReporteDetailScreen(
          servicioId: widget.servicioId,
          reporteId: reporte.id,
          servicioNombre: _resolvedTitle,
        ),
      ),
    );
    _load();
  }

  Future<void> _delete(ServicioReporte reporte) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte?'),
        content: Text(
          'Se eliminara el reporte ${reporte.tipoReporte ?? 'SIN TIPO'} del ${_fmtDate(reporte.fecha)}',
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
      await _service.deleteReporte(widget.servicioId, reporte.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte eliminado correctamente')),
      );
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

  String get _resolvedTitle {
    final explicit = widget.servicioNombre?.trim() ?? '';
    if (explicit.isNotEmpty) return explicit;
    final servicio = _servicio;
    if (servicio == null) return 'Mis reportes';
    final folio = servicio.folioOperativo?.trim() ?? '';
    if (folio.isNotEmpty) return folio;
    final clave = servicio.unidadClave?.trim() ?? '';
    if (clave.isNotEmpty) return clave;
    return 'Servicio #${servicio.id}';
  }

  @override
  Widget build(BuildContext context) {
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
                      Expanded(
                        child: Text(
                          'Reportes • $_resolvedTitle',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      _IconButton(icon: Icons.add_rounded, onTap: _openCreate),
                      const SizedBox(width: 8),
                      _IconButton(icon: Icons.refresh_rounded, onTap: _load),
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
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _reportes.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin reportes capturados',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _reportes.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final item = _reportes[i];
                              return _ReporteCard(
                                item: item,
                                onTap: () => _openDetail(item),
                                onEdit: () => _openEdit(item),
                                onDelete: () => _delete(item),
                              );
                            },
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

class _ReporteCard extends StatelessWidget {
  final ServicioReporte item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReporteCard({
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
                    '${item.tipoReporte ?? 'REPORTE'} • ${_fmtDate(item.fecha)} ${_fmtHour(item.hora)}',
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
                  text: item.municipio?.trim().isNotEmpty == true
                      ? item.municipio!
                      : 'Sin municipio',
                ),
                _Tag(
                  text: item.fotos.isEmpty
                      ? 'Sin fotos'
                      : '${item.fotos.length} fotos',
                  green: true,
                ),
                _Tag(text: item.creador?.label ?? 'Sin creador', soft: true),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Asunto: ${item.asunto ?? '-'}',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Resumen: ${item.resumen.isEmpty ? '-' : item.resumen}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
                height: 1.3,
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
