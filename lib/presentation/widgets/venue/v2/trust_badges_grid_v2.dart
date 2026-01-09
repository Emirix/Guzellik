import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TrustBadgesGridV2 extends StatelessWidget {
  final Venue venue;

  const TrustBadgesGridV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    // Get features from venue or use defaults
    final features = venue.features.isNotEmpty
        ? venue.features
        : ['Ücretsiz Wi-Fi', 'Engelli Uygun', 'Otopark', 'Kredi Kartı'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Certificates & Awards Section
        Text(
          'Sertifikalar & Ödüller',
          style: AppTextStyles.heading4.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: [
            _buildBadgeCard(
              icon: Icons.verified_rounded,
              title: 'Sağlık Bakanlığı',
              subtitle: 'Onaylı Merkez',
            ),
            _buildBadgeCard(
              icon: Icons.workspace_premium_rounded,
              title: 'ISO 9001',
              subtitle: 'Kalite Belgesi',
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Features Section (Özellikler)
        Text(
          'Özellikler',
          style: AppTextStyles.heading4.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((feature) => _buildFeatureChip(feature)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nude),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    IconData icon;
    switch (label.toLowerCase()) {
      case 'ücretsiz wi-fi':
      case 'wi-fi':
        icon = Icons.wifi;
        break;
      case 'engelli uygun':
      case 'accessible':
        icon = Icons.accessible;
        break;
      case 'otopark':
      case 'parking':
        icon = Icons.local_parking;
        break;
      case 'kredi kartı':
      case 'credit card':
        icon = Icons.credit_card;
        break;
      default:
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.nude.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
