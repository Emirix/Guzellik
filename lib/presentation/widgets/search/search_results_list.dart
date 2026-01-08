import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/venue.dart';
import 'search_result_card.dart';

/// Arama sonuçları listesi
class SearchResultsList extends StatelessWidget {
  final List<Venue> results;

  const SearchResultsList({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Results count header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} sonuç bulundu',
                style: TextStyle(fontSize: 13, color: AppColors.gray500),
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
              return SearchResultCard(venue: results[index]);
            },
          ),
        ),
      ],
    );
  }
}
