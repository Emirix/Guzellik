import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/review_submission_provider.dart';
import '../../providers/venue_details_provider.dart';
import 'star_rating_selector.dart';

class EditReviewBottomSheet extends StatefulWidget {
  final String venueId;
  final String venueName;

  const EditReviewBottomSheet({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<EditReviewBottomSheet> createState() => _EditReviewBottomSheetState();
}

class _EditReviewBottomSheetState extends State<EditReviewBottomSheet> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ReviewSubmissionProvider>();
    _commentController = TextEditingController(text: provider.comment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewSubmissionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Değerlendirmenizi Düzenleyin',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.venueName,
                            style: AppTextStyles.subtitle2,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Star Rating
                Text(
                  'Puanınızı güncelleyin',
                  style: AppTextStyles.heading4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                StarRatingSelector(
                  initialRating: provider.rating ?? 0,
                  onRatingChanged: (rating) => provider.setRating(rating),
                ),
                const SizedBox(height: 32),

                // Comment
                Text('Yorumunuz (Opsiyonel)', style: AppTextStyles.heading4),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 500,
                  onChanged: (text) => provider.setComment(text),
                  decoration: InputDecoration(
                    hintText: 'Deneyiminizi anlatın...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray400,
                    ),
                    filled: true,
                    fillColor: AppColors.gray50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '${provider.characterCount}/500',
                  ),
                ),
                const SizedBox(height: 32),

                // Error Message
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      provider.errorMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Actions
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: provider.isLoading || provider.rating == null
                          ? null
                          : () async {
                              final success = await provider.submitReview(
                                widget.venueId,
                              );
                              if (success && mounted) {
                                await context
                                    .read<VenueDetailsProvider>()
                                    .refreshReviews();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Değerlendirmeniz güncellendi.',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Güncelle'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => _showDeleteConfirmation(context, provider),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text('Değerlendirmeyi Sil'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ReviewSubmissionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değerlendirmeyi Sil'),
        content: const Text(
          'Değerlendirmenizi silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await provider.deleteReview();
              if (success && mounted) {
                await context.read<VenueDetailsProvider>().refreshReviews();
                Navigator.pop(context); // Close bottom sheet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Değerlendirme silindi.'),
                    backgroundColor: AppColors.gray700,
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
