import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Matching the design exactly
  static const Color primaryBlue = Color(0xFF2B4CFF);
  static const Color lightBlue = Color(0xFF4F78FF);
  static const Color backgroundGray = Color(0xFFF5F7FA);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);

  // Balance Status Colors
  static const Color balancePositive = Color(
    0xFF22C55E,
  ); // Green for positive balance
  static const Color balanceNegative = Color(
    0xFFEF4444,
  ); // Red for negative balance
  static const Color balanceAverage = Color(
    0xFF3B82F6,
  ); // Blue for average (around 5000)
  static const Color balanceNeutral = Color(
    0xFF6B7280,
  ); // Gray for zero/neutral

  // Category Colors - From the design
  static const Color groceryBlue = Color(0xFF3B82F6);
  static const Color entertainmentOrange = Color(0xFFFF8B66);
  static const Color transportPurple = Color(0xFF8B5CF6);
  static const Color rentGreen = Color(0xFF10B981);
  static const Color shoppingYellow = Color(0xFFFFB946);

  static final TextTheme textTheme = TextTheme(
    headlineLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: cardWhite,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: textDark,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textDark,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textMedium,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: cardWhite,
    ),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundGray,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: cardWhite,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cardWhite,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: cardWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: backgroundGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: backgroundGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  // Helper method to get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
      case 'food':
        return groceryBlue;
      case 'entertainment':
        return entertainmentOrange;
      case 'transportation':
      case 'transport':
        return transportPurple;
      case 'rent':
      case 'housing':
        return rentGreen;
      case 'shopping':
        return shoppingYellow;
      default:
        return primaryBlue;
    }
  }

  // Helper method to get category icon
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
      case 'food':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      case 'transportation':
      case 'transport':
        return Icons.directions_car;
      case 'rent':
      case 'housing':
        return Icons.home;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }
}
