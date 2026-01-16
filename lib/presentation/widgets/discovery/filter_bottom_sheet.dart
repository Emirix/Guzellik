import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/venue_filter.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late VenueFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    final provider = context.read<DiscoveryProvider>();
    _tempFilter = VenueFilter(
      categories: List.from(provider.filter.categories),
      minPrice: provider.filter.minPrice,
      maxPrice: provider.filter.maxPrice,
      minRating: provider.filter.minRating,
      maxDistanceKm: provider.filter.maxDistanceKm,
      onlyVerified: provider.filter.onlyVerified,
      onlyPreferred: provider.filter.onlyPreferred,
      onlyHygienic: provider.filter.onlyHygienic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrele',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilter = VenueFilter();
                    });
                  },
                  child: const Text(
                    'Temizle',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Distance
                  _buildSectionTitle('Uzaklık'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _tempFilter.maxDistanceKm ?? 10.0,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.gray200,
                          label:
                              '${(_tempFilter.maxDistanceKm ?? 10.0).toStringAsFixed(0)} km',
                          onChanged: (value) {
                            setState(() {
                              _tempFilter = _tempFilter.copyWith(
                                maxDistanceKm: value,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${(_tempFilter.maxDistanceKm ?? 10.0).toStringAsFixed(0)} km',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Distance filter is the only one remaining for now besides potential others not asked to remove
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<DiscoveryProvider>().updateFilter(_tempFilter);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Filtreleri Uygula',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.gray900,
      ),
    );
  }
}
