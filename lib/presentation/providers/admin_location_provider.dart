import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLocationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;

  String _address = '';
  double _latitude = 0;
  double _longitude = 0;
  int? _provinceId;
  String? _districtId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get address => _address;
  double get latitude => _latitude;
  double get longitude => _longitude;
  int? get provinceId => _provinceId;
  String? get districtId => _districtId;

  Future<void> loadLocation(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('venues')
          .select('address, latitude, longitude, province_id, district_id')
          .eq('id', venueId)
          .single();

      _address = response['address'] ?? '';
      _latitude = (response['latitude'] as num?)?.toDouble() ?? 0;
      _longitude = (response['longitude'] as num?)?.toDouble() ?? 0;
      _provinceId = response['province_id'];
      _districtId = response['district_id'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveLocation(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use RPC for PostGIS update if possible, otherwise normal update
      await _supabase
          .from('venues')
          .update({
            'address': _address,
            'latitude': _latitude,
            'longitude': _longitude,
            'province_id': _provinceId,
            'district_id': _districtId,
          })
          .eq('id', venueId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void updateAddress(String address) {
    _address = address;
    notifyListeners();
  }

  void updateCoordinates(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void updateProvinceDistrict(int provinceId, String districtId) {
    _provinceId = provinceId;
    _districtId = districtId;
    notifyListeners();
  }
}
