import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<AuthResponse> login(String email, String password) async {
    return _supabase.signInWithEmail(email: email, password: password);
  }

  Future<AuthResponse> register(
    String email,
    String password,
    String fullName,
  ) async {
    return _supabase.signUpWithEmail(
      email: email,
      password: password,
      metadata: {'full_name': fullName},
    );
  }

  Future<void> logout() async {
    await _supabase.signOut();
  }

  /// Save FCM token to user profile
  Future<void> saveFcmToken(String token) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) {
        print('Cannot save FCM token: User not authenticated');
        return;
      }

      await _supabase
          .from('profiles')
          .update({
            'fcm_token': token,
            'fcm_token_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      print('FCM token saved successfully');
    } catch (e) {
      print('Error saving FCM token: $e');
      rethrow;
    }
  }

  /// Clear FCM token from user profile (on logout)
  Future<void> clearFcmToken() async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'fcm_token': null, 'fcm_token_updated_at': null})
          .eq('id', userId);

      print('FCM token cleared');
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }

  User? get currentUser => _supabase.currentUser;
  bool get isAuthenticated => _supabase.isAuthenticated;

  /// Fetch user profile from database
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return null;

    try {
      return await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
