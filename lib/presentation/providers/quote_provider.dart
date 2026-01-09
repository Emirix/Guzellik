import 'package:flutter/material.dart';
import '../../data/models/quote_request.dart';
import '../../data/models/quote_response.dart';
import '../../data/models/service_category.dart';
import '../../data/models/province.dart';
import '../../data/models/district.dart';
import '../../data/repositories/quote_repository.dart';
import '../../data/repositories/location_repository.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteRepository _quoteRepository;
  final LocationRepository _locationRepository;

  QuoteProvider(this._quoteRepository, this._locationRepository);

  // State for creating a quote
  List<ServiceCategory> _selectedServices = [];
  DateTime? _preferredDate;
  String? _preferredTimeSlot;
  String? _notes;
  int? _provinceId;
  String? _districtId;
  bool _isCreating = false;

  List<ServiceCategory> get selectedServices => _selectedServices;
  DateTime? get preferredDate => _preferredDate;
  String? get preferredTimeSlot => _preferredTimeSlot;
  String? get notes => _notes;
  int? get provinceId => _provinceId;
  String? get districtId => _districtId;
  bool get isCreating => _isCreating;

  // New location state
  List<Province> _provinces = [];
  List<District> _districts = [];
  bool _isLoadingLocations = false;

  List<Province> get provinces => _provinces;
  List<District> get districts => _districts;
  bool get isLoadingLocations => _isLoadingLocations;

  // State for viewing quotes
  List<QuoteRequest> _myQuotes = [];
  bool _isLoadingQuotes = false;
  String? _quotesError;
  bool _hasCheckedQuotes = false;

  List<QuoteRequest> get myQuotes => _myQuotes;
  bool get isLoadingQuotes => _isLoadingQuotes;
  String? get quotesError => _quotesError;
  bool get hasCheckedQuotes => _hasCheckedQuotes;
  bool get hasAnyQuotes => _myQuotes.isNotEmpty;

  List<ServiceCategory> _allServiceCategories = [];
  bool _isLoadingServiceCategories = false;

  List<ServiceCategory> get allServiceCategories => _allServiceCategories;
  bool get isLoadingServiceCategories => _isLoadingServiceCategories;

  Future<void> loadLocations() async {
    _isLoadingLocations = true;
    notifyListeners();
    try {
      _provinces = await _locationRepository.fetchProvinces();
    } catch (e) {
      debugPrint('Error loading provinces: $e');
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }

  Future<void> loadDistricts(int provinceId) async {
    _isLoadingLocations = true;
    notifyListeners();
    try {
      _districts = await _locationRepository.fetchDistrictsByProvince(
        provinceId,
      );
    } catch (e) {
      debugPrint('Error loading districts: $e');
    } finally {
      _isLoadingLocations = false;
      notifyListeners();
    }
  }

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

  void setPreferredDate(DateTime? date) {
    _preferredDate = date;
    notifyListeners();
  }

  void setPreferredTimeSlot(String? slot) {
    _preferredTimeSlot = slot;
    notifyListeners();
  }

  void setNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  void setLocation(int? provinceId, String? districtId) {
    _provinceId = provinceId;
    _districtId = districtId;
    if (provinceId != null) {
      loadDistricts(provinceId);
    } else {
      _districts = [];
    }
    notifyListeners();
  }

  void resetForm() {
    _selectedServices = [];
    _preferredDate = null;
    _preferredTimeSlot = null;
    _notes = null;
    _provinceId = null;
    _districtId = null;
    notifyListeners();
  }

  // API methods
  Future<bool> createQuoteRequest() async {
    if (_selectedServices.isEmpty) return false;

    _isCreating = true;
    notifyListeners();

    try {
      await _quoteRepository.createQuoteRequest(
        preferredDate: _preferredDate,
        preferredTimeSlot: _preferredTimeSlot,
        notes: _notes,
        serviceCategoryIds: _selectedServices.map((s) => s.id).toList(),
        provinceId: _provinceId,
        districtId: _districtId,
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
      _hasCheckedQuotes = true;
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
