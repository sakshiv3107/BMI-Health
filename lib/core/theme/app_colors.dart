import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary / Accent colors
  static const Color primary = Color(0xFF0F6E5C); // Deep teal
  static const Color primaryAccent = Color(0xFF0D8A6E); // BMI value teal
  static const Color primaryLight = Color(0xFFE6F3F0); // Light teal/emerald tint

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF5F6F7); // Very light gray background
  static const Color cardBg = Color(0xFFFFFFFF); // White card background
  static const Color fillLight = Color(0xFFF3F4F6); // Light gray fill for inputs

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Dark charcoal for headings
  static const Color textSecondary = Color(0xFF6B7280); // Gray for subtext

  // Indicator & Status colors
  static const Color success = Color(0xFF0F6E5C); // Teal green success
  static const Color warning = Color(0xFFE53935); // Red warning/overweight

  // Bottom Navigation
  static const Color navActive = Color(0xFF0F6E5C);
  static const Color navInactive = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
}
