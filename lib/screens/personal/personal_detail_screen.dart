import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/personal_detail.dart';
import '../../services/personals_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';

class PersonalDetailScreen extends StatefulWidget {
  final int personalId;

  const PersonalDetailScreen({super.key, required this.personalId});

  @override
  State<PersonalDetailScreen> createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  final PersonalsService _service = PersonalsService();

  bool _loading = true;
  String? _error;
  PersonalDetail? _detail;

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
      final detail = await _service.show(widget.personalId);
      if (!mounted) return;
      setState(() => _detail = detail);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      _IconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _detail == null ? 'Detalle de Personal' : _detail!.personal.nombres,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      _IconButton(icon: Icons.refresh_rounded, onTap: _load),
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
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800),
                            ),
                          )
                        : _detail == null
                        ? const Center(
                            child: Text('Sin informacion', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                          )
                        : ListView(
                            children: [
                              _SectionCard(
                                title: 'Informacion general',
                                children: [
                                  _InfoLine(label: 'Nombre completo', value: _detail!.personal.nombres),
                                  _InfoLine(label: 'Grado', value: _detail!.personal.grado ?? '-'),
                                  _InfoLine(label: 'Cargo', value: _detail!.personal.cargo ?? '-'),
                                  _InfoLine(label: 'Dependencia', value: _detail!.personal.dependencia ?? '-'),
                                  _InfoLine(label: 'CUIP', value: _detail!.personal.cuip ?? '-'),
                                  _InfoLine(label: 'CRP', value: _detail!.personal.crp ?? '-'),
                                  _InfoLine(label: 'Turno', value: _detail!.personal.turno?.nombre ?? '-'),
                                  _InfoLine(label: 'Area', value: _detail!.personal.area?.nombre ?? '-'),
                                  _InfoLine(label: 'Usuario', value: _detail!.personal.user?.name ?? '-'),
                                  _InfoLine(label: 'Correo', value: _detail!.personal.user?.email ?? '-'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _SectionCard(
                                title: 'Servicios activos',
                                children: _detail!.servicios.isEmpty
                                    ? [const _MutedText('Sin servicios activos')]
                                    : _detail!.servicios.map((s) {
                                        return _InfoLine(
                                          label: s.tipo ?? 'Servicio',
                                          value: 'Inicio ${_fmtDate(s.fechaInicioCiclo)} • ${s.horasTrabajo ?? '-'}h trabajo / ${s.horasDescanso ?? '-'}h descanso',
                                        );
                                      }).toList(),
                              ),
                              const SizedBox(height: 12),
                              _SectionCard(
                                title: 'Horario',
                                children: _buildHorario(_detail!.horario),
                              ),
                              const SizedBox(height: 12),
                              _SectionCard(
                                title: 'Armamento asignado',
                                children: _detail!.armasActivas.isEmpty
                                    ? [const _MutedText('Sin arma asignada')]
                                    : _detail!.armasActivas.map((a) => _InfoLine(
                                          label: '${a.weaponTipo ?? '-'} • ${a.weaponMatricula ?? '-'}',
                                          value: 'Estado ${a.weaponEstado ?? '-'} • Asignada ${_fmtDateTime(a.fechaAsignacion)}',
                                        )).toList(),
                              ),
                              const SizedBox(height: 12),
                              _SectionCard(
                                title: 'Historial de armamento',
                                children: _detail!.historialArmamento.isEmpty
                                    ? [const _MutedText('Sin historial')]
                                    : _detail!.historialArmamento.map((a) => _InfoLine(
                                          label: '${a.weaponTipo ?? '-'} • ${a.weaponMatricula ?? '-'}',
                                          value: '${a.status ?? '-'} • ${_fmtDateTime(a.fechaAsignacion)} / ${_fmtDateTime(a.fechaDevolucion)}',
                                        )).toList(),
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

  List<Widget> _buildHorario(PersonalHorario? horario) {
    if (horario == null || horario.detalles.isEmpty) {
      return const [
        _MutedText('Sin horario configurado'),
      ];
    }

    final labels = {
      0: 'Lunes',
      1: 'Martes',
      2: 'Miercoles',
      3: 'Jueves',
      4: 'Viernes',
      5: 'Sabado',
      6: 'Domingo',
    };

    final grouped = <int, List<PersonalHorarioDetalle>>{};
    for (final item in horario.detalles) {
      final key = item.diaSemana ?? -1;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return labels.entries.map((entry) {
      final tramos = grouped[entry.key] ?? const [];
      final value = tramos.isEmpty
          ? 'Sin tramos'
          : tramos.map((t) {
              final base = '${_hhmm(t.horaEntrada)} - ${_hhmm(t.horaSalida)}';
              final extras = [
                if (t.cruzaDia) 'Cruza dia',
                if ((t.bloque ?? '').trim().isNotEmpty) t.bloque!,
                if ((t.notas ?? '').trim().isNotEmpty) t.notas!,
              ];
              return extras.isEmpty ? base : '$base (${extras.join(', ')})';
            }).join(' | ');
      return _InfoLine(label: entry.value, value: value);
    }).toList();
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.22)),
        color: AppColors.whiteWarm.withValues(alpha: 0.60),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 15.5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800, fontSize: 12.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, height: 1.3)),
        ],
      ),
    );
  }
}

class _MutedText extends StatelessWidget {
  final String text;

  const _MutedText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700));
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

String _hhmm(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '--:--';
  return raw.length >= 5 ? raw.substring(0, 5) : raw;
}
