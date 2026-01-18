import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_review_provider.dart';
import '../../../data/models/review.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BusinessReviewsScreen extends StatefulWidget {
  final String venueId;

  const BusinessReviewsScreen({super.key, required this.venueId});

  @override
  State<BusinessReviewsScreen> createState() => _BusinessReviewsScreenState();
}

class _BusinessReviewsScreenState extends State<BusinessReviewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessReviewProvider>().loadReviews(widget.venueId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yorum Yönetimi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Bekleyenler'),
            Tab(text: 'Onaylananlar'),
          ],
        ),
      ),
      body: Consumer<BusinessReviewProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReviewList(
                context,
                provider.pendingReviews,
                isPending: true,
              ),
              _buildReviewList(
                context,
                provider.approvedReviews,
                isPending: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewList(
    BuildContext context,
    List<Review> reviews, {
    required bool isPending,
  }) {
    if (reviews.isEmpty) {
      return Center(
        child: Text(
          isPending
              ? 'Bekleyen yorum bulunmamaktadır.'
              : 'Onaylanmış yorum bulunmamaktadır.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (User, Date, Rating)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: review.userAvatarUrl != null
                          ? NetworkImage(review.userAvatarUrl!)
                          : null,
                      child: review.userAvatarUrl == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        review.userFullName ?? 'Anonim',
                        style: AppTextStyles.subtitle2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
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
                const SizedBox(height: 12),
                if (review.comment != null && review.comment!.isNotEmpty)
                  Text(review.comment!, style: AppTextStyles.bodyMedium),
                if (review.photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: review.photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            review.photos[index],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending)
                      ElevatedButton(
                        onPressed: () => _showApproveDialog(context, review),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Onayla & Yanıtla'),
                      ),
                    if (!isPending && review.businessReply != null)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Yanıt: ${review.businessReply}',
                            style: AppTextStyles.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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

  void _showApproveDialog(BuildContext context, Review review) {
    final replyController = TextEditingController();
    final List<String> templates = [
      "Teşekkür ederiz, yine bekleriz.",
      "Geri bildiriminiz için teşekkürler.",
      "Memnun kalmanıza sevindik!",
      "Harika bir deneyim sunabildiysek ne mutlu bize.",
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yorumu Onayla'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bu yorumu yayınlamak istediğinize emin misiniz? İsterseniz bir yanıt ekleyebilirsiniz.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: replyController,
                decoration: const InputDecoration(
                  hintText: 'Yanıtınız (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              const Text(
                'Hazır Şablonlar:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: templates
                    .map(
                      (t) => ActionChip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          replyController.text = t;
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BusinessReviewProvider>().approveReview(
                review.id,
                replyController.text.isEmpty ? null : replyController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }
}
