import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import 'glass.dart';

class HomeRightDrawer extends StatelessWidget {
  const HomeRightDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, Routes.welcome, (_) => false);
  }

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
                    border: Border.all(
                      color: AppColors.creamStroke.withValues(alpha: 0.28),
                    ),
                    color: AppColors.whiteWarm.withValues(alpha: 0.58),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.manage_accounts_rounded,
                        color: AppColors.brownDeep,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cuenta',
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
                _MenuTile(
                  icon: Icons.badge_rounded,
                  title: 'Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil proximamente')),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.password_rounded,
                  title: 'Cambiar contrasena',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cambio de contrasena proximamente'),
                      ),
                    );
                  },
                ),
                const Spacer(),
                _DangerTile(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesion',
                  onTap: () async {
                    Navigator.pop(context);
                    await _logout(context);
                  },
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
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
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
          border: Border.all(
            color: AppColors.creamStroke.withValues(alpha: 0.24),
          ),
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

class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DangerTile({
    required this.icon,
    required this.title,
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
          border: Border.all(color: AppColors.red.withValues(alpha: 0.30)),
          color: AppColors.redSoft.withValues(alpha: 0.72),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w900,
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
