import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_utils.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/search_provider.dart';
import 'popular_searches_section.dart';
import 'search_hero.dart';

/// Arama ekranının başlangıç görünümü
/// Kullanıcıdan bir mekan kategorisi seçmesini ister
class SearchInitialView extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback onClear;

  const SearchInitialView({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onSubmitted,
    required this.onClear,
  });

  static Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFFFF6B9D),
      Color(0xFF9C27B0),
      Color(0xFFE91E63),
      Color(0xFFFF5722),
      Color(0xFFFF9800),
      Color(0xFF00BCD4),
      Color(0xFF4CAF50),
      Color(0xFF3F51B5),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingCategories) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final categories = provider.categories;

        return CustomScrollView(
          slivers: [
            // Hero Section
            SliverToBoxAdapter(
              child: SearchHero(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onClear: onClear,
                onBack: () {
                  FocusScope.of(context).unfocus();
                  context.read<AppStateProvider>().setBottomNavIndex(0);
                },
                onMapTap: () {
                  FocusScope.of(context).unfocus();
                  context.read<DiscoveryProvider>().setViewMode(
                    DiscoveryViewMode.map,
                  );
                  context.read<AppStateProvider>().setBottomNavIndex(0);
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategoriler',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Aramaya başlamak için bir kategori seçin.',
                      style: TextStyle(fontSize: 14, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  final color = _getCategoryColor(index);
                  final icon = IconUtils.getCategoryIcon(category.icon);

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 10 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: GestureDetector(
                      onTap: () => provider.selectCategory(category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.gray100),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gray900,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }, childCount: categories.length),
              ),
            ),
            SliverToBoxAdapter(
              child: PopularSearchesSection(
                services: provider.popularServices,
                isLoading: provider.isLoadingServices,
                onServiceTap: (service) =>
                    provider.selectPopularService(service),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            // Suggested Venues Section
            if (provider.suggestedVenues.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Önerilen Mekanlar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final venue = provider.suggestedVenues[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            // Kategori seçimini simüle et veya direkt navigasyon
                            provider.selectCategory(
                              provider.categories.firstWhere(
                                (c) => c.id == venue.category?.id,
                                orElse: () => provider.categories.first,
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gray100),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    venue.imageUrl ?? '',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 100,
                                              height: 100,
                                              color: AppColors.gray100,
                                              child: const Icon(
                                                Icons.image,
                                                color: AppColors.gray400,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        venue.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        venue.address,
                                        style: TextStyle(
                                          color: AppColors.gray500,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: provider.suggestedVenues.length > 5
                        ? 5
                        : provider.suggestedVenues.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}
