import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/review_submission_provider.dart';
import '../../providers/venue_details_provider.dart';
import 'star_rating_selector.dart';

class ReviewSubmissionBottomSheet extends StatefulWidget {
  final String venueId;
  final String venueName;

  const ReviewSubmissionBottomSheet({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<ReviewSubmissionBottomSheet> createState() =>
      _ReviewSubmissionBottomSheetState();
}

class _ReviewSubmissionBottomSheetState
    extends State<ReviewSubmissionBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

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
                            'Değerlendirmenizi Paylaşın',
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
                  'Deneyiminizi puanlayın',
                  style: AppTextStyles.heading4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                StarRatingSelector(
                  initialRating: provider.rating ?? 0,
                  onRatingChanged: (rating) => provider.setRating(rating),
                ),
                const SizedBox(height: 32),

                // Photo Upload
                Text('Fotoğraf Ekle (Maks. 2)', style: AppTextStyles.heading4),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (provider.selectedPhotos.length < 2)
                        GestureDetector(
                          onTap: provider.pickPhotos,
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.gray50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
                      ...provider.selectedPhotos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final photo = entry.value;
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(photo.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => provider.removePhoto(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
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

                // Submit Button
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

                ElevatedButton(
                  onPressed: provider.isLoading || provider.rating == null
                      ? null
                      : () async {
                          final success = await provider.submitReview(
                            widget.venueId,
                          );
                          if (success && mounted) {
                            // Refresh venue details reviews
                            await context
                                .read<VenueDetailsProvider>()
                                .refreshReviews();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Değerlendirmeniz paylaşıldı.'),
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
                      : const Text('Gönder'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
