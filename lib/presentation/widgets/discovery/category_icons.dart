import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_utils.dart';
import '../../../data/models/venue_category.dart';
import 'discovery_shimmer_loading.dart';

class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

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
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCategories) {
          return const RepaintBoundary(child: CategoryIconsShimmer());
        }

        final categories = provider.categories;

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Kategoriler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 130,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryIconItem(
                    category: category,
                    color: _getCategoryColor(index),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class CategoryIconItem extends StatelessWidget {
  final VenueCategory category;
  final Color color;

  const CategoryIconItem({
    super.key,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<SearchProvider, AppStateProvider>(
      builder: (context, searchProvider, appState, child) {
        return GestureDetector(
          onTap: () {
            // 1. Kategoriyi Ara ekranında seç ve aramayı başlat
            searchProvider.selectCategory(category);

            // 2. Alt navigasyondan Arama sekmesine (index 1) geç
            appState.setBottomNavIndex(1);
          },
          child: SizedBox(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    IconUtils.getCategoryIcon(category.icon),
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
