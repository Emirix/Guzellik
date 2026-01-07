import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../../data/models/venue_photo.dart';
import '../components/photo_thumbnail_grid.dart';
import '../photo_gallery_viewer.dart';

class GalleryTab extends StatelessWidget {
  final String venueId;

  const GalleryTab({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<VenueDetailsProvider>(
      builder: (context, provider, child) {
        final venue = provider.venue;
        if (venue == null) return const SizedBox.shrink();

        final photos = venue.galleryPhotos ?? [];

        // If no gallery photos, show hero images as fallback
        final displayPhotos = photos.isNotEmpty
            ? photos
            : venue.heroImages
                  .asMap()
                  .entries
                  .map(
                    (e) => VenuePhoto(
                      id: 'hero_${e.key}',
                      venueId: venue.id,
                      url: e.value,
                      category: PhotoCategory.interior,
                      uploadedAt: DateTime.now(),
                      sortOrder: e.key,
                      isHeroImage: true,
                    ),
                  )
                  .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoThumbnailGrid(
                photos: displayPhotos,
                showCategoryFilter: true,
                onPhotoTap: (index) =>
                    _openGallery(context, displayPhotos, index, provider),
              ),
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  void _openGallery(
    BuildContext context,
    List<VenuePhoto> photos,
    int index,
    VenueDetailsProvider provider,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoGalleryViewer(
          photos: photos,
          initialIndex: index,
          venueName: 'Galeri',
          onLike: (photoId) => provider.likePhoto(photoId),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
