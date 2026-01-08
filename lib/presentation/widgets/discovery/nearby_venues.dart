import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';
import 'package:go_router/go_router.dart';

class NearbyVenues extends StatelessWidget {
  const NearbyVenues({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.venues.isEmpty) {
          return const SizedBox.shrink();
        }

        if (provider.venues.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show first 6 venues
        final nearbyVenues = provider.venues.take(6).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yakınımdaki Mekanlar',
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                image: venue.heroImages.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(venue.heroImages.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: venue.heroImages.isEmpty ? AppColors.gray200 : null,
              ),
              child: venue.heroImages.isEmpty
                  ? const Icon(Icons.store, color: AppColors.gray400, size: 40)
                  : null,
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
