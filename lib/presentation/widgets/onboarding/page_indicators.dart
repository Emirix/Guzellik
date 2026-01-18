import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated page indicators for onboarding
class OnboardingPageIndicators extends StatelessWidget {
  final int totalPages;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;

  const OnboardingPageIndicators({
    super.key,
    required this.totalPages,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? (activeColor ?? AppColors.primary)
                : (inactiveColor ?? AppColors.primary.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
