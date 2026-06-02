import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Dark HSL values mapped to Hex Colors
  static const Color backgroundDark = Color(0xFF0A0E12); // hsl(210, 25%, 8%)
  static const Color surfaceDark = Color(0xFF171E25); // hsl(210, 20%, 14%)
  static const Color surfaceLightDark = Color(0xFF222C36); 

  // Liturgical Accents
  static const Color liturgicalGold = Color(0xFFEAA926); // hsl(43, 85%, 55%)
  static const Color liturgicalViolet = Color(0xFF703CA2); // hsl(270, 45%, 45%)
  static const Color liturgicalRed = Color(0xFFD62B2B); // hsl(0, 75%, 50%)
  static const Color liturgicalGreen = Color(0xFF2A8445); // hsl(140, 50%, 34%)
  static const Color liturgicalRose = Color(0xFFDF7E99); // hsl(343, 60%, 68%)

  // Neutral Accent text colors
  static const Color textPrimary = Color(0xFFF4F5F6); // hsl(40, 20%, 94%)
  static const Color textSecondary = Color(0xFF90A1B0); // hsl(210, 10%, 70%)
  static const Color textMuted = Color(0xFF5D6B77);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        surface: surfaceDark,
        primary: liturgicalGold,
        onPrimary: Colors.black,
        secondary: textSecondary,
        onSecondary: Colors.white,
        error: liturgicalRed,
      ),
      textTheme: TextTheme(
        // Scripture Display Style (Serif)
        displayLarge: GoogleFonts.lora(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.25,
        ),
        displayMedium: GoogleFonts.lora(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.lora(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: liturgicalGold,
          letterSpacing: 1.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: liturgicalGold,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
