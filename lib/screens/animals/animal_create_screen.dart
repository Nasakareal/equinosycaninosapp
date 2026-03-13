import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/animals_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'animal_detail_screen.dart';

class AnimalCreateScreen extends StatefulWidget {
  const AnimalCreateScreen({super.key});

  @override
  State<AnimalCreateScreen> createState() => _AnimalCreateScreenState();
}

class _AnimalCreateScreenState extends State<AnimalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AnimalsService();

  final _nombreCtrl = TextEditingController();
  final _razaCtrl = TextEditingController();
  final _procedenciaCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _caracteristicasCtrl = TextEditingController();
  final _marcajeCtrl = TextEditingController();
  final _chipCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  final _edadTextoCtrl = TextEditingController();
  final _forrajeCtrl = TextEditingController();
  final _granoCtrl = TextEditingController();
  final _fechaNacimientoCtrl = TextEditingController();

  String _tipo = 'EQUINO';
  String _estatus = 'ACTIVO';
  String? _sexo;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _razaCtrl.dispose();
    _procedenciaCtrl.dispose();
    _colorCtrl.dispose();
    _caracteristicasCtrl.dispose();
    _marcajeCtrl.dispose();
    _chipCtrl.dispose();
    _especialidadCtrl.dispose();
    _observacionesCtrl.dispose();
    _edadTextoCtrl.dispose();
    _forrajeCtrl.dispose();
    _granoCtrl.dispose();
    _fechaNacimientoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFechaNacimiento() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 3, now.month, now.day),
      firstDate: DateTime(1990),
      lastDate: now,
    );

    if (picked != null) {
      _fechaNacimientoCtrl.text = _fmtDate(picked);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (!_formKey.currentState!.validate()) return;

    final payload = <String, dynamic>{
      'tipo': _tipo,
      'nombre': _nombreCtrl.text.trim(),
      'raza': _nullIfEmpty(_razaCtrl.text),
      'procedencia': _nullIfEmpty(_procedenciaCtrl.text),
      'sexo': _sexo,
      'color': _nullIfEmpty(_colorCtrl.text),
      'caracteristicas': _nullIfEmpty(_caracteristicasCtrl.text),
      'marcaje': _nullIfEmpty(_marcajeCtrl.text),
      'chip': _nullIfEmpty(_chipCtrl.text),
      'especialidad': _nullIfEmpty(_especialidadCtrl.text),
      'estatus': _estatus,
      'observaciones': _nullIfEmpty(_observacionesCtrl.text),
      'fecha_nacimiento': _nullIfEmpty(_fechaNacimientoCtrl.text),
      'edad_texto': _nullIfEmpty(_edadTextoCtrl.text),
      'forraje_kg_diario': _toDouble(_forrajeCtrl.text),
      'grano_kg_diario': _toDouble(_granoCtrl.text),
    };

    setState(() => _saving = true);
    try {
      final animal = await _service.create(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal registrado correctamente')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnimalDetailScreen(animalId: animal.id),
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

  String? _nullIfEmpty(String v) {
    final s = v.trim();
    return s.isEmpty ? null : s;
  }

  double? _toDouble(String v) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s.replaceAll(',', '.'));
  }

  String _fmtDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
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
                      InkWell(
                        onTap: () => Navigator.pop(context),
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
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.brownDeep,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Agregar animal',
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          const Text(
                            'Registro base del animal',
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Capturamos primero los campos del formulario web para que ya puedas dar de alta desde la app.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.redSoft.withValues(alpha: 0.78),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.red.withValues(alpha: 0.30),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppColors.red,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _tipo,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'EQUINO',
                                      child: Text('Equino'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'CANINO',
                                      child: Text('Canino'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(() => _tipo = v ?? 'EQUINO'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _estatus,
                                  decoration: const InputDecoration(
                                    labelText: 'Estatus',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'ACTIVO',
                                      child: Text('Activo'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'BAJA',
                                      child: Text('Baja'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'RESGUARDO',
                                      child: Text('Resguardo'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(() => _estatus = v ?? 'ACTIVO'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nombreCtrl,
                            decoration: const InputDecoration(labelText: 'Nombre'),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Captura el nombre'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _razaCtrl,
                            decoration: const InputDecoration(labelText: 'Raza'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _procedenciaCtrl,
                            decoration: const InputDecoration(labelText: 'Procedencia'),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String?>(
                            value: _sexo,
                            decoration: const InputDecoration(labelText: 'Sexo'),
                            items: const [
                              DropdownMenuItem<String?>(value: null, child: Text('Sin definir')),
                              DropdownMenuItem(value: 'MACHO', child: Text('Macho')),
                              DropdownMenuItem(value: 'HEMBRA', child: Text('Hembra')),
                            ],
                            onChanged: (v) => setState(() => _sexo = v),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _colorCtrl,
                            decoration: const InputDecoration(labelText: 'Color'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _especialidadCtrl,
                            decoration: const InputDecoration(labelText: 'Especialidad'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _marcajeCtrl,
                            decoration: const InputDecoration(labelText: 'Marcaje'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _chipCtrl,
                            decoration: const InputDecoration(labelText: 'Chip'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _fechaNacimientoCtrl,
                            readOnly: true,
                            onTap: _pickFechaNacimiento,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de nacimiento',
                              suffixIcon: Icon(Icons.calendar_today_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _edadTextoCtrl,
                            decoration: const InputDecoration(labelText: 'Edad texto'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _forrajeCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'Forraje kg/dia'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _granoCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'Grano kg/dia'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _caracteristicasCtrl,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(labelText: 'Caracteristicas'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _observacionesCtrl,
                            minLines: 2,
                            maxLines: 4,
                            decoration: const InputDecoration(labelText: 'Observaciones'),
                          ),
                          const SizedBox(height: 20),
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
                            label: Text(_saving ? 'Guardando...' : 'Guardar animal'),
                          ),
                        ],
                      ),
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
