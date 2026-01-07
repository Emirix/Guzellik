import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/review.dart';

class RatingDistributionChart extends StatelessWidget {
  final List<Review> reviews;

  const RatingDistributionChart({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    // Calculate distribution
    final Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in reviews) {
      final rating = review.rating.floor();
      if (counts.containsKey(rating)) {
        counts[rating] = counts[rating]! + 1;
      }
    }

    final int total = reviews.length;

    return Column(
      children: [5, 4, 3, 2, 1].map((stars) {
        final count = counts[stars] ?? 0;
        final double percentage = total > 0 ? count / total : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Row(
                  children: [
                    Text(
                      stars.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.gray400,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 35,
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray500,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
