import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/venue_photo.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../../providers/venue_details_provider.dart';
import '../venue_hero_carousel.dart';
import '../photo_gallery_viewer.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/discovery_provider.dart';
import '../../../providers/search_provider.dart';

class VenueHeroV2 extends StatelessWidget {
  final Venue venue;
  final bool showBackButton;

  const VenueHeroV2({
    super.key,
    required this.venue,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gallery Carousel
            Builder(
              builder: (builderContext) {
                // Use gallery photos if available (sorted by hero first, then sortOrder)
                // If not, fallback to heroImages or legacy imageUrl
                List<String> images = [];
                if (venue.galleryPhotos != null &&
                    venue.galleryPhotos!.isNotEmpty) {
                  final sorted = List<VenuePhoto>.from(venue.galleryPhotos!);
                  sorted.sort((a, b) {
                    if (a.isHeroImage && !b.isHeroImage) return -1;
                    if (!a.isHeroImage && b.isHeroImage) return 1;
                    return a.sortOrder.compareTo(b.sortOrder);
                  });
                  images = sorted.map((p) => p.url).toList();
                } else if (venue.heroImages.isNotEmpty) {
                  images = venue.heroImages;
                } else if (venue.imageUrl != null) {
                  images = [venue.imageUrl!];
                }

                return VenueHeroCarousel(
                  imageUrls: images,
                  height: 360,
                  onTap: () {
                    // Open full-screen gallery viewer if there are photos
                    if (images.isNotEmpty) {
                      _openGalleryViewer(builderContext);
                    }
                  },
                );
              },
            ),

            // Gradient Overlay (Bottom to Top) - Ignore pointer to allow taps
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0x99000000), Colors.transparent],
                    stops: [0.0, 0.4],
                  ),
                ),
              ),
            ),

            // Top Actions
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (showBackButton)
                      _buildGlassButton(
                        icon: Icons.arrow_back,
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      )
                    else
                      const SizedBox(
                        width: 44,
                      ), // Placeholder if back button hidden
                    Row(
                      children: [
                        _buildGlassButton(
                          icon: venue.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          iconColor: venue.isFavorited
                              ? AppColors.primary
                              : AppColors.gray900,
                          onTap: () async {
                            final authProvider = context.read<AuthProvider>();
                            if (!authProvider.isAuthenticated) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen önce giriş yapın'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            try {
                              final favoritesProvider = context
                                  .read<FavoritesProvider>();
                              final discoveryProvider = context
                                  .read<DiscoveryProvider>();
                              final searchProvider = context
                                  .read<SearchProvider>();
                              final detailsProvider = context
                                  .read<VenueDetailsProvider>();

                              await Future.wait([
                                favoritesProvider.toggleFavorite(venue),
                                discoveryProvider.toggleFavoriteVenue(venue),
                                searchProvider.toggleFavoriteVenue(venue),
                                detailsProvider.toggleFavoriteVenue(venue),
                              ]);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Hata: $e')),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildGlassButton(
                          icon: Icons.ios_share,
                          onTap: () {
                            Share.share(
                              '${venue.name}\n${venue.address}\n\nDaima uygulamasında keşfet!',
                              subject: venue.name,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGalleryViewer(BuildContext context) {
    List<VenuePhoto> photos = [];

    if (venue.galleryPhotos != null && venue.galleryPhotos!.isNotEmpty) {
      // Use existing gallery photos, sorted correctly
      photos = List<VenuePhoto>.from(venue.galleryPhotos!);
      photos.sort((a, b) {
        if (a.isHeroImage && !b.isHeroImage) return -1;
        if (!a.isHeroImage && b.isHeroImage) return 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    } else {
      // Fallback for legacy data/heroImages
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

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withOpacity(0.9),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: iconColor ?? AppColors.gray900,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
