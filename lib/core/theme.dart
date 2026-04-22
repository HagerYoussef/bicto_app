import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryLight = Colors.white;
  static const Color secondaryLight = Color(0xFFF8FAFC);
  static const Color textMainLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color primaryDark = Color(0xFF0F172A);
  static const Color secondaryDark = Color(0xFF1E293B);
  static const Color textMainDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color errorColor = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: blueAccent,
      scaffoldBackgroundColor: primaryLight,
      colorScheme: const ColorScheme.light(
        primary: blueAccent,
        secondary: blueAccent,
        surface: primaryLight,
        error: errorColor,
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: textMainLight),
        displayMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: textMainLight),
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: textMainLight),
        bodyLarge: GoogleFonts.cairo(color: textMainLight),
        bodyMedium: GoogleFonts.cairo(color: textSecondaryLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textMainLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textMainLight),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: blueAccent,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: blueAccent,
        secondary: blueAccent,
        surface: secondaryDark,
        error: errorColor,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: textMainDark),
        displayMedium: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: textMainDark),
        titleLarge: GoogleFonts.cairo(fontWeight: FontWeight.w600, color: textMainDark),
        bodyLarge: GoogleFonts.cairo(color: textMainDark),
        bodyMedium: GoogleFonts.cairo(color: textSecondaryDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textMainDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textMainDark),
      ),
      cardTheme: CardThemeData(
        color: secondaryDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
