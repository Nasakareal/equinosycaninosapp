import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/equinoterapia.dart';
import '../../services/equinoterapias_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'equinoterapia_detail_screen.dart';

class EquinoterapiaCreateScreen extends StatefulWidget {
  final int? reporteId;

  const EquinoterapiaCreateScreen({super.key, this.reporteId});

  bool get isEdit => reporteId != null;

  @override
  State<EquinoterapiaCreateScreen> createState() => _EquinoterapiaCreateScreenState();
}

class _EquinoterapiaCreateScreenState extends State<EquinoterapiaCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = EquinoterapiasService();

  final _fechaCtrl = TextEditingController();
  final _personalCtrl = TextEditingController(text: '0');
  final _equinosCtrl = TextEditingController(text: '0');
  final _valoracionesCtrl = TextEditingController(text: '0');
  final _actividadesCtrl = TextEditingController(text: 'ASEO Y MANTENIMIENTO DE TODA EL AREA');
  final _observacionesCtrl = TextEditingController();

  final List<_RegistroFormRow> _rows = [];

  bool _booting = true;
  bool _saving = false;
  String? _error;
  _CreateSummary _summary = const _CreateSummary();

  @override
  void initState() {
    super.initState();
    _initForm();
  }

  Future<void> _initForm() async {
    if (widget.isEdit) {
      await _loadExisting();
    } else {
      _fechaCtrl.text = _rawDate(DateTime.now());
      final row = _RegistroFormRow();
      row.addListener(_recalc);
      _rows.add(row);
      _recalc();
      setState(() => _booting = false);
    }
  }

  Future<void> _loadExisting() async {
    try {
      final data = await _service.show(widget.reporteId!);
      final reporte = data.reporte;
      _fechaCtrl.text = _toDateInput(reporte.fecha);
      _personalCtrl.text = reporte.personal.toString();
      _equinosCtrl.text = reporte.equinos.toString();
      _valoracionesCtrl.text = reporte.valoraciones.toString();
      _actividadesCtrl.text = reporte.actividadesArea ?? '';
      _observacionesCtrl.text = reporte.observaciones ?? '';

      if (reporte.registros.isEmpty) {
        final row = _RegistroFormRow();
        row.addListener(_recalc);
        _rows.add(row);
      } else {
        for (final item in reporte.registros) {
          final row = _RegistroFormRow.fromRegistro(item);
          row.addListener(_recalc);
          _rows.add(row);
        }
      }
      _recalc();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _booting = false);
      }
    }
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _personalCtrl.dispose();
    _equinosCtrl.dispose();
    _valoracionesCtrl.dispose();
    _actividadesCtrl.dispose();
    _observacionesCtrl.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_fechaCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) _fechaCtrl.text = _rawDate(picked);
  }

  void _addRow() {
    final row = _RegistroFormRow();
    row.addListener(_recalc);
    setState(() => _rows.add(row));
    _recalc();
  }

  void _removeRow(int index) {
    if (_rows.length == 1) {
      _rows.first.reset();
    } else {
      final row = _rows.removeAt(index);
      row.dispose();
    }
    setState(() {});
    _recalc();
  }

  void _recalc() {
    int terapias = 0;
    int inasistencias = 0;
    int ninas = 0;
    int ninos = 0;
    int valoraciones = 0;
    int registros = 0;

    for (final row in _rows) {
      final hasName = row.nombreCtrl.text.trim().isNotEmpty;
      if (!hasName) continue;
      registros++;
      if (row.asistencia == 'INASISTIO') inasistencias++;
      if (row.asistencia == 'ASISTIO' && !row.esValoracion) terapias++;
      if (row.asistencia == 'ASISTIO' && row.sexo == 'NINA') ninas++;
      if (row.asistencia == 'ASISTIO' && row.sexo == 'NINO') ninos++;
      if (row.esValoracion) valoraciones++;
    }

    _valoracionesCtrl.text = valoraciones.toString();
    setState(() {
      _summary = _CreateSummary(
        terapias: terapias,
        inasistencias: inasistencias,
        ninas: ninas,
        ninos: ninos,
        valoraciones: valoraciones,
        registros: registros,
      );
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'fecha': _fechaCtrl.text.trim(),
      'personal': _toInt(_personalCtrl.text),
      'equinos': _toInt(_equinosCtrl.text),
      'valoraciones': _toInt(_valoracionesCtrl.text),
      'actividades_area': _blankToNull(_actividadesCtrl.text),
      'observaciones': _blankToNull(_observacionesCtrl.text),
      'nombre_completo': _rows.map((r) => r.nombreCtrl.text.trim()).toList(),
      'sexo': _rows.map((r) => r.sexoApi).toList(),
      'diagnostico': _rows.map((r) => _blankToNull(r.diagnosticoCtrl.text) ?? '').toList(),
      'estatus_asistencia': _rows.map((r) => r.asistencia).toList(),
      'motivo_inasistencia': _rows.map((r) => _blankToNull(r.motivoCtrl.text) ?? '').toList(),
      'es_valoracion': _rows.map((r) => r.esValoracion ? '1' : '0').toList(),
    };

    setState(() => _saving = true);
    try {
      final result = widget.isEdit
          ? await _service.update(widget.reporteId!, payload)
          : await _service.create(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit
              ? 'Reporte de equinoterapia actualizado correctamente'
              : 'Reporte de equinoterapia registrado correctamente'),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EquinoterapiaDetailScreen(reporteId: result.id)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
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
                          widget.isEdit ? 'Editar Equinoterapia' : 'Registrar Equinoterapia',
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _booting
                      ? const Center(child: CircularProgressIndicator())
                      : Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              if (_error != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.redSoft.withValues(alpha: 0.78),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.red.withValues(alpha: 0.30)),
                                  ),
                                  child: Text(_error!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
                                ),
                              Glass(
                                radius: 22,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _fechaCtrl,
                                            readOnly: true,
                                            onTap: _pickFecha,
                                            decoration: const InputDecoration(labelText: 'Fecha'),
                                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Captura la fecha' : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _personalCtrl,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(labelText: 'Personal'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _equinosCtrl,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(labelText: 'Equinos'),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _valoracionesCtrl,
                                            readOnly: true,
                                            decoration: const InputDecoration(labelText: 'Valoraciones'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _actividadesCtrl,
                                      minLines: 2,
                                      maxLines: 4,
                                      decoration: const InputDecoration(labelText: 'Actividades del area'),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _observacionesCtrl,
                                      minLines: 2,
                                      maxLines: 4,
                                      decoration: const InputDecoration(labelText: 'Observaciones'),
                                    ),
                                    const SizedBox(height: 14),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        _SummaryPill(title: 'Terapias', value: _summary.terapias.toString(), color: AppColors.brownDeep),
                                        _SummaryPill(title: 'Inasistencias', value: _summary.inasistencias.toString(), color: AppColors.red),
                                        _SummaryPill(title: 'Ninas', value: _summary.ninas.toString(), color: const Color(0xFFC05B7B)),
                                        _SummaryPill(title: 'Ninos', value: _summary.ninos.toString(), color: const Color(0xFF557C9C)),
                                        _SummaryPill(title: 'Valoraciones', value: _summary.valoraciones.toString(), color: const Color(0xFFBE8759)),
                                        _SummaryPill(title: 'Registros', value: _summary.registros.toString(), color: AppColors.greenDeep),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Glass(
                                radius: 22,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text('Registros de asistencia', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 16)),
                                        ),
                                        ElevatedButton.icon(onPressed: _addRow, icon: const Icon(Icons.add_rounded), label: const Text('Agregar registro')),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ...List.generate(_rows.length, (i) {
                                      final row = _rows[i];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: _RegistroCard(index: i + 1, row: row, onRemove: () => _removeRow(i)),
                                      );
                                    }),
                                    ElevatedButton.icon(
                                      onPressed: _saving ? null : _submit,
                                      icon: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteWarm),
                                            )
                                          : const Icon(Icons.save_rounded),
                                      label: Text(_saving
                                          ? (widget.isEdit ? 'Actualizando...' : 'Guardando...')
                                          : (widget.isEdit ? 'Actualizar reporte' : 'Guardar reporte')),
                                    ),
                                  ],
                                ),
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

class _CreateSummary {
  final int terapias;
  final int inasistencias;
  final int ninas;
  final int ninos;
  final int valoraciones;
  final int registros;
  const _CreateSummary({
    this.terapias = 0,
    this.inasistencias = 0,
    this.ninas = 0,
    this.ninos = 0,
    this.valoraciones = 0,
    this.registros = 0,
  });
}

class _RegistroFormRow {
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController diagnosticoCtrl = TextEditingController();
  final TextEditingController motivoCtrl = TextEditingController();
  String sexo = 'NINO';
  String asistencia = 'ASISTIO';
  bool esValoracion = false;
  final List<VoidCallback> _listeners = [];

  _RegistroFormRow();

  factory _RegistroFormRow.fromRegistro(EquinoterapiaRegistro item) {
    final row = _RegistroFormRow();
    row.nombreCtrl.text = item.nombreCompleto;
    row.diagnosticoCtrl.text = item.diagnostico ?? '';
    row.motivoCtrl.text = item.motivoInasistencia ?? '';
    row.sexo = item.sexo == 'NIÑA' ? 'NINA' : 'NINO';
    row.asistencia = item.estatusAsistencia;
    row.esValoracion = item.esValoracion;
    return row;
  }

  String get sexoApi => sexo == 'NINA' ? 'NIÑA' : 'NIÑO';

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    nombreCtrl.addListener(listener);
    diagnosticoCtrl.addListener(listener);
    motivoCtrl.addListener(listener);
  }

  void notify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void reset() {
    nombreCtrl.clear();
    diagnosticoCtrl.clear();
    motivoCtrl.clear();
    sexo = 'NINO';
    asistencia = 'ASISTIO';
    esValoracion = false;
    notify();
  }

  void dispose() {
    nombreCtrl.dispose();
    diagnosticoCtrl.dispose();
    motivoCtrl.dispose();
  }
}

class _RegistroCard extends StatefulWidget {
  final int index;
  final _RegistroFormRow row;
  final VoidCallback onRemove;

  const _RegistroCard({required this.index, required this.row, required this.onRemove});

  @override
  State<_RegistroCard> createState() => _RegistroCardState();
}

class _RegistroCardState extends State<_RegistroCard> {
  @override
  Widget build(BuildContext context) {
    final row = widget.row;
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
          Row(
            children: [
              Text('Registro ${widget.index}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900)),
              const Spacer(),
              IconButton(onPressed: widget.onRemove, icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red)),
            ],
          ),
          TextFormField(
            controller: row.nombreCtrl,
            decoration: const InputDecoration(labelText: 'Nombre completo'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Captura el nombre' : null,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: row.sexo,
                  decoration: const InputDecoration(labelText: 'Sexo'),
                  items: const [
                    DropdownMenuItem(value: 'NINO', child: Text('Nino')),
                    DropdownMenuItem(value: 'NINA', child: Text('Nina')),
                  ],
                  onChanged: (v) {
                    setState(() => row.sexo = v ?? 'NINO');
                    row.notify();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: row.asistencia,
                  decoration: const InputDecoration(labelText: 'Asistencia'),
                  items: const [
                    DropdownMenuItem(value: 'ASISTIO', child: Text('Asistio')),
                    DropdownMenuItem(value: 'INASISTIO', child: Text('Inasistio')),
                  ],
                  onChanged: (v) {
                    setState(() => row.asistencia = v ?? 'ASISTIO');
                    if (row.asistencia == 'ASISTIO') row.motivoCtrl.clear();
                    row.notify();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<bool>(
            value: row.esValoracion,
            decoration: const InputDecoration(labelText: 'Valoracion'),
            items: const [
              DropdownMenuItem(value: false, child: Text('No')),
              DropdownMenuItem(value: true, child: Text('Si')),
            ],
            onChanged: (v) {
              setState(() => row.esValoracion = v ?? false);
              row.notify();
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: row.diagnosticoCtrl,
            decoration: const InputDecoration(labelText: 'Diagnostico'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: row.motivoCtrl,
            enabled: row.asistencia == 'INASISTIO',
            decoration: const InputDecoration(labelText: 'Motivo de inasistencia'),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _SummaryPill({required this.title, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700, fontSize: 12)),
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
          border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.24)),
          color: AppColors.whiteWarm.withValues(alpha: 0.62),
        ),
        child: Icon(icon, color: AppColors.brownDeep),
      ),
    );
  }
}

int _toInt(String v) => int.tryParse(v.trim()) ?? 0;
String? _blankToNull(String v) => v.trim().isEmpty ? null : v.trim();
String _rawDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

String _toDateInput(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw.trim());
  return dt == null ? raw : _rawDate(dt);
}
