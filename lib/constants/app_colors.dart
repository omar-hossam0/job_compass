import 'package:flutter/material.dart';

class AppColors {
  // Gradient colors (similar to the provided images)
  static const gradientStart = Color(0xFFE8F1FF);
  static const gradientMiddle = Color(0xFFCBDCFF);
  static const gradientEnd = Color(0xFFA7C2FF);

  // Primary colors (shifted to blue palette)
  static const primaryGreen = Color(0xFF3566F6); // renamed palette, keep identifier for compatibility
  static const primaryBlue = Color(0xFF1D4ED8);
  static const primaryTeal = Color(0xFF6EA0FF);
  static const secondaryBlue = Color(0xFF4299E1);
  static const accentGold = Color(0xFFD4A574);

  // Text colors
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  static const textLight = Color(0xFFFFFFFF);

  // Background colors
  static const cardBackground = Color(0xFFFFFFFF);
  static const cardBackgroundLight = Color(0xFFF7FAFC);

  // Status colors
  static const success = Color(0xFF1FB6FF);
  static const warning = Color(0xFFED8936);
  static const error = Color(0xFFF56565);
  static const info = Color(0xFF4299E1);

  // Glassmorphic overlay
  static const glassWhite = Color(0x40FFFFFF);
  static const glassWhiteStrong = Color(0x60FFFFFF);

  // Gradients
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE0F2FF), Color(0xFFB3CCFF)],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  );
}
