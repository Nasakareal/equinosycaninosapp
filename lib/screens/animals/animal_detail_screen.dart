import 'package:flutter/material.dart';
import '../../models/animal.dart';
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
  final AnimalsService _service = AnimalsService();

  bool _loading = true;
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
      final a = await _service.show(widget.animalId);
      if (!mounted) return;
      setState(() {
        _animal = a;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
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
                                color: const Color(0x24FFFFFF),
                              ),
                              color: const Color(0x0AFFFFFF),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFFF3F7FF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _animal == null
                                ? 'Expediente del Animal'
                                : 'Expediente: ${_animal!.nombre}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF3F7FF),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _load,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0x24FFFFFF),
                              ),
                              color: const Color(0x0AFFFFFF),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFFF3F7FF),
                            ),
                          ),
                        ),
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
                        Tab(text: 'Historial Médico'),
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
                                style: const TextStyle(
                                  color: Color(0xFFFFD6D6),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : _animal == null
                          ? const Center(
                              child: Text(
                                'Sin información',
                                style: TextStyle(
                                  color: Color(0xB6FFFFFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : TabBarView(
                              children: [
                                _DatosTab(a: _animal!),
                                const Center(
                                  child: Text(
                                    'Aquí conectamos /{animal}/historial-medico',
                                    style: TextStyle(
                                      color: Color(0xB6FFFFFF),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    'Aquí conectamos incidencias del show o endpoint futuro',
                                    style: TextStyle(
                                      color: Color(0xB6FFFFFF),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    'Aquí conectamos assignments del show',
                                    style: TextStyle(
                                      color: Color(0xB6FFFFFF),
                                      fontWeight: FontWeight.w700,
                                    ),
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
        _InfoTile(title: 'Tipo', value: a.tipo),
        _InfoTile(title: 'Nombre', value: a.nombre),
        _InfoTile(title: 'Raza', value: a.raza ?? '-'),
        _InfoTile(title: 'Procedencia', value: a.procedencia ?? '-'),
        _InfoTile(title: 'Sexo', value: a.sexo ?? '-'),
        _InfoTile(title: 'Color', value: a.color ?? '-'),
        _InfoTile(title: 'Especialidad', value: a.especialidad ?? '-'),
        _InfoTile(title: 'Marcaje', value: a.marcaje ?? '-'),
        _InfoTile(title: 'Chip', value: a.chip ?? '-'),
        _InfoTile(title: 'Estatus', value: a.estatus),
        _InfoTile(title: 'Fecha nacimiento', value: a.fechaNacimiento ?? '-'),
        _InfoTile(title: 'Edad', value: a.edadTexto ?? '-'),
        _InfoTile(
          title: 'Forraje (kg/día)',
          value: a.forrajeKgDiario?.toString() ?? '-',
        ),
        _InfoTile(
          title: 'Grano (kg/día)',
          value: a.granoKgDiario?.toString() ?? '-',
        ),
        _InfoTile(title: 'Observaciones', value: a.observaciones ?? '-'),
        _InfoTile(title: 'Características', value: a.caracteristicas ?? '-'),
      ],
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x24FFFFFF)),
        color: const Color(0x0AFFFFFF),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0x88FFFFFF),
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFF3F7FF),
                fontWeight: FontWeight.w800,
                fontSize: 13.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
