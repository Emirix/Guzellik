import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';

/// Yeniden kullanılabilir AdMob banner widget'ı
/// Banner yüklenene kadar shimmer efekti gösterir
/// Hata durumunda veya web platformunda gizlenir
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Web platformunda reklam yükleme
    if (!AdService.instance.isSupported) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    _bannerAd = AdService.instance.createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Banner ad failed to load: ${error.message}');
        ad.dispose();
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
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
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        // PERF: RepaintBoundary isolates PlatformView (AdWidget) GPU surface updates
        child: RepaintBoundary(
          child: _isLoaded && _bannerAd != null
              ? SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                )
              : _buildShimmerPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    // Use static placeholder instead of animated shimmer to prevent continuous GPU redraws
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gray100, AppColors.gray50, AppColors.gray100],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
