import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF7C75FF);
  static const primarySoft = Color(0xFF9D97FF);
  static const primaryGlow = Color(0xFF6C63FF);
  static const accent = Color(0xFF4ECDC4);
  static const accentGlow = Color(0xFF3DBDB5);

  static const backgroundTop = Color(0xFF0A0A14);
  static const backgroundBottom = Color(0xFF14141E);
  static const surface = Color(0xFF1A1A26);
  static const surfaceElevated = Color(0xFF222230);
  static const field = Color(0xFF12121E);
  static const fieldFocused = Color(0xFF181828);

  static const textPrimary = Color(0xFFEEEEF4);
  static const textSecondary = Color(0xFF88889A);
  static const textTertiary = Color(0xFF5A5A6E);
  static const textDisabled = Color(0xFF3A3A4A);

  static const border = Color(0xFF2A2A3E);
  static const borderLight = Color(0xFF35354A);
  static const borderGlow = Color(0xFF7C75FF);

  static const error = Color(0xFFE0454B);
  static const warning = Color(0xFFE8A838);
  static const success = Color(0xFF34B78F);

  static const shimmerBase = Color(0xFF1E1E2A);
  static const shimmerHighlight = Color(0xFF282838);

  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF7C75FF), Color(0xFF6C63FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A14), Color(0xFF14141E), Color(0xFF0D0D18)],
  );

  static const gradientCardBorder = LinearGradient(
    colors: [Color(0xFF2A2A4E), Color(0xFF4A3A6E), Color(0xFF2A2A4E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sectionAccent = Color(0xFF3A3A5E);
}
