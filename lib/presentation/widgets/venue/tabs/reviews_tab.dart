import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../providers/review_submission_provider.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../review/rating_distribution_chart.dart';
import '../../review/review_submission_bottom_sheet.dart';
import '../../review/edit_review_bottom_sheet.dart';
import '../components/review_card.dart';
import '../../common/empty_state.dart';

class ReviewsTab extends StatelessWidget {
  final String venueId;

  const ReviewsTab({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.instance.currentUser?.id;

    return Consumer2<VenueDetailsProvider, ReviewSubmissionProvider>(
      builder: (context, provider, submissionProvider, child) {
        if (provider.isLoading && provider.reviews.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (provider.error != null && provider.reviews.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Hata Oluştu',
              message: 'Değerlendirmeler yüklenirken bir sorun oluştu.',
              actionLabel: 'Tekrar Dene',
              onAction: () => provider.refreshReviews(),
            ),
          );
        }

        final bool hasReviews = provider.reviews.isNotEmpty;
        final bool userHasReview = provider.reviews.any(
          (r) => r.userId == currentUserId,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            // Rating Summary & Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.gray200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Big Rating Number
                      Column(
                        children: [
                          Text(
                            provider.venue?.rating.toStringAsFixed(1) ?? '0.0',
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < (provider.venue?.rating ?? 0).round()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: AppColors.gold,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.venue?.ratingCount ?? 0} yorum',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      // Distribution Chart
                      Expanded(
                        child: RatingDistributionChart(
                          reviews: provider.reviews,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // CTA Button
                  ElevatedButton(
                    onPressed: () => _handleReviewAction(context, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      userHasReview
                          ? 'Değerlendirmenizi Düzenleyin'
                          : 'Değerlendirme Yap',
                      style: AppTextStyles.button,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (!hasReviews)
              EmptyState(
                icon: Icons.rate_review_outlined,
                title: 'Henüz değerlendirme yok',
                message: 'Bu mekan için ilk değerlendirmeyi siz yapın!',
                actionLabel: 'Değerlendirme Yap',
                onAction: () => _handleReviewAction(context, provider),
              )
            else ...[
              Text('Tüm Değerlendirmeler', style: AppTextStyles.heading4),
              const SizedBox(height: 16),
              // Reviews List (Own review first)
              ..._buildReviewList(context, provider, currentUserId),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildReviewList(
    BuildContext context,
    VenueDetailsProvider provider,
    String? currentUserId,
  ) {
    final List<Widget> list = [];

    // Sort reviews to show own review first
    final sortedReviews = List.of(provider.reviews);
    sortedReviews.sort((a, b) {
      if (a.userId == currentUserId) return -1;
      if (b.userId == currentUserId) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    for (var review in sortedReviews) {
      final isOwn = review.userId == currentUserId;
      list.add(
        ReviewCard(
          review: review,
          isOwnReview: isOwn,
          onEdit: isOwn ? () => _handleReviewAction(context, provider) : null,
        ),
      );
    }

    return list;
  }

  void _handleReviewAction(
    BuildContext context,
    VenueDetailsProvider provider,
  ) async {
    final currentUserId = SupabaseService.instance.currentUser?.id;

    if (currentUserId == null) {
      final currentPath = GoRouterState.of(context).uri.toString();
      await context.push('/login?redirect=${Uri.encodeComponent(currentPath)}');
      return;
    }

    final submissionProvider = context.read<ReviewSubmissionProvider>();
    await submissionProvider.checkExistingReview(venueId);

    if (context.mounted) {
      if (submissionProvider.isEditing) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => EditReviewBottomSheet(
            venueId: venueId,
            venueName: provider.venue?.name ?? '',
          ),
        );
      } else {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ReviewSubmissionBottomSheet(
            venueId: venueId,
            venueName: provider.venue?.name ?? '',
          ),
        );
      }
    }
  }
}
