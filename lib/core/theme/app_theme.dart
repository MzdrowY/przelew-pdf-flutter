import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final _poppins = GoogleFonts.poppins();
final _inter = GoogleFonts.inter();

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme
          .fromSeed(
            seedColor: const Color(0xFF7C75FF),
            brightness: Brightness.dark,
            surface: AppColors.surface,
            surfaceContainerHighest: AppColors.surfaceElevated,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            error: AppColors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.textPrimary,
            onError: Colors.white,
          )
          .copyWith(
            outline: AppColors.border,
            outlineVariant: AppColors.borderLight,
          ),
      scaffoldBackgroundColor: Colors.transparent,
     
      textTheme: TextTheme(
        titleLarge: _poppins.copyWith(
            fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.2),
        titleMedium: _inter.copyWith(
            fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        bodyLarge: _inter.copyWith(
            fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: _inter.copyWith(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: _inter.copyWith(
            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelSmall: _inter.copyWith(
            fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.field,
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A3E), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7C75FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0454B), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: _inter.copyWith(fontSize: 12, color: AppColors.textTertiary),
        hintStyle: _inter.copyWith(fontSize: 12, color: AppColors.textDisabled),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          textStyle: _inter.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: Color(0xFF7C75FF), width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _inter.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: _inter.copyWith(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        toolbarHeight: 40,
        iconTheme: IconThemeData(color: AppColors.textSecondary, size: 20),
        actionsIconTheme: IconThemeData(color: AppColors.textSecondary, size: 20),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: _inter.copyWith(fontSize: 12, color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
