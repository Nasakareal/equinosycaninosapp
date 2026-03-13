import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/option_item.dart';
import '../../models/personal_summary.dart';
import '../../services/personals_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';
import 'personal_detail_screen.dart';

class PersonalsIndexScreen extends StatefulWidget {
  const PersonalsIndexScreen({super.key});

  @override
  State<PersonalsIndexScreen> createState() => _PersonalsIndexScreenState();
}

class _PersonalsIndexScreenState extends State<PersonalsIndexScreen> {
  final PersonalsService _service = PersonalsService();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _dependenciaCtrl = TextEditingController();

  bool? _activo = true;
  int? _turnoId;
  List<OptionItem> _turnos = const [];
  List<PersonalSummary> _items = const [];
  bool _loading = true;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _boot();
    _searchCtrl.addListener(_onFiltersChanged);
    _dependenciaCtrl.addListener(_onFiltersChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _dependenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    try {
      final catalogs = await _service.catalogs();
      if (!mounted) return;
      setState(() => _turnos = catalogs.turnos);
    } catch (_) {}
    await _load();
  }

  void _onFiltersChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await _service.index(
        search: _searchCtrl.text,
        dependencia: _dependenciaCtrl.text,
        activo: _activo,
        turnoId: _turnoId,
      );
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _openDetail(PersonalSummary item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PersonalDetailScreen(personalId: item.id)),
    );
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
                      const Expanded(
                        child: Text(
                          'Listado de Personal',
                          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      _IconButton(icon: Icons.refresh_rounded, onTap: _load),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Buscar por nombre, CUIP o cargo',
                          suffixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _dependenciaCtrl,
                        decoration: const InputDecoration(labelText: 'Dependencia'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<bool?>(
                              value: _activo,
                              decoration: const InputDecoration(labelText: 'Estatus'),
                              items: const [
                                DropdownMenuItem<bool?>(value: true, child: Text('Activos')),
                                DropdownMenuItem<bool?>(value: false, child: Text('Inactivos')),
                                DropdownMenuItem<bool?>(value: null, child: Text('Todos')),
                              ],
                              onChanged: (v) {
                                setState(() => _activo = v);
                                _load();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              value: _turnoId,
                              decoration: const InputDecoration(labelText: 'Turno'),
                              items: [
                                const DropdownMenuItem<int?>(value: null, child: Text('Todos')),
                                ..._turnos.map((t) => DropdownMenuItem<int?>(value: t.id, child: Text(t.label))),
                              ],
                              onChanged: (v) {
                                setState(() => _turnoId = v);
                                _load();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(12),
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
                        : _items.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin registros de personal',
                              style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final p = _items[i];
                              return _PersonalCard(item: p, onTap: () => _openDetail(p));
                            },
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

class _PersonalCard extends StatelessWidget {
  final PersonalSummary item;
  final VoidCallback onTap;

  const _PersonalCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nombres, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 14.5)),
                      const SizedBox(height: 4),
                      Text(
                        '${item.grado ?? '-'} • ${item.cargo ?? '-'}',
                        style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: (item.activo ? AppColors.greenDeep : AppColors.red).withValues(alpha: 0.12),
                    border: Border.all(
                      color: (item.activo ? AppColors.greenDeep : AppColors.red).withValues(alpha: 0.30),
                    ),
                  ),
                  child: Text(
                    item.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: item.activo ? AppColors.greenDeep : AppColors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Dependencia: ${item.dependencia ?? '-'}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
            Text('CRP: ${item.crp ?? '-'}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
            Text('Turno: ${item.turno?.nombre ?? '-'}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
