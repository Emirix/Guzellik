import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import 'supabase_service.dart';

/// Service for managing customers with soft delete support
class CustomerService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  static const String _tableName = 'customers';

  /// Get current user ID
  String? get _userId => _supabaseService.currentUser?.id;

  /// Fetch all active (not deleted) customers for the current user
  Future<List<Customer>> getCustomers() async {
    final uid = _userId;
    if (uid == null) throw 'Kullanıcı girişi yapılmamış';

    try {
      final response = await _supabaseService
          .from(_tableName)
          .select()
          .eq('owner_id', uid)
          .eq('is_deleted', false)
          .order('name');

      return (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching customers: $e');
      rethrow;
    }
  }

  /// Add a new customer
  Future<Customer> addCustomer(Customer customer) async {
    final uid = _userId;
    if (uid == null) throw 'Kullanıcı girişi yapılmamış';

    try {
      final data = customer.toJson();
      data['owner_id'] = uid;
      data.remove('id'); // Let Supabase generate UUID
      data.remove('created_at'); // Let Supabase use default

      final response = await _supabaseService
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      return Customer.fromJson(response);
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  /// Update an existing customer
  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final data = customer.toJson();
      // Remove fields that should not be updated
      data.remove('id');
      data.remove('owner_id');
      data.remove('created_at');

      final response = await _supabaseService
          .from(_tableName)
          .update(data)
          .eq('id', customer.id)
          .select()
          .single();

      return Customer.fromJson(response);
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    }
  }

  /// Soft delete a customer by setting is_deleted to true
  Future<void> deleteCustomer(String id) async {
    final uid = _userId;
    if (uid == null) throw 'Kullanıcı girişi yapılmamış';

    try {
      await _supabaseService
          .from(_tableName)
          .update({'is_deleted': true})
          .eq('id', id)
          .eq('owner_id', uid) // Extra safety check
          .select()
          .single();
    } catch (e) {
      print('Error soft deleting customer: $e');
      rethrow;
    }
  }

  /// Hard delete a customer (Admin only or specific use cases)
  Future<void> hardDeleteCustomer(String id) async {
    try {
      await _supabaseService.from(_tableName).delete().eq('id', id);
    } catch (e) {
      print('Error hard deleting customer: $e');
      rethrow;
    }
  }
}
