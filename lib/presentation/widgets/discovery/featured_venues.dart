import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';

class FeaturedVenues extends StatelessWidget {
  const FeaturedVenues({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingHome && provider.featuredVenues.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.featuredVenues.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Öne Çıkanlar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.setViewMode(DiscoveryViewMode.list);
                    },
                    child: const Text(
                      'Tümünü gör',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: provider.featuredVenues.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final venue = provider.featuredVenues[index];
                  return FeaturedVenueCard(venue: venue, index: index);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class FeaturedVenueCard extends StatelessWidget {
  final Venue venue;
  final int index;

  const FeaturedVenueCard({
    super.key,
    required this.venue,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the badge type based on index for variety
    final String? badgeText = index % 2 == 0 ? '%20 İndirim' : 'Popüler';
    final Color badgeColor = index % 2 == 0
        ? AppColors.primary
        : Colors.white.withOpacity(0.3);
    final Color textColor = index % 2 == 0 ? Colors.white : Colors.white;

    return GestureDetector(
      onTap: () {
        context.push('/venue/${venue.id}', extra: venue);
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: venue.heroImages.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(venue.heroImages.first),
                  fit: BoxFit.cover,
                )
              : null,
          color: venue.heroImages.isEmpty ? AppColors.gray200 : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dark gradient at the bottom
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Badge
            if (badgeText != null)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                    border: index % 2 != 0
                        ? Border.all(color: Colors.white.withOpacity(0.5))
                        : null,
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Favorite button
            Positioned(
              top: 16,
              right: 16,
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
                    await favoritesProvider.toggleFavorite(venue);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
                    }
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Center(
                        child: Icon(
                          venue.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: venue.isFavorited
                              ? AppColors.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${venue.rating.toStringAsFixed(1)} (${venue.ratingCount})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      if (venue.distance != null) ...[
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 8),
                        Text(
                          '${(venue.distance! / 1000).toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
