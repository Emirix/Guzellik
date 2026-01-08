import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/search_provider.dart';
import '../../../data/models/search_filter.dart';
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

              // Open now chip
              _ToggleChip(
                label: 'Şu An Açık',
                isSelected: filter.isOpenNow,
                onTap: () {
                  provider.setFilter(
                    filter.copyWith(isOpenNow: !filter.isOpenNow),
                  );
                },
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activeCount > 0 ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activeCount > 0 ? AppColors.primary : AppColors.gray200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 16,
              color: activeCount > 0 ? Colors.white : AppColors.gray700,
            ),
            const SizedBox(width: 4),
            Text(
              activeCount > 0 ? 'Filtrele ($activeCount)' : 'Filtrele',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: activeCount > 0 ? Colors.white : AppColors.gray700,
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
      case SortOption.priceAsc:
        return 'Fiyat (Artan)';
      case SortOption.priceDesc:
        return 'Fiyat (Azalan)';
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
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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

/// Toggle chip (seçilebilir)
class _ToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.gray700,
          ),
        ),
      ),
    );
  }
}
