import 'package:flutter/material.dart';

class AppTheme {
  // 🌞 LIGHT THEME
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4CAF50),      // Green
      secondary: Color(0xFF8BC34A),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),

    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 3,
      centerTitle: true,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    cardColor: Colors.white,
  );

  // 🌚 DARK THEME
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00E676),     // Neon green
      secondary: Color(0xFF1B5E20),
      surface: Color(0xFF1A1A1A),
      onPrimary: Colors.black,
    ),

    scaffoldBackgroundColor: const Color(0xFF0D0D0D),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00E676),
      foregroundColor: Colors.black,
      elevation: 3,
      centerTitle: true,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00E676),
      foregroundColor: Colors.black,
      elevation: 8,
    ),

    cardColor: Color(0xFF1E1E1E),
  );
}
