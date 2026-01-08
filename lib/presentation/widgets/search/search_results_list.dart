import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';
import 'search_result_card.dart';

/// Arama sonuçları listesi
class SearchResultsList extends StatelessWidget {
  final List<Venue> results;
  final String? highlightedService;

  const SearchResultsList({
    super.key,
    required this.results,
    this.highlightedService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Results count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sonuçlar & Detaylı Karşılaştırma',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              Text(
                '${results.length} Mekan',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return SearchResultCard(
                venue: results[index],
                highlightedService: highlightedService,
              );
            },
          ),
        ),
      ],
    );
  }
}
