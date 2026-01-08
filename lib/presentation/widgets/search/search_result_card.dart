import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';

/// Arama sonucu kartı
/// design/ara/code.html tasarımına uygun venue kartı
class SearchResultCard extends StatelessWidget {
  final Venue venue;
  final String? highlightedService;

  const SearchResultCard({
    super.key,
    required this.venue,
    this.highlightedService,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/venue/${venue.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue image with distance badge
            _buildVenueImage(),
            const SizedBox(width: 12),

            // Venue info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and favorite button row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Favorite button
                      Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.gray400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Rating and review count
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        venue.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${venue.ratingCount} yorum)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Service tags
                  _buildServiceTags(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenueImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: venue.imageUrl != null
              ? Image.network(
                  venue.imageUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),
        // Distance badge
        if (venue.distance != null)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${(venue.distance! / 1000).toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.gray100,
      child: const Icon(Icons.store, size: 32, color: AppColors.gray400),
    );
  }

  Widget _buildServiceTags() {
    // Use features as service tags
    final services = venue.features;
    if (services.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: services.take(3).map((service) {
        final isHighlighted =
            highlightedService != null &&
            service.toLowerCase().contains(highlightedService!.toLowerCase());

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.gray100,
            borderRadius: BorderRadius.circular(6),
            border: isHighlighted
                ? Border.all(color: AppColors.primary.withOpacity(0.3))
                : null,
          ),
          child: Text(
            service,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
              color: isHighlighted ? AppColors.primary : AppColors.gray600,
            ),
          ),
        );
      }).toList(),
    );
  }
}
