import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD6D2C4), Color(0xFFCEC8B7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const _RadialGlow(
          alignment: Alignment(-0.82, -0.95),
          color: Color(0x2D6F8F69),
          radius: 360,
        ),
        const _RadialGlow(
          alignment: Alignment(0.95, -0.90),
          color: Color(0x26A47754),
          radius: 320,
        ),
        const _RadialGlow(
          alignment: Alignment(0.10, 1.05),
          color: Color(0x1C4F6B50),
          radius: 460,
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cream.withValues(alpha: 0.78),
                  AppColors.creamStrong.withValues(alpha: 0.54),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        child,
      ],
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
