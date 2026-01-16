import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/review.dart';
import '../../../../data/models/specialist.dart';
import '../../../../core/theme/app_colors.dart';
import 'experts_section_v2.dart';
import 'working_hours_card_v2.dart';
import 'map_preview_v2.dart';
import 'trust_badges_grid_v2.dart';
import 'reviews_preview_v2.dart';
import 'faq_section_v2.dart';
import '../photo_gallery_viewer.dart';
import '../../../providers/venue_details_provider.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/venue_feature.dart';

class VenueOverviewV2 extends StatelessWidget {
  final Venue venue;
  final List<Review> reviews;
  final List<Specialist> specialists;
  final List<VenueFeature> venueFeatures;
  final VoidCallback onSeeAll;

  const VenueOverviewV2({
    super.key,
    required this.venue,
    required this.reviews,
    required this.specialists,
    required this.venueFeatures,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // 1. Identity Section (Now handled by VenueHeroV2)
        const SizedBox(height: 12),

        // About Section
        if (venue.description != null && venue.description!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hakkında',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  venue.description!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Gallery Section
        if (venue.galleryPhotos != null && venue.galleryPhotos!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Galeri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: venue.galleryPhotos!.length > 6
                        ? 6
                        : venue.galleryPhotos!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final photo = venue.galleryPhotos![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoGalleryViewer(
                                photos: venue.galleryPhotos!,
                                initialIndex: index,
                                venueName: venue.name,
                                onLike: (photoId) => context
                                    .read<VenueDetailsProvider>()
                                    .likePhoto(photoId),
                              ),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: photo.url,
                            width: 160,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: AppColors.gray200,
                              highlightColor: AppColors.gray100,
                              child: Container(
                                width: 160,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.gray200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: 160,
                              height: 120,
                              color: AppColors.gray100,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: AppColors.gray400,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Refined Divider
        Container(height: 6, color: AppColors.gray50),
        const SizedBox(height: 24),

        // 3. Experts Section
        ExpertsSectionV2(venue: venue, specialists: specialists),
        const SizedBox(height: 16),

        // Refined Divider
        Container(height: 6, color: AppColors.gray50),
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

        // Refined Divider
        Container(height: 6, color: AppColors.gray50),
        const SizedBox(height: 24),

        // 6. Social Proof (Certificates & Features are combined in TrustBadgesGridV2)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TrustBadgesGridV2(venue: venue, features: venueFeatures),
        ),
        const SizedBox(height: 16),

        // Refined Divider
        Container(height: 6, color: AppColors.gray50),
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
        const SizedBox(height: 16),

        // Refined Divider
        if (venue.faq.isNotEmpty) ...[
          Container(height: 6, color: AppColors.gray50),
          const SizedBox(height: 24),

          // 8. FAQ Section
          FaqSectionV2(faq: venue.faq),
          const SizedBox(height: 16),
        ],

        // Adding bottom padding for the fixed bar
        const SizedBox(height: 120),
      ],
    );
  }
}
