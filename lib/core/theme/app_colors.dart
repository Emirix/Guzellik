import 'package:flutter/material.dart';

/// Color palette for the beauty services platform
/// Primary colors: Nude, Soft Pink, Cream
/// Accent: Gold (premium feel)
/// Base: White (cleanliness + trust)
class AppColors {
  // Primary Colors - Nude Palette
  static const Color nude = Color(0xFFE8D5C4);
  static const Color nudeLight = Color(0xFFF5EBE0);
  static const Color nudeDark = Color(0xFFD4B5A0);
  
  // Soft Pink Palette
  static const Color softPink = Color(0xFFFFC9D9);
  static const Color softPinkLight = Color(0xFFFFE4EC);
  static const Color softPinkDark = Color(0xFFFFB0C6);
  
  // Cream Palette
  static const Color cream = Color(0xFFFFFBF5);
  static const Color creamLight = Color(0xFFFFFEFA);
  static const Color creamDark = Color(0xFFF5F0E8);
  
  // Gold Accent (Premium)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE5C158);
  static const Color goldDark = Color(0xFFB8941F);
  
  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color offWhite = Color(0xFFFAFAFA);
  
  // Neutral Grays
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  
  static const Color error = Color(0xFFE57373);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color errorDark = Color(0xFFD32F2F);
  
  static const Color warning = Color(0xFFFFB74D);
  static const Color warningLight = Color(0xFFFFCC80);
  static const Color warningDark = Color(0xFFF57C00);
  
  static const Color info = Color(0xFF64B5F6);
  static const Color infoLight = Color(0xFF90CAF9);
  static const Color infoDark = Color(0xFF1976D2);
  
  // Trust Badge Colors
  static const Color verifiedBadge = Color(0xFF4CAF50);
  static const Color popularBadge = Color(0xFFD4AF37);
  static const Color hygieneBadge = Color(0xFF2196F3);
  
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [nude, softPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient creamGradient = LinearGradient(
    colors: [cream, creamDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadow Colors
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  
  // Overlay Colors
  static const Color overlayLight = Color(0x0DFFFFFF);
  static const Color overlayMedium = Color(0x33FFFFFF);
  static const Color overlayDark = Color(0x66000000);
  
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  
  // Private constructor to prevent instantiation
  AppColors._();
}
