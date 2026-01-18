import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReviewFilterBar extends StatelessWidget {
  final String venueId;
  const ReviewFilterBar({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                label: 'En Yeni',
                selected: provider.sortBy == 'newest',
                onTap: () => provider.setSortBy('newest', venueId),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'En Faydalı',
                selected: provider.sortBy == 'most_helpful',
                onTap: () => provider.setSortBy('most_helpful', venueId),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Fotoğraflı',
                selected: provider.filterHasPhotos,
                onTap: () => provider.setFilterHasPhotos(
                  !provider.filterHasPhotos,
                  venueId,
                ),
              ),
              const SizedBox(width: 8),
              // Ratings
              ...List.generate(5, (index) {
                final rating = 5 - index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    label: '$rating Yıldız',
                    selected: provider.filterRating == rating,
                    onTap: () => provider.setFilterRating(rating, venueId),
                    icon: Icons.star,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.gray200,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.gold,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: selected ? Colors.white : AppColors.gray700,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
