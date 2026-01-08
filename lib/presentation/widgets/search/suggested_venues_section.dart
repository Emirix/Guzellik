import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/search_provider.dart';
import 'search_result_card.dart';

/// Önerilen mekanlar bölümü
class SuggestedVenuesSection extends StatelessWidget {
  const SuggestedVenuesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingSuggestions) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final suggestedVenues = provider.suggestedVenues;

        if (suggestedVenues.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Senin İçin Önerilenler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Tüm önerilenleri göster
                  },
                  child: const Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Venue list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestedVenues.length,
              itemBuilder: (context, index) {
                return SearchResultCard(venue: suggestedVenues[index]);
              },
            ),
          ],
        );
      },
    );
  }
}
