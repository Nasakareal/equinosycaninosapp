import 'package:flutter/material.dart';

class AppColors {
  static const Color text = Color(0xFF2F3D2F);
  static const Color muted = Color(0xFF5E6655);
  static const Color mutedSoft = Color(0xFF7F8478);

  static const Color cream = Color(0xFFF5F0E3);
  static const Color creamStrong = Color(0xFFECE5D8);
  static const Color creamDeep = Color(0xFFD8CFBC);
  static const Color creamStroke = Color(0xFFBFAF91);

  static const Color green = Color(0xFF6F8F69);
  static const Color greenDeep = Color(0xFF4F6B50);
  static const Color brown = Color(0xFFA47754);
  static const Color brownDeep = Color(0xFF6F4E38);
  static const Color red = Color(0xFFB17160);
  static const Color redSoft = Color(0xFFFFE2DB);

  static const Color whiteWarm = Color(0xFFFFFBF4);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brownDeep,
      brightness: Brightness.light,
      primary: AppColors.brownDeep,
      secondary: AppColors.green,
      surface: AppColors.cream,
      error: AppColors.red,
    );

    OutlineInputBorder inputBorder(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: 1.15),
      );
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cream.withValues(alpha: 0.96),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.creamStroke.withValues(alpha: 0.35),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.whiteWarm.withValues(alpha: 0.88),
        labelStyle: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(color: AppColors.mutedSoft),
        suffixIconColor: AppColors.muted,
        prefixIconColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: inputBorder(
          AppColors.creamStroke.withValues(alpha: 0.48),
        ),
        focusedBorder: inputBorder(AppColors.green.withValues(alpha: 0.72)),
        errorBorder: inputBorder(AppColors.red.withValues(alpha: 0.72)),
        focusedErrorBorder: inputBorder(AppColors.red),
        border: inputBorder(AppColors.creamStroke.withValues(alpha: 0.48)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.whiteWarm,
          backgroundColor: AppColors.brownDeep,
          disabledBackgroundColor: AppColors.brownDeep.withValues(alpha: 0.45),
          disabledForegroundColor: AppColors.whiteWarm.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brownDeep,
          foregroundColor: AppColors.whiteWarm,
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.greenDeep,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: const TextStyle(
          color: AppColors.whiteWarm,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.brownDeep,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.greenDeep,
        labelStyle: TextStyle(fontWeight: FontWeight.w900),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.greenDeep,
      ),
      dividerColor: AppColors.creamStroke.withValues(alpha: 0.35),
    );
  }
}
