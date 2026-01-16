import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/search_provider.dart';
import 'discovery_shimmer_loading.dart';

class FeaturedVenues extends StatefulWidget {
  const FeaturedVenues({super.key});

  @override
  State<FeaturedVenues> createState() => _FeaturedVenuesState();
}

class _FeaturedVenuesState extends State<FeaturedVenues> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DiscoveryProvider>().loadMoreFeaturedVenues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingHome && provider.featuredVenues.isEmpty) {
          return const RepaintBoundary(child: FeaturedVenuesShimmer());
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
              height: 260,
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount:
                    provider.featuredVenues.length +
                    (provider.isLoadingMoreFeatured ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  if (index < provider.featuredVenues.length) {
                    final venue = provider.featuredVenues[index];
                    return FeaturedVenueCard(venue: venue, index: index);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: SizedBox(
                        width: 280,
                        child: FeaturedVenuesShimmerCard(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class FeaturedVenuesShimmerCard extends StatefulWidget {
  const FeaturedVenuesShimmerCard({super.key});

  @override
  State<FeaturedVenuesShimmerCard> createState() =>
      _FeaturedVenuesShimmerCardState();
}

class _FeaturedVenuesShimmerCardState extends State<FeaturedVenuesShimmerCard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addObserver(this);
    startAnimation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopAnimation();
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;
    _controller.repeat();
  }

  void stopAnimation() {
    if (!_isAnimating) return;
    _isAnimating = false;
    _controller.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause animation when app is not visible to reduce GPU work
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      stopAnimation();
    } else if (state == AppLifecycleState.resumed && mounted) {
      startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.gray100,
          ),
        ),
        builder: (context, child) {
          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value + 1, 0),
                colors: const [
                  AppColors.gray100,
                  AppColors.gray50,
                  AppColors.gray100,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 180,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
    // EXCEPT for Valery (ID: 77777777-7777-7777-7777-777777777777) as requested
    final bool isValery = venue.id == '77777777-7777-7777-7777-777777777777';
    final String? badgeText = (index % 2 == 0 && !isValery)
        ? '%20 İndirim'
        : 'Popüler';
    final Color badgeColor = (index % 2 == 0 && !isValery)
        ? AppColors.primary
        : const Color.fromRGBO(255, 255, 255, 0.3);
    final Color textColor = Colors.white;

    return GestureDetector(
      onTap: () {
        context.push('/venue/${venue.id}', extra: venue);
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.gray200,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background image with CachedNetworkImage
            Builder(
              builder: (context) {
                final imageUrl =
                    venue.imageUrl ??
                    (venue.heroImages.isNotEmpty
                        ? venue.heroImages.first
                        : null);

                if (imageUrl == null) return const SizedBox.shrink();

                return Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: AppColors.gray200),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.gray200,
                      child: const Icon(
                        Icons.store,
                        color: AppColors.gray400,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Dark gradient at the bottom
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color.fromRGBO(0, 0, 0, 0.7),
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
                        ? Border.all(
                            color: const Color.fromRGBO(255, 255, 255, 0.5),
                          )
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

            // Favorite button - OPTIMIZED: Removed expensive BackdropFilter
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
                    final discoveryProvider = context.read<DiscoveryProvider>();
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
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    shape: BoxShape.circle,
                  ),
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
                  if (venue.ratingCount > 0)
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
                          const Text(
                            '•',
                            style: TextStyle(color: Colors.white),
                          ),
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
                    )
                  else if (venue.distance != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(venue.distance! / 1000).toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
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
