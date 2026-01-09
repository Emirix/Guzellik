import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ad_service.dart';
import '../../../data/models/venue.dart';
import '../common/native_ad_widget.dart';
import 'search_result_card.dart';

/// Arama sonuçları listesi
/// Her 5 sonuçtan sonra native reklam gösterir
class SearchResultsList extends StatelessWidget {
  final List<Venue> results;
  final String? highlightedService;

  /// Her kaç sonuçtan sonra reklam gösterilecek
  static const int _adInterval = 5;

  const SearchResultsList({
    super.key,
    required this.results,
    this.highlightedService,
  });

  /// Toplam öğe sayısını hesapla (sonuçlar + reklamlar)
  int get _totalItemCount {
    if (!AdService.instance.isSupported || results.isEmpty) {
      return results.length;
    }
    // Her _adInterval sonuç için 1 reklam ekle
    final adCount = (results.length / _adInterval).floor();
    return results.length + adCount;
  }

  /// Verilen index'in reklam mı yoksa sonuç mu olduğunu belirle
  bool _isAdPosition(int index) {
    if (!AdService.instance.isSupported) return false;
    // Her (_adInterval + 1). pozisyon reklam
    return (index + 1) % (_adInterval + 1) == 0 && index > 0;
  }

  /// Verilen display index'ten gerçek venue index'i hesapla
  int _getVenueIndex(int displayIndex) {
    if (!AdService.instance.isSupported) return displayIndex;
    // Şimdiye kadar kaç reklam gösterildi?
    final adsBefore = (displayIndex / (_adInterval + 1)).floor();
    return displayIndex - adsBefore;
  }

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

        // Results list with native ads
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _totalItemCount,
            itemBuilder: (context, index) {
              // Reklam pozisyonu mu kontrol et
              if (_isAdPosition(index)) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: NativeAdWidget(height: 180, factoryId: 'listTile'),
                );
              }

              // Normal venue kartı
              final venueIndex = _getVenueIndex(index);
              if (venueIndex >= results.length) {
                return const SizedBox.shrink();
              }

              return SearchResultCard(
                venue: results[venueIndex],
                highlightedService: highlightedService,
              );
            },
          ),
        ),
      ],
    );
  }
}
