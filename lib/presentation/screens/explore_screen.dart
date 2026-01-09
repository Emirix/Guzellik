import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/discovery_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/discovery/map_view.dart';
import '../widgets/discovery/venue_list_view.dart';
import '../widgets/discovery/view_toggle.dart';
import '../widgets/discovery/location_selection_bottom_sheet.dart';
import '../widgets/discovery/featured_venues.dart';
import '../widgets/discovery/category_icons.dart';
import '../widgets/discovery/nearby_venues.dart';
import '../widgets/discovery/map_preview_card.dart';
import '../widgets/common/ad_banner_widget.dart';
import '../../core/theme/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Listen for location errors and show snackbar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationError();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<DiscoveryProvider>();
      if (provider.viewMode == DiscoveryViewMode.home) {
        provider.loadMoreNearbyVenues();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkLocationError() {
    final provider = context.read<DiscoveryProvider>();
    if (provider.hasLocationError) {
      _showLocationErrorSnackbar(provider.locationError!);
      provider.clearLocationError();
    }
  }

  void _showLocationErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Ayarlar',
          onPressed: () {
            // Open app settings for location permission
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        // Check for location errors when provider updates
        if (provider.hasLocationError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLocationErrorSnackbar(provider.locationError!);
            provider.clearLocationError();
          });
        }

        // Show home view
        if (provider.viewMode == DiscoveryViewMode.home) {
          return _buildHomeView(context, provider);
        }

        // Show map or list view
        return Stack(
          children: [
            // 1. Content (Map or List) - RepaintBoundary ile optimize
            Positioned.fill(
              child: RepaintBoundary(
                child: provider.viewMode == DiscoveryViewMode.map
                    ? const DiscoveryMapView()
                    : const VenueListView(),
              ),
            ),

            // 2. Top Header & Search Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 24,
                  16,
                  16,
                ),
                decoration: BoxDecoration(
                  gradient: provider.viewMode == DiscoveryViewMode.map
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color.fromRGBO(255, 255, 255, 0.9),
                            const Color.fromRGBO(255, 255, 255, 0.5),
                            Colors.transparent,
                          ],
                        )
                      : null,
                  color: provider.viewMode == DiscoveryViewMode.list
                      ? AppColors.background
                      : null,
                ),
                child: Column(
                  children: [_buildLocationHeader(context, provider)],
                ),
              ),
            ),

            // 3. View mode toggle (Floating at bottom center)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(child: const ViewToggle()),
            ),

            // 4. Loading Overlay - only show when actually loading data
            if (provider.isLoading &&
                provider.viewMode != DiscoveryViewMode.home)
              const Positioned.fill(
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLocationHeader(
    BuildContext context,
    DiscoveryProvider provider,
  ) {
    final isMapView = provider.viewMode == DiscoveryViewMode.map;

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const LocationSelectionBottomSheet(),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/logo-transparent.svg',
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konum',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.currentLocationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.expand_more,
                            color: AppColors.gray900,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            context.read<AppStateProvider>().setBottomNavIndex(2);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gray100),
            ),
            child: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.gray700,
                  size: 22,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isMapView) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildHomeView(BuildContext context, DiscoveryProvider provider) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header with location
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [_buildLocationHeader(context, provider)],
                    ),
                  ),
                ),

                // Featured Venues
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: FeaturedVenues(),
                  ),
                ),

                // Category Icons
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: CategoryIcons(),
                  ),
                ),

                // Map Preview Card - Harita Görünümü
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: MapPreviewCard(),
                  ),
                ),

                // Ad Banner
                const SliverToBoxAdapter(child: AdBannerWidget()),

                // Nearby Venues
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: NearbyVenues(),
                  ),
                ),

                // Bottom padding for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),

            // Floating Action Button for Map View
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => provider.setViewMode(DiscoveryViewMode.map),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray900,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromRGBO(0, 0, 0, 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.map, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Harita Görünümü',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
