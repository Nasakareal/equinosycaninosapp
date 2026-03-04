import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _Background(),
          SafeArea(
            child: SingleChildScrollView(
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
                        'Acceso restringido para operación. Inicia sesión para continuar.',
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
        ],
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF070B16), Color(0xFF0A1228)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Stack(
        children: [
          _RadialGlow(
            alignment: Alignment(-0.75, -0.95),
            color: Color(0x337C4DFF),
            radius: 340,
          ),
          _RadialGlow(
            alignment: Alignment(0.90, -0.92),
            color: Color(0x3300E5FF),
            radius: 320,
          ),
          _RadialGlow(
            alignment: Alignment(0.15, 1.05),
            color: Color(0x2600D084),
            radius: 420,
          ),
        ],
      ),
    );
  }
}

class _RadialGlow extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double radius;

  const _RadialGlow({
    required this.alignment,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return _Glass(
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
                colors: [Color(0x3D00E5FF), Color(0x3D7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0x2EFFFFFF)),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  offset: Offset(0, 10),
                  color: Color(0x33000000),
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
                    color: Color(0xFFF3F7FF),
                    fontWeight: FontWeight.w900,
                    fontSize: 15.4,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'SSP Michoacán • App Operativa',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0x88FFFFFF),
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
    return _HeroSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Kicker(icon: Icons.shield_rounded, text: 'Acceso seguro'),
            const SizedBox(height: 14),
            Center(child: _LogoHero()),
            const SizedBox(height: 14),
            const Text(
              'Inicio de sesión requerido',
              style: TextStyle(
                color: Color(0xFFF3F7FF),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                height: 1.10,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta aplicación es de uso interno. Ingresa con tus credenciales para continuar.',
              style: TextStyle(
                color: Color(0xB6FFFFFF),
                fontSize: 13.8,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _GlowButton(
                    label: 'Iniciar sesión',
                    icon: Icons.login_rounded,
                    onTap: onLogin,
                  ),
                ),
              ],
            ),
          ],
        ),
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
        border: Border.all(color: const Color(0x33FFFFFF)),
        gradient: const LinearGradient(
          colors: [Color(0x18FFFFFF), Color(0x0AFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 60,
            offset: Offset(0, 22),
            color: Color(0x4D000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x2200E5FF), Colors.transparent],
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

class _HeroSurface extends StatelessWidget {
  final Widget child;

  const _HeroSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x1FFFFFFF)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 50,
            offset: Offset(0, 18),
            color: Color(0x73000000),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0x14FFFFFF), Color(0x08FFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.7, -0.5),
                    radius: 1.2,
                    colors: [Color(0x1400E5FF), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.8, -0.7),
                    radius: 1.3,
                    colors: [Color(0x147C4DFF), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final double radius;
  final EdgeInsets padding;
  final Widget child;

  const _Glass({
    required this.radius,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0x24FFFFFF)),
            gradient: const LinearGradient(
              colors: [Color(0x14FFFFFF), Color(0x08FFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: child,
        ),
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
    return _Glass(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xB8FFFFFF),
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
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFF3F7FF),
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xA8FFFFFF),
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
        border: Border.all(color: const Color(0x24FFFFFF)),
        color: const Color(0x0AFFFFFF),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(p.icon, size: 16, color: const Color(0xB8FFFFFF)),
          const SizedBox(width: 7),
          Text(
            p.label,
            style: const TextStyle(
              color: Color(0xB8FFFFFF),
              fontWeight: FontWeight.w800,
              fontSize: 12.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GlowButton({
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
          border: Border.all(color: const Color(0x24FFFFFF)),
          gradient: const LinearGradient(
            colors: [Color(0x2900E5FF), Color(0x297C4DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 30,
              offset: Offset(0, 14),
              color: Color(0x4D000000),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFF3F7FF), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFF3F7FF),
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
    return _Glass(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Text(
        '© $year • Equinos y Caninos • SSP Michoacán',
        style: const TextStyle(
          color: Color(0xA6FFFFFF),
          fontSize: 12.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
