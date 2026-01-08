import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/services/notification_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/icon_utils.dart';
import '../../../providers/venue_details_provider.dart';
import '../../dialogs/follow_info_bottom_sheet.dart';
import '../../dialogs/unfollow_confirmation_dialog.dart';

class VenueIdentityV2 extends StatelessWidget {
  final Venue venue;

  const VenueIdentityV2({super.key, required this.venue});

  Future<void> _handleFollowTap(BuildContext context) async {
    final provider = context.read<VenueDetailsProvider>();
    final authProvider = context.read<AuthProvider>();
    final notificationService = NotificationService.instance;
    final authRepo = AuthRepository();

    // Check if user is authenticated using AuthProvider
    if (!authProvider.isAuthenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mekanları takip etmek için giriş yapmalısınız'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final currentUser = authProvider.currentUser;

    // Debug: Check auth state
    print('=== AUTH DEBUG ===');
    print('Current user: ${currentUser?.id}');
    print('User email: ${currentUser?.email}');
    print('Is authenticated: ${authProvider.isAuthenticated}');
    print('==================');

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
        final isLoading = provider.isLoading || provider.isFollowLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name, Location, Category and Image Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Name
                      Text(
                        venue.name,
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Location Row (İl, İlçe)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              venue.address,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.gray600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Category Row (Mekan Türü)
                      Row(
                        children: [
                          Icon(
                            IconUtils.getCategoryIcon(
                              venue.icon ?? venue.category?.icon,
                            ),
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              venue.category?.name ?? 'Güzellik Salonu',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.gray600,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Follow Button
                      SizedBox(
                        height: 36,
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => _handleFollowTap(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.white,
                            side: BorderSide(
                              color: isFollowing
                                  ? AppColors.primary.withOpacity(0.5)
                                  : AppColors.primary,
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading)
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  isFollowing ? Icons.check : Icons.add,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              const SizedBox(width: 6),
                              Text(
                                isFollowing ? 'Takipte' : 'Takip Et',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Main Image Container (larger, rounded)
                Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: venue.imageUrl != null
                        ? Image.network(
                            venue.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.nude,
                                child: const Icon(
                                  Icons.business,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.nude,
                            child: const Icon(
                              Icons.business,
                              color: AppColors.primary,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Rating Card - Premium Design
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.nude.withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    venue.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Star icons - Gold and rounded
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final rating = venue.rating;
                      if (index < rating.floor()) {
                        return const Icon(
                          Icons.star_rounded,
                          color: AppColors.gold,
                          size: 18,
                        );
                      } else if (index < rating.ceil() && rating % 1 != 0) {
                        return const Icon(
                          Icons.star_half_rounded,
                          color: AppColors.gold,
                          size: 18,
                        );
                      } else {
                        return const Icon(
                          Icons.star_outline_rounded,
                          color: AppColors.gold,
                          size: 18,
                        );
                      }
                    }),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${venue.ratingCount} Değerlendirme)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
