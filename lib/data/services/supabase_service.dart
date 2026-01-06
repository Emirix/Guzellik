import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/environment_config.dart';

/// Supabase service for database operations and real-time subscriptions
/// Provides a centralized client for all Supabase interactions
class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;
  
  SupabaseService._internal();
  
  static SupabaseService get instance {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }
  
  /// Initialize Supabase with environment configuration
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvironmentConfig.current.supabaseUrl,
      anonKey: EnvironmentConfig.current.supabaseAnonKey,
      debug: EnvironmentConfig.current.isDev,
    );
    
    instance._client = Supabase.instance.client;
  }
  
  /// Get the Supabase client instance
  SupabaseClient get client => _client;
  
  /// Get the current user
  User? get currentUser => _client.auth.currentUser;
  
  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
  
  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
  
  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    return await _client.auth.updateUser(
      UserAttributes(data: metadata),
    );
  }
  
  /// Query builder for a table
  PostgrestQueryBuilder from(String table) {
    return _client.from(table);
  }
  
  /// Storage bucket access
  SupabaseStorageClient get storage => _client.storage;
  
  /// Real-time channel
  RealtimeChannel channel(String name) {
    return _client.channel(name);
  }
  
  /// Execute RPC (Remote Procedure Call)
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) async {
    return await _client.rpc(functionName, params: params);
  }
}
