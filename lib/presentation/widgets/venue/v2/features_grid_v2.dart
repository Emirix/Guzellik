import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FeaturesGridV2 extends StatelessWidget {
  final Venue venue;

  const FeaturesGridV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final features = venue.features.isNotEmpty
        ? venue.features
        : ['Ücretsiz Wi-Fi', 'Engelli Uygun', 'Otopark', 'Kredi Kartı'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: features
              .map((feature) => _buildFeatureChip(feature))
              .toList(),
        ),
      ],
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
        color: AppColors.nude.withValues(alpha: 0.5),
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
