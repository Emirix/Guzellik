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

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.5)),
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
