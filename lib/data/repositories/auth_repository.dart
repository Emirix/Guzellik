import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;

  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.signInWithEmail(email: email, password: password);
  }

  Future<AuthResponse> register(String email, String password, String fullName) async {
    return await _supabase.signUpWithEmail(
      email: email, 
      password: password,
      metadata: {'full_name': fullName},
    );
  }

  Future<void> logout() async {
    await _supabase.signOut();
  }

  User? get currentUser => _supabase.currentUser;
  bool get isAuthenticated => _supabase.isAuthenticated;
}
