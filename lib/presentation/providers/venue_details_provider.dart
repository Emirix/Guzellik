import 'package:flutter/material.dart';
import '../../data/models/venue.dart';
import '../../data/models/service.dart';
import '../../data/models/review.dart';
import '../../data/repositories/venue_repository.dart';

class VenueDetailsProvider extends ChangeNotifier {
  final VenueRepository _repository = VenueRepository();

  Venue? _venue;
  List<Service> _services = [];
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  Venue? get venue => _venue;
  List<Service> get services => _services;
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Grouped services by category
  Map<String, List<Service>> get groupedServices {
    final Map<String, List<Service>> grouped = {};
    for (var service in _services) {
      if (!grouped.containsKey(service.category)) {
        grouped[service.category] = [];
      }
      grouped[service.category]!.add(service);
    }
    return grouped;
  }

  Future<void> loadVenueDetails(String venueId, {Venue? initialVenue}) async {
    _venue = initialVenue;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // If we don't have the initial venue or need fresh data
      if (_venue == null) {
        _venue = await _repository.getVenueById(venueId);
      }

      // Fetch services for this venue
      _services = await _repository.getServicesByVenueId(venueId);

      // Fetch reviews
      _reviews = await _repository.getReviewsByVenueId(venueId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFollow() async {
    if (_venue == null) return;

    // In a real app, we'd update the follow status in the DB and then update local state
    // For now, let's assume we update the venue object or refetch
    try {
      // Logic for following/unfollowing would go here
      // This might require updating the Venue model to include isFollowing
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
