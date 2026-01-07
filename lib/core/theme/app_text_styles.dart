import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles for the beauty services platform
/// Based on design specifications using Manrope font family
class AppTextStyles {
  // Headings (using Manrope/Outfit style)
  static TextStyle heading1 = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    letterSpacing: -0.3,
  );

  static TextStyle heading3 = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static TextStyle heading4 = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // Subtitles
  static TextStyle subtitle1 = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.gray700,
  );

  static TextStyle subtitle2 = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.gray600,
  );

  // Body Text (using Inter style)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray700,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray600,
    height: 1.4,
  );

  // Caption
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
  );

  // Button Text
  static TextStyle button = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle buttonLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Label
  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.gray600,
  );

  // Overline (small uppercase text)
  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.gray500,
    letterSpacing: 1.5,
  );

  // Private constructor to prevent instantiation
  AppTextStyles._();
}
