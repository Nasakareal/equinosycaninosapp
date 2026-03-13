import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/routes.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/animals/animals_index_screen.dart';
import 'screens/animals/animal_create_screen.dart';
import 'screens/personal/personals_index_screen.dart';
import 'screens/equinoterapia/equinoterapias_index_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Equinos y Caninos',
      theme: AppTheme.light(),
      initialRoute: Routes.welcome,
      routes: {
        Routes.welcome: (_) => const WelcomeScreen(),
        Routes.login: (_) => const LoginScreen(),
        Routes.home: (_) => const HomeScreen(),
        Routes.animalsIndex: (_) => const AnimalsIndexScreen(),
        Routes.animalCreate: (_) => const AnimalCreateScreen(),
        Routes.personalsIndex: (_) => const PersonalsIndexScreen(),
        Routes.equinoterapiasIndex: (_) => const EquinoterapiasIndexScreen(),
      },
    );
  }
}
