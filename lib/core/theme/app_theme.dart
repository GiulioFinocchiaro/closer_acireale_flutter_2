import 'package:flutter/material.dart';

class AppTheme {
  // Colori basati sul tema originale
  static const Color primaryBlue = Color(0xFF1E3A8A); // blue-900
  static const Color primaryIndigo = Color(0xFF312E81); // indigo-900
  static const Color secondaryPurple = Color(0xFF667EEA);
  static const Color secondaryBlue = Color(0xFF764BA2);
  static const Color backgroundGray = Color(0xFFF8FAFC); // gray-50
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F2937); // gray-800
  static const Color textMedium = Color(0xFF4B5563); // gray-600
  static const Color textLight = Color(0xFF9CA3AF); // gray-400
  static const Color errorRed = Color(0xFFDC2626); // red-600
  static const Color successGreen = Color(0xFF059669); // emerald-600
  static const Color warningYellow = Color(0xFFF59E0B); // yellow-500

  // Nuovo colore per bordi chiari
  static const Color borderLight = Color(0xFFE5E7EB); // grigio chiaro coerente

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryPurple,
      surface: cardWhite,
      background: backgroundGray,
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textDark,
      onBackground: textDark,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 8,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFamily: 'Inter',
      ),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      shadowColor: Colors.black12,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorRed),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(
        color: textMedium,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textDark,
        fontFamily: 'Inter',
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textDark,
        fontFamily: 'Inter',
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
        fontFamily: 'Inter',
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
        fontFamily: 'Inter',
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDark,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textMedium,
        fontFamily: 'Inter',
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textLight,
        fontFamily: 'Inter',
      ),
    ),
  );

  static ThemeData darkTheme = lightTheme.copyWith(
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryPurple,
      surface: Color(0xFF1F2937),
      background: Color(0xFF111827),
      error: errorRed,
    ),
  );

  // Gradient decorations per ricreare gli effetti CSS originali
  static const LinearGradient blueIndigoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryIndigo],
  );

  static const LinearGradient purpleBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryPurple, secondaryBlue],
  );
}