import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/review.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReviewsPreviewV2 extends StatelessWidget {
  final Venue venue;
  final List<Review> reviews;
  final VoidCallback onSeeAll;

  const ReviewsPreviewV2({
    super.key,
    required this.venue,
    required this.reviews,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    // Get the latest review if available
    final Review? latestReview = reviews.isNotEmpty ? reviews.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and "See All" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Değerlendirmeler',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Tümünü Gör (${venue.ratingCount})',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Review Card or Empty State
        if (latestReview == null)
          _buildEmptyState()
        else
          _buildReviewCard(latestReview),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nude),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, color: AppColors.gray300, size: 40),
          const SizedBox(height: 12),
          Text(
            'Henüz değerlendirme yok',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'İlk değerlendirmeyi siz yapın!',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nude),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // User Avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gray100,
                    ),
                    child: review.userAvatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              review.userAvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.gray400,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.gray400,
                          ),
                  ),
                  const SizedBox(width: 10),
                  // User Name
                  Text(
                    review.userFullName ?? 'Anonim Kullanıcı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Date
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(color: AppColors.gray400, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Star Rating
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: AppColors.gold,
                size: 16,
              ),
            ),
          ),
          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray600,
                height: 1.5,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Bugün';
    if (difference.inDays == 1) return 'Dün';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} hafta önce';
    }
    return '${date.day}.${date.month}.${date.year}';
  }
}
