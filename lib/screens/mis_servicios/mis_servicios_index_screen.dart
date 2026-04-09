import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/servicio.dart';
import '../../services/mis_servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'mis_servicio_panel_screen.dart';
import 'mis_servicio_reporte_form_screen.dart';
import 'mis_servicio_reportes_screen.dart';

class MisServiciosIndexScreen extends StatefulWidget {
  const MisServiciosIndexScreen({super.key});

  @override
  State<MisServiciosIndexScreen> createState() =>
      _MisServiciosIndexScreenState();
}

class _MisServiciosIndexScreenState extends State<MisServiciosIndexScreen> {
  final MisServiciosService _service = MisServiciosService();

  bool _loading = true;
  String? _error;
  List<Servicio> _items = const [];

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
      final items = await _service.index();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openPanel(Servicio servicio) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioPanelScreen(servicioId: servicio.id),
      ),
    );
    _load();
  }

  Future<void> _openReportes(Servicio servicio) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReportesScreen(
          servicioId: servicio.id,
          servicioNombre: _serviceLabel(servicio),
        ),
      ),
    );
    _load();
  }

  Future<void> _openCreate(Servicio servicio) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReporteFormScreen(
          servicioId: servicio.id,
          servicioNombre: _serviceLabel(servicio),
          servicioBase: servicio,
        ),
      ),
    );
    _load();
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
                      const Expanded(
                        child: Text(
                          'Mis Servicios',
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _IconButton(icon: Icons.refresh_rounded, onTap: _load),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Servicios y apoyos asignados o disponibles para captura',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.4,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (!_loading)
                        _Pill(
                          label: '${_items.length} registros',
                          color: AppColors.greenDeep,
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
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _items.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay servicios disponibles',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final item = _items[i];
                              return _ServicioCard(
                                item: item,
                                onPanel: () => _openPanel(item),
                                onCreateReport: () => _openCreate(item),
                                onReportes: () => _openReportes(item),
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

class _ServicioCard extends StatelessWidget {
  final Servicio item;
  final VoidCallback onPanel;
  final VoidCallback onCreateReport;
  final VoidCallback onReportes;

  const _ServicioCard({
    required this.item,
    required this.onPanel,
    required this.onCreateReport,
    required this.onReportes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  _serviceLabel(item),
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.8,
                  ),
                ),
              ),
              _Pill(
                label: '${item.reportes.length} reportes',
                color: AppColors.brownDeep,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                label: item.categoriaRegistro.trim().isEmpty
                    ? 'Sin categoria'
                    : item.categoriaRegistro,
                color: AppColors.brownDeep,
              ),
              _Pill(
                label: item.tipoServicio.trim().isEmpty
                    ? 'Sin tipo'
                    : item.tipoServicio,
                color: AppColors.greenDeep,
              ),
              _Pill(label: _fmtDate(item.fecha), color: AppColors.brown),
              _Pill(label: _fmtHour(item.hora), color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 10),
          _Line(label: 'Asunto', value: item.asunto ?? '-'),
          _Line(label: 'Municipio', value: item.municipio ?? '-'),
          _Line(label: 'Lugar', value: item.lugar ?? '-'),
          _Line(
            label: 'Recursos',
            value:
                '${item.personal?.label ?? 'Sin personal'} • ${item.canino?.label ?? item.equino?.label ?? 'Sin animal'}',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onPanel,
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Panel'),
              ),
              ElevatedButton.icon(
                onPressed: onCreateReport,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nuevo reporte'),
              ),
              OutlinedButton.icon(
                onPressed: onReportes,
                icon: const Icon(Icons.description_outlined),
                label: const Text('Ver reportes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;

  const _Line({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.2,
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

String _serviceLabel(Servicio item) {
  final folio = item.folioOperativo?.trim() ?? '';
  final clave = item.unidadClave?.trim() ?? '';
  if (folio.isNotEmpty) return folio;
  if (clave.isNotEmpty) return clave;
  return 'Servicio #${item.id}';
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
