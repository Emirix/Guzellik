import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/services/notification_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../providers/venue_details_provider.dart';
import '../../../providers/business_provider.dart';
import '../../dialogs/follow_info_bottom_sheet.dart';
import '../../dialogs/unfollow_confirmation_dialog.dart';

class VenueIdentityV2 extends StatefulWidget {
  final Venue venue;

  const VenueIdentityV2({super.key, required this.venue});

  @override
  State<VenueIdentityV2> createState() => _VenueIdentityV2State();
}

class _VenueIdentityV2State extends State<VenueIdentityV2> {
  bool _isPressed = false;

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
        widget.venue.name,
      );
      if (!confirmed) return;

      final success = await provider.unfollowVenue();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.venue.name} takipten çıkarıldı'),
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
              content: Text('${widget.venue.name} takip ediliyor'),
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

  Widget _buildFollowButton(
    bool isFollowing,
    bool isLoading,
    BuildContext context,
  ) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.mediumImpact();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: isLoading ? null : () => _handleFollowTap(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
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
                    const SizedBox(width: 4),
                    Text(
                      isFollowing ? 'Takipte' : 'Takip Et',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VenueDetailsProvider, BusinessProvider>(
      builder: (context, provider, businessProvider, _) {
        final isFollowing = provider.isFollowing;
        final isLoading = provider.isLoading || provider.isFollowLoading;

        // Check if viewing own profile in business mode
        final isOwnProfile =
            businessProvider.isBusinessMode &&
            businessProvider.businessVenue?.id == widget.venue.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Follow Button Row - Split by SpaceBetween
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.venue.name,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.gray900,
                      height: 1.2,
                    ),
                  ),
                ),
                if (!isOwnProfile) ...[
                  const SizedBox(width: 12),
                  _buildFollowButton(isFollowing, isLoading, context),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // Location & Category Row
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.gray500,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.venue.address,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '•',
                    style: TextStyle(color: AppColors.gray400, fontSize: 12),
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.venue.category?.name ?? 'Güzellik Salonu',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Venue Description
            Text(
              widget.venue.description ??
                  'Bu mekan hakkında henüz detaylı bilgi eklenmemiştir. Daha fazla bilgi almak için iletişime geçebilirsiniz.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
                height: 1.5,
                fontSize: 14,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            // Rating Row
            if (widget.venue.ratingCount > 0)
              Row(
                children: [
                  // Rating Badge - Premium design
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.nude.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.venue.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Star icons - Gold
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final rating = widget.venue.rating;
                            if (index < rating.floor()) {
                              return const Icon(
                                Icons.star_rounded,
                                color: AppColors.gold,
                                size: 14,
                              );
                            } else if (index < rating.ceil() &&
                                rating % 1 != 0) {
                              return const Icon(
                                Icons.star_half_rounded,
                                color: AppColors.gold,
                                size: 14,
                              );
                            } else {
                              return Icon(
                                Icons.star_outline_rounded,
                                color: AppColors.gold.withValues(alpha: 0.4),
                                size: 14,
                              );
                            }
                          }),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${widget.venue.ratingCount})',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
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
