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
              child: Text(
                'Tümünü Gör (${venue.ratingCount})',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (latestReview == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.nude),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  color: AppColors.gray300,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Henüz değerlendirme yok',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.nude),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: latestReview.userAvatarUrl != null
                              ? NetworkImage(latestReview.userAvatarUrl!)
                              : null,
                          backgroundColor: AppColors.gray100,
                          child: latestReview.userAvatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: AppColors.gray400,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          latestReview.userFullName ?? 'Anonim Kullanıcı',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(latestReview.createdAt),
                      style: const TextStyle(
                        color: AppColors.gray400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < latestReview.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.gold,
                      size: 16,
                    ),
                  ),
                ),
                if (latestReview.comment != null &&
                    latestReview.comment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    latestReview.comment!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) return 'Bugün';
    if (difference.inDays == 1) return 'Dün';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    return '${date.day}.${date.month}.${date.year}';
  }
}
