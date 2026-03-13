import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/routes.dart';
import 'glass.dart';

enum AnimalFilter { all, equinos, caninos }

class HomeLeftDrawer extends StatefulWidget {
  final AnimalFilter filter;
  final ValueChanged<AnimalFilter> onChangeFilter;

  const HomeLeftDrawer({
    super.key,
    required this.filter,
    required this.onChangeFilter,
  });

  @override
  State<HomeLeftDrawer> createState() => _HomeLeftDrawerState();
}

class _HomeLeftDrawerState extends State<HomeLeftDrawer> {
  bool _animalsOpen = false;
  bool _personalOpen = false;
  bool _equinoterapiaOpen = false;

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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8D8C1), Color(0xFFD7C4A9)],
                    ),
                    border: Border.all(
                      color: AppColors.creamStroke.withValues(alpha: 0.30),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.dashboard_customize_rounded, color: AppColors.brownDeep),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Panel operativo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionTile(
                  icon: Icons.pets_rounded,
                  title: 'Animales',
                  open: _animalsOpen,
                  onTap: () => setState(() => _animalsOpen = !_animalsOpen),
                ),
                if (_animalsOpen) ...[
                  const SizedBox(height: 8),
                  _SubMenuTile(
                    icon: Icons.list_alt_rounded,
                    title: 'Listado general',
                    onTap: () {
                      Navigator.pop(context);
                      widget.onChangeFilter(AnimalFilter.all);
                      Navigator.pushNamed(context, Routes.animalsIndex);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SubMenuTile(
                    icon: Icons.add_rounded,
                    title: 'Agregar animal',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.animalCreate);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SubMenuTile(
                    icon: Icons.holiday_village_rounded,
                    title: 'Solo Equinos',
                    selected: widget.filter == AnimalFilter.equinos,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onChangeFilter(AnimalFilter.equinos);
                      Navigator.pushNamed(context, Routes.animalsIndex);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SubMenuTile(
                    icon: Icons.pets_rounded,
                    title: 'Solo Caninos',
                    selected: widget.filter == AnimalFilter.caninos,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onChangeFilter(AnimalFilter.caninos);
                      Navigator.pushNamed(context, Routes.animalsIndex);
                    },
                  ),
                ],
                const SizedBox(height: 10),
                _SectionTile(
                  icon: Icons.badge_rounded,
                  title: 'Personal',
                  open: _personalOpen,
                  onTap: () => setState(() => _personalOpen = !_personalOpen),
                ),
                if (_personalOpen) ...[
                  const SizedBox(height: 8),
                  _SubMenuTile(
                    icon: Icons.groups_2_rounded,
                    title: 'Ver listado',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.personalsIndex);
                    },
                  ),
                ],
                const SizedBox(height: 10),
                _SectionTile(
                  icon: Icons.volunteer_activism_rounded,
                  title: 'Equinoterapias',
                  open: _equinoterapiaOpen,
                  onTap: () => setState(() => _equinoterapiaOpen = !_equinoterapiaOpen),
                ),
                if (_equinoterapiaOpen) ...[
                  const SizedBox(height: 8),
                  _SubMenuTile(
                    icon: Icons.list_alt_rounded,
                    title: 'Ver reportes',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.equinoterapiasIndex);
                    },
                  ),
                ],
                const Spacer(),
                const Text(
                  'Uso interno • SSP Michoacan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
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

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool open;
  final VoidCallback onTap;

  const _SectionTile({
    required this.icon,
    required this.title,
    required this.open,
    required this.onTap,
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
          border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.24)),
          color: AppColors.whiteWarm.withValues(alpha: 0.58),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brownDeep),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.2,
                ),
              ),
            ),
            Icon(
              open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _SubMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.green.withValues(alpha: 0.40)
                : AppColors.creamStroke.withValues(alpha: 0.20),
          ),
          color: selected
              ? AppColors.green.withValues(alpha: 0.16)
              : AppColors.creamStrong.withValues(alpha: 0.54),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.greenDeep : AppColors.brownDeep, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? AppColors.greenDeep : AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
