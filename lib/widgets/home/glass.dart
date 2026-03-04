import 'dart:ui';
import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  final double radius;
  final EdgeInsets padding;
  final Widget child;

  const Glass({
    super.key,
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
