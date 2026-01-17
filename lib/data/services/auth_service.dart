import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/validators.dart';
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

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      return await _supabaseService.signInWithGoogle();
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

  /// Sign up with phone number and password (without OTP)
  /// Uses email mapping: phone number is converted to internal email format
  Future<AuthResponse> signUpWithPhone({
    required String phone,
    required String password,
    String? fullName,
    int? provinceId,
    String? districtId,
  }) async {
    try {
      // Convert phone to internal email format
      final internalEmail = Validators.phoneToEmail(phone);

      final metadata = <String, dynamic>{
        'phone': phone,
        'is_phone_account': true,
      };
      if (fullName != null) metadata['full_name'] = fullName;
      if (provinceId != null) metadata['province_id'] = provinceId;
      if (districtId != null) metadata['district_id'] = districtId;

      return await _supabaseService.signUpWithEmail(
        email: internalEmail,
        password: password,
        metadata: metadata,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with phone number and password
  /// Uses email mapping: phone number is converted to internal email format
  Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      // Convert phone to internal email format
      final internalEmail = Validators.phoneToEmail(phone);

      return await _supabaseService.signInWithEmail(
        email: internalEmail,
        password: password,
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
        // Update Auth Metadata
        await _supabaseService.updateUserMetadata(metadata);

        // Update profiles table in public schema
        final userId = _supabaseService.currentUser?.id;
        if (userId != null) {
          final profileData = <String, dynamic>{};
          if (fullName != null) profileData['full_name'] = fullName;
          if (avatarUrl != null) profileData['avatar_url'] = avatarUrl;
          if (provinceId != null) profileData['province_id'] = provinceId;
          if (districtId != null) profileData['district_id'] = districtId;

          if (profileData.isNotEmpty) {
            await _supabaseService
                .from('profiles')
                .update(profileData)
                .eq('id', userId);
          }
        }
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

  /// Get user profile from database
  Future<Map<String, dynamic>?> getProfile() async {
    final uid = userId;
    if (uid == null) return null;

    try {
      return await _supabaseService
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

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
    return error.toString();
  }
}
