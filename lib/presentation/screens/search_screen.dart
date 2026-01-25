import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/search_provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/discovery_provider.dart';
import '../widgets/search/search_header.dart';
import '../widgets/search/search_filter_chips.dart';

import '../widgets/search/popular_services_section.dart';
import '../widgets/search/search_categories_section.dart';
import '../widgets/search/suggested_venues_section.dart';
import '../widgets/search/search_results_list.dart';
import '../widgets/common/ad_banner_widget.dart';
import '../../core/utils/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/search/search_shimmer_loading.dart';
import '../../data/models/venue_category.dart';
import '../../data/models/venue.dart';

/// Arama ekranı
/// Kullanıcıların hizmet, mekan ve konuma göre arama yapabilmesini sağlar
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with RouteAware, SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isRouteActive = true;
  DiscoveryProvider? _discoveryProvider;
  late SearchProvider _searchProvider;

  // Animasyon kontrolcüleri
  late AnimationController _animationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<double> _searchBarSlideAnimation;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    // Sync controller with provider
    _searchProvider = context.read<SearchProvider>();
    _searchController.text = _searchProvider.searchQuery;
    _searchProvider.addListener(_onProviderChanged);

    // Animasyon controller'ı başlat
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Hero fade out animasyonu (1.0 -> 0.0)
    _heroFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Arama çubuğu yukarı kayma animasyonu
    _searchBarSlideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Focus listener ekle
    _searchFocusNode.addListener(_onSearchFocusChange);

    // Sync location from DiscoveryProvider and listen for changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLocation();
    });
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus && !_isSearchFocused) {
      setState(() => _isSearchFocused = true);
      _animationController.forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final discoveryProvider = context.read<DiscoveryProvider>();
    if (_discoveryProvider != discoveryProvider) {
      _discoveryProvider?.removeListener(_syncLocation);
      _discoveryProvider = discoveryProvider;
      _discoveryProvider?.addListener(_syncLocation);
    }
    _searchProvider = context.read<SearchProvider>();
    final route = ModalRoute.of(context);
    if (route is ModalRoute<void>) {
      AppRouter.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    if (mounted) {
      setState(() {
        _isRouteActive = false;
      });
    }
  }

  @override
  void didPopNext() {
    if (mounted) {
      setState(() {
        _isRouteActive = true;
      });
    }
  }

  void _syncLocation() {
    if (!mounted) return;
    final discoveryProvider = context.read<DiscoveryProvider>();
    final searchProvider = context.read<SearchProvider>();

    if (discoveryProvider.currentPosition != null) {
      searchProvider.setLocation(
        latitude: discoveryProvider.currentPosition!.latitude,
        longitude: discoveryProvider.currentPosition!.longitude,
        province: discoveryProvider.manualCity,
        district: discoveryProvider.manualDistrict,
        // provinceId: ... (if available)
      );
    }
  }

  void _onProviderChanged() {
    if (!mounted) return;
    final query = context.read<SearchProvider>().searchQuery;
    if (_searchController.text != query) {
      _searchController.text = query;
      // Cursor positioning
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }
  }

  @override
  void dispose() {
    AppRouter.routeObserver.unsubscribe(this);
    _searchProvider.removeListener(_onProviderChanged);
    _discoveryProvider?.removeListener(_syncLocation);
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<SearchProvider, AppStateProvider>(
          builder: (context, provider, appState, child) {
            return Column(
              children: [
                // Logo Header - Hide when showing results or search is focused
                if (!provider.isResultsMode && !_isSearchFocused)
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      MediaQuery.of(context).padding.top + 12,
                      16,
                      8,
                    ),
                    color: AppColors.background,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/maskot.png', width: 40, height: 40),
                        const SizedBox(width: 12),
                        Text(
                          'Güzellik Haritam',
                          style: GoogleFonts.outfit(
                            color: AppColors.primary,
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Compact Search Header - Only show when results mode is active
                if (provider.isResultsMode)
                  SearchHeader(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      context.read<SearchProvider>().setSearchQuery(value);
                    },
                    onSubmitted: (value) {
                      context.read<SearchProvider>().search();
                    },
                    onClear: () {
                      _searchController.clear();
                      context.read<SearchProvider>().clearSearch();
                    },
                  ),

                // Selected category banner
                if (provider.isCategorySelected && provider.isResultsMode)
                  _buildSelectedCategoryBanner(provider.selectedCategory!, () {
                    provider.clearFilters();
                  }),

                // Filter chips row and Ad Banner - hide when Hero is visible
                if (provider.isResultsMode) ...[
                  const SearchFilterChips(),
                  if (appState.selectedBottomNavIndex == 1 && _isRouteActive)
                    const AdBannerWidget(),
                ],

                // Content area
                Expanded(child: _buildSearchContent(provider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchHero(SearchProvider provider) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Hero yüksekliği: 160 -> 80 (sadece arama çubuğu için)
        final heroHeight = 160.0 - (80.0 * _searchBarSlideAnimation.value);
        // Border radius: 24 -> 0
        final borderRadius = 24.0 * (1 - _searchBarSlideAnimation.value);
        // Margin: 16 -> 0
        final horizontalMargin = 16.0 * (1 - _searchBarSlideAnimation.value);
        final bottomMargin = 16.0 * (1 - _searchBarSlideAnimation.value);

        return Container(
          width: double.infinity,
          height: heroHeight,
          margin: EdgeInsets.fromLTRB(
            horizontalMargin,
            0,
            horizontalMargin,
            bottomMargin,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: [
                // Arka Plan Resmi - Fade out
                Opacity(
                  opacity: _heroFadeAnimation.value,
                  child: Image.asset(
                    'assets/search_hero.jpg',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Karartma Katmanı (Gradyan) - Fade out
                Opacity(
                  opacity: _heroFadeAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Arka plan rengi (animasyon sırasında görünür)
                Container(
                  color: AppColors.background.withValues(
                    alpha: _searchBarSlideAnimation.value,
                  ),
                ),
                // İçerik
                Positioned(
                  left: 24.0 - (8.0 * _searchBarSlideAnimation.value),
                  right: 24.0 - (8.0 * _searchBarSlideAnimation.value),
                  bottom: 16.0 * (1 - _searchBarSlideAnimation.value) + 12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Başlık - Fade out
                      if (_heroFadeAnimation.value > 0)
                        Opacity(
                          opacity: _heroFadeAnimation.value,
                          child: Text(
                            'Güzelliği bul',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 12 * _heroFadeAnimation.value),
                      // Hero içindeki Arama Çubuğu
                      _buildHeroSearchInput(provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSearchInput(SearchProvider provider) {
    // Animasyon sırasında harita butonunu gizle
    final showMapButton = _heroFadeAnimation.value > 0.5;

    return Row(
      children: [
        // Geri butonu - sadece arama odaklandığında göster
        if (_isSearchFocused)
          GestureDetector(
            onTap: () {
              _searchController.clear();
              provider.clearSearch();
              setState(() => _isSearchFocused = false);
              _animationController.reverse();
              _searchFocusNode.unfocus();
            },
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray200),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.gray700,
                size: 20,
              ),
            ),
          ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Arama çubuğunun herhangi bir yerine tıklayınca focus ver
              if (!_isSearchFocused) {
                setState(() => _isSearchFocused = true);
                _animationController.forward();
                // Focus'u bir sonraki frame'e ertele - widget rebuild tamamlansın
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _searchFocusNode.requestFocus();
                });
              } else {
                _searchFocusNode.requestFocus();
              }
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: _isSearchFocused
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        provider.setSearchQuery(value);
                      },
                      onSubmitted: (value) {
                        provider.search();
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray900,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Hizmet veya mekan ara...',
                        hintStyle: TextStyle(
                          color: AppColors.gray400,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  // Temizle butonu - metin varken göster
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, _) {
                      if (value.text.isNotEmpty) {
                        return GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.close,
                              color: AppColors.gray400,
                              size: 20,
                            ),
                          ),
                        );
                      }
                      return const SizedBox(width: 12);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // Harita butonu - sadece animasyon olmadığında göster
        if (showMapButton) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              context.read<DiscoveryProvider>().setViewMode(
                DiscoveryViewMode.map,
              );
              context.read<AppStateProvider>().setBottomNavIndex(0);
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.map_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedCategoryBanner(
    VenueCategory category,
    VoidCallback onClear,
  ) {
    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (category.imageUrl != null)
              CachedNetworkImage(
                imageUrl: category.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.spa_outlined,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arama Kategorisi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Change button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onClear,
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                size: 18,
                                color: AppColors.gray800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Değiştir',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray800,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent(SearchProvider provider) {
    // 1. Full Results Mode (After Submit or Category Select)
    if (provider.isResultsMode) {
      if (provider.isLoading) return const SearchShimmerLoading();
      if (provider.errorMessage != null) {
        return buildErrorState(provider.errorMessage!);
      }
      if (provider.showNoResults) return buildNoResultsState();

      return SearchResultsList(
        results: provider.searchResults,
        highlightedService: provider.searchQuery.isNotEmpty
            ? provider.searchQuery
            : null,
      );
    }

    // Hero ve içerik her zaman aynı yapıda - sadece içerik değişiyor
    return Column(
      children: [
        _buildSearchHero(provider),
        Expanded(
          child: _isSearchFocused
              ? (provider.isLoading
                    ? _buildSuggestionSkeletonGrid()
                    : (provider.suggestions.isNotEmpty
                          ? _buildSuggestionsList(provider)
                          : SingleChildScrollView(
                              child: _buildInitialContent(),
                            )))
              : SingleChildScrollView(child: _buildInitialContent()),
        ),
      ],
    );
  }

  Widget _buildInitialContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 16),
          SearchCategoriesSection(),
          SizedBox(height: 24),
          PopularServicesSection(),
          SizedBox(height: 24),
          SuggestedVenuesSection(),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(SearchProvider provider) {
    return Container(
      color: AppColors.background,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 220, // Sabit yükseklik
        ),
        itemCount: provider.suggestions.length,
        itemBuilder: (context, index) {
          final venue = provider.suggestions[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildSuggestionCard(venue, provider),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard(Venue venue, SearchProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setSearchQuery(venue.name);
        provider.search();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim - sabit yükseklik
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: venue.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: venue.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: AppColors.gray100),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.gray100,
                          child: const Icon(
                            Icons.spa_outlined,
                            size: 32,
                            color: AppColors.gray300,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.gray100,
                        child: const Icon(
                          Icons.spa_outlined,
                          size: 32,
                          color: AppColors.gray300,
                        ),
                      ),
              ),
            ),
            // İçerik - kalan alan
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İsim
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Kategori
                  Text(
                    venue.category?.name ?? 'Mekan',
                    style: TextStyle(fontSize: 11, color: AppColors.gray500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Rating ve Mesafe
                  Row(
                    children: [
                      if (venue.ratingCount > 0) ...[
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          venue.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                        ),
                      ],
                      if (venue.distance != null) ...[
                        if (venue.ratingCount > 0) const SizedBox(width: 8),
                        Icon(
                          Icons.near_me_outlined,
                          size: 11,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${(venue.distance! / 1000).toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.gray500,
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

  Widget _buildSuggestionSkeletonGrid() {
    return Container(
      color: AppColors.background,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 220,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const _SkeletonCard();
        },
      ),
    );
  }
}

/// Shimmer animasyonlu skeleton kart
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resim Skeleton
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value, 0),
                      colors: [
                        AppColors.gray200,
                        AppColors.gray100,
                        AppColors.gray200,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // İçerik Skeleton
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(width: 100, height: 14),
                const SizedBox(height: 6),
                _buildShimmerBox(width: 60, height: 10),
                const SizedBox(height: 12),
                _buildShimmerBox(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [AppColors.gray200, AppColors.gray100, AppColors.gray200],
            ),
          ),
        );
      },
    );
  }
}

/// Arama ekranı ana bileşenleri (devam)
extension _SearchScreenErrorStates on _SearchScreenState {
  Widget buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SearchProvider>().search();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoResultsState() {
    final provider = context.read<SearchProvider>();
    final isCategorySelected = provider.isCategorySelected;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCategorySelected
                  ? 'Bu kategoride mekan bulunamadı'
                  : 'Aradığını bulamadın mı?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCategorySelected
                  ? 'Bu kategoride henüz kayıtlı mekan bulunmuyor. Başka bir kategori seçebilir veya harita üzerinden yakındaki mekanları inceleyebilirsin.'
                  : 'Arama kriterlerini genişleterek veya harita üzerinden yakındaki diğer mekanları inceleyebilirsin.',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isCategorySelected)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.clearFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Başka Kategori Seç'),
                ),
              ),
            if (isCategorySelected) const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to map view in Keşfet tab
                  context.read<DiscoveryProvider>().setViewMode(
                    DiscoveryViewMode.map,
                  );
                  context.read<AppStateProvider>().setBottomNavIndex(0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCategorySelected
                      ? AppColors.gray900
                      : AppColors.gray900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Haritada Görüntüle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
