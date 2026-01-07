import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/venue.dart';
import '../../../data/models/venue_photo.dart';
import '../../providers/venue_details_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/venue/components/photo_thumbnail_grid.dart';
import '../../widgets/venue/photo_gallery_viewer.dart';

class VenueGalleryScreen extends StatelessWidget {
  final Venue venue;

  const VenueGalleryScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Galeri',
          style: AppTextStyles.heading4.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<VenueDetailsProvider>(
        builder: (context, provider, child) {
          final galleryPhotos = provider.venue?.galleryPhotos ?? [];
          final allPhotos = galleryPhotos.isNotEmpty
              ? galleryPhotos
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
            child: PhotoThumbnailGrid(
              photos: allPhotos,
              showCategoryFilter: true,
              onPhotoTap: (index) =>
                  _openViewer(context, allPhotos, index, provider),
            ),
          );
        },
      ),
    );
  }

  void _openViewer(
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
          venueName: venue.name,
          onLike: (photoId) => provider.likePhoto(photoId),
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
