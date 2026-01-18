import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';

/// Content for the fourth onboarding screen: Filtering & Search
class FilteringOnboardingContent extends StatelessWidget {
  const FilteringOnboardingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Lottie.asset(
                'assets/animations/filtering.json',
                errorBuilder: (context, error, stackTrace) =>
                    _buildMockup(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockup(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Search Bar Mockup
        Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.gray500,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Tırnak Bakımı...',
                style: TextStyle(color: AppColors.gray500, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Category Chips Row 1
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChip('Saç Kesimi', true),
            const SizedBox(width: 8),
            _buildChip('Cilt Bakımı', false),
          ],
        ),
        const SizedBox(height: 8),

        // Category Chips Row 2
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChip('Masaj', false),
            const SizedBox(width: 8),
            _buildChip('Makyaj', true),
            const SizedBox(width: 8),
            _buildChip('Lazer', false),
          ],
        ),

        const SizedBox(height: 32),

        // Filter result preview
        Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                '12 Sonuç Bulundu',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.gray300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.white : AppColors.gray700,
        ),
      ),
    );
  }
}
