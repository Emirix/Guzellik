import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/venue_photo.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/venue_details_provider.dart';
import '../venue_hero_carousel.dart';
import '../photo_gallery_viewer.dart';
import 'venue_quick_actions_v2.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/discovery_provider.dart';
import '../../../providers/search_provider.dart';
import '../../dialogs/follow_info_bottom_sheet.dart';
import '../../dialogs/unfollow_confirmation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/repositories/auth_repository.dart';

class VenueHeroV2 extends StatelessWidget {
  final Venue venue;
  final bool showBackButton;
  final VoidCallback? onBookingTap;

  const VenueHeroV2({
    super.key,
    required this.venue,
    this.showBackButton = true,
    this.onBookingTap,
  });

  Future<void> _handleFollowTap(BuildContext context) async {
    final provider = context.read<VenueDetailsProvider>();
    final authProvider = context.read<AuthProvider>();
    final notificationService = NotificationService.instance;
    final authRepo = AuthRepository();

    if (!authProvider.isAuthenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mekanları takip etmek için giriş yapmalısınız'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final isFollowing = provider.isFollowing;

    if (isFollowing) {
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
          ),
        );
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenInfo = prefs.getBool('has_seen_follow_info') ?? false;

      if (!hasSeenInfo && context.mounted) {
        final wantsNotifications = await FollowInfoBottomSheet.show(context);
        await prefs.setBool('has_seen_follow_info', true);

        if (wantsNotifications) {
          try {
            final token = await notificationService.getToken();
            if (token != null) {
              await authRepo.saveFcmToken(token);
            }
          } catch (e) {
            debugPrint('Error requesting notification permissions: $e');
          }
        }
      }

      final success = await provider.followVenue();
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${venue.name} takip ediliyor'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 530, // 460 Image + 70 Overhang
        color: AppColors.white,
        child: Stack(
          children: [
            // 1. Background Image
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 460,
              child: Builder(
                builder: (builderContext) {
                  List<String> images = [];

                  // Use the main image (image_url) as first priority
                  if (venue.imageUrl != null) {
                    images.add(venue.imageUrl!);
                  }

                  if (venue.galleryPhotos != null &&
                      venue.galleryPhotos!.isNotEmpty) {
                    final sorted = List<VenuePhoto>.from(venue.galleryPhotos!);
                    sorted.sort((a, b) {
                      if (a.isHeroImage && !b.isHeroImage) return -1;
                      if (!a.isHeroImage && b.isHeroImage) return 1;
                      return a.sortOrder.compareTo(b.sortOrder);
                    });

                    final galleryUrls = sorted.map((p) => p.url).toList();
                    for (var url in galleryUrls) {
                      if (!images.contains(url)) {
                        images.add(url);
                      }
                    }
                  } else if (venue.heroImages.isNotEmpty) {
                    for (var url in venue.heroImages) {
                      if (!images.contains(url)) {
                        images.add(url);
                      }
                    }
                  }

                  return VenueHeroCarousel(
                    imageUrls: images,
                    height: 460,
                    onTap: () {
                      if (images.isNotEmpty) {
                        _openGalleryViewer(builderContext);
                      }
                    },
                  );
                },
              ),
            ),

            // 2. White Gradient Overlay for Readability (Left to Right)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 460, // Same as hero image
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Content (Constrained to Image Height)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 460,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Back and Actions
                    SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (showBackButton)
                            _buildCircleButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.maybePop(context),
                            )
                          else
                            const SizedBox(width: 44),
                          Row(
                            children: [
                              _buildCircleButton(
                                icon: venue.isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                iconColor: venue.isFavorited
                                    ? AppColors.primary
                                    : AppColors.gray900,
                                onTap: () => _toggleFavorite(context),
                              ),
                              const SizedBox(width: 12),
                              _buildCircleButton(
                                icon: Icons.ios_share_rounded,
                                onTap: () => _shareVenue(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Rating
                    if (venue.ratingCount > 0) ...[
                      _buildRatingRow(),
                      const SizedBox(height: 8),
                    ],
                    // Name with word coloring
                    _buildVenueName(),
                    const SizedBox(height: 12),
                    // Location & Category
                    _buildLocationCategory(),
                    const SizedBox(height: 24),
                    // Action Buttons (Book/Follow)
                    _buildMainActionButtons(context),
                    const SizedBox(
                      height: 60,
                    ), // Visual space at bottom of image
                  ],
                ),
              ),
            ),

            // 3. Quick Actions Card (Overlapping)
            Positioned(
              top: 400, // 460 - 60 overlap
              left: 20,
              right: 20,
              child: VenueQuickActionsV2(venue: venue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            final isFull = index < venue.rating.floor();
            return Icon(
              isFull ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.gold,
              size: 18,
            );
          }),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${venue.rating.toStringAsFixed(1)} ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVenueName() {
    final words = venue.name.split(' ');
    if (words.isEmpty) return const SizedBox.shrink();

    final half = (words.length / 2).ceil();
    final firstHalf = words.take(words.length - half).join(' ');
    final secondHalf = words.skip(words.length - half).join(' ');

    const double baseFontSize = 32;
    final textStyle = GoogleFonts.montserrat(
      fontSize: baseFontSize,
      fontWeight: FontWeight.w800,
      height: 1.4,
      letterSpacing: -0.5,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: '$firstHalf ',
              style: textStyle.copyWith(color: AppColors.gray900),
            ),
            TextSpan(
              text: secondHalf,
              style: textStyle.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _getShortAddress(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
            ),
            if (venue.distance != null) ...[
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.gray300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(venue.distance! / 1000).toStringAsFixed(1)} km',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getShortAddress() {
    if (venue.address.isEmpty) return 'Konum belirtilmedi';

    // Split by common delimiters and clean up
    final parts = venue.address
        .split(RegExp(r'[,|/]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'Konum belirtilmedi';

    // Remove duplicates (e.g. "İstanbul, İstanbul")
    final seen = <String>{};
    final uniqueParts = <String>[];
    for (var part in parts) {
      if (seen.add(part.toLowerCase())) {
        uniqueParts.add(part);
      }
    }

    if (uniqueParts.length >= 2) {
      // Return 'District, City' - typically the last two valid unique parts in TR addresses
      return '${uniqueParts[uniqueParts.length - 2]}, ${uniqueParts.last}';
    }

    return uniqueParts.last;
  }

  Widget _buildMainActionButtons(BuildContext context) {
    return Consumer<VenueDetailsProvider>(
      builder: (context, provider, _) {
        final isFollowing = provider.isFollowing;
        final isFollowLoading = provider.isFollowLoading;

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onBookingTap,
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: const Text('İletişime Geç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: isFollowLoading
                    ? null
                    : () => _handleFollowTap(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.gray200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: isFollowLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isFollowing ? 'Takiptesin' : 'Takip Et',
                        style: TextStyle(
                          color: isFollowing
                              ? AppColors.primary
                              : AppColors.gray900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _shareVenue() {
    Share.share(
      '${venue.name}\n${venue.address}\n\nDaima uygulamasında keşfet!',
      subject: venue.name,
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen önce giriş yapın')));
      return;
    }

    try {
      await Future.wait([
        context.read<FavoritesProvider>().toggleFavorite(venue),
        context.read<DiscoveryProvider>().toggleFavoriteVenue(venue),
        context.read<SearchProvider>().toggleFavoriteVenue(venue),
        context.read<VenueDetailsProvider>().toggleFavoriteVenue(venue),
      ]);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  void _openGalleryViewer(BuildContext context) {
    List<VenuePhoto> photos = [];
    if (venue.galleryPhotos != null && venue.galleryPhotos!.isNotEmpty) {
      photos = List<VenuePhoto>.from(venue.galleryPhotos!);
      photos.sort((a, b) {
        if (a.isHeroImage && !b.isHeroImage) return -1;
        if (!a.isHeroImage && b.isHeroImage) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    } else {
      final imageUrls = venue.heroImages.isNotEmpty
          ? venue.heroImages
          : (venue.imageUrl != null ? [venue.imageUrl!] : []);
      photos = imageUrls.asMap().entries.map((entry) {
        return VenuePhoto(
          id: '${venue.id}_hero_${entry.key}',
          venueId: venue.id,
          url: entry.value,
          category: PhotoCategory.interior,
          uploadedAt: DateTime.now(),
          sortOrder: entry.key,
          isHeroImage: entry.key == 0,
        );
      }).toList();
    }

    if (photos.isEmpty) return;

    final provider = context.read<VenueDetailsProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoGalleryViewer(
          photos: photos,
          initialIndex: 0,
          venueName: venue.name,
          onLike: (photoId) => provider.likePhoto(photoId),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(icon, color: iconColor ?? AppColors.gray900, size: 22),
          ),
        ),
      ),
    );
  }
}
