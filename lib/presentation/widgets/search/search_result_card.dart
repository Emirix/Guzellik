import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/favorites_provider.dart';

/// Arama sonucu kartı - Premium tasarım
/// Tasarıma uygun büyük resimli venue kartı
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top image section with badges
            _buildImageSection(context),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating row
                  _buildTitleRow(),
                  const SizedBox(height: 6),

                  // Location
                  _buildLocation(),
                  const SizedBox(height: 10),

                  // Description
                  if (venue.description?.isNotEmpty == true) ...[
                    _buildDescription(),
                    const SizedBox(height: 12),
                  ],

                  // Service tags
                  _buildServiceTags(),
                  const SizedBox(height: 14),

                  // Bottom row with actions
                  _buildBottomRow(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Main image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: venue.imageUrl != null
              ? Image.network(
                  venue.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),
        ),

        // Gradient overlay for better text visibility
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
              ),
            ),
          ),
        ),

        // "ÖNERİLEN" badge (if preferred)
        if (venue.isPreferred)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ÖNERİLEN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Distance badge (bottom right)
        if (venue.distance != null)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(venue.distance! / 1000).toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Favorite button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
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
                final favoritesProvider = context.read<FavoritesProvider>();
                final searchProvider = context.read<SearchProvider>();
                final discoveryProvider = context.read<DiscoveryProvider>();

                await Future.wait([
                  favoritesProvider.toggleFavorite(venue),
                  searchProvider.toggleFavoriteVenue(venue),
                  discoveryProvider.toggleFavoriteVenue(venue),
                ]);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                venue.isFavorited ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gray100, AppColors.gray200],
        ),
      ),
      child: const Icon(Icons.store, size: 48, color: AppColors.gray400),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Venue name
        Expanded(
          child: Text(
            venue.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),

        // Rating and reviews in a beautiful badge
        _buildRatingBadge(),
      ],
    );
  }

  Widget _buildRatingBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.star_rounded, size: 20, color: Color(0xFFFFB300)),
        const SizedBox(width: 2),
        Text(
          venue.rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827), // Siyah puan
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${venue.ratingCount})',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 14, color: AppColors.gray400),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            venue.address,
            style: TextStyle(fontSize: 13, color: AppColors.gray500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      venue.description!,
      style: TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.4),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildServiceTags() {
    // Use features as service tags
    final services = venue.features;
    if (services.isEmpty) return const SizedBox.shrink();

    const maxVisibleTags = 5;
    final visibleServices = services.take(maxVisibleTags).toList();
    final hasMore = services.length > maxVisibleTags;
    final moreCount = services.length - maxVisibleTags;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...visibleServices.map((service) {
          final isHighlighted =
              highlightedService != null &&
              service.toLowerCase().contains(highlightedService!.toLowerCase());

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHighlighted
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.primary.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Text(
              service,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          );
        }),
        if (hasMore)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gray200, width: 1),
            ),
            child: Text(
              '+$moreCount',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gray700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        // Takip Et Button (Secondary)
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final authProvider = context.read<AuthProvider>();
                if (!authProvider.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen önce giriş yapın'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // context.push('/login'); // Uncomment if login route exists
                  return;
                }

                // Update both providers if available to keep UI in sync across different screens
                try {
                  // We can use context.read directly since they are provided at the root
                  final searchProvider = context.read<SearchProvider>();
                  final discoveryProvider = context.read<DiscoveryProvider>();
                  final favoritesProvider = context.read<FavoritesProvider>();

                  await Future.wait([
                    searchProvider.toggleFollowVenue(venue),
                    discoveryProvider.toggleFollowVenue(venue),
                    favoritesProvider.toggleFollow(venue),
                  ]);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('İşlem sırasında bir hata oluştu: $e'),
                      ),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: venue.isFollowing
                      ? AppColors.primary.withOpacity(0.05)
                      : AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: venue.isFollowing
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.gray200,
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    venue.isFollowing ? 'Takibi Bırak' : 'Takip Et',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: venue.isFollowing
                          ? AppColors.primary
                          : AppColors.gray700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // İncele Button (Primary)
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/venue/${venue.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFE91E63)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'İncele',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
