import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../providers/venue_details_provider.dart';
import '../../dialogs/follow_info_bottom_sheet.dart';
import '../../dialogs/unfollow_confirmation_dialog.dart';

class VenueIdentityV2 extends StatelessWidget {
  final Venue venue;

  const VenueIdentityV2({super.key, required this.venue});

  Future<void> _handleFollowTap(BuildContext context) async {
    final provider = context.read<VenueDetailsProvider>();
    final authRepo = AuthRepository();
    final notificationService = NotificationService.instance;

    // Check if user is authenticated
    if (!authRepo.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mekanları takip etmek için giriş yapmalısınız'),
          backgroundColor: AppColors.error,
        ),
      );
      // TODO: Navigate to login screen
      return;
    }

    final isFollowing = provider.isFollowing;

    if (isFollowing) {
      // Show unfollow confirmation
      final confirmed = await UnfollowConfirmationDialog.show(
        context,
        venue.name,
      );
      if (!confirmed) return;

      final success = await provider.unfollowVenue();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${venue.name} takipten çıkarıldı'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Check if user has seen the follow info
      final prefs = await SharedPreferences.getInstance();
      final hasSeenInfo = prefs.getBool('has_seen_follow_info') ?? false;

      if (!hasSeenInfo && context.mounted) {
        // Show info bottom sheet (one-time)
        final wantsNotifications = await FollowInfoBottomSheet.show(context);
        await prefs.setBool('has_seen_follow_info', true);

        if (wantsNotifications) {
          // Request notification permissions
          try {
            final token = await notificationService.getToken();
            if (token != null) {
              await authRepo.saveFcmToken(token);
            }
          } catch (e) {
            print('Error requesting notification permissions: $e');
          }
        }
      }

      // Follow the venue
      final success = await provider.followVenue();
      if (success && context.mounted) {
        // Try to get and save FCM token if not already done
        try {
          final token = await notificationService.getToken();
          if (token != null) {
            await authRepo.saveFcmToken(token);
          }
        } catch (e) {
          print('Error saving FCM token: $e');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${venue.name} takip ediliyor'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bir hata oluştu, lütfen tekrar deneyin'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VenueDetailsProvider>(
      builder: (context, provider, _) {
        final isFollowing = provider.isFollowing;
        final isLoading = provider.isFollowLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Logo Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kadıköy, İstanbul', // TODO: Get from address or new field
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: TextStyle(color: AppColors.gray400),
                            ),
                          ),
                          Text(
                            'Cilt Bakımı & Lazer', // TODO: Get from categories
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Logo Container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: venue.imageUrl != null
                        ? Image.network(venue.imageUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.business, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Rating and Follow Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rating Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.nude.withOpacity(0.5)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '4.8',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        children: List.generate(5, (index) {
                          if (index < 4) {
                            return const Icon(
                              Icons.star,
                              color: Color(0xFFFFB800),
                              size: 14,
                            );
                          } else {
                            return const Icon(
                              Icons.star_half,
                              color: Color(0xFFFFB800),
                              size: 14,
                            );
                          }
                        }),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(124)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Follow Button
                ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _handleFollowTap(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.1),
                    foregroundColor: isFollowing
                        ? Colors.white
                        : AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          isFollowing
                              ? Icons.notifications
                              : Icons.notifications_outlined,
                          size: 16,
                        ),
                  label: Text(
                    isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
