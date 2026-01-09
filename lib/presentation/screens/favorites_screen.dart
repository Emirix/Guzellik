import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/favorites_provider.dart';
import '../widgets/common/custom_header.dart';
import '../widgets/common/ad_banner_widget.dart';
import '../widgets/search/search_result_card.dart';

/// Favorites screen - Displays Favorited and Followed venues in tabs
class FavoritesScreen extends StatefulWidget {
  final String? initialTab;

  const FavoritesScreen({super.key, this.initialTab});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Set initial tab based on parameter: 'following' = 1, else = 0
    final initialIndex = widget.initialTab == 'following' ? 1 : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
    _tabController.addListener(_handleTabChange);

    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadAll();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final provider = context.read<FavoritesProvider>();
    final newTab = _tabController.index == 0
        ? FavoritesTab.favorites
        : FavoritesTab.following;
    if (provider.currentTab != newTab) {
      provider.setTab(newTab);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomHeader(
            title: 'Favorilerim',
            subtitle: 'Kaydettiğiniz ve takip ettiğiniz mekanlar',
          ),
          _buildTabBar(),
          const AdBannerWidget(),
          Expanded(child: _buildTabBarView()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.gray500,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Favoriler'),
          Tab(text: 'Takip Ettiklerim'),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (provider.errorMessage != null) {
          return _buildErrorState(provider.errorMessage!);
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildVenueList(
              provider.favoriteVenues,
              'Henüz favori mekanınız yok',
              'Beğendiğiniz mekanları favorilere ekleyerek burada görebilirsiniz.',
            ),
            _buildVenueList(
              provider.followedVenues,
              'Henüz kimseyi takip etmiyorsunuz',
              'Mekanları takip ederek güncellemelerden haberdar olabilirsiniz.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildVenueList(
    List<dynamic> venues,
    String emptyTitle,
    String emptySubtitle,
  ) {
    if (venues.isEmpty) {
      return _buildEmptyState(emptyTitle, emptySubtitle);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<FavoritesProvider>().loadAll(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        itemCount: venues.length,
        itemBuilder: (context, index) {
          final venue = venues[index];
          return SearchResultCard(venue: venue);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 40,
                color: AppColors.gray300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppColors.gray700)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<FavoritesProvider>().loadAll(),
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}
