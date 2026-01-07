import 'package:flutter/material.dart';
import '../../../../data/models/review.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    ? Icon(Icons.person, color: AppColors.gray400)
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
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
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple formatter, in production use intl package
    return '${date.day}.${date.month}.${date.year}';
  }
}
