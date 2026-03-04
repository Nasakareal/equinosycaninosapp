import 'package:flutter/material.dart';
import '../../core/routes.dart';
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
                    border: Border.all(color: const Color(0x24FFFFFF)),
                    color: const Color(0x0AFFFFFF),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.manage_accounts_rounded,
                        color: Color(0xFFF3F7FF),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cuenta',
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
                  icon: Icons.badge_rounded,
                  title: 'Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil próximamente')),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _MenuTile(
                  icon: Icons.password_rounded,
                  title: 'Cambiar contraseña',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cambio de contraseña próximamente'),
                      ),
                    );
                  },
                ),
                const Spacer(),
                _DangerTile(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión',
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
          border: Border.all(color: const Color(0x24FFFFFF)),
          color: const Color(0x0AFFFFFF),
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
          border: Border.all(color: const Color(0x26FF6B6B)),
          color: const Color(0x14FF6B6B),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD6D6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFFFD6D6),
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
