import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/venue_feature.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TrustBadgesGridV2 extends StatelessWidget {
  final Venue venue;
  final List<VenueFeature>? features;

  const TrustBadgesGridV2({super.key, required this.venue, this.features});

  @override
  Widget build(BuildContext context) {
    // Priority: 1. Passed VenueFeature objects, 2. Venue slugs, 3. Default features
    final List<String> displayFeatures;

    if (features != null && features!.isNotEmpty) {
      displayFeatures = features!.map((f) => f.name).toList();
    } else if (venue.features.isNotEmpty) {
      displayFeatures = venue.features;
    } else {
      displayFeatures = [
        'Ücretsiz Wi-Fi',
        'Engelli Uygun',
        'Otopark',
        'Kredi Kartı',
      ];
    }

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
        // Features Section (İşletme Özellikleri)
        Text(
          'İşletme Özellikleri',
          style: AppTextStyles.heading4.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: displayFeatures
              .map((feature) => _buildFeatureChip(feature))
              .toList(),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.gray700,
        ),
      ),
    );
  }
}
