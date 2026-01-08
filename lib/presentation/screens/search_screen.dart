import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../widgets/search/search_header.dart';
import '../widgets/search/search_filter_chips.dart';
import '../widgets/search/recent_searches_section.dart';
import '../widgets/search/popular_services_section.dart';
import '../widgets/search/suggested_venues_section.dart';
import '../widgets/search/search_results_list.dart';
import '../../core/theme/app_colors.dart';

/// Arama ekranı
/// Kullanıcıların hizmet, mekan ve konuma göre arama yapabilmesini sağlar
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Sync controller with provider
    final provider = context.read<SearchProvider>();
    _searchController.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search input
            SearchHeader(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) {
                context.read<SearchProvider>().setSearchQuery(value);
              },
              onClear: () {
                _searchController.clear();
                context.read<SearchProvider>().clearSearch();
              },
            ),

            // Filter chips row
            const SearchFilterChips(),

            // Content area
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, provider, _) {
                  // Loading state
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error state
                  if (provider.errorMessage != null) {
                    return _buildErrorState(provider.errorMessage!);
                  }

                  // Empty state (show recent searches + popular services)
                  if (provider.showEmptyState) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 16),
                          RecentSearchesSection(),
                          SizedBox(height: 24),
                          PopularServicesSection(),
                          SizedBox(height: 24),
                          SuggestedVenuesSection(),
                          SizedBox(height: 100),
                        ],
                      ),
                    );
                  }

                  // No results state
                  if (provider.showNoResults) {
                    return _buildNoResultsState();
                  }

                  // Results list
                  return SearchResultsList(results: provider.searchResults);
                },
              ),
            ),
          ],
        ),
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
                color: AppColors.primary.withOpacity(0.1),
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
            const Text(
              'Aradığını bulamadın mı?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arama kriterlerini genişleterek veya harita üzerinden yakındaki diğer mekanları inceleyebilirsin.',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to map view
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gray900,
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
