import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../models/servicio.dart';
import '../../services/mis_servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'mis_servicio_reporte_form_screen.dart';

class MisServicioReporteDetailScreen extends StatefulWidget {
  final int servicioId;
  final int reporteId;
  final String? servicioNombre;

  const MisServicioReporteDetailScreen({
    super.key,
    required this.servicioId,
    required this.reporteId,
    this.servicioNombre,
  });

  @override
  State<MisServicioReporteDetailScreen> createState() =>
      _MisServicioReporteDetailScreenState();
}

class _MisServicioReporteDetailScreenState
    extends State<MisServicioReporteDetailScreen> {
  final MisServiciosService _service = MisServiciosService();

  bool _loading = true;
  bool _working = false;
  bool _shareLoading = false;
  String? _error;
  ServicioReporte? _reporte;
  ServicioReporteWhatsappData? _whatsapp;
  ServicioReporteCompartirData? _compartir;

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
      final reporte = await _service.reporteShow(
        widget.servicioId,
        widget.reporteId,
      );
      if (!mounted) return;
      setState(() => _reporte = reporte);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MisServicioReporteFormScreen(
          servicioId: widget.servicioId,
          reporteId: widget.reporteId,
          servicioNombre: _resolvedTitle,
        ),
      ),
    );
    _load();
  }

  Future<void> _delete() async {
    final reporte = _reporte;
    if (reporte == null) return;
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
      await _service.deleteReporte(widget.servicioId, widget.reporteId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte eliminado correctamente')),
      );
      Navigator.pop(context);
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

  Future<void> _copyWhatsapp() async {
    setState(() => _shareLoading = true);
    try {
      final data = await _service.whatsapp(widget.servicioId, widget.reporteId);
      if (!mounted) return;
      setState(() => _whatsapp = data);
      await Clipboard.setData(ClipboardData(text: data.texto));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje de WhatsApp copiado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _shareLoading = false);
      }
    }
  }

  Future<void> _loadCompartir() async {
    setState(() => _shareLoading = true);
    try {
      final data = await _service.compartirNativo(
        widget.servicioId,
        widget.reporteId,
      );
      if (!mounted) return;
      setState(() => _compartir = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _shareLoading = false);
      }
    }
  }

  Future<void> _deleteFoto(ServicioReporteFoto foto) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar foto?'),
        content: Text(
          'Se eliminara ${foto.nombreOriginal ?? 'la foto seleccionada'}',
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
      await _service.deleteFoto(widget.servicioId, widget.reporteId, foto.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto eliminada correctamente')),
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
    return 'Servicio ${widget.servicioId}';
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
                            _reporte == null
                                ? 'Detalle del reporte'
                                : '${_reporte!.tipoReporte ?? 'REPORTE'} • ${_fmtDate(_reporte!.fecha)}',
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _resolvedTitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
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
                        Tab(text: 'Narrativa'),
                        Tab(text: 'Fotos'),
                        Tab(text: 'Compartir'),
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
                          : _reporte == null
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
                                _ResumenTab(reporte: _reporte!),
                                _NarrativaTab(reporte: _reporte!),
                                _FotosTab(
                                  reporte: _reporte!,
                                  onDeleteFoto: _deleteFoto,
                                ),
                                _CompartirTab(
                                  whatsapp: _whatsapp,
                                  compartir: _compartir,
                                  loading: _shareLoading,
                                  onCopyWhatsapp: _copyWhatsapp,
                                  onLoadCompartir: _loadCompartir,
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
  final ServicioReporte reporte;

  const _ResumenTab({required this.reporte});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _BadgeBox(
              title: 'Tipo',
              value: reporte.tipoReporte ?? '-',
              color: AppColors.brownDeep,
            ),
            _BadgeBox(
              title: 'Fecha',
              value: _fmtDate(reporte.fecha),
              color: AppColors.greenDeep,
            ),
            _BadgeBox(
              title: 'Hora',
              value: _fmtHour(reporte.hora),
              color: AppColors.brown,
            ),
            _BadgeBox(
              title: 'Fotos',
              value: reporte.fotos.length.toString(),
              color: AppColors.greenDeep,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Datos generales',
          lines: [
            'Municipio: ${reporte.municipio ?? '-'}',
            'Lugar: ${reporte.lugar ?? '-'}',
            'Asunto: ${reporte.asunto ?? '-'}',
            'Creador: ${reporte.creador?.label ?? '-'}',
            'Latitud: ${reporte.lat ?? '-'}',
            'Longitud: ${reporte.lng ?? '-'}',
            'Creado: ${_fmtDateTime(reporte.createdAt)}',
            'Actualizado: ${_fmtDateTime(reporte.updatedAt)}',
          ],
        ),
      ],
    );
  }
}

class _NarrativaTab extends StatelessWidget {
  final ServicioReporte reporte;

  const _NarrativaTab({required this.reporte});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _InfoPanel(title: 'Narrativa', lines: [reporte.narrativa ?? '-']),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Estado de fuerza',
          lines: [reporte.estadoFuerzaTexto ?? '-'],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Acciones a realizar',
          lines: [reporte.accionesARealizar ?? '-'],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Acciones realizadas',
          lines: [reporte.accionesRealizadas ?? '-'],
        ),
        const SizedBox(height: 12),
        _InfoPanel(title: 'Resultados', lines: [reporte.resultados ?? '-']),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Datos persona asegurada',
          lines: [reporte.datosPersonaAsegurada ?? '-'],
        ),
        const SizedBox(height: 12),
        _InfoPanel(title: 'Conclusion', lines: [reporte.conclusion ?? '-']),
      ],
    );
  }
}

class _FotosTab extends StatelessWidget {
  final ServicioReporte reporte;
  final ValueChanged<ServicioReporteFoto> onDeleteFoto;

  const _FotosTab({required this.reporte, required this.onDeleteFoto});

  @override
  Widget build(BuildContext context) {
    if (reporte.fotos.isEmpty) {
      return const Center(
        child: Text(
          'Este reporte no tiene fotos',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
        ),
      );
    }

    return ListView.separated(
      itemCount: reporte.fotos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final foto = reporte.fotos[i];
        final imageUrl = foto.url?.trim() ?? '';
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
              if (imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      alignment: Alignment.center,
                      color: AppColors.creamStrong.withValues(alpha: 0.52),
                      child: const Text('No se pudo cargar la foto'),
                    ),
                  ),
                ),
              if (imageUrl.isNotEmpty) const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      foto.nombreOriginal ?? 'Foto ${i + 1}',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onDeleteFoto(foto),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
              Text(
                'Descripcion: ${foto.descripcion ?? '-'}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mime: ${foto.mime ?? '-'} • ${(foto.size / 1024).toStringAsFixed(1)} KB',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CompartirTab extends StatelessWidget {
  final ServicioReporteWhatsappData? whatsapp;
  final ServicioReporteCompartirData? compartir;
  final bool loading;
  final VoidCallback onCopyWhatsapp;
  final VoidCallback onLoadCompartir;

  const _CompartirTab({
    required this.whatsapp,
    required this.compartir,
    required this.loading,
    required this.onCopyWhatsapp,
    required this.onLoadCompartir,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: loading ? null : onCopyWhatsapp,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.whiteWarm,
                        ),
                      )
                    : const Icon(Icons.copy_rounded),
                label: const Text('Copiar WhatsApp'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: loading ? null : onLoadCompartir,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Cargar compartir'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Mensaje de WhatsApp',
          lines: [
            whatsapp?.texto.trim().isNotEmpty == true
                ? whatsapp!.texto
                : 'Carga el mensaje para copiarlo o revisarlo aqui.',
          ],
        ),
        if (whatsapp?.url.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          SelectableText(
            whatsapp!.url,
            style: const TextStyle(
              color: AppColors.greenDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Compartir nativo',
          lines: [
            compartir?.texto.trim().isNotEmpty == true
                ? compartir!.texto
                : 'Carga el paquete de compartir nativo para ver texto e imagenes disponibles.',
          ],
        ),
        if ((compartir?.imagenes.length ?? 0) > 0) ...[
          const SizedBox(height: 12),
          ...compartir!.imagenes.map(
            (url) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectableText(
                url,
                style: const TextStyle(
                  color: AppColors.greenDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
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
