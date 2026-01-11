import '../models/credit_package.dart';
import '../models/credit_transaction.dart';
import '../services/supabase_service.dart';

/// Repository for handling venue credit operations
class CreditRepository {
  // Singleton pattern
  static final CreditRepository _instance = CreditRepository._internal();
  static CreditRepository get instance => _instance;
  factory CreditRepository() => _instance;
  CreditRepository._internal();

  final SupabaseService _supabase = SupabaseService.instance;

  /// Get current credit balance for a venue
  Future<int> getBalance(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_credits')
          .select('balance')
          .eq('venue_id', venueId)
          .maybeSingle();

      if (response == null) return 0;
      return response['balance'] as int? ?? 0;
    } catch (e) {
      print('Error getting credit balance: $e');
      return 0;
    }
  }

  /// Get available credit packages
  Future<List<CreditPackage>> getPackages() async {
    try {
      final response = await _supabase
          .from('credit_packages')
          .select()
          .order('price', ascending: true);

      return (response as List)
          .map((json) => CreditPackage.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting credit packages: $e');
      return [];
    }
  }

  /// Get transaction history for a venue
  Future<List<CreditTransaction>> getTransactions(String venueId) async {
    try {
      final response = await _supabase
          .from('credit_transactions')
          .select()
          .eq('venue_id', venueId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CreditTransaction.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting credit transactions: $e');
      return [];
    }
  }

  /// Purchase a credit package (Mocked for now)
  Future<void> purchasePackage({
    required String venueId,
    required CreditPackage package,
  }) async {
    try {
      // In a real implementation, we would call a payment gateway here.
      // For now, we directly update the balance and log the transaction.

      // 1. Log the transaction
      await _supabase.from('credit_transactions').insert({
        'venue_id': venueId,
        'amount': package.creditAmount,
        'type': 'purchase',
        'description': '${package.name} satın alındı',
      });

      // 2. Update the balance
      // Note: In production, this should be done in a database transaction
      // or via an RPC to ensure atomicity.
      final currentBalance = await getBalance(venueId);
      final newBalance = currentBalance + package.creditAmount;

      await _supabase
          .from('venue_credits')
          .update({
            'balance': newBalance,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('venue_id', venueId);
    } catch (e) {
      print('Error purchasing credit package: $e');
      rethrow;
    }
  }
}
