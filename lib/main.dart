import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/routes.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/animals/animals_index_screen.dart';
import 'screens/animals/animal_create_screen.dart';
import 'screens/configuracion/configuracion_screen.dart';
import 'screens/configuracion/config_usuarios_screen.dart';
import 'screens/configuracion/config_roles_screen.dart';
import 'screens/personal/personals_index_screen.dart';
import 'screens/equinoterapia/equinoterapias_index_screen.dart';
import 'screens/mis_servicios/mis_servicios_index_screen.dart';
import 'screens/servicios/servicios_index_screen.dart';

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
        Routes.configuracion: (_) => const ConfiguracionScreen(),
        Routes.configuracionUsuarios: (_) => const ConfigUsuariosScreen(),
        Routes.configuracionRoles: (_) => const ConfigRolesScreen(),
        Routes.animalsIndex: (_) => const AnimalsIndexScreen(),
        Routes.animalCreate: (_) => const AnimalCreateScreen(),
        Routes.personalsIndex: (_) => const PersonalsIndexScreen(),
        Routes.equinoterapiasIndex: (_) => const EquinoterapiasIndexScreen(),
        Routes.serviciosIndex: (_) => const ServiciosIndexScreen(),
        Routes.misServiciosIndex: (_) => const MisServiciosIndexScreen(),
      },
    );
  }
}
