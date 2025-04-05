import 'package:flutter/material.dart';

class AppTheme {
  // Football-inspired color palette
  static const Color primaryColor = Color(0xFF0A3D62); // Deep blue
  static const Color secondaryColor = Color(0xFF3C6382); // Medium blue
  static const Color accentColor = Color(0xFF60A3BC); // Light blue
  static const Color bgColor = Color(0xFFF5F5F5); // Light background
  static const Color cardColor = Colors.white; // Card background
  static const Color highlightColor = Color(0xFFF6B93B); // Yellow highlight
  static const Color dangerColor = Color(0xFFE55039); // Error/loss color
  static const Color successColor = Color(0xFF78E08F); // Success/win color
  static const Color textDarkColor = Color(0xFF2C3A47); // Primary text
  static const Color textLightColor = Color(0xFF7F8C8D); // Secondary text

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: dangerColor,
      surface: cardColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: primaryColor.withOpacity(0.1),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textDarkColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineMedium: TextStyle(
        color: textDarkColor,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: textDarkColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: textDarkColor,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        color: textDarkColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textDarkColor,
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    iconTheme: const IconThemeData(
      color: secondaryColor,
    ),
  );
}