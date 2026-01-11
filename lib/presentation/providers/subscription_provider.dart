import 'package:flutter/foundation.dart';
import '../../data/models/business_subscription.dart';
import '../../data/repositories/subscription_repository.dart';

/// Provider for subscription management
class SubscriptionProvider with ChangeNotifier {
  final SubscriptionRepository _repository = SubscriptionRepository();

  BusinessSubscription? _subscription;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  BusinessSubscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveSubscription =>
      _subscription != null && _subscription!.isActive;

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
