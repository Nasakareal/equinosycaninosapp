import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/option_item.dart';
import '../../models/servicio.dart';
import '../../services/servicios_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'servicio_detail_screen.dart';

class ServicioCreateScreen extends StatefulWidget {
  final int? servicioId;

  const ServicioCreateScreen({super.key, this.servicioId});

  bool get isEdit => servicioId != null;

  @override
  State<ServicioCreateScreen> createState() => _ServicioCreateScreenState();
}

class _ServicioCreateScreenState extends State<ServicioCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiciosService _service = ServiciosService();

  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _horaFinCtrl = TextEditingController();
  final _patrullaIdCtrl = TextEditingController();
  final _oficioCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController();
  final _crpCtrl = TextEditingController();
  final _objetivoCtrl = TextEditingController();
  final _folioCtrl = TextEditingController();
  final _tipoBusquedaCtrl = TextEditingController();
  final _asuntoCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  final _lugarCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _accionesCtrl = TextEditingController();
  final _resultadosCtrl = TextEditingController();
  final _conclusionCtrl = TextEditingController();
  final _comandanteCtrl = TextEditingController();
  final _cargoCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _booting = true;
  bool _saving = false;
  String? _error;
  ServicioFormCatalogs? _catalogs;

  String _categoria = 'GENERAL';
  String _tipoServicio = 'OPERATIVO';
  String _estatus = 'PROGRAMADO';
  int? _personalId;
  int? _caninoId;
  int? _equinoId;
  bool _cumplio = false;
  bool _seguridad = false;
  bool _barridoSeguridad = false;
  bool _desfiles = false;
  bool _proximidadSocial = false;
  bool _actosCivicos = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _horaFinCtrl.dispose();
    _patrullaIdCtrl.dispose();
    _oficioCtrl.dispose();
    _memoCtrl.dispose();
    _unidadCtrl.dispose();
    _crpCtrl.dispose();
    _objetivoCtrl.dispose();
    _folioCtrl.dispose();
    _tipoBusquedaCtrl.dispose();
    _asuntoCtrl.dispose();
    _municipioCtrl.dispose();
    _lugarCtrl.dispose();
    _descripcionCtrl.dispose();
    _accionesCtrl.dispose();
    _resultadosCtrl.dispose();
    _conclusionCtrl.dispose();
    _comandanteCtrl.dispose();
    _cargoCtrl.dispose();
    _observacionesCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    Servicio? servicio;
    try {
      final catalogs = await _service.catalogs();
      if (widget.isEdit) {
        servicio = await _service.show(widget.servicioId!);
      }
      if (!mounted) return;
      _catalogs = catalogs;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (servicio != null) {
        _hydrate(servicio);
      } else {
        _fechaCtrl.text = _fechaCtrl.text.trim().isEmpty
            ? _rawDate(DateTime.now())
            : _fechaCtrl.text;
        _horaCtrl.text = _horaCtrl.text.trim().isEmpty
            ? '08:00'
            : _horaCtrl.text;
        _horaFinCtrl.text = _horaFinCtrl.text.trim().isEmpty
            ? '10:00'
            : _horaFinCtrl.text;
      }
      if (mounted) {
        setState(() => _booting = false);
      }
    }
  }

  void _hydrate(Servicio x) {
    _categoria = x.categoriaRegistro.isEmpty ? _categoria : x.categoriaRegistro;
    _tipoServicio = x.tipoServicio.isEmpty ? _tipoServicio : x.tipoServicio;
    _estatus = x.estatusServicio.isEmpty ? _estatus : x.estatusServicio;
    _personalId = x.personalId;
    _caninoId = x.caninoId;
    _equinoId = x.equinoId;
    _cumplio = x.cumplio;
    _seguridad = x.seguridad;
    _barridoSeguridad = x.barridoSeguridad;
    _desfiles = x.desfiles;
    _proximidadSocial = x.proximidadSocial;
    _actosCivicos = x.actosCivicos;
    _fechaCtrl.text = _toDateInput(x.fecha);
    _horaCtrl.text = _toTimeInput(x.hora, '08:00');
    _horaFinCtrl.text = _toTimeInput(x.horaFin, '10:00');
    _patrullaIdCtrl.text = x.patrullaId?.toString() ?? '';
    _oficioCtrl.text = x.oficioReferencia ?? '';
    _memoCtrl.text = x.memorandumReferencia ?? '';
    _unidadCtrl.text = x.unidadClave ?? '';
    _crpCtrl.text = x.crp ?? '';
    _objetivoCtrl.text = x.objetivoServicio ?? '';
    _folioCtrl.text = x.folioOperativo ?? '';
    _tipoBusquedaCtrl.text = x.tipoBusqueda ?? '';
    _asuntoCtrl.text = x.asunto ?? '';
    _municipioCtrl.text = x.municipio ?? '';
    _lugarCtrl.text = x.lugar ?? '';
    _descripcionCtrl.text = x.descripcion ?? '';
    _accionesCtrl.text = x.accionesRealizadas ?? '';
    _resultadosCtrl.text = x.resultados ?? '';
    _conclusionCtrl.text = x.conclusionOperativa ?? '';
    _comandanteCtrl.text = x.comandanteResponsable ?? '';
    _cargoCtrl.text = x.cargoResponsable ?? '';
    _observacionesCtrl.text = x.observaciones ?? '';
    _latCtrl.text = x.lat ?? '';
    _lngCtrl.text = x.lng ?? '';
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

  Future<void> _pickTime(TextEditingController ctrl) async {
    final initial =
        _parseTime(ctrl.text) ?? const TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => ctrl.text = _rawTime(picked));
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'personal_id': _personalId,
      'canino_id': _caninoId,
      'equino_id': _equinoId,
      'patrulla_id': _toNullableInt(_patrullaIdCtrl.text),
      'categoria_registro': _categoria,
      'tipo_servicio': _tipoServicio,
      'estatus_servicio': _estatus,
      'oficio_referencia': _blankToNull(_oficioCtrl.text),
      'memorandum_referencia': _blankToNull(_memoCtrl.text),
      'unidad_clave': _blankToNull(_unidadCtrl.text),
      'crp': _blankToNull(_crpCtrl.text),
      'objetivo_servicio': _blankToNull(_objetivoCtrl.text),
      'folio_operativo': _blankToNull(_folioCtrl.text),
      'fecha': _fechaCtrl.text.trim(),
      'hora': _horaCtrl.text.trim(),
      'hora_fin': _horaFinCtrl.text.trim(),
      'cumplio': _cumplio,
      'seguridad': _seguridad,
      'barrido_seguridad': _barridoSeguridad,
      'desfiles': _desfiles,
      'proximidad_social': _proximidadSocial,
      'actos_civicos': _actosCivicos,
      'tipo_busqueda': _blankToNull(_tipoBusquedaCtrl.text),
      'asunto': _blankToNull(_asuntoCtrl.text),
      'municipio': _blankToNull(_municipioCtrl.text),
      'lugar': _blankToNull(_lugarCtrl.text),
      'descripcion': _blankToNull(_descripcionCtrl.text),
      'acciones_realizadas': _blankToNull(_accionesCtrl.text),
      'resultados': _blankToNull(_resultadosCtrl.text),
      'conclusion_operativa': _blankToNull(_conclusionCtrl.text),
      'comandante_responsable': _blankToNull(_comandanteCtrl.text),
      'cargo_responsable': _blankToNull(_cargoCtrl.text),
      'observaciones': _blankToNull(_observacionesCtrl.text),
      'lat': _blankToNull(_latCtrl.text),
      'lng': _blankToNull(_lngCtrl.text),
    };

    setState(() => _saving = true);
    try {
      final result = widget.isEdit
          ? await _service.update(widget.servicioId!, payload)
          : await _service.create(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Servicio actualizado correctamente'
                : 'Servicio registrado correctamente',
          ),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ServicioDetailScreen(servicioId: result.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
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
                              ? 'Editar Servicio'
                              : 'Registrar Servicio',
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
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
                              _BaseSection(
                                fechaCtrl: _fechaCtrl,
                                horaCtrl: _horaCtrl,
                                horaFinCtrl: _horaFinCtrl,
                                folioCtrl: _folioCtrl,
                                categoria: _categoria,
                                tipoServicio: _tipoServicio,
                                estatus: _estatus,
                                onPickFecha: _pickFecha,
                                onPickHora: () => _pickTime(_horaCtrl),
                                onPickHoraFin: () => _pickTime(_horaFinCtrl),
                                onCategoriaChanged: (v) =>
                                    setState(() => _categoria = v),
                                onTipoChanged: (v) =>
                                    setState(() => _tipoServicio = v),
                                onEstatusChanged: (v) =>
                                    setState(() => _estatus = v),
                              ),
                              const SizedBox(height: 12),
                              Glass(
                                radius: 22,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Asignaciones',
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _OptionSelect(
                                      value: _personalId,
                                      label: 'Personal responsable',
                                      items: _catalogs?.personals ?? const [],
                                      onChanged: (v) =>
                                          setState(() => _personalId = v),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _OptionSelect(
                                            value: _caninoId,
                                            label: 'Canino',
                                            items:
                                                _catalogs?.caninos ?? const [],
                                            onChanged: (v) =>
                                                setState(() => _caninoId = v),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _OptionSelect(
                                            value: _equinoId,
                                            label: 'Equino',
                                            items:
                                                _catalogs?.equinos ?? const [],
                                            onChanged: (v) =>
                                                setState(() => _equinoId = v),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _patrullaIdCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Patrulla ID (opcional)',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _ReferencesSection(
                                oficioCtrl: _oficioCtrl,
                                memoCtrl: _memoCtrl,
                                unidadCtrl: _unidadCtrl,
                                crpCtrl: _crpCtrl,
                                objetivoCtrl: _objetivoCtrl,
                                municipioCtrl: _municipioCtrl,
                                lugarCtrl: _lugarCtrl,
                                latCtrl: _latCtrl,
                                lngCtrl: _lngCtrl,
                              ),
                              const SizedBox(height: 12),
                              _OperationSection(
                                tipoBusquedaCtrl: _tipoBusquedaCtrl,
                                asuntoCtrl: _asuntoCtrl,
                                descripcionCtrl: _descripcionCtrl,
                                accionesCtrl: _accionesCtrl,
                                resultadosCtrl: _resultadosCtrl,
                                conclusionCtrl: _conclusionCtrl,
                              ),
                              const SizedBox(height: 12),
                              _FlagsSection(
                                comandanteCtrl: _comandanteCtrl,
                                cargoCtrl: _cargoCtrl,
                                observacionesCtrl: _observacionesCtrl,
                                cumplio: _cumplio,
                                seguridad: _seguridad,
                                barridoSeguridad: _barridoSeguridad,
                                desfiles: _desfiles,
                                proximidadSocial: _proximidadSocial,
                                actosCivicos: _actosCivicos,
                                onCumplioChanged: (v) =>
                                    setState(() => _cumplio = v),
                                onSeguridadChanged: (v) =>
                                    setState(() => _seguridad = v),
                                onBarridoChanged: (v) =>
                                    setState(() => _barridoSeguridad = v),
                                onDesfilesChanged: (v) =>
                                    setState(() => _desfiles = v),
                                onProximidadChanged: (v) =>
                                    setState(() => _proximidadSocial = v),
                                onActosChanged: (v) =>
                                    setState(() => _actosCivicos = v),
                                saving: _saving,
                                isEdit: widget.isEdit,
                                onSubmit: _submit,
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

class _BaseSection extends StatelessWidget {
  final TextEditingController fechaCtrl;
  final TextEditingController horaCtrl;
  final TextEditingController horaFinCtrl;
  final TextEditingController folioCtrl;
  final String categoria;
  final String tipoServicio;
  final String estatus;
  final VoidCallback onPickFecha;
  final VoidCallback onPickHora;
  final VoidCallback onPickHoraFin;
  final ValueChanged<String> onCategoriaChanged;
  final ValueChanged<String> onTipoChanged;
  final ValueChanged<String> onEstatusChanged;

  const _BaseSection({
    required this.fechaCtrl,
    required this.horaCtrl,
    required this.horaFinCtrl,
    required this.folioCtrl,
    required this.categoria,
    required this.tipoServicio,
    required this.estatus,
    required this.onPickFecha,
    required this.onPickHora,
    required this.onPickHoraFin,
    required this.onCategoriaChanged,
    required this.onTipoChanged,
    required this.onEstatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuracion base',
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
                child: DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: const [
                    DropdownMenuItem(value: 'GENERAL', child: Text('General')),
                    DropdownMenuItem(value: 'CANINO', child: Text('Canino')),
                    DropdownMenuItem(value: 'EQUINO', child: Text('Equino')),
                    DropdownMenuItem(value: 'MIXTO', child: Text('Mixto')),
                  ],
                  onChanged: (v) => onCategoriaChanged(v ?? 'GENERAL'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: tipoServicio,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de servicio',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'OPERATIVO',
                      child: Text('Operativo'),
                    ),
                    DropdownMenuItem(
                      value: 'SEGURIDAD',
                      child: Text('Seguridad'),
                    ),
                    DropdownMenuItem(
                      value: 'BUSQUEDA',
                      child: Text('Busqueda'),
                    ),
                    DropdownMenuItem(
                      value: 'PROXIMIDAD',
                      child: Text('Proximidad'),
                    ),
                    DropdownMenuItem(value: 'APOYO', child: Text('Apoyo')),
                  ],
                  onChanged: (v) => onTipoChanged(v ?? 'OPERATIVO'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: estatus,
                  decoration: const InputDecoration(labelText: 'Estatus'),
                  items: const [
                    DropdownMenuItem(
                      value: 'PROGRAMADO',
                      child: Text('Programado'),
                    ),
                    DropdownMenuItem(
                      value: 'EN_CURSO',
                      child: Text('En curso'),
                    ),
                    DropdownMenuItem(
                      value: 'CONCLUIDO',
                      child: Text('Concluido'),
                    ),
                    DropdownMenuItem(
                      value: 'CANCELADO',
                      child: Text('Cancelado'),
                    ),
                  ],
                  onChanged: (v) => onEstatusChanged(v ?? 'PROGRAMADO'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: folioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Folio operativo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: fechaCtrl,
                  readOnly: true,
                  onTap: onPickFecha,
                  decoration: const InputDecoration(labelText: 'Fecha'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Captura la fecha'
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: horaCtrl,
                  readOnly: true,
                  onTap: onPickHora,
                  decoration: const InputDecoration(labelText: 'Hora inicio'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: horaFinCtrl,
                  readOnly: true,
                  onTap: onPickHoraFin,
                  decoration: const InputDecoration(labelText: 'Hora fin'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferencesSection extends StatelessWidget {
  final TextEditingController oficioCtrl;
  final TextEditingController memoCtrl;
  final TextEditingController unidadCtrl;
  final TextEditingController crpCtrl;
  final TextEditingController objetivoCtrl;
  final TextEditingController municipioCtrl;
  final TextEditingController lugarCtrl;
  final TextEditingController latCtrl;
  final TextEditingController lngCtrl;

  const _ReferencesSection({
    required this.oficioCtrl,
    required this.memoCtrl,
    required this.unidadCtrl,
    required this.crpCtrl,
    required this.objetivoCtrl,
    required this.municipioCtrl,
    required this.lugarCtrl,
    required this.latCtrl,
    required this.lngCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Referencias y ubicacion',
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
                  controller: oficioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Oficio referencia',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: memoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Memorandum referencia',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: unidadCtrl,
                  decoration: const InputDecoration(labelText: 'Unidad clave'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: crpCtrl,
                  decoration: const InputDecoration(labelText: 'CRP'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: objetivoCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Objetivo del servicio',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: municipioCtrl,
                  decoration: const InputDecoration(labelText: 'Municipio'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: lugarCtrl,
                  decoration: const InputDecoration(labelText: 'Lugar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: latCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Latitud'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: lngCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Longitud'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OperationSection extends StatelessWidget {
  final TextEditingController tipoBusquedaCtrl;
  final TextEditingController asuntoCtrl;
  final TextEditingController descripcionCtrl;
  final TextEditingController accionesCtrl;
  final TextEditingController resultadosCtrl;
  final TextEditingController conclusionCtrl;

  const _OperationSection({
    required this.tipoBusquedaCtrl,
    required this.asuntoCtrl,
    required this.descripcionCtrl,
    required this.accionesCtrl,
    required this.resultadosCtrl,
    required this.conclusionCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operacion',
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
                  controller: tipoBusquedaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de busqueda',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: asuntoCtrl,
                  decoration: const InputDecoration(labelText: 'Asunto'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descripcionCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descripcion'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: accionesCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Acciones realizadas'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: resultadosCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Resultados'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: conclusionCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Conclusion operativa',
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagsSection extends StatelessWidget {
  final TextEditingController comandanteCtrl;
  final TextEditingController cargoCtrl;
  final TextEditingController observacionesCtrl;
  final bool cumplio;
  final bool seguridad;
  final bool barridoSeguridad;
  final bool desfiles;
  final bool proximidadSocial;
  final bool actosCivicos;
  final ValueChanged<bool> onCumplioChanged;
  final ValueChanged<bool> onSeguridadChanged;
  final ValueChanged<bool> onBarridoChanged;
  final ValueChanged<bool> onDesfilesChanged;
  final ValueChanged<bool> onProximidadChanged;
  final ValueChanged<bool> onActosChanged;
  final bool saving;
  final bool isEdit;
  final VoidCallback onSubmit;

  const _FlagsSection({
    required this.comandanteCtrl,
    required this.cargoCtrl,
    required this.observacionesCtrl,
    required this.cumplio,
    required this.seguridad,
    required this.barridoSeguridad,
    required this.desfiles,
    required this.proximidadSocial,
    required this.actosCivicos,
    required this.onCumplioChanged,
    required this.onSeguridadChanged,
    required this.onBarridoChanged,
    required this.onDesfilesChanged,
    required this.onProximidadChanged,
    required this.onActosChanged,
    required this.saving,
    required this.isEdit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Responsables y banderas',
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
                  controller: comandanteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Comandante responsable',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: cargoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cargo responsable',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: observacionesCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Observaciones'),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BoolChip(
                label: 'Cumplio',
                value: cumplio,
                onChanged: onCumplioChanged,
              ),
              _BoolChip(
                label: 'Seguridad',
                value: seguridad,
                onChanged: onSeguridadChanged,
              ),
              _BoolChip(
                label: 'Barrido',
                value: barridoSeguridad,
                onChanged: onBarridoChanged,
              ),
              _BoolChip(
                label: 'Desfiles',
                value: desfiles,
                onChanged: onDesfilesChanged,
              ),
              _BoolChip(
                label: 'Proximidad',
                value: proximidadSocial,
                onChanged: onProximidadChanged,
              ),
              _BoolChip(
                label: 'Actos civicos',
                value: actosCivicos,
                onChanged: onActosChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: saving ? null : onSubmit,
            icon: saving
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
              saving
                  ? (isEdit ? 'Actualizando...' : 'Guardando...')
                  : (isEdit ? 'Actualizar servicio' : 'Guardar servicio'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionSelect extends StatelessWidget {
  final int? value;
  final String label;
  final List<OptionItem> items;
  final ValueChanged<int?> onChanged;

  const _OptionSelect({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      value: items.any((x) => x.id == value) ? value : null,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('Sin asignar')),
        ...items.map(
          (item) => DropdownMenuItem<int?>(
            value: item.id,
            child: Text(
              item.subtitle == null || item.subtitle!.trim().isEmpty
                  ? item.label
                  : '${item.label} • ${item.subtitle}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _BoolChip extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _BoolChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = value ? AppColors.greenDeep : AppColors.brownDeep;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
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

String _rawDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

String _rawTime(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

TimeOfDay? _parseTime(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;
  final parts = s.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return TimeOfDay(hour: h, minute: m);
}

int? _toNullableInt(String v) {
  final x = int.tryParse(v.trim());
  return x == null || x <= 0 ? null : x;
}

String? _blankToNull(String v) => v.trim().isEmpty ? null : v.trim();

String _toDateInput(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw.trim());
  return dt == null ? raw : _rawDate(dt);
}

String _toTimeInput(String? raw, String fallback) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final clean = raw.trim();
  return clean.length >= 5 ? clean.substring(0, 5) : clean;
}
