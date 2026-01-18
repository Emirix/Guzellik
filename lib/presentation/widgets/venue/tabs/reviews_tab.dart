import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../providers/review_submission_provider.dart';
import '../../../providers/review_provider.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../review/rating_distribution_chart.dart';
import '../../review/review_submission_bottom_sheet.dart';
import '../../review/edit_review_bottom_sheet.dart';
import '../../review/review_filter_bar.dart';
import '../components/review_card.dart';
import '../../common/empty_state.dart';

class ReviewsTab extends StatefulWidget {
  final String venueId;

  const ReviewsTab({super.key, required this.venueId});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ReviewProvider>().fetchReviews(widget.venueId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.instance.currentUser?.id;

    return Consumer2<VenueDetailsProvider, ReviewSubmissionProvider>(
      builder: (context, venueProvider, submissionProvider, child) {
        if (venueProvider.isLoading && venueProvider.reviews.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        // Global stats from venueProvider (assumed all reviews or summary)
        // If venueProvider.reviews is empty but venue rating count > 0, we might strictly rely on venue object numbers.
        // ratingCount comes from venue object.

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
                            venueProvider.venue?.rating.toStringAsFixed(1) ??
                                '0.0',
                            style: AppTextStyles.heading1.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index <
                                        (venueProvider.venue?.rating ?? 0)
                                            .round()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: AppColors.gold,
                                size: 16,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${venueProvider.venue?.ratingCount ?? 0} yorum',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      // Distribution Chart
                      Expanded(
                        child: RatingDistributionChart(
                          reviews: venueProvider
                              .reviews, // Use global list for chart
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // CTA Button
                  ElevatedButton(
                    onPressed: () =>
                        _handleReviewAction(context, venueProvider),
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
                      // We need to check if user has review.
                      // venueProvider.reviews might not have it if pagination/filtering.
                      // ReviewSubmissionProvider.checkExistingReview checks DB.
                      // For label, we can try to guess or just say "Değerlendir".
                      'Değerlendirme Yap / Düzenle',
                      style: AppTextStyles.button,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Filters
            ReviewFilterBar(venueId: widget.venueId),

            const SizedBox(height: 16),

            // Filtered List
            Consumer<ReviewProvider>(
              builder: (context, reviewProvider, _) {
                if (reviewProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (reviewProvider.reviews.isEmpty) {
                  return EmptyState(
                    icon: Icons.rate_review_outlined,
                    title: 'Yorum bulunamadı',
                    message: 'Seçili kriterlere uygun yorum yok.',
                    actionLabel: 'Filtreleri Temizle',
                    onAction: () {
                      reviewProvider.setFilterRating(null, widget.venueId);
                      reviewProvider.setFilterHasPhotos(false, widget.venueId);
                    },
                  );
                }

                return Column(
                  children: reviewProvider.reviews.map((review) {
                    final isOwn = review.userId == currentUserId;
                    return ReviewCard(
                      review: review,
                      isOwnReview: isOwn,
                      onEdit: isOwn
                          ? () => _handleReviewAction(context, venueProvider)
                          : null,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        );
      },
    );
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
    await submissionProvider.checkExistingReview(widget.venueId);

    if (context.mounted) {
      if (submissionProvider.isEditing) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => EditReviewBottomSheet(
            venueId: widget.venueId,
            venueName: provider.venue?.name ?? '',
          ),
        );
      } else {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ReviewSubmissionBottomSheet(
            venueId: widget.venueId,
            venueName: provider.venue?.name ?? '',
          ),
        );
      }
      // Refresh list after action
      if (context.mounted) {
        context.read<ReviewProvider>().fetchReviews(widget.venueId);
        context.read<VenueDetailsProvider>().refreshReviews(); // Update stats
      }
    }
  }
}
