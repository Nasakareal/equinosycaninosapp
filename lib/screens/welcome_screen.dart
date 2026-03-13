import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/routes.dart';
import '../services/auth_service.dart';
import '../widgets/home/app_background.dart';
import '../widgets/home/glass.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _checkingSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await AuthService().getToken();
    if (!mounted) return;

    if (token != null && token.trim().isNotEmpty) {
      Navigator.pushReplacementNamed(context, Routes.home);
      return;
    }

    setState(() => _checkingSession = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: _checkingSession
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TopBar(),
                      const SizedBox(height: 18),
                      _HeroCard(
                        onLogin: () {
                          Navigator.pushNamed(context, Routes.login);
                        },
                      ),
                      const SizedBox(height: 14),
                      const _GlassInfo(
                        title: 'Uso interno',
                        body:
                            'Acceso restringido para operacion. Inicia sesion para continuar.',
                        pills: [
                          _PillData(
                            icon: Icons.lock_outline_rounded,
                            label: 'Restringido',
                          ),
                          _PillData(
                            icon: Icons.verified_user_outlined,
                            label: 'Operativo',
                          ),
                          _PillData(icon: Icons.security_outlined, label: 'SSP'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _Footer(year: DateTime.now().year),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8DDC8), Color(0xFFD8CFBC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppColors.creamStroke.withValues(alpha: 0.24),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  color: AppColors.text.withValues(alpha: 0.12),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/escudo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Equinos y Caninos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.4,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'SSP Michoacan - App operativa',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onLogin;

  const _HeroCard({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Kicker(icon: Icons.shield_rounded, text: 'Acceso seguro'),
          const SizedBox(height: 14),
          Center(child: _LogoHero()),
          const SizedBox(height: 14),
          const Text(
            'Inicio de sesion requerido',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              height: 1.10,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta aplicacion es de uso interno. Ingresa con tus credenciales para continuar.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13.8,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CreamButton(
                  label: 'Iniciar sesion',
                  icon: Icons.login_rounded,
                  onTap: onLogin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LogoHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.24)),
        gradient: LinearGradient(
          colors: [
            AppColors.whiteWarm.withValues(alpha: 0.82),
            AppColors.creamStrong.withValues(alpha: 0.74),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 40,
            offset: const Offset(0, 18),
            color: AppColors.text.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.green.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/images/escudo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Kicker({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.24)),
        color: AppColors.green.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.greenDeep, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.greenDeep,
                fontSize: 12.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassInfo extends StatelessWidget {
  final String title;
  final String body;
  final List<_PillData> pills;

  const _GlassInfo({
    required this.title,
    required this.body,
    required this.pills,
  });

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13.2,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pills.map((p) => _Pill(p: p)).toList(),
          ),
        ],
      ),
    );
  }
}

class _PillData {
  final IconData icon;
  final String label;

  const _PillData({required this.icon, required this.label});
}

class _Pill extends StatelessWidget {
  final _PillData p;

  const _Pill({required this.p});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.creamStroke.withValues(alpha: 0.20)),
        color: AppColors.whiteWarm.withValues(alpha: 0.62),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(p.icon, size: 16, color: AppColors.brownDeep),
          const SizedBox(width: 7),
          Text(
            p.label,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 12.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreamButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CreamButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brown.withValues(alpha: 0.16)),
          gradient: const LinearGradient(
            colors: [Color(0xFFA47754), Color(0xFF6F4E38)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              offset: const Offset(0, 14),
              color: AppColors.brownDeep.withValues(alpha: 0.22),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.whiteWarm, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.whiteWarm,
                fontWeight: FontWeight.w900,
                fontSize: 13.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final int year;

  const _Footer({required this.year});

  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Text(
        '(c) $year - Equinos y Caninos - SSP Michoacan',
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
