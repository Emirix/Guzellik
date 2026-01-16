import 'package:flutter/material.dart';
import '../../data/models/venue.dart';
import '../../data/models/venue_photo.dart';
import '../../data/models/service.dart';
import '../../data/models/review.dart';
import '../../data/models/specialist.dart';
import '../../data/models/campaign.dart';
import '../../data/models/venue_feature.dart';
import '../../data/repositories/venue_repository.dart';

class VenueDetailsProvider extends ChangeNotifier {
  final VenueRepository _repository = VenueRepository();

  Venue? _venue;
  List<Service> _services = [];
  List<Review> _reviews = [];
  List<Specialist> _specialists = [];
  List<Campaign> _campaigns = [];
  List<VenueFeature> _venueFeatures = [];
  bool _isLoading = false;
  bool _isFollowLoading = false;
  String? _error;

  Venue? get venue => _venue;
  List<Service> get services => _services;
  List<Review> get reviews => _reviews;
  List<Specialist> get specialists => _specialists;
  List<Campaign> get campaigns => _campaigns;
  List<VenueFeature> get venueFeatures => _venueFeatures;
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
    _specialists = [];
    _campaigns = [];
    _venueFeatures = [];
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
        _repository.getVenueSpecialists(venueId),
        _repository.getVenueCampaigns(venueId),
        _repository.getVenueFeatures(venueId),
      ]);

      _services = results[0] as List<Service>;
      _reviews = results[1] as List<Review>;
      final galleryPhotos = results[2] as List<VenuePhoto>;
      final isFollowing = results[3] as bool;
      _specialists = results[4] as List<Specialist>;
      _campaigns = results[5] as List<Campaign>;
      _venueFeatures = results[6] as List<VenueFeature>;

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
      _venue = _venue!.copyWith(
        isFollowing: true,
        followerCount: _venue!.followerCount + 1,
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
      _venue = _venue!.copyWith(
        isFollowing: false,
        followerCount: _venue!.followerCount > 0
            ? _venue!.followerCount - 1
            : 0,
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

  /// Toggle favorite status
  Future<void> toggleFavoriteVenue(Venue venue) async {
    if (_venue == null || _venue!.id != venue.id) return;

    final isFavorited = _venue!.isFavorited;

    // Update local state immediately
    _venue = _venue!.copyWith(isFavorited: !isFavorited);
    notifyListeners();

    try {
      if (isFavorited) {
        await _repository.removeFavorite(_venue!.id);
      } else {
        await _repository.addFavorite(_venue!.id);
      }
    } catch (e) {
      // Revert local state on error
      _venue = _venue!.copyWith(isFavorited: isFavorited);
      notifyListeners();
      rethrow;
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

  /// Refresh specialists data
  Future<void> refreshSpecialists() async {
    if (_venue == null) return;

    try {
      _specialists = await _repository.getVenueSpecialists(_venue!.id);
      notifyListeners();
    } catch (e) {
      print('Error refreshing specialists: $e');
    }
  }

  /// Refresh campaigns data
  Future<void> refreshCampaigns() async {
    if (_venue == null) return;

    try {
      _campaigns = await _repository.getVenueCampaigns(_venue!.id);
      notifyListeners();
    } catch (e) {
      print('Error refreshing campaigns: $e');
    }
  }

  /// Refresh photos data
  Future<void> refreshPhotos() async {
    if (_venue == null) return;

    try {
      final photos = await _repository.getVenuePhotos(_venue!.id);
      _venue = _venue!.copyWith(galleryPhotos: photos);
      notifyListeners();
    } catch (e) {
      print('Error refreshing photos: $e');
    }
  }

  /// Get hero/primary image from gallery
  VenuePhoto? get heroImage {
    if (_venue?.galleryPhotos == null || _venue!.galleryPhotos!.isEmpty) {
      return null;
    }

    // Find hero image
    final hero = _venue!.galleryPhotos!.firstWhere(
      (photo) => photo.isHeroImage,
      orElse: () => _venue!.galleryPhotos!.first,
    );

    return hero;
  }
}
