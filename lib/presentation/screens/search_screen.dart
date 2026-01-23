import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/search_provider.dart';
import '../providers/app_state_provider.dart';
import '../providers/discovery_provider.dart';
import '../widgets/search/search_header.dart';
import '../widgets/search/search_filter_chips.dart';
import '../widgets/search/recent_searches_section.dart';
import '../widgets/search/popular_services_section.dart';
import '../widgets/search/search_categories_section.dart';
import '../widgets/search/suggested_venues_section.dart';
import '../widgets/search/search_results_list.dart';
import '../widgets/common/ad_banner_widget.dart';
import '../../core/utils/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/search/search_shimmer_loading.dart';
import '../../data/models/venue_category.dart';

/// Arama ekranı
/// Kullanıcıların hizmet, mekan ve konuma göre arama yapabilmesini sağlar
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isRouteActive = true;
  DiscoveryProvider? _discoveryProvider;
  late SearchProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    // Sync controller with provider
    _searchProvider = context.read<SearchProvider>();
    _searchController.text = _searchProvider.searchQuery;
    _searchProvider.addListener(_onProviderChanged);

    // Sync location from DiscoveryProvider and listen for changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncLocation();
    });
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
                // Logo Header - Hide when showing results to save space
                if (!provider.isResultsMode)
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
    return Container(
      width: double.infinity,
      height: 160,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Arka Plan Resmi
            Image.asset(
              'assets/search_hero.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            // Karartma Katmanı (Gradyan)
            Container(
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
            // İçerik
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
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
                  const SizedBox(height: 12),
                  // Hero içindeki Arama Çubuğu
                  _buildHeroSearchInput(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSearchInput(SearchProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Container(
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
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
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
        return _buildErrorState(provider.errorMessage!);
      }
      if (provider.showNoResults) return _buildNoResultsState();

      return SearchResultsList(
        results: provider.searchResults,
        highlightedService: provider.searchQuery.isNotEmpty
            ? provider.searchQuery
            : null,
      );
    }

    // 2. Typing Mode - Hero stays fixed at top, suggestions scroll below
    if (provider.searchQuery.isNotEmpty) {
      return Column(
        children: [
          _buildSearchHero(provider),
          Expanded(child: _buildSuggestionsList(provider)),
        ],
      );
    }

    // 3. Initial Mode - Everything scrolls together (Hero + Categories + Suggestions)
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSearchHero(provider), _buildInitialContent()],
      ),
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
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: provider.suggestions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final suggestion = provider.suggestions[index];
          return ListTile(
            leading: const Icon(Icons.search, color: AppColors.gray400),
            title: Text(
              suggestion.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            subtitle: Text(
              suggestion.category?.name ?? 'Mekan',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
            onTap: () {
              provider.setSearchQuery(suggestion.name);
              provider.search();
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
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

  Widget _buildNoResultsState() {
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
