import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/auth_service.dart';

/// Authentication state provider
/// Manages user authentication state and provides auth-related functionality
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Callback for business account detection
  Function(String userId)? onBusinessAccountDetected;

  AuthProvider() {
    _init();
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Initialize auth provider
  void _init() {
    _currentUser = _authService.currentUser;
    print(
      '🔐 AuthProvider initialized - Current user: ${_currentUser?.email ?? "null"}',
    );

    // Listen to auth state changes
    _authService.authStateChanges.listen((state) {
      _currentUser = state.session?.user;
      print('🔐 Auth state changed - User: ${_currentUser?.email ?? "null"}');
      notifyListeners();
    });
  }

  /// Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signInWithGoogle();
      _currentUser = response.user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
    int? provinceId,
    String? districtId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        provinceId: provinceId,
        districtId: districtId,
      );

      _currentUser = response.user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    int? provinceId,
    String? districtId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
        provinceId: provinceId,
        districtId: districtId,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Check if user profile is complete (e.g. has province_id and district_id)
  Future<bool> isProfileComplete() async {
    try {
      final profileData = await _authService.getProfile();
      if (profileData == null) return false;

      final provinceId = profileData['province_id'];
      final districtId = profileData['district_id'];
      return provinceId != null && districtId != null;
    } catch (e) {
      print('Error checking profile completion: $e');
      return true; // Return true on error to avoid loops, but ideally handle properly
    }
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
