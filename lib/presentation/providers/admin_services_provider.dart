import 'package:flutter/material.dart';
import '../../data/models/venue_service.dart';
import '../../data/models/service_category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminServicesProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<VenueService> _venueServices = [];
  List<ServiceCategory> _allCategories = [];
  bool _isLoading = false;
  String? _error;

  List<VenueService> get venueServices => _venueServices;
  List<ServiceCategory> get allCategories => _allCategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all available services from the catalog and the venue's selected services
  Future<void> initialize(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([fetchVenueServices(venueId), fetchAllCategories()]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchVenueServices(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_services')
          .select('*, service_categories(*)')
          .eq('venue_id', venueId)
          .order('sort_order', ascending: true);

      _venueServices = (response as List).map((json) {
        final serviceCat = json['service_categories'] as Map<String, dynamic>;
        return VenueService.fromJson({
          ...json,
          'service_name': serviceCat['name'],
          'service_category':
              serviceCat['sub_category'] ?? serviceCat['category'],
          'service_description': serviceCat['description'],
          'service_average_duration': serviceCat['average_duration_minutes'],
        });
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchAllCategories() async {
    try {
      final response = await _supabase
          .from('service_categories')
          .select()
          .order('sub_category', ascending: true)
          .order('name', ascending: true);

      _allCategories = (response as List)
          .map((json) => ServiceCategory.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback if sub_category doesn't exist (though it should according to recent migrations)
      try {
        final response = await _supabase
            .from('service_categories')
            .select()
            .order('name', ascending: true);
        _allCategories = (response as List)
            .map((json) => ServiceCategory.fromJson(json))
            .toList();
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> addService(
    String venueId,
    String categoryId, {
    double? price,
    int? durationMinutes,
  }) async {
    try {
      final newSortOrder = _venueServices.isEmpty
          ? 0
          : _venueServices
                    .map((e) => e.sortOrder)
                    .reduce((a, b) => a > b ? a : b) +
                1;

      await _supabase.from('venue_services').insert({
        'venue_id': venueId,
        'service_category_id': categoryId,
        'price': price,
        'duration_minutes': durationMinutes,
        'sort_order': newSortOrder,
      });

      await fetchVenueServices(venueId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateService(
    String serviceId, {
    double? price,
    int? durationMinutes,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      updates['price'] = price;
      updates['duration_minutes'] = durationMinutes;
      if (isActive != null) updates['is_active'] = isActive;

      await _supabase
          .from('venue_services')
          .update(updates)
          .eq('id', serviceId);

      // Fetch the whole list again to be sure
      if (_venueServices.isNotEmpty) {
        final venueId = _venueServices.first.venueId;
        await fetchVenueServices(venueId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      final index = _venueServices.indexWhere(
        (element) => element.id == serviceId,
      );
      if (index != -1) {
        final service = _venueServices[index];
        final venueId = service.venueId;

        // 1. Delete from DB
        await _supabase.from('venue_services').delete().eq('id', serviceId);

        await fetchVenueServices(venueId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reorderServices(String venueId, List<String> orderedIds) async {
    try {
      _venueServices.sort((a, b) {
        final indexA = orderedIds.indexOf(a.id);
        final indexB = orderedIds.indexOf(b.id);
        return indexA.compareTo(indexB);
      });
      notifyListeners();

      for (int i = 0; i < orderedIds.length; i++) {
        await _supabase
            .from('venue_services')
            .update({'sort_order': i})
            .eq('id', orderedIds[i]);
      }
    } catch (e) {
      _error = "Sıralama güncellenemedi";
      notifyListeners();
      await fetchVenueServices(venueId);
    }
  }
}
