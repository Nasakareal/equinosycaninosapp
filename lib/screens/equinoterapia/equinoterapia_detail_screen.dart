import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_theme.dart';
import '../../models/equinoterapia.dart';
import '../../services/equinoterapias_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'equinoterapia_create_screen.dart';

class EquinoterapiaDetailScreen extends StatefulWidget {
  final int reporteId;

  const EquinoterapiaDetailScreen({super.key, required this.reporteId});

  @override
  State<EquinoterapiaDetailScreen> createState() => _EquinoterapiaDetailScreenState();
}

class _EquinoterapiaDetailScreenState extends State<EquinoterapiaDetailScreen> {
  final EquinoterapiasService _service = EquinoterapiasService();

  bool _loading = true;
  bool _working = false;
  String? _error;
  EquinoterapiaShowData? _data;

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
      final data = await _service.show(widget.reporteId);
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

  Future<void> _edit() async {
    if (_data == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquinoterapiaCreateScreen(reporteId: _data!.reporte.id),
      ),
    );
    _load();
  }

  Future<void> _delete() async {
    if (_data == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar reporte?'),
        content: Text('Se eliminara el reporte del ${_fmtDate(_data!.reporte.fecha)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _working = true);
    try {
      await _service.delete(_data!.reporte.id);
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
    if (_data == null) return;
    await Clipboard.setData(ClipboardData(text: _data!.whatsappMensaje));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje copiado al portapapeles')),
    );
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        _IconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _data == null ? 'Detalle de Equinoterapia' : 'Reporte ${_fmtDate(_data!.reporte.fecha)}',
                            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ),
                        if (_working)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        _IconButton(icon: Icons.edit_rounded, onTap: _edit),
                        const SizedBox(width: 8),
                        _IconButton(icon: Icons.delete_outline_rounded, onTap: _delete, danger: true),
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
                        Tab(text: 'Registros'),
                        Tab(text: 'Diagnosticos'),
                        Tab(text: 'WhatsApp'),
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
                          ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)))
                          : _data == null
                          ? const Center(child: Text('Sin informacion', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)))
                          : TabBarView(
                              children: [
                                _ResumenTab(data: _data!),
                                _RegistrosTab(registros: _data!.reporte.registros),
                                _DiagnosticosTab(registros: _data!.reporte.registros),
                                _WhatsappTab(data: _data!, onCopy: _copyWhatsapp),
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
  final EquinoterapiaShowData data;
  const _ResumenTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final t = data.totales;
    final inasistencias = data.reporte.registros.where((r) => r.estatusAsistencia == 'INASISTIO').toList();
    return ListView(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _StatBox(title: 'Terapias', value: t.realizadas.toString(), color: AppColors.brownDeep),
            _StatBox(title: 'Inasistencias', value: t.inasistencias.toString(), color: AppColors.red),
            _StatBox(title: 'Ninas', value: t.ninas.toString(), color: const Color(0xFFC05B7B)),
            _StatBox(title: 'Ninos', value: t.ninos.toString(), color: const Color(0xFF557C9C)),
            _StatBox(title: 'Valoraciones', value: t.valoraciones.toString(), color: const Color(0xFFBE8759)),
            _StatBox(title: 'Personal', value: t.personal.toString(), color: AppColors.greenDeep),
            _StatBox(title: 'Equinos', value: t.equinos.toString(), color: const Color(0xFF7B6B57)),
          ],
        ),
        const SizedBox(height: 14),
        _InfoPanel(title: 'Datos del reporte', lines: [
          'Fecha: ${_fmtDate(data.reporte.fecha)}',
          'Personal: ${data.reporte.personal}',
          'Equinos: ${data.reporte.equinos}',
          'Valoraciones capturadas: ${data.reporte.valoraciones}',
          'Registros: ${data.reporte.registros.length}',
          'Actividades del area: ${data.reporte.actividadesArea ?? '-'}',
          'Observaciones: ${data.reporte.observaciones ?? '-'}',
          'Creado: ${_fmtDateTime(data.reporte.createdAt)}',
          'Actualizado: ${_fmtDateTime(data.reporte.updatedAt)}',
        ]),
        const SizedBox(height: 12),
        _InfoPanel(
          title: 'Inasistencias del dia',
          lines: inasistencias.isEmpty
              ? ['Sin inasistencias registradas']
              : inasistencias.map((i) => '${i.nombreCompleto} • ${i.sexo} • ${i.diagnostico ?? '-'} • ${i.motivoInasistencia ?? '-'}').toList(),
        ),
      ],
    );
  }
}

class _RegistrosTab extends StatelessWidget {
  final List<EquinoterapiaRegistro> registros;
  const _RegistrosTab({required this.registros});

  @override
  Widget build(BuildContext context) {
    if (registros.isEmpty) {
      return const Center(child: Text('Sin registros capturados', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)));
    }
    return ListView.separated(
      itemCount: registros.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = registros[i];
        return _InfoPanel(title: '${i + 1}. ${r.nombreCompleto}', lines: [
          'Sexo: ${r.sexo}',
          'Diagnostico: ${r.diagnostico ?? '-'}',
          'Asistencia: ${r.estatusAsistencia}',
          'Valoracion: ${r.esValoracion ? 'Si' : 'No'}',
          'Motivo de inasistencia: ${r.motivoInasistencia ?? '-'}',
        ]);
      },
    );
  }
}

class _DiagnosticosTab extends StatelessWidget {
  final List<EquinoterapiaRegistro> registros;
  const _DiagnosticosTab({required this.registros});

  @override
  Widget build(BuildContext context) {
    final totals = <String, int>{};
    for (final r in registros) {
      final key = (r.diagnostico ?? '').trim();
      if (key.isEmpty) continue;
      totals.update(key, (v) => v + 1, ifAbsent: () => 1);
    }
    final entries = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) {
      return const Center(child: Text('Sin diagnosticos registrados', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)));
    }
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _InfoPanel(title: entries[i].key, lines: ['Total: ${entries[i].value}']),
    );
  }
}

class _WhatsappTab extends StatelessWidget {
  final EquinoterapiaShowData data;
  final VoidCallback onCopy;
  const _WhatsappTab({required this.data, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copiar mensaje'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoPanel(title: 'Mensaje listo para WhatsApp', lines: [data.whatsappMensaje]),
        const SizedBox(height: 12),
        SelectableText(data.whatsappUrl, style: const TextStyle(color: AppColors.greenDeep, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  const _IconButton({required this.icon, required this.onTap, this.danger = false});
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
            color: danger ? AppColors.red.withValues(alpha: 0.28) : AppColors.creamStroke.withValues(alpha: 0.24),
          ),
          color: danger ? AppColors.redSoft.withValues(alpha: 0.72) : AppColors.whiteWarm.withValues(alpha: 0.62),
        ),
        child: Icon(icon, color: danger ? AppColors.red : AppColors.brownDeep),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _StatBox({required this.title, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
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
        border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.22)),
        color: AppColors.whiteWarm.withValues(alpha: 0.60),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 14.5)),
          const SizedBox(height: 10),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, height: 1.3)),
              )),
        ],
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
