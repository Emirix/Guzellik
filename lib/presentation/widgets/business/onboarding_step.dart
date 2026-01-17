import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A single step in the business onboarding carousel
/// Displays an icon, title, and description
class OnboardingStep extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final Gradient? gradient;

  const OnboardingStep({
    super.key,
    required this.title,
    required this.description,
    required this.iconData,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradient = LinearGradient(
      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: gradient ?? defaultGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(iconData, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B0E11),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B6B6B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
