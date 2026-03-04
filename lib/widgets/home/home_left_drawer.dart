import 'package:flutter/material.dart';
import '../../core/routes.dart';
import 'glass.dart';

enum AnimalFilter { all, equinos, caninos }

class HomeLeftDrawer extends StatelessWidget {
  final AnimalFilter filter;
  final ValueChanged<AnimalFilter> onChangeFilter;

  const HomeLeftDrawer({
    super.key,
    required this.filter,
    required this.onChangeFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Glass(
            radius: 20,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0x297C4DFF), Color(0x2900E5FF)],
                    ),
                    border: Border.all(color: const Color(0x24FFFFFF)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.pets_rounded, color: Color(0xFFF3F7FF)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Unidad Canina y Equina',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFF3F7FF),
                            fontWeight: FontWeight.w900,
                            fontSize: 14.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _MenuTile(
                  icon: Icons.list_alt_rounded,
                  title: 'Listado general',
                  onTap: () {
                    Navigator.pop(context);
                    onChangeFilter(AnimalFilter.all);
                    Navigator.pushNamed(context, Routes.animalsIndex);
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.add_rounded,
                  title: 'Agregar animal',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.animalCreate);
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.holiday_village_rounded,
                  title: 'Solo Equinos',
                  selected: filter == AnimalFilter.equinos,
                  onTap: () {
                    Navigator.pop(context);
                    onChangeFilter(AnimalFilter.equinos);
                    Navigator.pushNamed(context, Routes.animalsIndex);
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.pets_rounded,
                  title: 'Solo Caninos',
                  selected: filter == AnimalFilter.caninos,
                  onTap: () {
                    Navigator.pop(context);
                    onChangeFilter(AnimalFilter.caninos);
                    Navigator.pushNamed(context, Routes.animalsIndex);
                  },
                ),
                const Spacer(),
                const Text(
                  'Uso interno • SSP Michoacán',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xA6FFFFFF),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.2,
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x24FFFFFF)),
          color: selected ? const Color(0x1E7C4DFF) : const Color(0x0AFFFFFF),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF3F7FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF3F7FF),
                  fontWeight: FontWeight.w800,
                  fontSize: 14.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
