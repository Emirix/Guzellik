import 'package:flutter/material.dart';
import '../../../data/models/venue.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../common/trust_badge.dart';
import 'package:share_plus/share_plus.dart';

class VenueHero extends StatelessWidget {
  final Venue venue;

  const VenueHero({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.gray900),
              onPressed: () {
                Share.share(
                  '${venue.name}\n${venue.address}\n\nDaima uygulamasında keşfet!',
                  subject: venue.name,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(
                Icons.favorite_outline,
                color: AppColors.gray900,
              ),
              onPressed: () {
                // Favorite logic
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gallery / main image
            if (venue.imageUrl != null)
              Image.network(venue.imageUrl!, fit: BoxFit.cover)
            else
              Container(
                color: AppColors.gray200,
                child: const Icon(
                  Icons.image,
                  size: 100,
                  color: AppColors.gray400,
                ),
              ),

            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.heroGradient),
            ),

            // Venue Info Overlay
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      if (venue.isVerified)
                        const TrustBadge(
                          type: TrustBadgeType.verified,
                          size: 16,
                        ),
                      if (venue.isPreferred)
                        const TrustBadge(
                          type: TrustBadgeType.popular,
                          size: 16,
                        ),
                      if (venue.isHygienic)
                        const TrustBadge(
                          type: TrustBadgeType.hygiene,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    venue.name,
                    style: AppTextStyles.heading1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
