import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/review.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'venue_identity_v2.dart';
import 'venue_quick_actions_v2.dart';
import 'experts_section_v2.dart';
import 'working_hours_card_v2.dart';
import 'map_preview_v2.dart';
import 'trust_badges_grid_v2.dart';
import 'reviews_preview_v2.dart';
import 'gallery_section_v2.dart';

class VenueOverviewV2 extends StatelessWidget {
  final Venue venue;
  final List<Review> reviews;
  final VoidCallback onSeeAll;

  const VenueOverviewV2({
    super.key,
    required this.venue,
    required this.reviews,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 1. Identity Section (Name, Rating, Follow Button)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: VenueIdentityV2(venue: venue),
        ),
        const SizedBox(height: 20),

        // 2. Quick Actions Section (WhatsApp, Call, Directions, Instagram)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: VenueQuickActionsV2(venue: venue),
        ),
        const SizedBox(height: 24),

        // Divider
        const Divider(color: AppColors.nude, height: 1, thickness: 1),
        const SizedBox(height: 24),

        // 3. About Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildAboutSection(),
        ),
        const SizedBox(height: 24),

        // 4. Experts Section
        ExpertsSectionV2(venue: venue),
        const SizedBox(height: 16),

        // Grey Spacer
        Container(height: 8, color: AppColors.nude.withOpacity(0.3)),
        const SizedBox(height: 24),

        // 5. Working Hours & Map Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              WorkingHoursCardV2(venue: venue),
              const SizedBox(height: 16),
              MapPreviewV2(venue: venue),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grey Spacer
        Container(height: 8, color: AppColors.nude.withOpacity(0.3)),
        const SizedBox(height: 24),

        // 6. Social Proof (Certificates & Features are combined in TrustBadgesGridV2)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TrustBadgesGridV2(venue: venue),
        ),
        const SizedBox(height: 16),

        // Grey Spacer
        Container(height: 8, color: AppColors.nude.withOpacity(0.3)),
        const SizedBox(height: 24),

        // 7. Reviews Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ReviewsPreviewV2(
            venue: venue,
            reviews: reviews,
            onSeeAll: onSeeAll,
          ),
        ),

        // Adding bottom padding for the fixed bar
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
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
                text: venue.description ??
                    'Bu mekan hakkında henüz detaylı bilgi eklenmemiştir. Daha fazla bilgi almak için iletişime geçebilirsiniz.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray600,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
              if ((venue.description?.length ?? 0) > 150)
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
    );
  }
}
