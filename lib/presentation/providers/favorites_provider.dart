import 'package:flutter/foundation.dart';
import '../../data/models/venue.dart';
import '../../data/repositories/venue_repository.dart';

enum FavoritesTab { favorites, following }

class FavoritesProvider extends ChangeNotifier {
  final VenueRepository _venueRepository;

  FavoritesProvider({required VenueRepository venueRepository})
    : _venueRepository = venueRepository;

  // Lists
  List<Venue> _favoriteVenues = [];
  List<Venue> _followedVenues = [];

  // State
  bool _isLoading = false;
  String? _errorMessage;
  FavoritesTab _currentTab = FavoritesTab.favorites;

  // Getters
  List<Venue> get favoriteVenues => _favoriteVenues;
  List<Venue> get followedVenues => _followedVenues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FavoritesTab get currentTab => _currentTab;

  void setTab(FavoritesTab tab) {
    _currentTab = tab;
    notifyListeners();
    // Refresh the list for the selected tab
    if (tab == FavoritesTab.favorites) {
      loadFavorites();
    } else {
      loadFollowedVenues();
    }
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        loadFavorites(notify: false),
        loadFollowedVenues(notify: false),
      ]);
    } catch (e) {
      _errorMessage = 'Yükleme sırasında bir hata oluştu';
      debugPrint('Error loading favorites data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites({bool notify = true}) async {
    if (notify) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _favoriteVenues = await _venueRepository.getFavoriteVenues();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      if (notify) _errorMessage = 'Favoriler yüklenemedi';
    } finally {
      if (notify) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadFollowedVenues({bool notify = true}) async {
    if (notify) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _followedVenues = await _venueRepository.getFollowedVenues();
    } catch (e) {
      debugPrint('Error loading followed venues: $e');
      if (notify) _errorMessage = 'Takip edilen mekanlar yüklenemedi';
    } finally {
      if (notify) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleFavorite(Venue venue) async {
    final isFavorited = venue.isFavorited;

    try {
      if (isFavorited) {
        await _venueRepository.removeFavorite(venue.id);
        // Remove from local list if we are on favorites tab
        _favoriteVenues.removeWhere((v) => v.id == venue.id);
      } else {
        await _venueRepository.addFavorite(venue.id);
        // Ideally we'd refresh or add to list, but usually this is called from discovery/search
        // If we are on favorites screen, it might already be favorited.
      }

      // Update the venue object in both lists if it exists
      _updateVenueInLists(venue.id, isFavorited: !isFavorited);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<void> toggleFollow(Venue venue) async {
    final isFollowing = venue.isFollowing;
    final newFollowerCount = isFollowing
        ? (venue.followerCount > 0 ? venue.followerCount - 1 : 0)
        : venue.followerCount + 1;

    try {
      if (isFollowing) {
        await _venueRepository.unfollowVenue(venue.id);
        // Remove from local list if we are on following tab
        _followedVenues.removeWhere((v) => v.id == venue.id);
      } else {
        await _venueRepository.followVenue(venue.id);
      }

      _updateVenueInLists(
        venue.id,
        isFollowing: !isFollowing,
        followerCount: newFollowerCount,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      rethrow;
    }
  }

  void _updateVenueInLists(
    String venueId, {
    bool? isFollowing,
    int? followerCount,
    bool? isFavorited,
  }) {
    // Update in favoriteVenues
    final favIndex = _favoriteVenues.indexWhere((v) => v.id == venueId);
    if (favIndex != -1) {
      _favoriteVenues[favIndex] = _favoriteVenues[favIndex].copyWith(
        isFollowing: isFollowing,
        followerCount: followerCount,
        isFavorited: isFavorited,
      );
    }

    // Update in followedVenues
    final followIndex = _followedVenues.indexWhere((v) => v.id == venueId);
    if (followIndex != -1) {
      _followedVenues[followIndex] = _followedVenues[followIndex].copyWith(
        isFollowing: isFollowing,
        followerCount: followerCount,
        isFavorited: isFavorited,
      );
    }
  }
}
