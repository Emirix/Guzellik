import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';

/// Native (Yerel Gelişmiş) AdMob reklam widget'ı
/// Uygulama içeriğiyle daha iyi uyum sağlar
/// Web platformunda ve hata durumunda gizlenir
class NativeAdWidget extends StatefulWidget {
  /// Reklam yüksekliği (varsayılan: 280)
  final double height;

  /// Factory ID (Android: listTile veya medium, iOS: listTile veya medium)
  final String factoryId;

  const NativeAdWidget({
    super.key,
    this.height = 280,
    this.factoryId = 'listTile',
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    // Web platformunda reklam yükleme
    if (!AdService.instance.isSupported) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    _nativeAd = AdService.instance.createNativeAd(
      factoryId: widget.factoryId,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Native ad failed to load: ${error.message}');
        ad.dispose();
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      },
    );
    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hata durumunda veya desteklenmeyen platformda widget'ı gizle
    if (_hasError || !AdService.instance.isSupported) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isLoaded && _nativeAd != null
            ? AdWidget(ad: _nativeAd!)
            : _buildShimmerPlaceholder(),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.gray100,
      highlightColor: AppColors.gray50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reklam etiketi
            Container(
              width: 40,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Başlık placeholder
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Açıklama placeholder
            Container(
              width: double.infinity * 0.7,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            // Görsel placeholder
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            // CTA button placeholder
            Container(
              width: 100,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
