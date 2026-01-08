import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/search_provider.dart';

/// Son aramalar bölümü
class RecentSearchesSection extends StatelessWidget {
  const RecentSearchesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final recentSearches = provider.recentSearches;

        if (recentSearches.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Son Aramalar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                GestureDetector(
                  onTap: () => provider.clearAllRecentSearches(),
                  child: const Text(
                    'Temizle',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent searches list
            ...recentSearches.map(
              (search) => _RecentSearchTile(
                query: search.query,
                location: search.location,
                onTap: () => provider.selectRecentSearch(search),
                onDelete: () => provider.deleteRecentSearch(search.id),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tek bir son arama öğesi
class _RecentSearchTile extends StatelessWidget {
  final String query;
  final String? location;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecentSearchTile({
    required this.query,
    this.location,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // History icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 18,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(width: 12),

            // Query and location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    query,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      location!,
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                  ],
                ],
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, size: 16, color: AppColors.gray400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
