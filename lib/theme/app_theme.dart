import 'package:flutter/material.dart';

class AppTheme {
  // 🔹 CORE COLOR PALETTE (same across light/dark)
  static const Color accentBlue = Color(0xFF4CC9F0);
  static const Color accentRed = Color(0xFFFF595E);
  static const Color accentYellow = Color(0xFFFFCA3A);
  static const Color accentGreen = Color(0xFF8AC926);

  static const Color darkBg = Color(0xFF0D1B2A);
  static const Color darkCard = Color(0xFF1B263B);
  static const Color darkSurface = Color(0xFF223040);

  static const Color lightBg = Color(0xFFF5F5F5);
  static const Color lightCard = Colors.white;

  // ------------------------------------------------------------
  // 🌞 LIGHT THEME
  // ------------------------------------------------------------
  static final lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,

  scaffoldBackgroundColor: const Color(0xFFF2F4F7),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF3A86FF),
    secondary: Color(0xFF4CC9F0),
    surface: Colors.white,
    onSurface: Color(0xFF1F2937),
    onPrimary: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF2F4F7),
    foregroundColor: Color(0xFF1F2937),
    elevation: 0,
    centerTitle: true,
  ),

  cardColor: Colors.white,

  cardTheme: CardThemeData(
    elevation: 3,
    shadowColor: Color(0x33000000), // 20% black shadow
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: TextStyle(color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFCCD1D5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFFCCD1D5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(color: Color(0xFF3A86FF), width: 2),
    ),
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF1F2937),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3A86FF),
    foregroundColor: Colors.white,
    elevation: 6,
  ),
);

  // ------------------------------------------------------------
  // 🌚 DARK THEME (Matches your new premium UI)
  // ------------------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor: darkBg,
    cardColor: darkCard,
    dialogBackgroundColor: darkCard,

    colorScheme: ColorScheme.dark(
      primary: accentBlue,
      secondary: accentGreen,
      background: darkBg,
      surface: darkCard,
      onPrimary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white70,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentBlue,
      foregroundColor: Colors.black,
      elevation: 10,
      shape: CircleBorder(),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentBlue,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    dialogTheme: const DialogThemeData(surfaceTintColor: Colors.transparent),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accentBlue, width: 1.5),
      ),
      labelStyle: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
