import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/servicio.dart';
import '../../services/servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'servicio_create_screen.dart';

class ServicioDetailScreen extends StatefulWidget {
  final int servicioId;

  const ServicioDetailScreen({super.key, required this.servicioId});

  @override
  State<ServicioDetailScreen> createState() => _ServicioDetailScreenState();
}

class _ServicioDetailScreenState extends State<ServicioDetailScreen> {
  final ServiciosService _service = ServiciosService();

  bool _loading = true;
  bool _working = false;
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
      final data = await _service.show(widget.servicioId);
      if (!mounted) return;
      setState(() => _servicio = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    if (_servicio == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicioCreateScreen(servicioId: _servicio!.id),
      ),
    );
    _load();
  }

  Future<void> _delete() async {
    if (_servicio == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio?'),
        content: Text(
          'Se eliminara el registro ${_servicio!.folioOperativo ?? '#${_servicio!.id}'}',
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
      await _service.delete(_servicio!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicio eliminado correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
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
                            _servicio == null
                                ? 'Detalle de Servicio'
                                : (_servicio!.folioOperativo
                                              ?.trim()
                                              .isNotEmpty ==
                                          true
                                      ? _servicio!.folioOperativo!
                                      : 'Servicio #${_servicio!.id}'),
                            style: const TextStyle(
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
                        _IconButton(icon: Icons.edit_rounded, onTap: _edit),
                        const SizedBox(width: 8),
                        _IconButton(
                          icon: Icons.delete_outline_rounded,
                          onTap: _delete,
                          danger: true,
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
                        Tab(text: 'Operacion'),
                        Tab(text: 'Relaciones'),
                        Tab(text: 'Bitacora'),
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
                              ),
                            )
                          : _servicio == null
                          ? const Center(
                              child: Text(
                                'Sin informacion',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : TabBarView(
                              children: [
                                _ResumenTab(servicio: _servicio!),
                                _OperacionTab(servicio: _servicio!),
                                _RelacionesTab(servicio: _servicio!),
                                _BitacoraTab(servicio: _servicio!),
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
            _BadgeBox(
              title: 'Categoria',
              value: _safe(servicio.categoriaRegistro),
              color: AppColors.brownDeep,
            ),
            _BadgeBox(
              title: 'Tipo',
              value: _safe(servicio.tipoServicio),
              color: AppColors.greenDeep,
            ),
            _BadgeBox(
              title: 'Estatus',
              value: _safe(servicio.estatusServicio),
              color: AppColors.brown,
            ),
            _BadgeBox(
              title: 'Cumplio',
              value: servicio.cumplio ? 'Si' : 'No',
              color: servicio.cumplio ? AppColors.greenDeep : AppColors.red,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Datos principales',
          lines: [
            'Folio operativo: ${servicio.folioOperativo ?? '-'}',
            'Fecha: ${_fmtDate(servicio.fecha)}',
            'Horario: ${_fmtHour(servicio.hora)} - ${_fmtHour(servicio.horaFin)}',
            'Asunto: ${servicio.asunto ?? '-'}',
            'Objetivo: ${servicio.objetivoServicio ?? '-'}',
            'Unidad clave: ${servicio.unidadClave ?? '-'}',
            'CRP: ${servicio.crp ?? '-'}',
            'Municipio: ${servicio.municipio ?? '-'}',
            'Lugar: ${servicio.lugar ?? '-'}',
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Responsables',
          lines: [
            'Personal: ${servicio.personal?.label ?? '-'}',
            'Comandante: ${servicio.comandanteResponsable ?? '-'}',
            'Cargo: ${servicio.cargoResponsable ?? '-'}',
            'Creado por: ${servicio.creador?.label ?? '-'}',
            'Creado: ${_fmtDateTime(servicio.createdAt)}',
            'Actualizado: ${_fmtDateTime(servicio.updatedAt)}',
          ],
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
          title: 'Narrativa',
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
          title: 'Banderas del servicio',
          lines: [
            'Seguridad: ${servicio.seguridad ? 'Si' : 'No'}',
            'Barrido de seguridad: ${servicio.barridoSeguridad ? 'Si' : 'No'}',
            'Desfiles: ${servicio.desfiles ? 'Si' : 'No'}',
            'Proximidad social: ${servicio.proximidadSocial ? 'Si' : 'No'}',
            'Actos civicos: ${servicio.actosCivicos ? 'Si' : 'No'}',
            'Tipo de busqueda: ${servicio.tipoBusqueda ?? '-'}',
            'Coordenadas: ${servicio.lat ?? '-'}, ${servicio.lng ?? '-'}',
          ],
        ),
      ],
    );
  }
}

class _RelacionesTab extends StatelessWidget {
  final Servicio servicio;
  const _RelacionesTab({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoPanel(
          title: 'Recursos asignados',
          lines: [
            'Canino: ${servicio.canino?.label ?? '-'}',
            'Equino: ${servicio.equino?.label ?? '-'}',
            'Patrulla: ${servicio.patrulla?.label ?? (servicio.patrullaId?.toString() ?? '-')}',
            'Oficio referencia: ${servicio.oficioReferencia ?? '-'}',
            'Memorandum referencia: ${servicio.memorandumReferencia ?? '-'}',
            'Archivo: ${servicio.archivoNombreOriginal ?? servicio.archivo ?? '-'}',
          ],
        ),
        const SizedBox(height: 12),
        if (servicio.estadoFuerza != null)
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
        if (servicio.estadoFuerza != null) const SizedBox(height: 12),
        _CollectionPanel(
          title: 'Participantes',
          items: servicio.participantes
              .map(
                (x) =>
                    '${x.nombre ?? 'Sin nombre'} • ${x.cargo ?? '-'} • ${x.observaciones ?? '-'}',
              )
              .toList(),
          emptyLabel: 'Sin participantes',
        ),
        const SizedBox(height: 12),
        _CollectionPanel(
          title: 'Recursos',
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

class _BitacoraTab extends StatelessWidget {
  final Servicio servicio;
  const _BitacoraTab({required this.servicio});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _CollectionPanel(
          title: 'Movimientos',
          items: servicio.movimientos
              .map(
                (x) =>
                    '${_fmtDate(x.fecha)} ${_fmtHour(x.hora)} • ${x.lugar ?? '-'} • ${x.descripcion ?? '-'}',
              )
              .toList(),
          emptyLabel: 'Sin movimientos',
        ),
        const SizedBox(height: 12),
        _CollectionPanel(
          title: 'Coordenadas',
          items: servicio.coordenadas
              .map(
                (x) =>
                    'Orden ${x.orden} • ${x.lat ?? '-'}, ${x.lng ?? '-'} • ${x.referencia ?? '-'}',
              )
              .toList(),
          emptyLabel: 'Sin coordenadas',
        ),
        const SizedBox(height: 12),
        _CollectionPanel(
          title: 'Reportes',
          items: servicio.reportes
              .map(
                (x) =>
                    '${_fmtDate(x.fecha)} ${_fmtHour(x.hora)} • ${x.asunto ?? '-'} • ${x.descripcion ?? '-'}',
              )
              .toList(),
          emptyLabel: 'Sin reportes',
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

class _BadgeBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _BadgeBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
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
  final bool danger;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

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
            color: danger
                ? AppColors.red.withValues(alpha: 0.28)
                : AppColors.creamStroke.withValues(alpha: 0.24),
          ),
          color: danger
              ? AppColors.redSoft.withValues(alpha: 0.72)
              : AppColors.whiteWarm.withValues(alpha: 0.62),
        ),
        child: Icon(icon, color: danger ? AppColors.red : AppColors.brownDeep),
      ),
    );
  }
}

String _safe(String v) => v.trim().isEmpty ? '-' : v;

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
