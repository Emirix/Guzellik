import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'dart:ui' show VoidCallback;

/// AdMob reklam yönetim servisi
/// Singleton pattern ile global erişim sağlar
class AdService {
  static final AdService _instance = AdService._internal();
  static AdService get instance => _instance;

  AdService._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  /// Reklamların gösterilip gösterilmeyeceğini belirleyen global kontrol
  /// Şimdilik tüm reklamları kaldırmak için false yapıldı
  final bool _adsEnabled = false;

  /// Web platform kontrolü ve reklam etkinliği kontrolü
  bool get isSupported => !kIsWeb && _adsEnabled;

  /// Interstitial reklam hazır mı?
  bool get isInterstitialReady =>
      _isInterstitialAdReady && _interstitialAd != null;

  /// Rewarded reklam hazır mı?
  bool get isRewardedReady => _isRewardedAdReady && _rewardedAd != null;

  /// AdMob SDK'yı başlatır
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (!isSupported) {
      debugPrint('AdMob is not supported on web platform');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob initialized successfully');

      // Reklamları önceden yükle
      loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  /// Test banner ad unit ID (Production'da gerçek ID ile değiştirilmeli)
  /// Uyarlanabilir Banner: ca-app-pub-3940256099942544/9214589741
  String get bannerAdUnitId {
    return 'ca-app-pub-3940256099942544/9214589741';
  }

  /// Test native ad unit ID (Production'da gerçek ID ile değiştirilmeli)
  /// Yerel (Native): ca-app-pub-3940256099942544/2247696110
  String get nativeAdUnitId {
    return 'ca-app-pub-3940256099942544/2247696110';
  }

  /// Test interstitial ad unit ID (Production'da gerçek ID ile değiştirilmeli)
  /// Geçiş reklamı: ca-app-pub-3940256099942544/1033173712
  String get interstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  /// Test rewarded ad unit ID (Production'da gerçek ID ile değiştirilmeli)
  /// Ödüllü reklam: ca-app-pub-3940256099942544/5224354917
  String get rewardedAdUnitId {
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  /// Banner reklam oluşturur
  BannerAd? createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    if (!isSupported) return null;

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => debugPrint('Banner ad opened'),
        onAdClosed: (ad) => debugPrint('Banner ad closed'),
      ),
    );
  }

  /// Native (Yerel) reklam oluşturur
  NativeAd? createNativeAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
    required String factoryId,
  }) {
    if (!isSupported) return null;

    return NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => debugPrint('Native ad opened'),
        onAdClosed: (ad) => debugPrint('Native ad closed'),
      ),
    );
  }

  /// Interstitial (Geçiş) reklamını yükler
  void loadInterstitialAd() {
    if (!isSupported) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          // Reklam kapatıldığında yeni reklam yükle
          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Yeni reklam yükle
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial ad failed to show: ${error.message}');
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Tekrar dene
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Interstitial reklamı gösterir ve ardından callback çağırır
  Future<void> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (!isSupported) {
      onAdClosed?.call();
      return;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      // Callback'i kaydet
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Interstitial ad dismissed');
          ad.dispose();
          _isInterstitialAdReady = false;
          onAdClosed?.call();
          loadInterstitialAd(); // Yeni reklam yükle
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Interstitial ad failed to show: ${error.message}');
          ad.dispose();
          _isInterstitialAdReady = false;
          onAdClosed?.call();
          loadInterstitialAd();
        },
      );

      await _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready, skipping...');
      onAdClosed?.call();
      loadInterstitialAd(); // Sonraki sefer için yükle
    }
  }

  /// Rewarded (Ödüllü) reklamı yükler
  void loadRewardedAd() {
    if (!isSupported) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded');
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: ${error.message}');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// Rewarded reklamı gösterir
  /// [onUserEarnedReward]: Kullanıcı ödülü kazandığında çağrılır
  /// [onAdClosed]: Reklam kapatıldığında çağrılır (ödül alınmasa bile)
  /// [onAdNotReady]: Reklam hazır değilse çağrılır
  Future<void> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
    VoidCallback? onAdNotReady,
  }) async {
    if (!isSupported) {
      // Web'de direkt ödül ver
      onUserEarnedReward();
      return;
    }

    if (_isRewardedAdReady && _rewardedAd != null) {
      bool rewardEarned = false;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('Rewarded ad dismissed');
          ad.dispose();
          _isRewardedAdReady = false;

          if (rewardEarned) {
            onUserEarnedReward();
          }
          onAdClosed?.call();
          loadRewardedAd(); // Yeni reklam yükle
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Rewarded ad failed to show: ${error.message}');
          ad.dispose();
          _isRewardedAdReady = false;
          onAdClosed?.call();
          loadRewardedAd();
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;
        },
      );
    } else {
      debugPrint('Rewarded ad not ready');
      onAdNotReady?.call();
      loadRewardedAd(); // Sonraki sefer için yükle
    }
  }
}
