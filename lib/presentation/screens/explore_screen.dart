import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/discovery_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/discovery/map_view.dart';
import '../widgets/discovery/venue_list_view.dart';
import '../widgets/discovery/view_toggle.dart';
import '../widgets/discovery/featured_venues.dart';
import '../widgets/discovery/category_icons.dart';
import '../widgets/discovery/nearby_venues.dart';
import '../widgets/discovery/campaign_slider.dart';
import '../widgets/common/ad_banner_widget.dart';
import '../../core/utils/app_router.dart';
import '../../core/theme/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin, RouteAware {
  @override
  bool get wantKeepAlive => true;
  final ScrollController _scrollController = ScrollController();
  bool _isRouteActive = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Listen for location errors and show snackbar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocationError();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    // Route was pushed onto navigator and is now covering this route.
    if (mounted) {
      setState(() {
        _isRouteActive = false;
      });
    }
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    if (mounted) {
      setState(() {
        _isRouteActive = true;
      });
    }
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
    AppRouter.routeObserver.unsubscribe(this);
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

    return Consumer2<DiscoveryProvider, AppStateProvider>(
      builder: (context, provider, appState, child) {
        // Check for location errors when provider updates
        if (provider.hasLocationError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLocationErrorSnackbar(provider.locationError!);
            provider.clearLocationError();
          });
        }

        final bool isActive =
            appState.selectedBottomNavIndex == 0 && _isRouteActive;

        // Show home view
        if (provider.viewMode == DiscoveryViewMode.home) {
          return _buildHomeView(context, provider, isActive);
        }

        // Show map or list view
        return Stack(
          children: [
            // 1. Content (Map or List) - RepaintBoundary ile optimize
            Positioned.fill(
              child: RepaintBoundary(
                child: provider.viewMode == DiscoveryViewMode.map
                    // Wrap GoogleMap in another RepaintBoundary to isolate PlatformView redraws
                    // Only render Map if active to prevent background GPU usage
                    ? (isActive
                          ? const RepaintBoundary(child: DiscoveryMapView())
                          : const SizedBox.shrink())
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

            // 4. Loading Overlay - RepaintBoundary ile izole et
            // PERF: CircularProgressIndicator 60 FPS animasyon yapar
            // RepaintBoundary olmadan tüm ekran her frame'de repaint olur
            if (provider.isLoading &&
                provider.viewMode != DiscoveryViewMode.home)
              const Positioned.fill(
                child: RepaintBoundary(
                  child: Center(child: CircularProgressIndicator()),
                ),
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
          child: Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  provider.currentLocationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.gray900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            context.read<AppStateProvider>().setBottomNavIndex(3);
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

  Widget _buildHomeView(
    BuildContext context,
    DiscoveryProvider provider,
    bool isActive,
  ) {
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

                // Featured Venues - wrapped in RepaintBoundary
                const SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: FeaturedVenues(),
                    ),
                  ),
                ),

                // Category Icons - wrapped in RepaintBoundary
                const SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: CategoryIcons(),
                    ),
                  ),
                ),

                // Campaign Slider - wrapped in RepaintBoundary
                const SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: CampaignSlider(),
                    ),
                  ),
                ),

                // Ad Banner - wrapped in RepaintBoundary
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: isActive
                        ? const AdBannerWidget()
                        : const SizedBox.shrink(),
                  ),
                ),

                // Nearby Venues - wrapped in RepaintBoundary
                const SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: NearbyVenues(),
                    ),
                  ),
                ),
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
