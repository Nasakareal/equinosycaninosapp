import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/home/app_background.dart';
import '../widgets/home/glass.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_left_drawer.dart';
import '../widgets/home/home_right_drawer.dart';

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
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Aqui va el FEED del Home.\nEl menu izquierdo controla Animales.\nEl menu derecho es Cuenta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
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
}
