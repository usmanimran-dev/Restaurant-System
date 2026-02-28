import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Production-grade UI design system for the Restaurant SaaS platform.
/// "Bright, Clear, and Purposeful"
class AppTheme {
  AppTheme._();

  // ── Primary Colors ────────────────────────────────────────────────────────
  static const Color _surfaceColor = Color(0xFFFFFFFF); // Bright White
  static const Color _textColor = Color(0xFF1A1A1A); // Deep Charcoal
  static const Color _backgroundColor = Color(0xFFF5F5F5); // Light Gray

  // ── Accent Colors ─────────────────────────────────────────────────────────
  static const Color _primaryColor = Color(0xFF00D084); // Vibrant Green (success, primary CTAs)
  static const Color _interactiveColor = Color(0xFF0066FF); // Bright Blue (links, interactive)
  static const Color _warningColor = Color(0xFFFF6B35); // Warm Orange (alerts)
  static const Color _secondaryCtaColor = Color(0xFF6366F1); // Soft Purple
  static const Color _errorColor = Color(0xFFDC2626); // Subtle Red (danger)

  // ── Design Tokens ─────────────────────────────────────────────────────────
  static const double _borderRadius = 8.0;

  // ── Typography System ─────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base) {
    // Inter for body
    final interTheme = GoogleFonts.interTextTheme(base);
    // DM Sans for Display/Headers
    final dmsansTheme = GoogleFonts.dmSansTextTheme(base);

    return interTheme.copyWith(
      displayLarge: dmsansTheme.displayLarge?.copyWith(color: _textColor, fontWeight: FontWeight.bold),
      displayMedium: dmsansTheme.displayMedium?.copyWith(color: _textColor, fontWeight: FontWeight.bold),
      displaySmall: dmsansTheme.displaySmall?.copyWith(color: _textColor, fontWeight: FontWeight.bold),
      headlineLarge: dmsansTheme.headlineLarge?.copyWith(color: _textColor, fontWeight: FontWeight.w700),
      headlineMedium: dmsansTheme.headlineMedium?.copyWith(color: _textColor, fontWeight: FontWeight.w700),
      headlineSmall: dmsansTheme.headlineSmall?.copyWith(color: _textColor, fontWeight: FontWeight.w700),
      titleLarge: dmsansTheme.titleLarge?.copyWith(color: _textColor, fontWeight: FontWeight.w600),
      titleMedium: dmsansTheme.titleMedium?.copyWith(color: _textColor, fontWeight: FontWeight.w600),
      titleSmall: dmsansTheme.titleSmall?.copyWith(color: _textColor, fontWeight: FontWeight.w600),
      bodyLarge: interTheme.bodyLarge?.copyWith(color: _textColor),
      bodyMedium: interTheme.bodyMedium?.copyWith(color: _textColor),
      bodySmall: interTheme.bodySmall?.copyWith(color: _textColor.withValues(alpha: 0.7)),
      labelLarge: interTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: interTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: interTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  // ── Theme Data ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    final textTheme = _buildTextTheme(baseTheme.textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        secondary: _interactiveColor,
        surface: _surfaceColor,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      cardColor: _surfaceColor,
      hintColor: _textColor.withValues(alpha: 0.5),
      textTheme: textTheme,
      
      // ── Component Themes ───────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _surfaceColor,
        foregroundColor: _textColor,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: _textColor),
      ),
      cardTheme: CardThemeData(
        color: _surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius * 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        hintStyle: textTheme.bodyMedium?.copyWith(color: _textColor.withValues(alpha: 0.4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: _textColor.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: _textColor.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _interactiveColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: _errorColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.hovered)
                ? Colors.white.withValues(alpha: 0.1)
                : null,
          ),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textColor,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(color: _textColor.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _interactiveColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ).copyWith(
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _surfaceColor,
        selectedIconTheme: const IconThemeData(color: _interactiveColor),
        unselectedIconTheme: IconThemeData(
          color: _textColor.withValues(alpha: 0.5),
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: _interactiveColor,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: _textColor.withValues(alpha: 0.5),
        ),
        indicatorColor: _interactiveColor.withValues(alpha: 0.1),
      ),
      dividerTheme: DividerThemeData(
        color: _textColor.withValues(alpha: 0.08),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _backgroundColor,
        labelStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        side: BorderSide(color: _textColor.withValues(alpha: 0.1)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius * 2),
        ),
        elevation: 10,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
