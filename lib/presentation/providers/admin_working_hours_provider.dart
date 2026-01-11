import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminWorkingHoursProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _workingHours = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get workingHours => _workingHours;

  Future<void> loadWorkingHours(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('venues')
          .select('working_hours')
          .eq('id', venueId)
          .single();

      _workingHours = response['working_hours'] as Map<String, dynamic>? ?? {};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveWorkingHours(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase
          .from('venues')
          .update({'working_hours': _workingHours})
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

  void updateDayHours(String day, Map<String, dynamic> hours) {
    _workingHours[day] = hours;
    notifyListeners();
  }

  void applyToAllDays(Map<String, dynamic> hours) {
    _workingHours = {
      'monday': hours,
      'tuesday': hours,
      'wednesday': hours,
      'thursday': hours,
      'friday': hours,
      'saturday': hours,
      'sunday': hours,
    };
    notifyListeners();
  }
}
