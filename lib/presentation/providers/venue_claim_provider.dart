import 'package:flutter/material.dart';
import '../repositories/venue_claim_repository.dart';

class VenueClaimProvider extends ChangeNotifier {
  final _repository = VenueClaimRepository.instance;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _myClaims = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  List<Map<String, dynamic>> get myClaims => _myClaims;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchVenues(String query) async {
    if (query.length < 3) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _repository.searchVenues(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyClaims(String profileId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myClaims = await _repository.getMyClaimRequests(profileId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitClaim({
    required String profileId,
    required String venueId,
    required List<String> documentUrls,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitClaimRequest(
        profileId: profileId,
        venueId: venueId,
        documentUrls: documentUrls,
      );
      await loadMyClaims(profileId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
