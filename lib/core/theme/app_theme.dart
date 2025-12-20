import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: MiniDehaColors.primary,
      scaffoldBackgroundColor: MiniDehaColors.background,
      
      // Define Text Theme using Google Fonts (Quicksand as requested)
      textTheme: GoogleFonts.quicksandTextTheme().copyWith(
        displayLarge: TextStyle(
          color: MiniDehaColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: TextStyle(
          color: MiniDehaColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: MiniDehaColors.textSecondary,
          fontSize: 14,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: MiniDehaColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: MiniDehaColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.quicksand(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: MiniDehaColors.accent),
    );
  }
}
