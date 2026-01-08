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

  const VenueHeroV2({super.key, required this.venue});

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
              builder: (BuildContext builderContext) {
                return VenueHeroCarousel(
                  imageUrls: venue.heroImages.isNotEmpty
                      ? venue.heroImages
                      : (venue.imageUrl != null ? [venue.imageUrl!] : []),
                  height: 360,
                  onTap: () {
                    // Open full-screen gallery viewer if there are photos
                    final hasPhotos =
                        venue.heroImages.isNotEmpty || venue.imageUrl != null;
                    if (hasPhotos) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        _buildGlassButton(
                          icon: venue.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          iconColor: venue.isFavorited
                              ? AppColors.primary
                              : Colors.white,
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
    // Get image URLs (either from heroImages or fallback to imageUrl)
    final imageUrls = venue.heroImages.isNotEmpty
        ? venue.heroImages
        : (venue.imageUrl != null ? [venue.imageUrl!] : []);

    // Convert to VenuePhoto objects for the gallery viewer
    final photos = imageUrls.asMap().entries.map((entry) {
      return VenuePhoto(
        id: '${venue.id}_hero_${entry.key}',
        venueId: venue.id,
        url: entry.value,
        category: PhotoCategory.interior,
        uploadedAt: DateTime.now(),
        sortOrder: entry.key,
        isHeroImage: true,
      );
    }).toList();

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
    Color iconColor = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.3),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
