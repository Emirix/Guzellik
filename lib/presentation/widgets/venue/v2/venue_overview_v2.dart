import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'venue_identity_v2.dart';
import 'venue_quick_actions_v2.dart';
import 'experts_section_v2.dart';
import 'working_hours_card_v2.dart';
import 'map_preview_v2.dart';
import 'trust_badges_grid_v2.dart';
import 'features_grid_v2.dart';
import 'reviews_preview_v2.dart';

class VenueOverviewV2 extends StatelessWidget {
  final Venue venue;

  const VenueOverviewV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        // 1. Identity Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: VenueIdentityV2(venue: venue),
        ),
        const SizedBox(height: 24),

        // 2. Quick Actions Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: VenueQuickActionsV2(venue: venue),
        ),
        const SizedBox(height: 32),

        // Divider
        const Divider(color: AppColors.nude, height: 1),
        const SizedBox(height: 24),

        // 3. About Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mekan Hakkında',
                style: AppTextStyles.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          venue.description ??
                          'Lina Estetik, 10 yılı aşkın tecrübesiyle güzelliğinize güzellik katmak için hizmetinizde. Son teknoloji cihazlarımız ve uzman kadromuz...',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.gray600,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text: ' Devamını Oku',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // 4. Experts Section
        ExpertsSectionV2(venue: venue),
        const SizedBox(height: 24),

        // Grey Spacer
        Container(height: 8, color: AppColors.nude.withOpacity(0.3)),
        const SizedBox(height: 24),

        // 5. Working Hours & Map Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              WorkingHoursCardV2(venue: venue),
              const SizedBox(height: 12),
              MapPreviewV2(venue: venue),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Grey Spacer
        Container(height: 8, color: AppColors.nude.withOpacity(0.3)),
        const SizedBox(height: 24),

        // 6. Social Proof (Certificates & Features)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TrustBadgesGridV2(venue: venue),
              const SizedBox(height: 32),
              FeaturesGridV2(venue: venue),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Grey Spacer
        Container(height: 8, color: AppColors.nude.withOpacity(0.3)),
        const SizedBox(height: 24),

        // 7. Reviews Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ReviewsPreviewV2(venue: venue),
        ),

        // Adding bottom padding for the fixed bar
        const SizedBox(height: 100),
      ],
    );
  }
}
