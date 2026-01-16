import 'package:flutter/material.dart';

/// Color palette for the beauty services platform
/// Updated based on design specifications
class AppColors {
  // Primary Color (Vibrant Pink/Rouge) - From Design V2
  static const Color primary = Color(0xFFEE2B5B);
  static const Color primaryLight = Color(0xFFFFEAF3);
  static const Color primaryDark = Color(0xFFD4316D);

  // Secondary (Muted Rose/Sand)
  static const Color secondary = Color(0xFF9A4C5F);

  // Nude Palette - From Design V2
  static const Color nude = Color(0xFFF3E7EA);
  static const Color nudeDark = Color(0xFFF3E7EA); // Keep for compatibility
  static const Color nudeLight = Color(0xFFFCF8F9);
  static const Color backgroundLight = Color(0xFFFFF9FA);
  static const Color backgroundDark = Color(0xFF221015);

  // Gold Accent (Premium)
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE5C158);
  static const Color goldDark = Color(0xFFB8941F);

  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFFAFAFA);

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
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);

  // Avatar Background Colors (Gender-based)
  /// Light blue background for male specialist avatars without photos
  static const Color avatarMale = Color(0xFFE3F2FD);

  /// Light pink background for female specialist avatars without photos
  /// Matches primaryLight for theme consistency
  static const Color avatarFemale = Color(0xFFFFEAF3);

  /// Neutral gray background for specialists with unknown/unspecified gender
  /// Matches gray100 for theme consistency
  static const Color avatarNeutral = Color(0xFFF5F5F5);

  // Shadows
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Design Palette (from design files)
  static const Color softPink = Color(0xFFFFB6C1);
  static const Color lightGray = Color(0xFFFAFAFA);

  // Gradients for backward compatibility and splash
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFFC9D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Hero overlay gradient (for venue details)
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x8A000000)],
  );

  // Dark Mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);

  // Trust Badge Colors (for backward compatibility)
  static const Color verifiedBadge = Color(0xFF4CAF50);
  static const Color popularBadge = Color(0xFFD4AF37);
  static const Color hygieneBadge = Color(0xFF2196F3);

  // Private constructor to prevent instantiation
  AppColors._();
}
