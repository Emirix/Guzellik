import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/review.dart';
import '../../../../data/models/specialist.dart';
import '../../../../core/theme/app_colors.dart';
import 'venue_identity_v2.dart';
import 'venue_quick_actions_v2.dart';
import 'experts_section_v2.dart';
import 'working_hours_card_v2.dart';
import 'map_preview_v2.dart';
import 'trust_badges_grid_v2.dart';
import 'reviews_preview_v2.dart';

class VenueOverviewV2 extends StatelessWidget {
  final Venue venue;
  final List<Review> reviews;
  final List<Specialist> specialists;
  final VoidCallback onSeeAll;

  const VenueOverviewV2({
    super.key,
    required this.venue,
    required this.reviews,
    required this.specialists,
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

        // 3. Experts Section
        ExpertsSectionV2(venue: venue, specialists: specialists),
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
}
