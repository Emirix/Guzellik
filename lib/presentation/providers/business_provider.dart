import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/enums/business_mode.dart';
import '../../data/models/business_subscription.dart';
import '../../data/models/venue.dart';
import '../../data/repositories/business_repository.dart';

/// Provider for business account management
class BusinessProvider with ChangeNotifier {
  final BusinessRepository _repository = BusinessRepository();

  BusinessMode _currentMode = BusinessMode.normal;
  Venue? _businessVenue;
  BusinessSubscription? _subscription;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  BusinessMode get currentMode => _currentMode;
  bool get isBusinessMode => _currentMode == BusinessMode.business;
  Venue? get businessVenue => _businessVenue;
  BusinessSubscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize business provider
  Future<void> init(String userId) async {
    await _loadSavedMode();
    if (_currentMode == BusinessMode.business) {
      await loadBusinessData(userId);
    }
  }

  /// Load saved mode from SharedPreferences
  Future<void> _loadSavedMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString('business_mode');
      if (savedMode != null) {
        _currentMode = BusinessMode.fromStorageString(savedMode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved mode: $e');
    }
  }

  /// Save mode to SharedPreferences
  Future<void> _saveMode(BusinessMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('business_mode', mode.toStorageString());
    } catch (e) {
      debugPrint('Error saving mode: $e');
    }
  }

  /// Clear saved mode
  Future<void> clearSavedMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('business_mode');
    } catch (e) {
      debugPrint('Error clearing saved mode: $e');
    }
  }

  /// Switch business mode
  Future<void> switchMode(BusinessMode mode, String userId) async {
    _currentMode = mode;
    await _saveMode(mode);

    if (mode == BusinessMode.business) {
      await loadBusinessData(userId);
    } else {
      _businessVenue = null;
      _subscription = null;
    }

    notifyListeners();
  }

  /// Load business data (venue and subscription)
  Future<void> loadBusinessData(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load venue and subscription in parallel
      final results = await Future.wait([
        _repository.getBusinessVenue(userId),
        _repository.getSubscription(userId),
      ]);

      _businessVenue = results[0] as Venue?;
      _subscription = results[1] as BusinessSubscription?;

      _setLoading(false);
    } catch (e) {
      _setError('İşletme verileri yüklenirken hata oluştu: $e');
      _setLoading(false);
    }
  }

  /// Check if user has business account
  Future<bool> checkBusinessAccount(String userId) async {
    try {
      return await _repository.checkBusinessAccount(userId);
    } catch (e) {
      debugPrint('Error checking business account: $e');
      return false;
    }
  }

  /// Check if user has access to a feature
  Future<bool> hasFeatureAccess(String userId, String feature) async {
    try {
      return await _repository.checkFeatureAccess(userId, feature);
    } catch (e) {
      debugPrint('Error checking feature access: $e');
      return false;
    }
  }

  /// Refresh subscription data
  Future<void> refreshSubscription(String userId) async {
    try {
      _subscription = await _repository.getSubscription(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing subscription: $e');
    }
  }

  /// Refresh venue data
  Future<void> refreshVenue(String userId) async {
    try {
      _businessVenue = await _repository.getBusinessVenue(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing venue: $e');
    }
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
