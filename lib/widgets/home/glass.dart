import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

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
            border: Border.all(
              color: AppColors.creamStroke.withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D382B).withValues(alpha: 0.10),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
            gradient: LinearGradient(
              colors: [
                AppColors.cream.withValues(alpha: 0.94),
                AppColors.creamStrong.withValues(alpha: 0.90),
              ],
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
