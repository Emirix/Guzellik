import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models/venue_photo.dart';

class PhotoThumbnailGrid extends StatefulWidget {
  final List<VenuePhoto> photos;
  final Function(int index)? onPhotoTap;
  final bool showCategoryFilter;

  const PhotoThumbnailGrid({
    super.key,
    required this.photos,
    this.onPhotoTap,
    this.showCategoryFilter = true,
  });

  @override
  State<PhotoThumbnailGrid> createState() => _PhotoThumbnailGridState();
}

class _PhotoThumbnailGridState extends State<PhotoThumbnailGrid> {
  PhotoCategory? _selectedCategory;

  List<VenuePhoto> get _filteredPhotos {
    if (_selectedCategory == null) {
      return widget.photos;
    }
    return widget.photos
        .where((photo) => photo.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showCategoryFilter) _buildCategoryFilter(),
        if (widget.showCategoryFilter) const SizedBox(height: 16),
        _buildGrid(),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Hepsi', null),
          const SizedBox(width: 8),
          ...PhotoCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(category.displayName, category),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PhotoCategory? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildGrid() {
    final filteredPhotos = _filteredPhotos;

    if (filteredPhotos.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: filteredPhotos.length,
      itemBuilder: (context, index) {
        return _buildThumbnail(filteredPhotos[index], index);
      },
    );
  }

  Widget _buildThumbnail(VenuePhoto photo, int index) {
    final imageUrl = photo.thumbnailUrl ?? photo.url;

    return GestureDetector(
      onTap: () => widget.onPhotoTap?.call(index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),

            // Overlay for hero images
            if (photo.isHeroImage)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.star, size: 16, color: Colors.amber),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz fotoğraf yok',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu kategoride fotoğraf bulunmuyor',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
