import 'package:flutter/material.dart';

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color primary;
  final Color primarySoft;
  final Color primaryGlow;
  final Color accent;
  final Color accentGlow;

  final Color backgroundTop;
  final Color backgroundBottom;
  final Color surface;
  final Color surfaceElevated;
  final Color field;
  final Color fieldFocused;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  final Color border;
  final Color borderLight;
  final Color borderGlow;

  final Color error;
  final Color warning;
  final Color success;

  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color sectionAccent;

  final bool useAurora;
  final bool isDark;

  const AppThemeColors({
    required this.primary,
    required this.primarySoft,
    required this.primaryGlow,
    required this.accent,
    required this.accentGlow,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.surface,
    required this.surfaceElevated,
    required this.field,
    required this.fieldFocused,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.borderLight,
    required this.borderGlow,
    required this.error,
    required this.warning,
    required this.success,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.sectionAccent,
    required this.useAurora,
    required this.isDark,
  });

  factory AppThemeColors.dark() => const AppThemeColors(
        primary: Color(0xFF7C75FF),
        primarySoft: Color(0xFF9D97FF),
        primaryGlow: Color(0xFF6C63FF),
        accent: Color(0xFF4ECDC4),
        accentGlow: Color(0xFF3DBDB5),
        backgroundTop: Color(0xFF0A0A14),
        backgroundBottom: Color(0xFF14141E),
        surface: Color(0xFF1A1A26),
        surfaceElevated: Color(0xFF222230),
        field: Color(0xFF12121E),
        fieldFocused: Color(0xFF181828),
        textPrimary: Color(0xFFEEEEF4),
        textSecondary: Color(0xFF88889A),
        textTertiary: Color(0xFF5A5A6E),
        textDisabled: Color(0xFF3A3A4A),
        border: Color(0xFF2A2A3E),
        borderLight: Color(0xFF35354A),
        borderGlow: Color(0xFF7C75FF),
        error: Color(0xFFE0454B),
        warning: Color(0xFFE8A838),
        success: Color(0xFF34B78F),
        shimmerBase: Color(0xFF1E1E2A),
        shimmerHighlight: Color(0xFF282838),
        sectionAccent: Color(0xFF3A3A5E),
        useAurora: true,
        isDark: true,
      );

  factory AppThemeColors.office() => const AppThemeColors(
        primary: Color(0xFF7C75FF),
        primarySoft: Color(0xFF9D97FF),
        primaryGlow: Color(0xFF6C63FF),
        accent: Color(0xFF4ECDC4),
        accentGlow: Color(0xFF3DBDB5),
        backgroundTop: Color(0xFF3A3A45),
        backgroundBottom: Color(0xFF2E2E38),
        surface: Color(0xFF42424D),
        surfaceElevated: Color(0xFF4A4A55),
        field: Color(0xFF363640),
        fieldFocused: Color(0xFF40404A),
        textPrimary: Color(0xFFE8E8EC),
        textSecondary: Color(0xFFB0B0BC),
        textTertiary: Color(0xFF888894),
        textDisabled: Color(0xFF5A5A66),
        border: Color(0xFF52525E),
        borderLight: Color(0xFF60606C),
        borderGlow: Color(0xFF7C75FF),
        error: Color(0xFFE0454B),
        warning: Color(0xFFE8A838),
        success: Color(0xFF34B78F),
        shimmerBase: Color(0xFF363640),
        shimmerHighlight: Color(0xFF42424D),
        sectionAccent: Color(0xFF4A4A55),
        useAurora: false,
        isDark: true,
      );

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? primarySoft,
    Color? primaryGlow,
    Color? accent,
    Color? accentGlow,
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? surface,
    Color? surfaceElevated,
    Color? field,
    Color? fieldFocused,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? border,
    Color? borderLight,
    Color? borderGlow,
    Color? error,
    Color? warning,
    Color? success,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? sectionAccent,
    bool? useAurora,
    bool? isDark,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      accent: accent ?? this.accent,
      accentGlow: accentGlow ?? this.accentGlow,
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      field: field ?? this.field,
      fieldFocused: fieldFocused ?? this.fieldFocused,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      borderGlow: borderGlow ?? this.borderGlow,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      success: success ?? this.success,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      sectionAccent: sectionAccent ?? this.sectionAccent,
      useAurora: useAurora ?? this.useAurora,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentGlow: Color.lerp(accentGlow, other.accentGlow, t)!,
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundBottom: Color.lerp(backgroundBottom, other.backgroundBottom, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      field: Color.lerp(field, other.field, t)!,
      fieldFocused: Color.lerp(fieldFocused, other.fieldFocused, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      borderGlow: Color.lerp(borderGlow, other.borderGlow, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      sectionAccent: Color.lerp(sectionAccent, other.sectionAccent, t)!,
      useAurora: t < 0.5 ? useAurora : other.useAurora,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppThemeColorsExtension on BuildContext {
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.dark();
}
