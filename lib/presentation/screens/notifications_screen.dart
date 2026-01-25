import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../widgets/notifications/notification_card.dart';
import '../widgets/common/ad_banner_widget.dart';
import '../widgets/common/guzellik_haritam_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const GuzellikHaritamHeader(backgroundColor: AppColors.background),
          const AdBannerWidget(),
          const AdBannerWidget(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNotificationList(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (Navigator.of(context).canPop())
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                      elevation: 2,
                    ),
                  ),
                ),
              Text('Bildirimler', style: AppTextStyles.heading2),
            ],
          ),
          IconButton(
            onPressed: () {
              // Show settings or more options
            },
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    NotificationProvider provider,
  ) {
    if (provider.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text('Bildirim bulunmuyor', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Henüz yeni bir bildirim almadınız.',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    final groups = _groupNotifications(provider.notifications);
    final sortedGroupKeys = ['Bugün', 'Dün', 'Geçen Hafta', 'Daha Eski'];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedGroupKeys.length,
      itemBuilder: (context, index) {
        final key = sortedGroupKeys[index];
        final items = groups[key];

        if (items == null || items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key,
                    style: AppTextStyles.heading3.copyWith(fontSize: 18),
                  ),
                  if (key == 'Bugün' && items.any((n) => !n.isRead))
                    TextButton(
                      onPressed: () => provider.markAllAsRead(),
                      child: const Text(
                        'Tümünü Oku',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ...items.map(
              (n) => NotificationCard(
                notification: n,
                onTap: () {
                  provider.markAsRead(n.id);
                  // Handle deep link navigation if needed
                },
                onDelete: () => provider.deleteNotification(n.id),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, List<NotificationModel>> _groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final Map<String, List<NotificationModel>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    for (var n in notifications) {
      final date = DateTime(
        n.createdAt.year,
        n.createdAt.month,
        n.createdAt.day,
      );
      String group;
      if (date == today) {
        group = 'Bugün';
      } else if (date == yesterday) {
        group = 'Dün';
      } else if (date.isAfter(lastWeek)) {
        group = 'Geçen Hafta';
      } else {
        group = 'Daha Eski';
      }

      if (!groups.containsKey(group)) {
        groups[group] = [];
      }
      groups[group]!.add(n);
    }
    return groups;
  }
}
