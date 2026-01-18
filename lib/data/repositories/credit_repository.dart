import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/credit_package.dart';
import '../models/credit_transaction.dart';

class CreditRepository {
  static final CreditRepository _instance = CreditRepository._internal();
  static CreditRepository get instance => _instance;
  CreditRepository._internal();

  final _supabase = Supabase.instance.client;

  /// Fetch balance for a venue
  Future<int> getBalance(String venueId) async {
    final response = await _supabase
        .from('venues_subscription')
        .select('credits_balance')
        .eq('venue_id', venueId)
        .single();

    return response['credits_balance'] as int? ?? 0;
  }

  /// Fetch all active packages
  Future<List<CreditPackage>> getPackages() async {
    final response = await _supabase
        .from('credit_packages')
        .select()
        .eq('is_active', true)
        .order('price_cents');

    return (response as List).map((json) {
      // Mapping DB columns to model fields
      return CreditPackage(
        id: json['id'],
        name: json['name'],
        creditAmount: json['credits'],
        price: (json['price_cents'] as int) / 100.0,
        description: json['description'],
        isPopular: json['is_active'] ?? false, // Placeholder or add this to DB
      );
    }).toList();
  }

  /// Fetch transactions for a venue
  Future<List<CreditTransaction>> getTransactions(String venueId) async {
    final response = await _supabase
        .from('credit_transactions')
        .select()
        .eq('venue_id', venueId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      return CreditTransaction(
        id: json['id'],
        venueId: json['venue_id'],
        amount: json['amount'],
        type: json['transaction_type'],
        description: json['description'],
        createdAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }

  /// Purchase a package
  Future<void> purchasePackage({
    required String venueId,
    required CreditPackage package,
  }) async {
    // In a real app, this would be tied to a payment gateway success callback
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Atomic update via RPC
    await _supabase.rpc(
      'increment_venue_credits',
      params: {'p_venue_id': venueId, 'p_amount': package.creditAmount},
    );

    // Record transaction
    await _supabase.from('credit_transactions').insert({
      'venue_id': venueId,
      'profile_id': userId,
      'amount': package.creditAmount,
      'transaction_type': 'purchase',
      'description': '${package.name} satın alındı',
    });
  }

  /// Use credits
  Future<bool> useCredits(
    String venueId,
    int amount,
    String featureName,
  ) async {
    final currentBalance = await getBalance(venueId);
    if (currentBalance < amount) return false;

    await _supabase.rpc(
      'increment_venue_credits',
      params: {'p_venue_id': venueId, 'p_amount': -amount},
    );

    await _supabase.from('credit_transactions').insert({
      'venue_id': venueId,
      'amount': -amount,
      'transaction_type': 'usage',
      'description': '$featureName için kullanıldı',
    });

    return true;
  }
}
