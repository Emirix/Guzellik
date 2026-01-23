import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_reviews_provider.dart';
import '../../data/models/review.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../widgets/common/empty_state.dart';

class UserReviewsScreen extends StatefulWidget {
  const UserReviewsScreen({super.key});

  @override
  State<UserReviewsScreen> createState() => _UserReviewsScreenState();
}

class _UserReviewsScreenState extends State<UserReviewsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserReviewsProvider>().fetchUserReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBFB).withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0E11)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'İncelemelerim',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B0E11),
          ),
        ),
      ),
      body: Consumer<UserReviewsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchUserReviews(),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.reviews.isEmpty) {
            return EmptyState(
              icon: Icons.rate_review_outlined,
              title: 'Henüz bir incelemeniz yok',
              message:
                  'Deneyimlerinizi paylaşmak için mekanları keşfedin ve değerlendirin.',
              actionLabel: 'Mekanları Keşfet',
              onAction: () => context.push('/'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchUserReviews(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final review = provider.reviews[index];
                return _ReviewItem(
                  review: review,
                  onTap: () => _openVenueDetail(review.venueId),
                  onDelete: () => _confirmDeleteReview(review),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openVenueDetail(String venueId) {
    context.push('/venue/$venueId');
  }

  void _confirmDeleteReview(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('İncelemeyi Sil'),
        content: const Text('Bu incelemeyi silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              try {
                await context.read<UserReviewsProvider>().deleteReview(
                  review.id,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('İnceleme silindi')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ReviewItem({
    required this.review,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3E8EA)),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.venueName ?? review.venueId,
                        style: AppTextStyles.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      review.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(review.status),
                    style: AppTextStyles.caption.copyWith(
                      color: _getStatusColor(review.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Sil'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  String _getStatusText(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.approved:
        return 'Onaylandı';
      case ReviewStatus.pending:
        return 'Beklemede';
      case ReviewStatus.rejected:
        return 'Reddedildi';
    }
  }

  Color _getStatusColor(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.approved:
        return Colors.green;
      case ReviewStatus.pending:
        return Colors.orange;
      case ReviewStatus.rejected:
        return Colors.red;
    }
  }
}
