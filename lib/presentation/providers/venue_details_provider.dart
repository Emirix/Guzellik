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
  bool _isFollowLoading = false;
  String? _error;

  Venue? get venue => _venue;
  List<Service> get services => _services;
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get isFollowLoading => _isFollowLoading;
  String? get error => _error;

  // Follow state
  bool get isFollowing => _venue?.isFollowing ?? false;

  // Grouped services by category
  Map<String, List<Service>> get groupedServices {
    final Map<String, List<Service>> grouped = {};
    for (var service in _services) {
      final category = service.category ?? 'Genel';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(service);
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

      // Check follow status
      final isFollowing = await _repository.checkIfFollowing(venueId);

      // Update venue with follow status
      if (_venue != null) {
        _venue = Venue(
          id: _venue!.id,
          name: _venue!.name,
          description: _venue!.description,
          address: _venue!.address,
          latitude: _venue!.latitude,
          longitude: _venue!.longitude,
          imageUrl: _venue!.imageUrl,
          heroImages: _venue!.heroImages,
          galleryPhotos: _venue!.galleryPhotos,
          isVerified: _venue!.isVerified,
          isPreferred: _venue!.isPreferred,
          isHygienic: _venue!.isHygienic,
          isFollowing: isFollowing,
          followerCount: _venue!.followerCount,
          workingHours: _venue!.workingHours,
          expertTeam: _venue!.expertTeam,
          certifications: _venue!.certifications,
          paymentOptions: _venue!.paymentOptions,
          accessibility: _venue!.accessibility,
          faq: _venue!.faq,
          socialLinks: _venue!.socialLinks,
          features: _venue!.features,
          ownerId: _venue!.ownerId,
          createdAt: _venue!.createdAt,
        );
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

  /// Follow a venue
  Future<bool> followVenue() async {
    if (_venue == null) return false;

    _isFollowLoading = true;
    notifyListeners();

    try {
      await _repository.followVenue(_venue!.id);

      // Update local state
      _venue = Venue(
        id: _venue!.id,
        name: _venue!.name,
        description: _venue!.description,
        address: _venue!.address,
        latitude: _venue!.latitude,
        longitude: _venue!.longitude,
        imageUrl: _venue!.imageUrl,
        heroImages: _venue!.heroImages,
        galleryPhotos: _venue!.galleryPhotos,
        isVerified: _venue!.isVerified,
        isPreferred: _venue!.isPreferred,
        isHygienic: _venue!.isHygienic,
        isFollowing: true,
        followerCount: _venue!.followerCount + 1,
        workingHours: _venue!.workingHours,
        expertTeam: _venue!.expertTeam,
        certifications: _venue!.certifications,
        paymentOptions: _venue!.paymentOptions,
        accessibility: _venue!.accessibility,
        faq: _venue!.faq,
        socialLinks: _venue!.socialLinks,
        features: _venue!.features,
        ownerId: _venue!.ownerId,
        createdAt: _venue!.createdAt,
      );

      _isFollowLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isFollowLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Unfollow a venue
  Future<bool> unfollowVenue() async {
    if (_venue == null) return false;

    _isFollowLoading = true;
    notifyListeners();

    try {
      await _repository.unfollowVenue(_venue!.id);

      // Update local state
      _venue = Venue(
        id: _venue!.id,
        name: _venue!.name,
        description: _venue!.description,
        address: _venue!.address,
        latitude: _venue!.latitude,
        longitude: _venue!.longitude,
        imageUrl: _venue!.imageUrl,
        heroImages: _venue!.heroImages,
        galleryPhotos: _venue!.galleryPhotos,
        isVerified: _venue!.isVerified,
        isPreferred: _venue!.isPreferred,
        isHygienic: _venue!.isHygienic,
        isFollowing: false,
        followerCount: _venue!.followerCount > 0
            ? _venue!.followerCount - 1
            : 0,
        workingHours: _venue!.workingHours,
        expertTeam: _venue!.expertTeam,
        certifications: _venue!.certifications,
        paymentOptions: _venue!.paymentOptions,
        accessibility: _venue!.accessibility,
        faq: _venue!.faq,
        socialLinks: _venue!.socialLinks,
        features: _venue!.features,
        ownerId: _venue!.ownerId,
        createdAt: _venue!.createdAt,
      );

      _isFollowLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isFollowLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
