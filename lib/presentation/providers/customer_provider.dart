import 'package:flutter/foundation.dart';
import '../../data/models/customer.dart';
import '../../data/services/customer_service.dart';

/// Provider for managing customer state and operations
class CustomerProvider with ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all active customers
  Future<void> fetchCustomers() async {
    _setLoading(true);
    _clearError();

    try {
      _customers = await _customerService.getCustomers();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Add a new customer
  Future<bool> addCustomer(Customer customer) async {
    _setLoading(true);
    _clearError();

    try {
      final newCustomer = await _customerService.addCustomer(customer);
      _customers.add(newCustomer);
      _customers.sort((a, b) => a.name.compareTo(b.name));
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing customer
  Future<bool> updateCustomer(Customer customer) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedCustomer = await _customerService.updateCustomer(customer);
      final index = _customers.indexWhere((c) => c.id == updatedCustomer.id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
        _customers.sort((a, b) => a.name.compareTo(b.name));
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Soft delete a customer
  Future<bool> deleteCustomer(String id) async {
    _setLoading(true);
    _clearError();

    try {
      print('Deleting customer with ID: $id');
      await _customerService.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);
      print(
        'Customer removed from local list. New count: ${_customers.length}',
      );
      _setLoading(false);
      return true;
    } catch (e) {
      print('Error in deleteCustomer Provider: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Search customers locally
  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return _customers;

    final lowerQuery = query.toLowerCase();
    return _customers.where((c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
          c.phone.contains(lowerQuery);
    }).toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
