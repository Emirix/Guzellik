import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../data/models/business_subscription.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/services/purchase_service.dart';
import '../../config/app_config.dart';

/// Provider for subscription management
class SubscriptionProvider with ChangeNotifier {
  final SubscriptionRepository _repository = SubscriptionRepository();
  final PurchaseService _purchaseService = PurchaseService.instance;

  BusinessSubscription? _subscription;
  bool _isLoading = false;
  String? _errorMessage;
  List<ProductDetails> _availableProducts = [];

  SubscriptionProvider() {
    _initializePurchases();
  }

  // Getters
  BusinessSubscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductDetails> get availableProducts => _availableProducts;
  bool get hasActiveSubscription =>
      _subscription != null && _subscription!.isActive;

  /// Initialize purchase stream
  void _initializePurchases() {
    _purchaseService.purchaseStream.listen((purchase) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _handleSuccessfulPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        _setError('Ödeme sırasında hata oluştu: ${purchase.error?.message}');
      }
    });
  }

  /// Load available products from store
  Future<void> loadAvailableProducts() async {
    try {
      await _purchaseService.initialize();
      _availableProducts = await _purchaseService.getProducts(
        AppConfig.subscriptionIds,
      );
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  /// Purchase a subscription
  Future<void> buySubscription(ProductDetails product, String venueId) async {
    _setLoading(true);
    _currentPurchaseVenueId = venueId;
    try {
      await _purchaseService.buySubscription(product);
    } catch (e) {
      _setError('Satın alma işlemi başlatılamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  String? _currentPurchaseVenueId;

  /// Handle successful purchase and update Supabase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    final venueId = _currentPurchaseVenueId;

    if (venueId != null) {
      // Always use premium for all subscriptions
      const type = 'premium';

      // Calculate expiry date (30 days from now for monthly)
      final expiryDate = DateTime.now().add(const Duration(days: 30));

      await _repository.createSubscription(
        venueId: venueId,
        type: type,
        expiresAt: expiryDate,
      );

      await loadSubscription(venueId); // Refresh
    }

    await _purchaseService.completePurchase(purchase);
  }

  /// Load subscription data
  Future<void> loadSubscription(String profileId) async {
    _setLoading(true);
    _clearError();

    try {
      _subscription = await _repository.getSubscription(profileId);
      _setLoading(false);
    } catch (e) {
      _setError('Abonelik bilgileri yüklenirken hata oluştu: $e');
      _setLoading(false);
    }
  }

  /// Check if user has access to a feature
  Future<bool> hasFeatureAccess(String profileId, String feature) async {
    try {
      return await _repository.checkFeatureAccess(profileId, feature);
    } catch (e) {
      print('Error checking feature access: $e');
      return false;
    }
  }

  /// Get feature limit
  Future<int> getFeatureLimit(
    String profileId,
    String feature,
    String limitKey,
  ) async {
    try {
      return await _repository.getFeatureLimit(profileId, feature, limitKey);
    } catch (e) {
      print('Error getting feature limit: $e');
      return 0;
    }
  }

  /// Calculate days remaining
  int get daysRemaining {
    if (_subscription == null) return 0;
    return _subscription!.daysRemaining;
  }

  /// Get subscription display name
  String get subscriptionName {
    if (_subscription == null) return 'Üyelik Yok';
    return _subscription!.displayName;
  }

  /// Check if subscription is expiring soon (less than 7 days)
  bool get isExpiringSoon {
    if (_subscription == null) return false;
    final days = _subscription!.daysRemaining;
    return days > 0 && days < 7;
  }

  /// Refresh subscription data
  Future<void> refresh(String profileId) async {
    await loadSubscription(profileId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
