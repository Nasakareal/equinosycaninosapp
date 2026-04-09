import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/routes.dart';
import '../../models/auth_user.dart';
import '../../services/auth_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  AuthUser? _authUser;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().resolveCurrentUser();
    if (!mounted) return;
    setState(() {
      _authUser = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canViewUsers = _authUser?.canViewUsuarios ?? true;
    final canViewRoles = _authUser?.canViewRoles ?? true;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Glass(
                  radius: 22,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.creamStroke.withValues(
                                alpha: 0.24,
                              ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuraciones',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Accesos de administracion del sistema',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA47754), Color(0xFF6F4E38)],
                            ),
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            color: AppColors.whiteWarm,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Glass(
                    radius: 24,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Modulos disponibles',
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Desde aqui ya puedes administrar usuarios, roles y permisos segun el acceso del usuario autenticado.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.2,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: ListView(
                            children: [
                              if (canViewUsers)
                                _ConfigCard(
                                  icon: Icons.group_rounded,
                                  title: 'Usuarios',
                                  subtitle:
                                      'Gestion de usuarios del sistema y asignacion de rol.',
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    Routes.configuracionUsuarios,
                                  ),
                                ),
                              if (canViewUsers && canViewRoles)
                                const SizedBox(height: 12),
                              if (canViewRoles)
                                _ConfigCard(
                                  icon: Icons.admin_panel_settings_rounded,
                                  title: 'Roles',
                                  subtitle:
                                      'Administracion de roles y permisos disponibles.',
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    Routes.configuracionRoles,
                                  ),
                                ),
                              if (!canViewUsers && !canViewRoles)
                                const Padding(
                                  padding: EdgeInsets.only(top: 24),
                                  child: Center(
                                    child: Text(
                                      'No cuentas con permisos para ver modulos de configuracion.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ConfigCard({
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.creamStroke.withValues(alpha: 0.24),
          ),
          color: AppColors.whiteWarm.withValues(alpha: 0.60),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8D8C1), Color(0xFFD7C4A9)],
                ),
              ),
              child: Icon(icon, color: AppColors.brownDeep),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.6,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: AppColors.brownDeep,
            ),
          ],
        ),
      ),
    );
  }
}
