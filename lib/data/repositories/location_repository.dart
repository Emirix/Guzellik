import '../models/province.dart';
import '../models/district.dart';
import '../services/supabase_service.dart';

/// Repository for fetching location data (provinces and districts) from Supabase
class LocationRepository {
  // In-memory cache for provinces
  List<Province>? _provincesCache;

  // In-memory cache for districts by province ID
  final Map<int, List<District>> _districtsCache = {};

  /// Fetch all provinces from Supabase
  /// Returns cached data if available
  Future<List<Province>> fetchProvinces() async {
    // Return cached data if available
    if (_provincesCache != null) {
      return _provincesCache!;
    }

    try {
      final response = await SupabaseService.instance.client
          .from('provinces')
          .select()
          .order('name', ascending: true)
          .timeout(const Duration(seconds: 10));

      final provinces = (response as List)
          .map((json) => Province.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the result
      _provincesCache = provinces;
      return provinces;
    } catch (e) {
      throw LocationRepositoryException(
        'İl listesi yüklenemedi: ${e.toString()}',
      );
    }
  }

  /// Fetch districts for a specific province
  /// Returns cached data if available
  Future<List<District>> fetchDistrictsByProvince(int provinceId) async {
    // Return cached data if available
    if (_districtsCache.containsKey(provinceId)) {
      return _districtsCache[provinceId]!;
    }

    try {
      final response = await SupabaseService.instance.client
          .from('districts')
          .select()
          .eq('province_id', provinceId)
          .order('name', ascending: true)
          .timeout(const Duration(seconds: 10));

      final districts = (response as List)
          .map((json) => District.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the result
      _districtsCache[provinceId] = districts;
      return districts;
    } catch (e) {
      throw LocationRepositoryException(
        'İlçe listesi yüklenemedi: ${e.toString()}',
      );
    }
  }

  /// Find province by name (case-insensitive)
  Future<Province?> findProvinceByName(String name) async {
    final provinces = await fetchProvinces();
    final normalizedName = name.toLowerCase().trim();

    try {
      return provinces.firstWhere(
        (p) => p.name.toLowerCase() == normalizedName,
      );
    } catch (_) {
      return null;
    }
  }

  /// Find district by name within a province (case-insensitive)
  Future<District?> findDistrictByName(int provinceId, String name) async {
    final districts = await fetchDistrictsByProvince(provinceId);
    final normalizedName = name.toLowerCase().trim();

    try {
      return districts.firstWhere(
        (d) => d.name.toLowerCase() == normalizedName,
      );
    } catch (_) {
      return null;
    }
  }

  /// Clear all cached data
  void clearCache() {
    _provincesCache = null;
    _districtsCache.clear();
  }

  /// Clear only districts cache
  void clearDistrictsCache() {
    _districtsCache.clear();
  }
}

/// Exception thrown when location repository operations fail
class LocationRepositoryException implements Exception {
  final String message;
  LocationRepositoryException(this.message);

  @override
  String toString() => message;
}
