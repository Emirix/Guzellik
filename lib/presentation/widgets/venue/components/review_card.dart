import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/review_provider.dart';
import '../../../../data/models/review.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final bool isOwnReview;
  final VoidCallback? onEdit;

  const ReviewCard({
    super.key,
    required this.review,
    this.isOwnReview = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOwnReview
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOwnReview
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.gray200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwnReview)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Sizin değerlendirmeniz',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onEdit,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Düzenle',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: review.userAvatarUrl != null
                    ? NetworkImage(review.userAvatarUrl!)
                    : null,
                backgroundColor: AppColors.gray100,
                child: review.userAvatarUrl == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.gray400,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userFullName ?? 'Anonim Kullanıcı',
                      style: AppTextStyles.subtitle2,
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ],
          // Photos
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      review.photos[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) =>
                          Container(color: Colors.grey[200]),
                    ),
                  );
                },
              ),
            ),
          ],

          // Business Reply
          if (review.businessReply != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'İşletme Yanıtı',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(review.businessReply!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],

          // Helpful Button
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Bu yorum faydalı mı?',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  context.read<ReviewProvider>().toggleHelpful(review.id);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 16,
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.helpfulCount.toString(),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}
