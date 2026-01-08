import 'package:flutter/foundation.dart';
import '../../data/models/venue_category.dart';
import '../../data/repositories/venue_repository.dart';

class CategoryProvider with ChangeNotifier {
  final VenueRepository _venueRepository = VenueRepository();

  List<VenueCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<VenueCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _venueRepository.getVenueCategories();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  VenueCategory? getCategoryById(String? id) {
    if (id == null) return null;
    return _categories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => _categories.first,
    );
  }
}
