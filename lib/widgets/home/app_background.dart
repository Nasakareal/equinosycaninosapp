import 'package:flutter/material.dart';

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
              colors: [Color(0xFF070B16), Color(0xFF0A1228)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        const _RadialGlow(
          alignment: Alignment(-0.78, -0.98),
          color: Color(0x337C4DFF),
          radius: 360,
        ),
        const _RadialGlow(
          alignment: Alignment(0.95, -0.95),
          color: Color(0x3300E5FF),
          radius: 340,
        ),
        const _RadialGlow(
          alignment: Alignment(0.20, 1.08),
          color: Color(0x2600D084),
          radius: 460,
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
