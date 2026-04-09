import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/servicio.dart';
import '../../services/mis_servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'mis_servicio_reporte_detail_screen.dart';

class MisServicioReporteFormScreen extends StatefulWidget {
  final int servicioId;
  final int? reporteId;
  final String? servicioNombre;
  final Servicio? servicioBase;

  const MisServicioReporteFormScreen({
    super.key,
    required this.servicioId,
    this.reporteId,
    this.servicioNombre,
    this.servicioBase,
  });

  bool get isEdit => reporteId != null;

  @override
  State<MisServicioReporteFormScreen> createState() =>
      _MisServicioReporteFormScreenState();
}

class _MisServicioReporteFormScreenState
    extends State<MisServicioReporteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MisServiciosService _service = MisServiciosService();

  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  final _asuntoCtrl = TextEditingController();
  final _narrativaCtrl = TextEditingController();
  final _estadoFuerzaCtrl = TextEditingController();
  final _accionesRealizarCtrl = TextEditingController();
  final _accionesRealizadasCtrl = TextEditingController();
  final _resultadosCtrl = TextEditingController();
  final _personaAseguradaCtrl = TextEditingController();
  final _conclusionCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _booting = true;
  bool _saving = false;
  String? _error;
  String _tipoReporte = 'INICIO';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _municipioCtrl.dispose();
    _lugarCtrl.dispose();
    _asuntoCtrl.dispose();
    _narrativaCtrl.dispose();
    _estadoFuerzaCtrl.dispose();
    _accionesRealizarCtrl.dispose();
    _accionesRealizadasCtrl.dispose();
    _resultadosCtrl.dispose();
    _personaAseguradaCtrl.dispose();
    _conclusionCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      if (widget.isEdit) {
        final reporte = await _service.reporteShow(
          widget.servicioId,
          widget.reporteId!,
        );
        _hydrate(reporte);
      } else {
        _fechaCtrl.text = _rawDate(DateTime.now());
        _horaCtrl.text = _rawTime(TimeOfDay.now());
        final base = widget.servicioBase;
        if (base != null) {
          _municipioCtrl.text = base.municipio ?? '';
          _lugarCtrl.text = base.lugar ?? '';
          _asuntoCtrl.text = base.asunto ?? '';
        }
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _booting = false);
      }
    }
  }

  void _hydrate(ServicioReporte reporte) {
    _tipoReporte = reporte.tipoReporte?.trim().isNotEmpty == true
        ? reporte.tipoReporte!
        : _tipoReporte;
    _fechaCtrl.text = _toDateInput(reporte.fecha, _rawDate(DateTime.now()));
    _horaCtrl.text = _toTimeInput(reporte.hora);
    _municipioCtrl.text = reporte.municipio ?? '';
    _lugarCtrl.text = reporte.lugar ?? '';
    _asuntoCtrl.text = reporte.asunto ?? '';
    _narrativaCtrl.text = reporte.narrativa ?? '';
    _estadoFuerzaCtrl.text = reporte.estadoFuerzaTexto ?? '';
    _accionesRealizarCtrl.text = reporte.accionesARealizar ?? '';
    _accionesRealizadasCtrl.text = reporte.accionesRealizadas ?? '';
    _resultadosCtrl.text = reporte.resultados ?? '';
    _personaAseguradaCtrl.text = reporte.datosPersonaAsegurada ?? '';
    _conclusionCtrl.text = reporte.conclusion ?? '';
    _latCtrl.text = reporte.lat ?? '';
    _lngCtrl.text = reporte.lng ?? '';
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_fechaCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fechaCtrl.text = _rawDate(picked));
    }
  }

  Future<void> _pickHora() async {
    final initial = _parseTime(_horaCtrl.text) ?? TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => _horaCtrl.text = _rawTime(picked));
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'tipo_reporte': _tipoReporte,
      'fecha': _fechaCtrl.text.trim(),
      'hora': _blankToNull(_horaCtrl.text),
      'municipio': _blankToNull(_municipioCtrl.text),
      'lugar': _blankToNull(_lugarCtrl.text),
      'asunto': _blankToNull(_asuntoCtrl.text),
      'narrativa': _blankToNull(_narrativaCtrl.text),
      'estado_fuerza_texto': _blankToNull(_estadoFuerzaCtrl.text),
      'acciones_a_realizar': _blankToNull(_accionesRealizarCtrl.text),
      'acciones_realizadas': _blankToNull(_accionesRealizadasCtrl.text),
      'resultados': _blankToNull(_resultadosCtrl.text),
      'datos_persona_asegurada': _blankToNull(_personaAseguradaCtrl.text),
      'conclusion': _blankToNull(_conclusionCtrl.text),
      'lat': _blankToNull(_latCtrl.text),
      'lng': _blankToNull(_lngCtrl.text),
    };

    setState(() => _saving = true);
    try {
      final result = widget.isEdit
          ? await _service.updateReporte(
              widget.servicioId,
              widget.reporteId!,
              payload,
            )
          : await _service.createReporte(widget.servicioId, payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Reporte actualizado correctamente'
                : 'Reporte registrado correctamente',
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MisServicioReporteDetailScreen(
            servicioId: widget.servicioId,
            reporteId: result.id,
            servicioNombre: _resolvedTitle,
          ),
        ),
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

  String get _resolvedTitle {
    final explicit = widget.servicioNombre?.trim() ?? '';
    if (explicit.isNotEmpty) return explicit;
    final base = widget.servicioBase;
    if (base == null) return 'Servicio';
    final folio = base.folioOperativo?.trim() ?? '';
    if (folio.isNotEmpty) return folio;
    return 'Servicio #${base.id}';
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
                          widget.isEdit
                              ? 'Editar reporte • $_resolvedTitle'
                              : 'Nuevo reporte • $_resolvedTitle',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                              if (_error != null) _ErrorBox(message: _error!),
                              Glass(
                                radius: 22,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Datos base',
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                              DropdownButtonFormField<String>(
                                                value: _tipoReporte,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText:
                                                          'Tipo de reporte',
                                                    ),
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: 'INICIO',
                                                    child: Text('Inicio'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'CONTINUIDAD',
                                                    child: Text('Continuidad'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'FINALIZACION',
                                                    child: Text('Finalizacion'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'INCIDENTE',
                                                    child: Text('Incidente'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'RESULTADO',
                                                    child: Text('Resultado'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'PUESTA_DISPOSICION',
                                                    child: Text(
                                                      'Puesta a disposicion',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'APOYO_BUSQUEDA',
                                                    child: Text(
                                                      'Apoyo de busqueda',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'EVENTO',
                                                    child: Text('Evento'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'OTRO',
                                                    child: Text('Otro'),
                                                  ),
                                                ],
                                                onChanged: (v) {
                                                  setState(() {
                                                    _tipoReporte =
                                                        v ?? 'INICIO';
                                                  });
                                                },
                                              ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _fechaCtrl,
                                            readOnly: true,
                                            onTap: _pickFecha,
                                            decoration: const InputDecoration(
                                              labelText: 'Fecha',
                                            ),
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                ? 'Captura la fecha'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _horaCtrl,
                                            readOnly: true,
                                            onTap: _pickHora,
                                            decoration: const InputDecoration(
                                              labelText: 'Hora',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _municipioCtrl,
                                            decoration: const InputDecoration(
                                              labelText: 'Municipio',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _lugarCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Lugar',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _asuntoCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Asunto',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Glass(
                                radius: 22,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Contenido del reporte',
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _AreaField(
                                      controller: _narrativaCtrl,
                                      label: 'Narrativa',
                                    ),
                                    const SizedBox(height: 12),
                                    _AreaField(
                                      controller: _estadoFuerzaCtrl,
                                      label: 'Estado de fuerza',
                                    ),
                                    const SizedBox(height: 12),
                                    _AreaField(
                                      controller: _accionesRealizarCtrl,
                                      label: 'Acciones a realizar',
                                    ),
                                    const SizedBox(height: 12),
                                    _AreaField(
                                      controller: _accionesRealizadasCtrl,
                                      label: 'Acciones realizadas',
                                    ),
                                    const SizedBox(height: 12),
                                    _AreaField(
                                      controller: _resultadosCtrl,
                                      label: 'Resultados',
                                    ),
                                    const SizedBox(height: 12),
                                    _AreaField(
                                      controller: _personaAseguradaCtrl,
                                      label: 'Datos de persona asegurada',
                                    ),
                                    const SizedBox(height: 12),
                                    _AreaField(
                                      controller: _conclusionCtrl,
                                      label: 'Conclusion',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Glass(
                                radius: 22,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ubicacion y fotos',
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _latCtrl,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            decoration: const InputDecoration(
                                              labelText: 'Latitud',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _lngCtrl,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            decoration: const InputDecoration(
                                              labelText: 'Longitud',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: AppColors.creamStrong.withValues(
                                          alpha: 0.52,
                                        ),
                                        border: Border.all(
                                          color: AppColors.creamStroke
                                              .withValues(alpha: 0.20),
                                        ),
                                      ),
                                      child: const Text(
                                        'La captura y carga de fotos se administra desde el detalle del reporte. Esta pantalla se enfoca en la narrativa y datos operativos.',
                                        style: TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _saving ? null : _submit,
                                      icon: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.whiteWarm,
                                              ),
                                            )
                                          : const Icon(Icons.save_rounded),
                                      label: Text(
                                        _saving
                                            ? (widget.isEdit
                                                  ? 'Actualizando...'
                                                  : 'Guardando...')
                                            : (widget.isEdit
                                                  ? 'Actualizar reporte'
                                                  : 'Guardar reporte'),
                                      ),
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

class _AreaField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _AreaField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redSoft.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.30)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.red,
          fontWeight: FontWeight.w700,
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

String? _blankToNull(String value) =>
    value.trim().isEmpty ? null : value.trim();

String _rawDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String _rawTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

TimeOfDay? _parseTime(String raw) {
  final clean = raw.trim();
  if (clean.isEmpty) return null;
  final parts = clean.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String _toDateInput(String? raw, String fallback) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final dt = DateTime.tryParse(raw.trim());
  return dt == null ? raw : _rawDate(dt);
}

String _toTimeInput(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final clean = raw.trim();
  return clean.length >= 5 ? clean.substring(0, 5) : clean;
}
