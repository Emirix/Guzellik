import 'package:flutter/material.dart';
import '../../../data/models/venue_feature.dart';
import '../../../data/repositories/venue_features_repository.dart';

class AdminFeaturesProvider with ChangeNotifier {
  final VenueFeaturesRepository _repository;
  final String venueId;

  AdminFeaturesProvider({
    required VenueFeaturesRepository repository,
    required this.venueId,
  }) : _repository = repository;

  // State
  List<VenueFeature> _allFeatures = [];
  List<String> _selectedFeatureIds = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<VenueFeature> get allFeatures => _allFeatures;
  List<String> get selectedFeatureIds => _selectedFeatureIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get features grouped by category
  Map<String, List<VenueFeature>> get featuresByCategory {
    final Map<String, List<VenueFeature>> grouped = {};
    for (final feature in _allFeatures) {
      if (!grouped.containsKey(feature.category)) {
        grouped[feature.category] = [];
      }
      grouped[feature.category]!.add(feature);
    }
    return grouped;
  }

  // Check if a feature is selected
  bool isFeatureSelected(String featureId) {
    return _selectedFeatureIds.contains(featureId);
  }

  // Initialize - Load all features and selected ones
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all available features
      _allFeatures = await _repository.getAllFeatures();

      // Load selected features for this venue
      _selectedFeatureIds = await _repository.getVenueFeatureIds(venueId);

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error initializing features: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle feature selection
  void toggleFeature(String featureId) {
    if (_selectedFeatureIds.contains(featureId)) {
      _selectedFeatureIds.remove(featureId);
    } else {
      _selectedFeatureIds.add(featureId);
    }
    notifyListeners();
  }

  // Save selected features
  Future<bool> saveFeatures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateVenueFeatures(venueId, _selectedFeatureIds);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error saving features: $e');
      return false;
    }
  }

  // Reset to original state
  Future<void> reset() async {
    try {
      _selectedFeatureIds = await _repository.getVenueFeatureIds(venueId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
