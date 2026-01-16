import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/venue_photo.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../components/photo_thumbnail_grid.dart';
import '../photo_gallery_viewer.dart';
import '../../../screens/venue/venue_gallery_screen.dart';

class GallerySectionV2 extends StatelessWidget {
  final Venue venue;

  const GallerySectionV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final hasPhotos =
        venue.galleryPhotos != null && venue.galleryPhotos!.isNotEmpty;

    if (!hasPhotos && venue.heroImages.isEmpty) {
      return const SizedBox.shrink();
    }

    // Combine hero images and gallery photos for a complete set
    final List<VenuePhoto> allPhotos = [];

    // Add gallery photos first
    if (venue.galleryPhotos != null) {
      allPhotos.addAll(venue.galleryPhotos!);
    }

    // If no gallery photos, convert hero images to VenuePhoto objects
    if (allPhotos.isEmpty) {
      for (int i = 0; i < venue.heroImages.length; i++) {
        allPhotos.add(
          VenuePhoto(
            id: 'hero_$i',
            venueId: venue.id,
            url: venue.heroImages[i],
            category: PhotoCategory.interior,
            uploadedAt: DateTime.now(),
            sortOrder: i,
            isHeroImage: true,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fotoğraf Galerisi',
                    style: AppTextStyles.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              if (allPhotos.length > 3)
                TextButton(
                  onPressed: () => _openFullGallery(context, allPhotos),
                  child: Text(
                    'Tümünü Gör',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PhotoThumbnailGrid(
            photos: allPhotos.take(3).toList(), // Show only 3 items (one row)
            showCategoryFilter: false,
            onPhotoTap: (index) =>
                _openFullGallery(context, allPhotos, initialIndex: index),
          ),
        ),
      ],
    );
  }

  void _openFullGallery(
    BuildContext context,
    List<VenuePhoto> photos, {
    int? initialIndex,
  }) {
    if (initialIndex == null) {
      // Navigate to the Grid Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VenueGalleryScreen(venue: venue),
        ),
      );
    } else {
      // Open the viewer directly
      final provider = context.read<VenueDetailsProvider>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PhotoGalleryViewer(
            photos: photos,
            initialIndex: initialIndex,
            venueName: venue.name,
            onLike: (photoId) => provider.likePhoto(photoId),
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }
}
