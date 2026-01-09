import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';
import 'discovery_shimmer_loading.dart';

class NearbyVenues extends StatelessWidget {
  const NearbyVenues({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingNearby && provider.nearbyVenues.isEmpty) {
          return const NearbyVenuesShimmer();
        }

        if (provider.nearbyVenues.isEmpty) {
          return const SizedBox.shrink();
        }

        // No longer limiting to 10 venues
        final nearbyVenues = provider.nearbyVenues;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sana yakın yerler',
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
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: nearbyVenues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final venue = nearbyVenues[index];
                return NearbyVenueCard(venue: venue);
              },
            ),
            if (provider.isLoadingMoreNearby)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: NearbyVenuesShimmer(itemCount: 1),
              ),
            if (!provider.hasMoreNearby && nearbyVenues.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Daha fazla mekan bulunamadı',
                    style: TextStyle(color: AppColors.gray500, fontSize: 13),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class NearbyVenueCard extends StatelessWidget {
  final Venue venue;

  const NearbyVenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/venue/${venue.id}', extra: venue);
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with CachedNetworkImage and favorite button overlay
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: venue.heroImages.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: venue.heroImages.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: AppColors.gray200),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.gray200,
                                child: const Icon(
                                  Icons.store,
                                  color: AppColors.gray400,
                                  size: 40,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.gray200,
                              child: const Icon(
                                Icons.store,
                                color: AppColors.gray400,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    left: 8,
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
                          final favoritesProvider = context
                              .read<FavoritesProvider>();
                          final discoveryProvider = context
                              .read<DiscoveryProvider>();
                          final searchProvider = context.read<SearchProvider>();

                          await Future.wait([
                            favoritesProvider.toggleFavorite(venue),
                            discoveryProvider.toggleFavoriteVenue(venue),
                            searchProvider.toggleFavoriteVenue(venue),
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
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          venue.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          venue.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (venue.ratingCount > 0) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            venue.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${venue.ratingCount})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                        if (venue.ratingCount > 0 && venue.distance != null)
                          const Spacer(),
                        if (venue.distance != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${(venue.distance! / 1000).toStringAsFixed(1)} km',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
}
