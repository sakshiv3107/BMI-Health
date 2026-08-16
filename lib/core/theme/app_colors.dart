import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDarkMode = false;

  // Primary / Accent colors
  static const Color primary = Color(0xFF0F6E5C); // Deep teal
  static const Color primaryAccent = Color(0xFF0D8A6E); // BMI value teal
  static Color get primaryLight => isDarkMode ? const Color(0xFF163E36) : const Color(0xFFE6F3F0); // Light teal/emerald tint

  // Backgrounds & Surfaces
  static Color get background => isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F6F7); // Very light gray background
  static Color get cardBg => isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF); // White card background
  static Color get fillLight => isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6); // Light gray fill for inputs

  // Text colors
  static Color get textPrimary => isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A); // Dark charcoal for headings
  static Color get textSecondary => isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280); // Gray for subtext

  // Indicator & Status colors
  static const Color success = Color(0xFF0F6E5C); // Teal green success
  static const Color warning = Color(0xFFE53935); // Red warning/error
  static const Color warningAmber = Color(0xFFD97706); // Warm amber for underweight/overweight
  static const Color obeseRed = Color(0xFFE53935); // Pure red for obese

  static Color getBmiColor(double bmi) {
    if (bmi < 18.5) return warningAmber;
    if (bmi < 25.0) return success;
    if (bmi < 30.0) return warningAmber;
    return obeseRed;
  }

  static Color getBmiCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('underweight') || cat.contains('overweight')) {
      return warningAmber;
    }
    if (cat.contains('normal')) {
      return success;
    }
    if (cat.contains('obese')) {
      return obeseRed;
    }
    return success;
  }

  // Bottom Navigation
  static const Color navActive = Color(0xFF0F6E5C);
  static const Color navInactive = Color(0xFF9CA3AF);
  static Color get borderLight => isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB);
}

