import 'package:flutter/foundation.dart';
import '../../data/models/appointment.dart';
import '../../data/models/venue_service.dart';
import '../../data/services/appointment_data_service.dart';

/// Provider for managing appointment state and operations
class AppointmentProvider with ChangeNotifier {
  final AppointmentDataService _appointmentService = AppointmentDataService();

  List<Appointment> _appointments = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Appointment> get appointments => _appointments;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Seçili tarihi değiştir
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Günlük randevuları getir
  Future<void> fetchDailyAppointments(String venueId, DateTime date) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint(
        '🔍 [AppointmentProvider] Fetching appointments for venue: $venueId, date: $date',
      );
      _appointments = await _appointmentService.getAppointmentsByDate(
        venueId: venueId,
        date: date,
      );
      debugPrint(
        '✅ [AppointmentProvider] Found ${_appointments.length} appointments',
      );
      _setLoading(false);
    } catch (e) {
      debugPrint('❌ [AppointmentProvider] Error: $e');
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Tarih aralığı için randevuları getir
  Future<void> fetchAppointmentsByRange({
    required String venueId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _appointments = await _appointmentService.getAppointmentsByDateRange(
        venueId: venueId,
        startDate: startDate,
        endDate: endDate,
      );
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  /// Müşteriye ait randevuları getir
  Future<List<Appointment>> fetchCustomerAppointments(String customerId) async {
    try {
      return await _appointmentService.getAppointmentsByCustomerId(
        customerId: customerId,
      );
    } catch (e) {
      print('Error fetching customer appointments: $e');
      return [];
    }
  }

  /// Yeni randevu oluştur
  Future<bool> createAppointment(Appointment appointment) async {
    _setLoading(true);
    _clearError();

    try {
      // Convert appointment.services to VenueService list for the data service
      // Note: We're using the service data from the appointment model
      final selectedServices = appointment.services.map((service) {
        return VenueService(
          id: service.serviceId,
          venueId: appointment.venueId,
          serviceCategoryId: service.serviceId,
          serviceName: service.serviceName,
          price: service.servicePrice,
          durationMinutes: service.serviceDurationMinutes,
          createdAt: DateTime.now(),
        );
      }).toList();

      final newAppointment = await _appointmentService.createAppointment(
        appointment: appointment,
        selectedServices: selectedServices,
      );
      _appointments.add(newAppointment);
      _appointments.sort((a, b) => a.startTime.compareTo(b.startTime));
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Randevu durumunu güncelle
  Future<bool> updateStatus({
    required String appointmentId,
    required String status,
    String? cancellationReason,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _appointmentService.updateStatus(
        appointmentId: appointmentId,
        status: status,
        cancellationReason: cancellationReason,
      );

      // Local state'i güncelle
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: status,
          cancellationReason: cancellationReason,
          cancelledAt: status == 'cancelled' ? DateTime.now() : null,
        );
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Randevu sil
  Future<bool> deleteAppointment(String appointmentId) async {
    _setLoading(true);
    _clearError();

    try {
      await _appointmentService.deleteAppointment(appointmentId);
      _appointments.removeWhere((a) => a.id == appointmentId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Duruma göre filtrele
  List<Appointment> filterByStatus(String status) {
    return _appointments.where((a) => a.status == status).toList();
  }

  /// Saat aralığına göre filtrele
  List<Appointment> filterByTimeRange(String startTime, String endTime) {
    return _appointments.where((a) {
      return a.startTime.compareTo(startTime) >= 0 &&
          a.endTime.compareTo(endTime) <= 0;
    }).toList();
  }

  /// Uzman bazlı filtrele
  List<Appointment> filterBySpecialist(String? specialistId) {
    if (specialistId == null) return _appointments;
    return _appointments.where((a) => a.specialistId == specialistId).toList();
  }

  /// Randevu istatistiklerini getir
  Future<Map<String, dynamic>?> getStats({
    required String venueId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      return await _appointmentService.getStats(
        venueId: venueId,
        fromDate: fromDate,
        toDate: toDate,
      );
    } catch (e) {
      print('Error fetching stats: $e');
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Provider'ı sıfırla
  void reset() {
    _appointments = [];
    _selectedDate = DateTime.now();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
