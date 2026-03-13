
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/animal.dart';
import '../../models/animal_assignment.dart';
import '../../models/animal_incidence.dart';
import '../../models/animal_medical_record.dart';
import '../../models/option_item.dart';
import '../../services/animal_assignments_service.dart';
import '../../services/animal_incidences_service.dart';
import '../../services/animal_medical_records_service.dart';
import '../../services/animals_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';

class AnimalDetailScreen extends StatefulWidget {
  final int animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final AnimalsService _animalsService = AnimalsService();
  final AnimalMedicalRecordsService _medicalService = AnimalMedicalRecordsService();
  final AnimalIncidencesService _incidencesService = AnimalIncidencesService();
  final AnimalAssignmentsService _assignmentsService = AnimalAssignmentsService();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  Animal? _animal;

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
      final animal = await _animalsService.show(widget.animalId);
      if (!mounted) return;
      setState(() => _animal = animal);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _runMutation(Future<void> Function() action, String message) async {
    setState(() => _saving = true);
    try {
      await action();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<bool> _confirmDelete(String title, String text) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(text),
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
    return result ?? false;
  }

  Future<void> _createMedical() async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _MedicalDialog(),
    );
    if (payload == null || _animal == null) return;
    await _runMutation(
      () => _medicalService.create(_animal!.id, payload),
      'Registro medico agregado',
    );
  }

  Future<void> _editMedical(AnimalMedicalRecord record) async {
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _MedicalDialog(record: record),
    );
    if (payload == null || _animal == null) return;
    await _runMutation(
      () => _medicalService.update(_animal!.id, record.id, payload),
      'Registro medico actualizado',
    );
  }

  Future<void> _deleteMedical(AnimalMedicalRecord record) async {
    if (_animal == null) return;
    final ok = await _confirmDelete('Eliminar registro medico?', record.tipo);
    if (!ok) return;
    await _runMutation(
      () => _medicalService.delete(_animal!.id, record.id),
      'Registro medico eliminado',
    );
  }

  Future<void> _createIncidence() async {
    if (_animal == null) return;
    final catalogs = await _incidencesService.catalogs(_animal!.id);
    if (!mounted) return;
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _IncidenceDialog(types: catalogs.incidenceTypes),
    );
    if (payload == null) return;
    await _runMutation(
      () => _incidencesService.create(_animal!.id, payload),
      'Incidencia registrada',
    );
  }

  Future<void> _editIncidence(AnimalIncidence incidence) async {
    if (_animal == null) return;
    final catalogs = await _incidencesService.catalogs(_animal!.id);
    if (!mounted) return;
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _IncidenceDialog(incidence: incidence, types: catalogs.incidenceTypes),
    );
    if (payload == null) return;
    await _runMutation(
      () => _incidencesService.update(_animal!.id, incidence.id, payload),
      'Incidencia actualizada',
    );
  }

  Future<void> _deleteIncidence(AnimalIncidence incidence) async {
    if (_animal == null) return;
    final ok = await _confirmDelete('Eliminar incidencia?', incidence.descripcion ?? incidence.gravedad);
    if (!ok) return;
    await _runMutation(
      () => _incidencesService.delete(_animal!.id, incidence.id),
      'Incidencia eliminada',
    );
  }

  Future<void> _createAssignment() async {
    if (_animal == null) return;
    final catalogs = await _assignmentsService.catalogs(_animal!.id);
    if (!mounted) return;
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AssignmentDialog(
        personals: catalogs.personals,
        patrols: catalogs.patrols,
        turnos: catalogs.turnos,
      ),
    );
    if (payload == null) return;
    await _runMutation(
      () => _assignmentsService.create(_animal!.id, payload),
      'Asignacion registrada',
    );
  }

  Future<void> _editAssignment(AnimalAssignment assignment) async {
    if (_animal == null) return;
    final catalogs = await _assignmentsService.catalogs(_animal!.id);
    if (!mounted) return;
    final payload = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _AssignmentDialog(
        assignment: assignment,
        personals: catalogs.personals,
        patrols: catalogs.patrols,
        turnos: catalogs.turnos,
      ),
    );
    if (payload == null) return;
    await _runMutation(
      () => _assignmentsService.update(_animal!.id, assignment.id, payload),
      'Asignacion actualizada',
    );
  }

  Future<void> _deleteAssignment(AnimalAssignment assignment) async {
    if (_animal == null) return;
    final ok = await _confirmDelete('Eliminar asignacion?', assignment.personal?.label ?? 'Asignacion');
    if (!ok) return;
    await _runMutation(
      () => _assignmentsService.delete(_animal!.id, assignment.id),
      'Asignacion eliminada',
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
                        _SoftIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _animal == null ? 'Expediente del Animal' : 'Expediente: ${_animal!.nombre}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (_saving)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        _SoftIconButton(icon: Icons.refresh_rounded, onTap: _load),
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
                        Tab(text: 'Datos'),
                        Tab(text: 'Historial medico'),
                        Tab(text: 'Incidencias'),
                        Tab(text: 'Asignaciones'),
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
                          : _animal == null
                          ? const Center(
                              child: Text(
                                'Sin informacion',
                                style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
                              ),
                            )
                          : TabBarView(
                              children: [
                                _DatosTab(a: _animal!),
                                _MedicalTab(
                                  records: _animal!.medicalRecords,
                                  onCreate: _createMedical,
                                  onEdit: _editMedical,
                                  onDelete: _deleteMedical,
                                ),
                                _IncidencesTab(
                                  incidences: _animal!.incidences,
                                  onCreate: _createIncidence,
                                  onEdit: _editIncidence,
                                  onDelete: _deleteIncidence,
                                ),
                                _AssignmentsTab(
                                  assignments: _animal!.assignments,
                                  onCreate: _createAssignment,
                                  onEdit: _editAssignment,
                                  onDelete: _deleteAssignment,
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

class _SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SoftIconButton({required this.icon, required this.onTap});

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

class _DatosTab extends StatelessWidget {
  final Animal a;

  const _DatosTab({required this.a});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if ((a.fotoUrl ?? '').trim().isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: _panelDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                a.fotoUrl!,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 120,
                  child: Center(child: Text('No se pudo cargar la foto')),
                ),
              ),
            ),
          ),
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Nombre', value: a.nombre, icon: Icons.pets_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(title: 'Raza', value: a.raza ?? '-', icon: Icons.science_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatCard(title: 'Estatus', value: a.estatus, icon: Icons.health_and_safety_rounded)),
          ],
        ),
        const SizedBox(height: 14),
        ...[
          _InfoTile(title: 'Tipo', value: a.tipo),
          _InfoTile(title: 'Procedencia', value: a.procedencia ?? '-'),
          _InfoTile(title: 'Sexo', value: a.sexo ?? '-'),
          _InfoTile(title: 'Color', value: a.color ?? '-'),
          _InfoTile(title: 'Especialidad', value: a.especialidad ?? '-'),
          _InfoTile(title: 'Marcaje', value: a.marcaje ?? '-'),
          _InfoTile(title: 'Chip', value: a.chip ?? '-'),
          _InfoTile(title: 'Fecha nacimiento', value: _fmtDate(a.fechaNacimiento)),
          _InfoTile(title: 'Edad', value: a.edadTexto ?? '-'),
          _InfoTile(title: 'Forraje (kg/dia)', value: a.forrajeKgDiario?.toString() ?? '-'),
          _InfoTile(title: 'Grano (kg/dia)', value: a.granoKgDiario?.toString() ?? '-'),
          _InfoTile(title: 'Observaciones', value: a.observaciones ?? '-'),
          _InfoTile(title: 'Caracteristicas', value: a.caracteristicas ?? '-'),
        ],
      ],
    );
  }
}

class _MedicalTab extends StatelessWidget {
  final List<AnimalMedicalRecord> records;
  final VoidCallback onCreate;
  final ValueChanged<AnimalMedicalRecord> onEdit;
  final ValueChanged<AnimalMedicalRecord> onDelete;

  const _MedicalTab({
    required this.records,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Historial medico', actionLabel: 'Agregar', onTap: onCreate),
        const SizedBox(height: 12),
        Expanded(
          child: records.isEmpty
              ? const _EmptyState(text: 'Sin registros medicos')
              : ListView.separated(
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = records[i];
                    return _EntryCard(
                      title: r.tipo,
                      subtitle: 'Fecha: ${_fmtDate(r.fecha)}',
                      lines: [
                        'Veterinario: ${r.veterinario ?? '-'}',
                        'Costo: ${r.costo?.toString() ?? '-'}',
                        'Proxima cita: ${_fmtDate(r.proximaCita)}',
                        'Descripcion: ${r.descripcion ?? '-'}',
                        'Archivos: ${r.files.isEmpty ? 'Sin archivos' : r.files.map((f) => f.tipo ?? 'Archivo').join(', ')}',
                      ],
                      onEdit: () => onEdit(r),
                      onDelete: () => onDelete(r),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _IncidencesTab extends StatelessWidget {
  final List<AnimalIncidence> incidences;
  final VoidCallback onCreate;
  final ValueChanged<AnimalIncidence> onEdit;
  final ValueChanged<AnimalIncidence> onDelete;

  const _IncidencesTab({
    required this.incidences,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Incidencias', actionLabel: 'Registrar', onTap: onCreate),
        const SizedBox(height: 12),
        Expanded(
          child: incidences.isEmpty
              ? const _EmptyState(text: 'Sin incidencias registradas')
              : ListView.separated(
                  itemCount: incidences.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final x = incidences[i];
                    return _EntryCard(
                      title: x.incidenceType?.label ?? 'Sin tipo',
                      subtitle: 'Fecha: ${_fmtDateTime(x.fecha)}',
                      badgeText: x.gravedad,
                      badgeColor: _severityColor(x.gravedad),
                      lines: [
                        'Descripcion: ${x.descripcion ?? '-'}',
                        'Resuelto: ${x.resuelto ? 'Si' : 'No'}',
                        'Resuelto en: ${_fmtDate(x.resueltoEn)}',
                        'Atendido por: ${x.atendidoPor ?? '-'}',
                        'Archivos: ${x.files.length}',
                      ],
                      onEdit: () => onEdit(x),
                      onDelete: () => onDelete(x),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AssignmentsTab extends StatelessWidget {
  final List<AnimalAssignment> assignments;
  final VoidCallback onCreate;
  final ValueChanged<AnimalAssignment> onEdit;
  final ValueChanged<AnimalAssignment> onDelete;

  const _AssignmentsTab({
    required this.assignments,
    required this.onCreate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(title: 'Asignaciones', actionLabel: 'Nueva', onTap: onCreate),
        const SizedBox(height: 12),
        Expanded(
          child: assignments.isEmpty
              ? const _EmptyState(text: 'Sin asignaciones')
              : ListView.separated(
                  itemCount: assignments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final x = assignments[i];
                    return _EntryCard(
                      title: x.personal?.label ?? 'Sin personal',
                      subtitle: 'Inicio: ${_fmtDateTime(x.inicio)}',
                      lines: [
                        'Fin: ${_fmtDateTime(x.fin)}',
                        'Patrulla: ${x.patrol?.label ?? '-'}',
                        'Turno: ${x.turno?.label ?? '-'}',
                        'Observaciones: ${x.observaciones ?? '-'}',
                      ],
                      onEdit: () => onEdit(x),
                      onDelete: () => onDelete(x),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({required this.title, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_rounded),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> lines;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? badgeText;
  final Color? badgeColor;

  const _EntryCard({
    required this.title,
    required this.subtitle,
    required this.lines,
    required this.onEdit,
    required this.onDelete,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 14.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, fontSize: 12.6),
                    ),
                  ],
                ),
              ),
              if (badgeText != null && badgeColor != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: badgeColor!.withValues(alpha: 0.12),
                    border: Border.all(color: badgeColor!.withValues(alpha: 0.30)),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(color: badgeColor, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _ActionButton(icon: Icons.edit_rounded, onTap: onEdit),
              const SizedBox(width: 8),
              _ActionButton(icon: Icons.delete_outline_rounded, onTap: onDelete, danger: true),
            ],
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _ActionButton({required this.icon, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: danger ? AppColors.red.withValues(alpha: 0.28) : AppColors.creamStroke.withValues(alpha: 0.24),
          ),
          color: danger ? AppColors.redSoft.withValues(alpha: 0.72) : AppColors.whiteWarm.withValues(alpha: 0.64),
        ),
        child: Icon(icon, color: danger ? AppColors.red : AppColors.brownDeep, size: 18),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brownDeep),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _panelDecoration(),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(title, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalDialog extends StatefulWidget {
  final AnimalMedicalRecord? record;

  const _MedicalDialog({this.record});

  @override
  State<_MedicalDialog> createState() => _MedicalDialogState();
}

class _MedicalDialogState extends State<_MedicalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _tipoCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _veterinarioCtrl;
  late final TextEditingController _costoCtrl;
  late final TextEditingController _proximaCtrl;

  @override
  void initState() {
    super.initState();
    _fechaCtrl = TextEditingController(text: _toDateInput(widget.record?.fecha));
    _tipoCtrl = TextEditingController(text: widget.record?.tipo ?? '');
    _descripcionCtrl = TextEditingController(text: widget.record?.descripcion ?? '');
    _veterinarioCtrl = TextEditingController(text: widget.record?.veterinario ?? '');
    _costoCtrl = TextEditingController(text: widget.record?.costo?.toString() ?? '');
    _proximaCtrl = TextEditingController(text: _toDateInput(widget.record?.proximaCita));
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _tipoCtrl.dispose();
    _descripcionCtrl.dispose();
    _veterinarioCtrl.dispose();
    _costoCtrl.dispose();
    _proximaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _rawDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.record == null ? 'Agregar registro medico' : 'Editar registro medico'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fechaCtrl,
                  readOnly: true,
                  onTap: () => _pickDate(_fechaCtrl),
                  decoration: const InputDecoration(labelText: 'Fecha'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Captura la fecha' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tipoCtrl,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Captura el tipo' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _veterinarioCtrl, decoration: const InputDecoration(labelText: 'Veterinario')),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _costoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Costo'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _proximaCtrl,
                  readOnly: true,
                  onTap: () => _pickDate(_proximaCtrl),
                  decoration: const InputDecoration(labelText: 'Proxima cita'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcionCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'fecha': _fechaCtrl.text.trim(),
              'tipo': _tipoCtrl.text.trim(),
              'descripcion': _blankToNull(_descripcionCtrl.text),
              'veterinario': _blankToNull(_veterinarioCtrl.text),
              'costo': _toDouble(_costoCtrl.text),
              'proxima_cita': _blankToNull(_proximaCtrl.text),
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _IncidenceDialog extends StatefulWidget {
  final AnimalIncidence? incidence;
  final List<OptionItem> types;

  const _IncidenceDialog({this.incidence, required this.types});

  @override
  State<_IncidenceDialog> createState() => _IncidenceDialogState();
}

class _IncidenceDialogState extends State<_IncidenceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _resueltoEnCtrl;
  int? _typeId;
  String _gravedad = 'MEDIA';
  bool _resuelto = false;

  @override
  void initState() {
    super.initState();
    _fechaCtrl = TextEditingController(text: _toDateInput(widget.incidence?.fecha));
    _descripcionCtrl = TextEditingController(text: widget.incidence?.descripcion ?? '');
    _resueltoEnCtrl = TextEditingController(text: _toDateInput(widget.incidence?.resueltoEn));
    _typeId = widget.incidence?.incidenceTypeId;
    _gravedad = widget.incidence?.gravedad ?? 'MEDIA';
    _resuelto = widget.incidence?.resuelto ?? false;
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _descripcionCtrl.dispose();
    _resueltoEnCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = _rawDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.incidence == null ? 'Registrar incidencia' : 'Editar incidencia'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fechaCtrl,
                  readOnly: true,
                  onTap: () => _pickDate(_fechaCtrl),
                  decoration: const InputDecoration(labelText: 'Fecha'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Captura la fecha' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _typeId,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Sin tipo')),
                    ...widget.types.map((type) => DropdownMenuItem<int?>(value: type.id, child: Text(type.label))),
                  ],
                  onChanged: (v) => setState(() => _typeId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gravedad,
                  decoration: const InputDecoration(labelText: 'Gravedad'),
                  items: const [
                    DropdownMenuItem(value: 'BAJA', child: Text('Baja')),
                    DropdownMenuItem(value: 'MEDIA', child: Text('Media')),
                    DropdownMenuItem(value: 'ALTA', child: Text('Alta')),
                  ],
                  onChanged: (v) => setState(() => _gravedad = v ?? 'MEDIA'),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  value: _resuelto,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Resuelto'),
                  onChanged: (v) => setState(() => _resuelto = v),
                ),
                if (_resuelto) ...[
                  TextFormField(
                    controller: _resueltoEnCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(_resueltoEnCtrl),
                    decoration: const InputDecoration(labelText: 'Resuelto en'),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _descripcionCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'fecha': _fechaCtrl.text.trim(),
              'incidence_type_id': _typeId,
              'gravedad': _gravedad,
              'descripcion': _blankToNull(_descripcionCtrl.text),
              'resuelto': _resuelto,
              'resuelto_en': _resuelto ? _blankToNull(_resueltoEnCtrl.text) : null,
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _AssignmentDialog extends StatefulWidget {
  final AnimalAssignment? assignment;
  final List<OptionItem> personals;
  final List<OptionItem> patrols;
  final List<OptionItem> turnos;

  const _AssignmentDialog({
    this.assignment,
    required this.personals,
    required this.patrols,
    required this.turnos,
  });

  @override
  State<_AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<_AssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _inicioCtrl;
  late final TextEditingController _finCtrl;
  late final TextEditingController _obsCtrl;
  int? _personalId;
  int? _patrolId;
  int? _turnoId;

  @override
  void initState() {
    super.initState();
    _inicioCtrl = TextEditingController(text: _toDateTimeInput(widget.assignment?.inicio));
    _finCtrl = TextEditingController(text: _toDateTimeInput(widget.assignment?.fin));
    _obsCtrl = TextEditingController(text: widget.assignment?.observaciones ?? '');
    _personalId = widget.assignment?.personalId;
    _patrolId = widget.assignment?.patrolId;
    _turnoId = widget.assignment?.turnoId;
  }

  @override
  void dispose() {
    _inicioCtrl.dispose();
    _finCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    controller.text = _rawDateTime(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.assignment == null ? 'Nueva asignacion' : 'Editar asignacion'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int?>(
                  value: _personalId,
                  decoration: const InputDecoration(labelText: 'Personal'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Sin personal')),
                    ...widget.personals.map((item) => DropdownMenuItem<int?>(value: item.id, child: Text(item.label))),
                  ],
                  onChanged: (v) => setState(() => _personalId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _patrolId,
                  decoration: const InputDecoration(labelText: 'Patrulla'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Sin patrulla')),
                    ...widget.patrols.map((item) => DropdownMenuItem<int?>(value: item.id, child: Text(item.label))),
                  ],
                  onChanged: (v) => setState(() => _patrolId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _turnoId,
                  decoration: const InputDecoration(labelText: 'Turno'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Sin turno')),
                    ...widget.turnos.map((item) => DropdownMenuItem<int?>(value: item.id, child: Text(item.label))),
                  ],
                  onChanged: (v) => setState(() => _turnoId = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _inicioCtrl,
                  readOnly: true,
                  onTap: () => _pickDateTime(_inicioCtrl),
                  decoration: const InputDecoration(labelText: 'Inicio'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Captura el inicio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _finCtrl,
                  readOnly: true,
                  onTap: () => _pickDateTime(_finCtrl),
                  decoration: const InputDecoration(labelText: 'Fin'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _obsCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'personal_id': _personalId,
              'patrol_id': _patrolId,
              'turno_id': _turnoId,
              'inicio': _inicioCtrl.text.trim(),
              'fin': _blankToNull(_finCtrl.text),
              'observaciones': _blankToNull(_obsCtrl.text),
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

BoxDecoration _panelDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.22)),
    color: AppColors.whiteWarm.withValues(alpha: 0.60),
  );
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

String _toDateInput(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw.trim());
  return dt == null ? raw : _rawDate(dt);
}

String _toDateTimeInput(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final dt = DateTime.tryParse(raw.trim());
  return dt == null ? raw : _rawDateTime(dt);
}

String _rawDate(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

String _rawDateTime(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '${date.year}-$m-$d $h:$min:00';
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double? _toDouble(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed.replaceAll(',', '.'));
}

Color _severityColor(String gravedad) {
  switch (gravedad) {
    case 'ALTA':
      return AppColors.red;
    case 'MEDIA':
      return AppColors.brownDeep;
    default:
      return AppColors.greenDeep;
  }
}
