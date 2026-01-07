import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../components/review_card.dart';

class ReviewsTab extends StatelessWidget {
  final String venueId;

  const ReviewsTab({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<VenueDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 64,
                  color: AppColors.gray300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz değerlendirme yok',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate average rating
        double avgRating = 0;
        if (provider.reviews.isNotEmpty) {
          avgRating =
              provider.reviews.map((r) => r.rating).reduce((a, b) => a + b) /
              provider.reviews.length;
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Summary Header
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < avgRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.primary,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.reviews.length} değerlendirme',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Reviews List
            ...provider.reviews.map((review) => ReviewCard(review: review)),
          ],
        );
      },
    );
  }
}
