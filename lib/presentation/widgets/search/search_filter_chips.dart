import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/search_provider.dart';
import '../../../data/models/search_filter.dart';
import '../../../data/models/service.dart';
import 'search_filter_bottom_sheet.dart';

/// Filtre chip'leri satırı
/// Horizontal scroll ile filtrele buttonu ve aktif filtreler gösterilir
class SearchFilterChips extends StatelessWidget {
  const SearchFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        final filter = provider.filter;

        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Filter button
              _FilterButton(
                activeCount: filter.activeFilterCount,
                onTap: () => _showFilterBottomSheet(context),
              ),
              const SizedBox(width: 8),

              // Sort chip
              _SortChip(
                currentSort: filter.sortBy,
                onSortChanged: (sort) {
                  provider.setFilter(filter.copyWith(sortBy: sort));
                },
              ),
              const SizedBox(width: 8),

              // Rating chip
              if (filter.minRating != null)
                _ActiveChip(
                  label: '${filter.minRating!.toStringAsFixed(1)}+ ⭐',
                  onRemove: () {
                    provider.setFilter(filter.copyWith(clearMinRating: true));
                  },
                ),
              if (filter.minRating != null) const SizedBox(width: 8),

              // Distance chip
              if (filter.maxDistanceKm != null)
                _ActiveChip(
                  label: '${filter.maxDistanceKm!.toInt()} km içinde',
                  onRemove: () {
                    provider.setFilter(filter.copyWith(clearMaxDistance: true));
                  },
                ),
              if (filter.maxDistanceKm != null) const SizedBox(width: 8),

              // Service chips
              ...filter.serviceIds.map((id) {
                final service = provider.categoryServices.firstWhere(
                  (s) => s.id == id,
                  orElse: () => Service(
                    id: id,
                    name: 'Hizmet',
                    venueServiceId: '',
                    createdAt: DateTime.now(),
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ActiveChip(
                    label: service.name,
                    onRemove: () {
                      final newServiceIds = List<String>.from(filter.serviceIds)
                        ..remove(id);
                      provider.setFilter(
                        filter.copyWith(serviceIds: newServiceIds),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchFilterBottomSheet(),
    );
  }
}

/// Filtre butonu
class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFilterActive = activeCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.gray900, // Black background as in design
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                const Icon(Icons.tune, size: 18, color: Colors.white),
                if (isFilterActive)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gray900,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              'Filtrele',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sıralama chip'i
class _SortChip extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortChanged;

  const _SortChip({required this.currentSort, required this.onSortChanged});

  String get _sortLabel {
    switch (currentSort) {
      case SortOption.recommended:
        return 'Önerilen';
      case SortOption.nearest:
        return 'En Yakın';
      case SortOption.highestRated:
        return 'En Yüksek Puan';
      case SortOption.mostReviewed:
        return 'En Çok Yorum';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      onSelected: onSortChanged,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        _buildMenuItem(SortOption.recommended, 'Önerilen'),
        _buildMenuItem(SortOption.nearest, 'En Yakın'),
        _buildMenuItem(SortOption.highestRated, 'En Yüksek Puan'),
        _buildMenuItem(SortOption.mostReviewed, 'En Çok Yorum'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _sortLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<SortOption> _buildMenuItem(SortOption option, String label) {
    return PopupMenuItem<SortOption>(
      value: option,
      child: Row(
        children: [
          if (currentSort == option)
            const Icon(Icons.check, size: 16, color: AppColors.primary)
          else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

/// Aktif filtre chip'i (kaldırılabilir)
class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
