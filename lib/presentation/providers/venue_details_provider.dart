import 'package:flutter/material.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_photo.dart';
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
    print('DEBUG: Loading details for venueId: $venueId');

    // reset all data to absolute zero to prevent "leaking" data from previous venue
    _venue = initialVenue;
    _services = [];
    _reviews = [];
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Force fresh fetch for EVERYTHING - absolute no caching
      _venue = await _repository.getVenueById(venueId);

      if (_venue == null) {
        throw Exception('Mekan verisi bulunamadı');
      }

      // Parallel fetch for speed but ensured freshness
      final results = await Future.wait([
        _repository.getServicesByVenueId(venueId),
        _repository.getReviewsByVenueId(venueId),
        _repository.fetchVenuePhotos(venueId),
        _repository.checkIfFollowing(venueId),
      ]);

      _services = results[0] as List<Service>;
      _reviews = results[1] as List<Review>;
      final galleryPhotos = results[2] as List<VenuePhoto>;
      final isFollowing = results[3] as bool;

      // Final update of the venue object with all dynamic data
      _venue = _venue!.copyWith(
        galleryPhotos: galleryPhotos,
        isFollowing: isFollowing,
      );

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

  /// Like a gallery photo
  Future<void> likePhoto(String photoId) async {
    try {
      await _repository.likePhoto(photoId);

      // Update local state if needed (find photo in galleryPhotos and increment count)
      if (_venue != null && _venue!.galleryPhotos != null) {
        final photos = List<VenuePhoto>.from(_venue!.galleryPhotos!);
        final index = photos.indexWhere((p) => p.id == photoId);
        if (index != -1) {
          final photo = photos[index];
          photos[index] = photo.copyWith(likesCount: photo.likesCount + 1);
          _venue = _venue!.copyWith(galleryPhotos: photos);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error liking photo: $e');
    }
  }

  /// Unlike a gallery photo
  Future<void> unlikePhoto(String photoId) async {
    try {
      await _repository.unlikePhoto(photoId);

      // Update local state if needed
      if (_venue != null && _venue!.galleryPhotos != null) {
        final photos = List<VenuePhoto>.from(_venue!.galleryPhotos!);
        final index = photos.indexWhere((p) => p.id == photoId);
        if (index != -1) {
          final photo = photos[index];
          photos[index] = photo.copyWith(
            likesCount: photo.likesCount > 0 ? photo.likesCount - 1 : 0,
          );
          _venue = _venue!.copyWith(galleryPhotos: photos);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error unliking photo: $e');
    }
  }

  /// Refresh reviews and venue data (useful after submitting a review)
  Future<void> refreshReviews() async {
    if (_venue == null) return;

    try {
      // Reload reviews
      _reviews = await _repository.getReviewsByVenueId(_venue!.id);

      // Reload venue to get updated rating/ratingCount
      final updatedVenue = await _repository.getVenueById(_venue!.id);
      if (updatedVenue != null) {
        // preserve follow status and gallery photos if they were lazy loaded
        _venue = updatedVenue.copyWith(
          isFollowing: _venue!.isFollowing,
          galleryPhotos: _venue!.galleryPhotos,
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error refreshing reviews: $e');
    }
  }
}
