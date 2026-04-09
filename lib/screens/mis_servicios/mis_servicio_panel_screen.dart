import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/servicio.dart';
import '../../services/mis_servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'mis_servicio_reporte_detail_screen.dart';
import 'mis_servicio_reporte_form_screen.dart';
import 'mis_servicio_reportes_screen.dart';

class MisServicioPanelScreen extends StatefulWidget {
  final int servicioId;

  const MisServicioPanelScreen({super.key, required this.servicioId});

  @override
  State<MisServicioPanelScreen> createState() => _MisServicioPanelScreenState();
}

class _MisServicioPanelScreenState extends State<MisServicioPanelScreen> {
  final MisServiciosService _service = MisServiciosService();

  bool _loading = true;
  String? _error;
  Servicio? _servicio;

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
      final servicio = await _service.panel(widget.servicioId);
      if (!mounted) return;
      setState(() => _servicio = servicio);
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
    final servicio = _servicio;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReporteFormScreen(
          servicioId: widget.servicioId,
          servicioNombre: _serviceLabel(servicio),
          servicioBase: servicio,
        ),
      ),
    );
    _load();
  }

  Future<void> _openReportes() async {
    final servicio = _servicio;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReportesScreen(
          servicioId: widget.servicioId,
          servicioNombre: _serviceLabel(servicio),
        ),
      ),
    );
    _load();
  }

  Future<void> _openReporte(ServicioReporte reporte) async {
    final servicio = _servicio;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReporteDetailScreen(
          servicioId: widget.servicioId,
          reporteId: reporte.id,
          servicioNombre: _serviceLabel(servicio),
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
                            _serviceLabel(_servicio),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _IconButton(
                          icon: Icons.add_rounded,
                          onTap: _openCreate,
                        ),
                        const SizedBox(width: 8),
                        _IconButton(icon: Icons.refresh_rounded, onTap: _load),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Glass(
                    radius: 18,
                    padding: const EdgeInsets.all(8),
                    child: const TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(text: 'Resumen'),
                        Tab(text: 'Equipo'),
                        Tab(text: 'Operacion'),
                        Tab(text: 'Reportes'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Glass(
                      radius: 22,
                      padding: const EdgeInsets.all(14),
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
                          : _servicio == null
                          ? const Center(
                              child: Text(
                                'Sin informacion disponible',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : TabBarView(
                              children: [
                                _ResumenTab(servicio: _servicio!),
                                _EquipoTab(servicio: _servicio!),
                                _OperacionTab(servicio: _servicio!),
                                _ReportesTab(
                                  servicio: _servicio!,
                                  onCreate: _openCreate,
                                  onOpenAll: _openReportes,
                                  onOpenReporte: _openReporte,
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
      ),
    );
  }
}

class _ResumenTab extends StatelessWidget {
  final Servicio servicio;

  const _ResumenTab({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatBox(
              title: 'Categoria',
              value: _safe(servicio.categoriaRegistro),
              color: AppColors.brownDeep,
            ),
            _StatBox(
              title: 'Tipo',
              value: _safe(servicio.tipoServicio),
              color: AppColors.greenDeep,
            ),
            _StatBox(
              title: 'Estatus',
              value: _safe(servicio.estatusServicio),
              color: AppColors.brown,
            ),
            _StatBox(
              title: 'Reportes',
              value: servicio.reportes.length.toString(),
              color: AppColors.greenDeep,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Datos principales',
          lines: [
            'Folio operativo: ${servicio.folioOperativo ?? '-'}',
            'Unidad clave: ${servicio.unidadClave ?? '-'}',
            'Fecha: ${_fmtDate(servicio.fecha)}',
            'Horario: ${_fmtHour(servicio.hora)} - ${_fmtHour(servicio.horaFin)}',
            'Asunto: ${servicio.asunto ?? '-'}',
            'Municipio: ${servicio.municipio ?? '-'}',
            'Lugar: ${servicio.lugar ?? '-'}',
            'Objetivo: ${servicio.objetivoServicio ?? '-'}',
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Responsables',
          lines: [
            'Creador: ${servicio.creador?.label ?? '-'}',
            'Personal: ${servicio.personal?.label ?? '-'}',
            'Comandante: ${servicio.comandanteResponsable ?? '-'}',
            'Cargo: ${servicio.cargoResponsable ?? '-'}',
            'Creado: ${_fmtDateTime(servicio.createdAt)}',
            'Actualizado: ${_fmtDateTime(servicio.updatedAt)}',
          ],
        ),
      ],
    );
  }
}

class _EquipoTab extends StatelessWidget {
  final Servicio servicio;

  const _EquipoTab({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoPanel(
          title: 'Recursos asignados',
          lines: [
            'Personal: ${servicio.personal?.label ?? '-'}',
            'Canino: ${servicio.canino?.label ?? '-'}',
            'Equino: ${servicio.equino?.label ?? '-'}',
            'Patrulla: ${servicio.patrulla?.label ?? (servicio.patrullaId?.toString() ?? '-')}',
            'CRP: ${servicio.crp ?? '-'}',
            'Oficio: ${servicio.oficioReferencia ?? '-'}',
            'Memorandum: ${servicio.memorandumReferencia ?? '-'}',
          ],
        ),
        if (servicio.estadoFuerza != null) ...[
          const SizedBox(height: 12),
          _InfoPanel(
            title: 'Estado de fuerza',
            lines: [
              'Personal: ${servicio.estadoFuerza!.totalPersonal}',
              'Caninos: ${servicio.estadoFuerza!.totalCaninos}',
              'Equinos: ${servicio.estadoFuerza!.totalEquinos}',
              'Patrullas: ${servicio.estadoFuerza!.totalPatrullas}',
              'Observaciones: ${servicio.estadoFuerza!.observaciones ?? '-'}',
            ],
          ),
        ],
        const SizedBox(height: 12),
        _CollectionPanel(
          title: 'Participantes',
          items: servicio.participantes
              .map(
                (x) =>
                    '${x.nombre ?? 'Sin nombre'} • ${x.cargo ?? '-'} • ${x.observaciones ?? '-'}',
              )
              .toList(),
          emptyLabel: 'Sin participantes registrados',
        ),
        const SizedBox(height: 12),
        _CollectionPanel(
          title: 'Recursos operativos',
          items: servicio.recursos
              .map(
                (x) =>
                    '${x.tipo ?? 'Recurso'} • ${x.descripcion ?? '-'} • Cantidad: ${x.cantidad ?? '-'}',
              )
              .toList(),
          emptyLabel: 'Sin recursos registrados',
        ),
      ],
    );
  }
}

class _OperacionTab extends StatelessWidget {
  final Servicio servicio;

  const _OperacionTab({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoPanel(
          title: 'Narrativa operativa',
          lines: [
            'Descripcion: ${servicio.descripcion ?? '-'}',
            'Acciones realizadas: ${servicio.accionesRealizadas ?? '-'}',
            'Resultados: ${servicio.resultados ?? '-'}',
            'Conclusion operativa: ${servicio.conclusionOperativa ?? '-'}',
            'Observaciones: ${servicio.observaciones ?? '-'}',
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Cobertura y ubicacion',
          lines: [
            'Seguridad: ${servicio.seguridad ? 'Si' : 'No'}',
            'Barrido de seguridad: ${servicio.barridoSeguridad ? 'Si' : 'No'}',
            'Desfiles: ${servicio.desfiles ? 'Si' : 'No'}',
            'Proximidad social: ${servicio.proximidadSocial ? 'Si' : 'No'}',
            'Actos civicos: ${servicio.actosCivicos ? 'Si' : 'No'}',
            'Cumplio: ${servicio.cumplio ? 'Si' : 'No'}',
            'Tipo de busqueda: ${servicio.tipoBusqueda ?? '-'}',
            'Coordenadas: ${servicio.lat ?? '-'}, ${servicio.lng ?? '-'}',
          ],
        ),
        const SizedBox(height: 12),
        _CollectionPanel(
          title: 'Coordenadas registradas',
          items: servicio.coordenadas
              .map(
                (x) =>
                    'Orden ${x.orden} • ${x.lat ?? '-'}, ${x.lng ?? '-'} • ${x.referencia ?? '-'}',
              )
              .toList(),
          emptyLabel: 'Sin coordenadas',
        ),
      ],
    );
  }
}

class _ReportesTab extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback onCreate;
  final VoidCallback onOpenAll;
  final ValueChanged<ServicioReporte> onOpenReporte;

  const _ReportesTab({
    required this.servicio,
    required this.onCreate,
    required this.onOpenAll,
    required this.onOpenReporte,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reportes capturados: ${servicio.reportes.length}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.8,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onOpenAll,
              icon: const Icon(Icons.list_alt_rounded),
              label: const Text('Ver todo'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: servicio.reportes.isEmpty
              ? const Center(
                  child: Text(
                    'Aun no hay reportes para este servicio',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  itemCount: servicio.reportes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final reporte = servicio.reportes[i];
                    return InkWell(
                      onTap: () => onOpenReporte(reporte),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.creamStroke.withValues(
                              alpha: 0.22,
                            ),
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
                                    '${reporte.tipoReporte ?? 'REPORTE'} • ${_fmtDate(reporte.fecha)} ${_fmtHour(reporte.hora)}',
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Asunto: ${reporte.asunto ?? '-'}',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Resumen: ${reporte.resumen.isEmpty ? '-' : reporte.resumen}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CollectionPanel extends StatelessWidget {
  final String title;
  final List<String> items;
  final String emptyLabel;

  const _CollectionPanel({
    required this.title,
    required this.items,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoPanel(
      title: title,
      lines: items.isEmpty ? [emptyLabel] : items,
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _InfoPanel({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
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

String _serviceLabel(Servicio? item) {
  if (item == null) return 'Panel de servicio';
  final folio = item.folioOperativo?.trim() ?? '';
  final clave = item.unidadClave?.trim() ?? '';
  if (folio.isNotEmpty) return folio;
  if (clave.isNotEmpty) return clave;
  return 'Servicio #${item.id}';
}

String _safe(String value) => value.trim().isEmpty ? '-' : value;

String _fmtDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final dt = DateTime.tryParse(raw.trim());
  if (dt == null) return raw;
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$d/$m/${dt.year}';
}

String _fmtDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final dt = DateTime.tryParse(raw.trim());
  if (dt == null) return raw;
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$d/$m/${dt.year} $h:$min';
}

String _fmtHour(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final clean = raw.trim();
  return clean.length >= 5 ? clean.substring(0, 5) : clean;
}
