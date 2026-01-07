import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TrustBadgesGridV2 extends StatelessWidget {
  final Venue venue;

  const TrustBadgesGridV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          childAspectRatio: 2.2,
          children: [
            _buildBadgeCard(
              icon: Icons.verified,
              title: 'Sağlık Bakanlığı',
              subtitle: 'Onaylı Merkez',
            ),
            _buildBadgeCard(
              icon: Icons.workspace_premium,
              title: 'ISO 9001',
              subtitle: 'Kalite Belgesi',
            ),
          ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nude),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 30),
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
                    fontSize: 11,
                    color: AppColors.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
}
