import 'package:flutter/material.dart';
import '../../data/models/quote_request.dart';
import '../../data/models/quote_response.dart';
import '../../data/models/service_category.dart';
import '../../data/repositories/quote_repository.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteRepository _quoteRepository;

  QuoteProvider(this._quoteRepository);

  // State for creating a quote
  List<ServiceCategory> _selectedServices = [];
  DateTime? _preferredDate;
  String? _preferredTimeSlot;
  String? _notes;
  bool _isCreating = false;

  List<ServiceCategory> get selectedServices => _selectedServices;
  DateTime? get preferredDate => _preferredDate;
  String? get preferredTimeSlot => _preferredTimeSlot;
  String? get notes => _notes;
  bool get isCreating => _isCreating;

  // State for viewing quotes
  List<QuoteRequest> _myQuotes = [];
  bool _isLoadingQuotes = false;
  String? _quotesError;

  List<QuoteRequest> get myQuotes => _myQuotes;
  bool get isLoadingQuotes => _isLoadingQuotes;
  String? get quotesError => _quotesError;

  List<ServiceCategory> _allServiceCategories = [];
  bool _isLoadingServiceCategories = false;

  List<ServiceCategory> get allServiceCategories => _allServiceCategories;
  bool get isLoadingServiceCategories => _isLoadingServiceCategories;

  Future<void> loadServiceCategories() async {
    _isLoadingServiceCategories = true;
    notifyListeners();
    try {
      _allServiceCategories = await _quoteRepository.getServiceCategories();
    } catch (e) {
      debugPrint('Error loading service categories: $e');
    } finally {
      _isLoadingServiceCategories = false;
      notifyListeners();
    }
  }

  // Selection methods
  void toggleService(ServiceCategory service) {
    if (_selectedServices.any((s) => s.id == service.id)) {
      _selectedServices.removeWhere((s) => s.id == service.id);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }

  void setPreferredDate(DateTime date) {
    _preferredDate = date;
    notifyListeners();
  }

  void setPreferredTimeSlot(String slot) {
    _preferredTimeSlot = slot;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void resetForm() {
    _selectedServices = [];
    _preferredDate = null;
    _preferredTimeSlot = null;
    _notes = null;
    notifyListeners();
  }

  // API methods
  Future<bool> createQuoteRequest() async {
    if (_selectedServices.isEmpty) return false;

    _isCreating = true;
    notifyListeners();

    try {
      await _quoteRepository.createQuoteRequest(
        preferredDate: _preferredDate!,
        preferredTimeSlot: _preferredTimeSlot,
        notes: _notes,
        serviceCategoryIds: _selectedServices.map((s) => s.id).toList(),
      );
      resetForm();
      await fetchMyQuotes();
      return true;
    } catch (e) {
      debugPrint('Error creating quote request: $e');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyQuotes() async {
    _isLoadingQuotes = true;
    _quotesError = null;
    notifyListeners();

    try {
      _myQuotes = await _quoteRepository.getMyQuoteRequests();
    } catch (e) {
      _quotesError = 'Teklifler yüklenirken bir hata oluştu.';
      debugPrint('Error fetching quotes: $e');
    } finally {
      _isLoadingQuotes = false;
      notifyListeners();
    }
  }

  Future<List<QuoteResponse>> getResponses(String quoteRequestId) async {
    try {
      return await _quoteRepository.getQuoteResponses(quoteRequestId);
    } catch (e) {
      debugPrint('Error fetching responses: $e');
      return [];
    }
  }

  Future<void> closeQuote(String id) async {
    try {
      await _quoteRepository.closeQuoteRequest(id);
      await fetchMyQuotes();
    } catch (e) {
      debugPrint('Error closing quote: $e');
    }
  }
}
