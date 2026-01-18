import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReviewEmptyState extends StatelessWidget {
  final bool isPending;

  const ReviewEmptyState({super.key, required this.isPending});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Yorum bulunamadı',
            style: AppTextStyles.heading3.copyWith(color: AppColors.black),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isPending
                  ? 'Şu anda onay bekleyen yeni bir yorumunuz bulunmuyor.'
                  : 'Şu anda listelenecek onaylanmış bir yorumunuz bulunmuyor.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Action Button (Optional - mimics "Filtreleri Temizle" from design if suitable)
          // For now, we'll keep it simple as this is an empty state for lists
        ],
      ),
    );
  }
}
