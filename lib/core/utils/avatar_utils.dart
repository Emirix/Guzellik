import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Utilities for avatar rendering and customization
class AvatarUtils {
  /// Returns the appropriate background color for a specialist avatar
  /// based on their gender.
  ///
  /// Supports multiple gender formats:
  /// - Male: "male", "m", "erkek", "e" (case-insensitive)
  /// - Female: "female", "f", "kadın", "k" (case-insensitive)
  /// - Unknown/Null: Returns neutral gray
  ///
  /// Example:
  /// ```dart
  /// final color = AvatarUtils.getAvatarBackgroundColor(specialist.gender);
  /// Container(color: color, child: Icon(Icons.person))
  /// ```
  static Color getAvatarBackgroundColor(String? gender) {
    if (gender == null || gender.isEmpty) {
      return AppColors.avatarNeutral;
    }

    final normalizedGender = gender.toLowerCase().trim();

    // Male variants
    if (normalizedGender == 'male' ||
        normalizedGender == 'm' ||
        normalizedGender == 'erkek' ||
        normalizedGender == 'e') {
      return AppColors.avatarMale;
    }

    // Female variants
    if (normalizedGender == 'female' ||
        normalizedGender == 'f' ||
        normalizedGender == 'kadın' ||
        normalizedGender == 'k') {
      return AppColors.avatarFemale;
    }

    // Unknown/unrecognized gender
    return AppColors.avatarNeutral;
  }

  /// Returns the appropriate icon color for a specialist avatar
  /// based on their gender.
  static Color getAvatarIconColor(String? gender) {
    if (gender == null || gender.isEmpty) {
      return AppColors.avatarNeutralIcon;
    }

    final normalizedGender = gender.toLowerCase().trim();

    // Male variants
    if (normalizedGender == 'male' ||
        normalizedGender == 'm' ||
        normalizedGender == 'erkek' ||
        normalizedGender == 'e') {
      return AppColors.avatarMaleIcon;
    }

    // Female variants
    if (normalizedGender == 'female' ||
        normalizedGender == 'f' ||
        normalizedGender == 'kadın' ||
        normalizedGender == 'k') {
      return AppColors.avatarFemaleIcon;
    }

    // Unknown/unrecognized gender
    return AppColors.avatarNeutralIcon;
  }

  // Private constructor to prevent instantiation
  AvatarUtils._();
}
