import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual tokens for Calebsons Flutter.
abstract final class AppColors {
  static const ink = Color(0xFF0B1F1E);
  static const teal = Color(0xFF1F6F6A);
  static const tealDeep = Color(0xFF134E4A);
  static const mist = Color(0xFFE7F1F0);
  static const wash = Color(0xFFF3F7F6);
  static const chalk = Color(0xFFFAFCFB);
  static const line = Color(0xFFC9D8D6);
  static const muted = Color(0xFF5B7371);
  static const alert = Color(0xFFB45309);
  static const alertSoft = Color(0xFFFFF4E5);
  static const ok = Color(0xFF047857);
  static const okSoft = Color(0xFFE6F6EF);
}

abstract final class Breakpoints {
  static const compact = 600.0;
  static const medium = 840.0;
  static const contentMax = 960.0;
}

ThemeData buildAppTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    brightness: Brightness.light,
    primary: AppColors.teal,
    onPrimary: Colors.white,
    secondary: AppColors.tealDeep,
    surface: AppColors.chalk,
    onSurface: AppColors.ink,
    error: AppColors.alert,
  );

  final display = GoogleFonts.frauncesTextTheme();
  final body = GoogleFonts.manropeTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: AppColors.wash,
    textTheme: body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
      ),
      displayMedium: display.displayMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: body.titleLarge?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: body.titleMedium?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: AppColors.ink, height: 1.45),
      bodyMedium: body.bodyMedium?.copyWith(color: AppColors.ink, height: 1.45),
      bodySmall: body.bodySmall?.copyWith(color: AppColors.muted, height: 1.4),
      labelLarge: body.labelLarge?.copyWith(
        color: AppColors.muted,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      centerTitle: false,
      titleTextStyle: GoogleFonts.fraunces(
        color: AppColors.ink,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.chalk.withValues(alpha: 0.92),
      indicatorColor: AppColors.mist,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.tealDeep : AppColors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.tealDeep : AppColors.muted,
          size: 22,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: AppColors.mist,
      selectedIconTheme: const IconThemeData(color: AppColors.tealDeep),
      unselectedIconTheme: const IconThemeData(color: AppColors.muted),
      selectedLabelTextStyle: GoogleFonts.manrope(
        color: AppColors.tealDeep,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: GoogleFonts.manrope(
        color: AppColors.muted,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.mist,
      selectedColor: AppColors.teal,
      labelStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.teal,
    ),
  );
}
