import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';

/// Content for the sixth onboarding screen: Favorites & Social
class FavoritesOnboardingContent extends StatelessWidget {
  const FavoritesOnboardingContent({super.key});

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
                'assets/animations/favorites.json',
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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background decorative circles
        ...List.generate(3, (index) => _buildPulseCircle(index)),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating Heart with Glow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 48),

            // Sample Favorite Cards Mockup
            _buildFavoriteItem('Güzellik Vadisi', 'Beşiktaş, İstanbul'),
            const SizedBox(height: 12),
            _buildFavoriteItem('Harmony Spa', 'Kadıköy, İstanbul'),
          ],
        ),
      ],
    );
  }

  Widget _buildPulseCircle(int index) {
    return Container(
      width: 150.0 + (index * 50),
      height: 150.0 + (index * 50),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1 / (index + 1)),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildFavoriteItem(String name, String location) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(fontSize: 9, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.favorite_rounded,
            color: AppColors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
