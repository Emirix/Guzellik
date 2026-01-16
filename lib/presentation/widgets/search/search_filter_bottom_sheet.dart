import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/search_provider.dart';
import '../../../data/models/search_filter.dart';

/// Gelişmiş filtreleme bottom sheet
/// design/filtreleme_sayfası/screen.png tasarımına uygun
class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({super.key});

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SearchFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = context.read<SearchProvider>().filter;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: AppColors.gray700),
                    ),
                    const Text(
                      'Filtrele',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearFilters,
                      child: const Text(
                        'Temizle',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort section
                      _buildSortSection(),
                      const SizedBox(height: 24),

                      // Services section (hizmetlere göre filtreleme)
                      _buildServicesSection(),
                      const SizedBox(height: 24),

                      // Distance section
                      _buildDistanceSection(),
                      const SizedBox(height: 24),

                      // Rating section
                      _buildRatingSection(),
                      const SizedBox(height: 100),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Apply button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sonuçları Göster',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sıralama',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSortChip(SortOption.recommended, 'Önerilen'),
            _buildSortChip(SortOption.nearest, 'En Yakın'),
            _buildSortChip(SortOption.highestRated, 'En Yüksek Puan'),
            _buildSortChip(SortOption.mostReviewed, 'En Çok Yorum Alan'),
          ],
        ),
      ],
    );
  }

  Widget _buildSortChip(SortOption option, String label) {
    final isSelected = _tempFilter.sortBy == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempFilter = _tempFilter.copyWith(sortBy: option);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
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
            color: isSelected ? Colors.white : AppColors.gray700,
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceSection() {
    final distance = _tempFilter.maxDistanceKm ?? 25.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mesafe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            Text(
              '${distance.toInt()} km',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.gray200,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: distance,
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: (value) {
              setState(() {
                _tempFilter = _tempFilter.copyWith(maxDistanceKm: value);
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '1 km',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
            Text(
              '50 km',
              style: TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Puan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [3.0, 3.5, 4.0, 4.5].map((rating) {
            final isSelected = _tempFilter.minRating == rating;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(
                      minRating: isSelected ? null : rating,
                      clearMinRating: isSelected,
                    );
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.gray200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)}+',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.selectedCategory == null) return const SizedBox.shrink();

        if (provider.isLoadingCategoryServices) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (provider.categoryServices.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hizmetler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Tümünü Seç Chip
                Builder(
                  builder: (context) {
                    final allServiceIds = provider.categoryServices
                        .map((s) => s.id)
                        .toList();
                    final isAllSelected = allServiceIds.every(
                      (id) => _tempFilter.serviceIds.contains(id),
                    );

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          final newServiceIds = List<String>.from(
                            _tempFilter.serviceIds,
                          );
                          if (isAllSelected) {
                            // Tümünü kaldır
                            for (final id in allServiceIds) {
                              newServiceIds.remove(id);
                            }
                          } else {
                            // Eksik olanları ekle
                            for (final id in allServiceIds) {
                              if (!newServiceIds.contains(id)) {
                                newServiceIds.add(id);
                              }
                            }
                          }
                          _tempFilter = _tempFilter.copyWith(
                            serviceIds: newServiceIds,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isAllSelected
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAllSelected
                                ? AppColors.primary
                                : AppColors.gray200,
                          ),
                        ),
                        child: Text(
                          'Tümünü Seç',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isAllSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                ...provider.categoryServices.map((service) {
                  final isSelected = _tempFilter.serviceIds.contains(
                    service.id,
                  );
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        final newServiceIds = List<String>.from(
                          _tempFilter.serviceIds,
                        );
                        if (isSelected) {
                          newServiceIds.remove(service.id);
                        } else {
                          newServiceIds.add(service.id);
                        }
                        _tempFilter = _tempFilter.copyWith(
                          serviceIds: newServiceIds,
                        );
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.gray200,
                        ),
                      ),
                      child: Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.gray700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _tempFilter = SearchFilter.empty();
    });
  }

  void _applyFilters() {
    context.read<SearchProvider>().setFilter(_tempFilter);
    Navigator.pop(context);
  }
}
