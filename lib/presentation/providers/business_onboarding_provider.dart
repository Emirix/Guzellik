import 'package:flutter/foundation.dart';
import '../../data/repositories/business_repository.dart';
import '../../data/repositories/venue_category_repository.dart';
import '../../data/models/venue_category.dart';

/// Provider for managing business onboarding flow state
class BusinessOnboardingProvider extends ChangeNotifier {
  final BusinessRepository _businessRepository;
  final VenueCategoryRepository _categoryRepository;

  BusinessOnboardingProvider(
    this._businessRepository,
    this._categoryRepository,
  );

  // Onboarding state
  int _currentStep = 0;
  int get currentStep => _currentStep;

  static const int totalSteps = 4;

  // Form data
  String? _businessName;
  String? get businessName => _businessName;

  String? _businessType;
  String? get businessType => _businessType;

  // Categories
  List<VenueCategory> _categories = [];
  List<VenueCategory> get categories => _categories;

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingCategories = false;
  bool get isFetchingCategories => _isFetchingCategories;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Navigate to next step in carousel
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Navigate to previous step in carousel
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Skip onboarding and go directly to form
  void skipOnboarding() {
    _currentStep = totalSteps - 1;
    notifyListeners();
  }

  /// Reset to first step
  void resetOnboarding() {
    _currentStep = 0;
    notifyListeners();
  }

  /// Set business name
  void setBusinessName(String? name) {
    _businessName = name?.trim();
    _errorMessage = null;
    notifyListeners();
  }

  /// Set business type (category ID)
  void setBusinessType(String? typeId) {
    _businessType = typeId;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validate form data
  bool validateForm() {
    _errorMessage = null;

    if (_businessName == null || _businessName!.isEmpty) {
      _errorMessage = 'İşletme adı gereklidir';
      notifyListeners();
      return false;
    }

    if (_businessName!.length < 2) {
      _errorMessage = 'İşletme adı en az 2 karakter olmalıdır';
      notifyListeners();
      return false;
    }

    if (_businessName!.length > 100) {
      _errorMessage = 'İşletme adı en fazla 100 karakter olabilir';
      notifyListeners();
      return false;
    }

    if (_businessType == null || _businessType!.isEmpty) {
      _errorMessage = 'İşletme türü seçilmelidir';
      notifyListeners();
      return false;
    }

    return true;
  }

  /// Check if form is valid (for enabling submit button)
  bool get isFormValid {
    return _businessName != null &&
        _businessName!.trim().isNotEmpty &&
        _businessName!.length >= 2 &&
        _businessName!.length <= 100 &&
        _businessType != null &&
        _businessType!.isNotEmpty;
  }

  /// Fetch active venue categories
  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return; // Already loaded

    _isFetchingCategories = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _categoryRepository.getActiveCategories();
    } catch (e) {
      _errorMessage = 'Kategoriler yüklenirken hata oluştu';
      debugPrint('Error fetching categories: $e');
    } finally {
      _isFetchingCategories = false;
      notifyListeners();
    }
  }

  /// Convert user account to business account
  Future<bool> convertToBusinessAccount(String userId) async {
    if (!validateForm()) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    debugPrint('🚀 Converting account for userId: $userId');
    debugPrint('📂 Business Name: $_businessName');
    debugPrint('🏷️ Business Type: $_businessType');

    try {
      await _businessRepository.convertToBusinessAccount(
        userId: userId,
        businessName: _businessName!,
        businessType: _businessType!,
      );

      debugPrint('✅ Account converted successfully');

      // Clear form data after successful conversion
      _businessName = null;
      _businessType = null;
      _currentStep = 0;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('zaten işletme')
          ? 'Bu hesap zaten işletme hesabıdır'
          : 'Hesap dönüştürme başarısız oldu. Lütfen tekrar deneyin.';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error converting to business account: $e');
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _currentStep = 0;
    _businessName = null;
    _businessType = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up
    super.dispose();
  }
}
