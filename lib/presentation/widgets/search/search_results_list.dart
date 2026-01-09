import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ad_service.dart';
import '../../../data/models/venue.dart';
import '../../providers/search_provider.dart';
import '../common/native_ad_widget.dart';
import 'search_result_card.dart';
import 'search_shimmer_loading.dart';

/// Arama sonuçları listesi
/// Her 5 sonuçtan sonra native reklam gösterir
class SearchResultsList extends StatefulWidget {
  final List<Venue> results;
  final String? highlightedService;

  const SearchResultsList({
    super.key,
    required this.results,
    this.highlightedService,
  });

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList> {
  final ScrollController _scrollController = ScrollController();

  /// Her kaç sonuçtan sonra reklam gösterilecek
  static const int _adInterval = 5;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchProvider>().loadMore();
    }
  }

  /// Toplam öğe sayısını hesapla (sonuçlar + reklamlar)
  int get _totalItemCount {
    if (!AdService.instance.isSupported || widget.results.isEmpty) {
      return widget.results.length;
    }
    // Her _adInterval sonuç için 1 reklam ekle
    final adCount = (widget.results.length / _adInterval).floor();
    return widget.results.length + adCount;
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
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
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
                    '${widget.results.length} Mekan',
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
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _totalItemCount + (provider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loading indicator at the end
                  if (index == _totalItemCount && provider.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: SearchShimmerLoading(itemCount: 1),
                    );
                  }

                  // Reklam pozisyonu mu kontrol et
                  if (_isAdPosition(index)) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: NativeAdWidget(height: 180, factoryId: 'listTile'),
                    );
                  }

                  // Normal venue kartı
                  final venueIndex = _getVenueIndex(index);
                  if (venueIndex >= widget.results.length) {
                    return const SizedBox.shrink();
                  }

                  return SearchResultCard(
                    venue: widget.results[venueIndex],
                    highlightedService: widget.highlightedService,
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
