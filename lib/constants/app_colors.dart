import 'package:flutter/material.dart';

class AppColors {
  // Gradient colors (similar to the provided images)
  static const gradientStart = Color(0xFFB8E6D5);
  static const gradientMiddle = Color(0xFFD4E8E0);
  static const gradientEnd = Color(0xFFF5E6D3);

  // Primary colors
  static const primaryGreen = Color(0xFF5A9B8A);
  static const primaryTeal = Color(0xFF6BA89F);
  static const accentGold = Color(0xFFD4A574);

  // Text colors
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  static const textLight = Color(0xFFFFFFFF);

  // Background colors
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardBackgroundLight = Color(0xFFF7FAFC);

  // Status colors
  static const success = Color(0xFF48BB78);
  static const warning = Color(0xFFED8936);
  static const error = Color(0xFFF56565);
  static const info = Color(0xFF4299E1);

  // Glassmorphic overlay
  static const glassWhite = Color(0x40FFFFFF);
  static const glassWhiteStrong = Color(0x60FFFFFF);

  // Gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  );
}
