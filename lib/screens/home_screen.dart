import 'package:flutter/material.dart';
import '../widgets/home/app_background.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_left_drawer.dart';
import '../widgets/home/home_right_drawer.dart';
import '../widgets/home/glass.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimalFilter _filter = AnimalFilter.all;

  void _openLeft() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openRight() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: HomeLeftDrawer(
        filter: _filter,
        onChangeFilter: (f) => setState(() => _filter = f),
      ),
      endDrawer: const HomeRightDrawer(),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeAppBar(openLeft: _openLeft, openRight: _openRight),
                const SizedBox(height: 14),
                const SizedBox(height: 14),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Aquí va el FEED del Home.\nEl menú izquierdo controla Animales.\nEl menú derecho es Cuenta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xB6FFFFFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 13.6,
                          height: 1.4,
                        ),
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

  String _subtitleForFilter(AnimalFilter f) {
    switch (f) {
      case AnimalFilter.equinos:
        return 'Acceso operativo • Filtro activo: Solo Equinos';
      case AnimalFilter.caninos:
        return 'Acceso operativo • Filtro activo: Solo Caninos';
      case AnimalFilter.all:
      default:
        return 'Acceso operativo • Listado general';
    }
  }
}

class _QuickTiles extends StatelessWidget {
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenAccount;

  const _QuickTiles({required this.onOpenMenu, required this.onOpenAccount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Tile(
            icon: Icons.pets_rounded,
            title: 'Animales',
            subtitle: 'Abrir menú',
            onTap: onOpenMenu,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Tile(
            icon: Icons.manage_accounts_rounded,
            title: 'Cuenta',
            subtitle: 'Opciones',
            onTap: onOpenAccount,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x24FFFFFF)),
          gradient: const LinearGradient(
            colors: [Color(0x1200E5FF), Color(0x127C4DFF)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x24FFFFFF)),
                color: const Color(0x0AFFFFFF),
              ),
              child: Icon(icon, color: const Color(0xFFF3F7FF)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF3F7FF),
                      fontWeight: FontWeight.w900,
                      fontSize: 14.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xB6FFFFFF),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
