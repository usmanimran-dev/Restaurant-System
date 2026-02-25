import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium dark theme for the Restaurant SaaS platform.
class AppTheme {
  AppTheme._();

  // ── Brand Colours ─────────────────────────────────────────────────────────
  static const Color _primaryColor = Color(0xFF6C63FF);
  static const Color _secondaryColor = Color(0xFF03DAC6);
  static const Color _surfaceColor = Color(0xFF1E1E2C);
  static const Color _backgroundColor = Color(0xFF13131A);
  static const Color _cardColor = Color(0xFF252536);
  static const Color _errorColor = Color(0xFFCF6679);
  static const Color _onPrimary = Colors.white;
  static const Color _onSurface = Color(0xFFE0E0E0);
  static const Color _hintColor = Color(0xFF8E8E9A);

  // ── Theme Data ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );
    final fontFamily = GoogleFonts.inter().fontFamily;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColor,
        error: _errorColor,
        onPrimary: _onPrimary,
        onSurface: _onSurface,
        onError: Colors.black,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      cardColor: _cardColor,
      hintColor: _hintColor,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _surfaceColor,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: _onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: _onSurface),
      ),
      cardTheme: CardThemeData(
        color: _cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        hintStyle: GoogleFonts.inter(color: _hintColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _hintColor.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _surfaceColor,
        selectedIconTheme: const IconThemeData(color: _primaryColor),
        unselectedIconTheme: IconThemeData(
          color: _hintColor.withValues(alpha: 0.7),
        ),
        selectedLabelTextStyle: GoogleFonts.inter(
          color: _primaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: GoogleFonts.inter(
          color: _hintColor.withValues(alpha: 0.7),
        ),
        indicatorColor: _primaryColor.withValues(alpha: 0.15),
      ),
      dividerTheme: DividerThemeData(
        color: _hintColor.withValues(alpha: 0.15),
        thickness: 1,
      ),
    );
  }
}
