import 'package:flutter/foundation.dart';
import '../../data/models/credit_package.dart';
import '../../data/models/credit_transaction.dart';
import '../../data/repositories/credit_repository.dart';

/// Provider for managing venue credits and store state
class CreditProvider with ChangeNotifier {
  final CreditRepository _repository = CreditRepository.instance;

  int _balance = 0;
  List<CreditPackage> _packages = [];
  List<CreditTransaction> _transactions = [];
  bool _isLoading = false;
  bool _isPurchasing = false;
  String? _errorMessage;

  // Getters
  int get balance => _balance;
  List<CreditPackage> get packages => _packages;
  List<CreditTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get errorMessage => _errorMessage;

  /// Load all credit related data for a venue
  Future<void> loadCreditData(String venueId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load balance, packages and transactions in parallel
      final results = await Future.wait([
        _repository.getBalance(venueId),
        _repository.getPackages(),
        _repository.getTransactions(venueId),
      ]);

      _balance = results[0] as int;
      _packages = results[1] as List<CreditPackage>;
      _transactions = results[2] as List<CreditTransaction>;

      _setLoading(false);
    } catch (e) {
      _setError('Kredi verileri yüklenirken hata oluştu: $e');
      _setLoading(false);
    }
  }

  /// Purchase a credit package
  Future<bool> purchasePackage(String venueId, CreditPackage package) async {
    _isPurchasing = true;
    _clearError();
    notifyListeners();

    try {
      await _repository.purchasePackage(venueId: venueId, package: package);

      // Refresh balance and transactions after purchase
      _balance = await _repository.getBalance(venueId);
      _transactions = await _repository.getTransactions(venueId);

      _isPurchasing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Satın alma işlemi başarısız oldu: $e');
      _isPurchasing = false;
      return false;
    }
  }

  /// Refresh only the balance
  Future<void> refreshBalance(String venueId) async {
    try {
      _balance = await _repository.getBalance(venueId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing credit balance: $e');
    }
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
