import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Bottom sheet explaining notification permissions when user first follows a venue
class FollowInfoBottomSheet extends StatelessWidget {
  const FollowInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Bildirimleri Açın',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            'Takip ettiğiniz mekanlardan kampanya, indirim ve özel fırsatlar hakkında bildirim alabilirsiniz.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Benefits list
          _buildBenefit(
            icon: Icons.campaign_outlined,
            text: 'Özel kampanyalardan ilk siz haberdar olun',
          ),
          const SizedBox(height: 12),
          _buildBenefit(
            icon: Icons.discount_outlined,
            text: 'Size özel indirim ve fırsatları kaçırmayın',
          ),
          const SizedBox(height: 12),
          _buildBenefit(
            icon: Icons.star_outline,
            text: 'Yeni hizmet ve etkinliklerden haberdar olun',
          ),

          const SizedBox(height: 28),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Anladım',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Skip button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gray600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Şimdi Değil',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildBenefit({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Show the bottom sheet and return whether user wants to enable notifications
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FollowInfoBottomSheet(),
    );
    return result ?? false;
  }
}
