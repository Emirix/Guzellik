import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Authentication service for user management
/// Handles sign in, sign up, sign out, and password management
class AuthService {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get current user
  User? get currentUser => _supabaseService.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabaseService.isAuthenticated;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges;

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
    int? provinceId,
    String? districtId,
  }) async {
    try {
      final metadata = <String, dynamic>{};
      if (fullName != null) metadata['full_name'] = fullName;
      if (phone != null) metadata['phone'] = phone;
      if (provinceId != null) metadata['province_id'] = provinceId;
      if (districtId != null) metadata['district_id'] = districtId;

      return await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        metadata: metadata.isNotEmpty ? metadata : null,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.resetPassword(email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    int? provinceId,
    String? districtId,
  }) async {
    try {
      final metadata = <String, dynamic>{};
      if (fullName != null) metadata['full_name'] = fullName;
      if (phone != null) metadata['phone'] = phone;
      if (avatarUrl != null) metadata['avatar_url'] = avatarUrl;
      if (provinceId != null) metadata['province_id'] = provinceId;
      if (districtId != null) metadata['district_id'] = districtId;

      if (metadata.isNotEmpty) {
        await _supabaseService.updateUserMetadata(metadata);
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Get user metadata
  Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  /// Get user email
  String? get userEmail => currentUser?.email;

  /// Get user ID
  String? get userId => currentUser?.id;

  /// Handle authentication errors
  String _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.statusCode) {
        case '400':
          return 'Geçersiz e-posta veya şifre';
        case '422':
          return 'E-posta zaten kullanımda';
        case '500':
          return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin';
        default:
          return error.message;
      }
    }
    return 'Bir hata oluştu. Lütfen tekrar deneyin';
  }
}
