import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme_colors.dart';
import 'app_theme_mode.dart';

final _poppins = GoogleFonts.poppins();
final _inter = GoogleFonts.inter();

class AppTheme {
  AppTheme._();

  static ThemeData forMode(AppThemeMode mode) {
    final colors = mode == AppThemeMode.office ? AppThemeColors.office() : AppThemeColors.dark();
    final brightness = mode == AppThemeMode.office ? Brightness.light : Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        surface: colors.surface,
        surfaceContainerHighest: colors.surfaceElevated,
        primary: colors.primary,
        secondary: colors.accent,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        onError: Colors.white,
      ).copyWith(
        outline: colors.border,
        outlineVariant: colors.borderLight,
      ),
      scaffoldBackgroundColor: colors.backgroundTop,
      textTheme: TextTheme(
        titleLarge: _poppins.copyWith(
            fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary, letterSpacing: -0.2),
        titleMedium: _inter.copyWith(
            fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary),
        bodyLarge: _inter.copyWith(
            fontSize: 13, fontWeight: FontWeight.w400, color: colors.textPrimary),
        bodyMedium: _inter.copyWith(
            fontSize: 12, fontWeight: FontWeight.w400, color: colors.textSecondary),
        labelLarge: _inter.copyWith(
            fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary),
        labelSmall: _inter.copyWith(
            fontSize: 11, fontWeight: FontWeight.w400, color: colors.textTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.field,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: _inter.copyWith(fontSize: 12, color: colors.textTertiary),
        hintStyle: _inter.copyWith(fontSize: 12, color: colors.textDisabled),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          textStyle: _inter.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textSecondary,
          side: BorderSide(color: colors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _inter.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: _inter.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundTop,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        toolbarHeight: 40,
        iconTheme: IconThemeData(color: colors.textSecondary, size: 20),
        actionsIconTheme: IconThemeData(color: colors.textSecondary, size: 20),
        titleTextStyle: _poppins.copyWith(
          fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: _inter.copyWith(fontSize: 12, color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      cardColor: colors.surface,
      iconTheme: IconThemeData(color: colors.textSecondary),
    );
  }
}
