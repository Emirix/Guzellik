import 'package:flutter/foundation.dart';
import '../../data/models/campaign.dart';
import '../../data/repositories/campaign_repository.dart';

/// Provider for campaign state management
class CampaignProvider with ChangeNotifier {
  final CampaignRepository _repository;

  CampaignProvider({CampaignRepository? repository})
    : _repository = repository ?? CampaignRepository();

  // State
  List<Campaign> _campaigns = [];
  bool _isLoading = false;
  String? _error;
  CampaignSortType _sortType = CampaignSortType.date;

  // Getters
  List<Campaign> get campaigns => _campaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CampaignSortType get sortType => _sortType;
  bool get hasCampaigns => _campaigns.isNotEmpty;

  /// Fetch all active campaigns
  Future<void> fetchCampaigns({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _isLoading = true;
    _error = null;
    if (refresh) {
      _campaigns = [];
    }
    notifyListeners();

    try {
      _campaigns = await _repository.getAllCampaigns(sortBy: _sortType);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _campaigns = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change sort type and refetch
  Future<void> setSortType(CampaignSortType sortType) async {
    if (_sortType == sortType) return;

    _sortType = sortType;
    notifyListeners();

    await fetchCampaigns(refresh: true);
  }

  /// Get campaigns for a specific venue
  Future<List<Campaign>> getCampaignsForVenue(String venueId) async {
    try {
      return await _repository.getCampaignsByVenue(venueId);
    } catch (e) {
      debugPrint('Error fetching venue campaigns: $e');
      return [];
    }
  }

  /// Get active campaign count for a venue
  Future<int> getActiveCampaignCount(String venueId) async {
    try {
      return await _repository.getActiveCampaignCount(venueId);
    } catch (e) {
      debugPrint('Error fetching campaign count: $e');
      return 0;
    }
  }

  /// Refresh campaigns (pull-to-refresh)
  Future<void> refresh() async {
    await fetchCampaigns(refresh: true);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
