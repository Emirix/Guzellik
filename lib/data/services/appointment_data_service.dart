import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment.dart';
import '../models/appointment_service.dart' as model;
import '../models/venue_service.dart';
import 'supabase_service.dart';

/// Service for managing appointments with multi-service support
class AppointmentDataService {
  final SupabaseService _supabaseService = SupabaseService.instance;
  static const String _tableName = 'appointments';
  static const String _servicesTableName = 'appointment_services';

  String? get _userId => _supabaseService.currentUser?.id;

  /// Belirli bir tarih için randevuları getir (detaylı, JOIN'li)
  Future<List<Appointment>> getAppointmentsByDate({
    required String venueId,
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await _supabaseService
          .from(_tableName)
          .select('''
            *,
            customers!inner(name, phone),
            specialists(name),
            appointment_services(
              id,
              appointment_id,
              service_id,
              sort_order,
              service_name,
              service_price,
              service_duration_minutes,
              created_at
            )
          ''')
          .eq('venue_id', venueId)
          .eq('appointment_date', dateStr)
          .order('start_time', ascending: true);

      return (response as List).map((json) {
        return Appointment.fromJson({
          ...json,
          'customer_name': json['customers']?['name'],
          'customer_phone': json['customers']?['phone'],
          'specialist_name': json['specialists']?['name'],
          'services': json['appointment_services'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching appointments by date: $e');
      rethrow;
    }
  }

  /// Tarih aralığı için randevuları getir
  Future<List<Appointment>> getAppointmentsByDateRange({
    required String venueId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseService
          .from(_tableName)
          .select('''
            *,
            customers!inner(name, phone),
            specialists(name),
            appointment_services(
              id,
              service_id,
              sort_order,
              service_name,
              service_price,
              service_duration_minutes,
              created_at
            )
          ''')
          .eq('venue_id', venueId)
          .gte('appointment_date', startDate.toIso8601String().split('T')[0])
          .lte('appointment_date', endDate.toIso8601String().split('T')[0])
          .order('appointment_date', ascending: true)
          .order('start_time', ascending: true);

      return (response as List).map((json) {
        // Flatten nested relations
        return Appointment.fromJson({
          ...json,
          'customer_name': json['customers']?['name'],
          'customer_phone': json['customers']?['phone'],
          'specialist_name': json['specialists']?['name'],
          'services': json['appointment_services'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching appointments by range: $e');
      rethrow;
    }
  }

  /// Randevu çakışması kontrolü (uzman bazlı)
  Future<bool> checkConflict({
    required String venueId,
    String? specialistId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeAppointmentId,
  }) async {
    try {
      final response = await _supabaseService.rpc(
        'check_appointment_conflict',
        params: {
          'p_venue_id': venueId,
          'p_specialist_id': specialistId,
          'p_date': date.toIso8601String().split('T')[0],
          'p_start_time':
              startTime.contains(':') && startTime.split(':').length == 2
              ? '$startTime:00'
              : startTime,
          'p_end_time': endTime.contains(':') && endTime.split(':').length == 2
              ? '$endTime:00'
              : endTime,
          'p_exclude_appointment_id': excludeAppointmentId,
        },
      );

      return response as bool;
    } catch (e) {
      print('Error checking appointment conflict: $e');
      rethrow;
    }
  }

  /// Yeni randevu oluştur (birden fazla hizmet ile)
  Future<Appointment> createAppointment({
    required Appointment appointment,
    required List<VenueService> selectedServices,
  }) async {
    try {
      // Önce çakışma kontrolü (uzman bazlı)
      final hasConflict = await checkConflict(
        venueId: appointment.venueId,
        specialistId: appointment.specialistId,
        date: appointment.appointmentDate,
        startTime: appointment.startTime,
        endTime: appointment.endTime,
      );

      if (hasConflict) {
        final errorMsg = appointment.specialistId != null
            ? 'Bu uzmanın bu saatinde zaten bir randevu var!'
            : 'Bu saatte zaten bir randevu var!';
        throw errorMsg;
      }

      // Toplam süre ve fiyat hesapla
      int totalDuration = 0;
      double totalPrice = 0.0;

      for (var service in selectedServices) {
        totalDuration += service.effectiveDuration;
        totalPrice += service.effectivePrice;
      }

      // Ensure duration is at least 15 minutes to satisfy end_time > start_time
      if (totalDuration <= 0) {
        totalDuration = 30;
      }

      // Calculate end_time based on start_time and totalDuration to ensure consistency
      // This prevents the valid_time_range constraint violation
      final startParts = appointment.startTime.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);

      final totalStartMinutes = startHour * 60 + startMinute;
      final totalEndMinutes = totalStartMinutes + totalDuration;

      final endHour = (totalEndMinutes ~/ 60) % 24;
      final endMinute = totalEndMinutes % 60;

      final formattedStartTime =
          '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
      final formattedEndTime =
          '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}:00';

      // If end time wrapped around to next day, PostgreSQL TIME type comparison
      // '00:30:00' > '23:30:00' will be false.
      // For now, we cap it at 23:59:59 if it wraps, or just let it fail if it's an edge case.
      // Most beauty salons don't work past midnight.
      String finalEndTime = formattedEndTime;
      if (totalEndMinutes >= 1440) {
        finalEndTime = '23:59:59';
      }

      // Randevu oluştur
      final appointmentData = appointment.toJson();
      appointmentData.remove('id');
      appointmentData.remove('created_at');
      appointmentData.remove('updated_at');
      appointmentData['total_duration_minutes'] = totalDuration;
      appointmentData['total_price'] = totalPrice;
      appointmentData['start_time'] = formattedStartTime;
      appointmentData['end_time'] = finalEndTime;

      final appointmentResponse = await _supabaseService
          .from(_tableName)
          .insert(appointmentData)
          .select()
          .single();

      final newAppointmentId = appointmentResponse['id'] as String;

      // Hizmetleri ekle
      final servicesToInsert = selectedServices.asMap().entries.map((entry) {
        final index = entry.key;
        final service = entry.value;

        return {
          'appointment_id': newAppointmentId,
          'service_id': service.id,
          'sort_order': index,
          'service_name': service.serviceName ?? service.displayName,
          'service_price': service.price,
          'service_duration_minutes': service.durationMinutes,
        };
      }).toList();

      await _supabaseService.from(_servicesTableName).insert(servicesToInsert);

      // Tam randevu verisini getir
      return await getAppointmentById(newAppointmentId);
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  /// Müşteri ID'sine göre randevuları getir
  Future<List<Appointment>> getAppointmentsByCustomerId({
    required String customerId,
  }) async {
    try {
      final response = await _supabaseService
          .from(_tableName)
          .select('''
            *,
            customers!inner(name, phone),
            specialists(name),
            appointment_services(
              id,
              service_id,
              sort_order,
              service_name,
              service_price,
              service_duration_minutes,
              created_at
            )
          ''')
          .eq('customer_id', customerId)
          .order('appointment_date', ascending: false)
          .order('start_time', ascending: false);

      return (response as List).map((json) {
        return Appointment.fromJson({
          ...json,
          'customer_name': json['customers']?['name'],
          'customer_phone': json['customers']?['phone'],
          'specialist_name': json['specialists']?['name'],
          'services': json['appointment_services'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching customer appointments: $e');
      rethrow;
    }
  }

  /// Randevu ID'sine göre getir
  Future<Appointment> getAppointmentById(String appointmentId) async {
    try {
      final response = await _supabaseService
          .from(_tableName)
          .select('''
            *,
            customers!inner(name, phone),
            specialists(name),
            appointment_services(
              id,
              service_id,
              sort_order,
              service_name,
              service_price,
              service_duration_minutes,
              created_at
            )
          ''')
          .eq('id', appointmentId)
          .single();

      return Appointment.fromJson({
        ...response,
        'customer_name': response['customers']?['name'],
        'customer_phone': response['customers']?['phone'],
        'specialist_name': response['specialists']?['name'],
        'services': response['appointment_services'],
      });
    } catch (e) {
      print('Error fetching appointment by ID: $e');
      rethrow;
    }
  }

  /// Randevu güncelle
  Future<Appointment> updateAppointment(Appointment appointment) async {
    try {
      final data = appointment.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      await _supabaseService
          .from(_tableName)
          .update(data)
          .eq('id', appointment.id);

      return await getAppointmentById(appointment.id);
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  /// Randevu durumunu güncelle
  Future<void> updateStatus({
    required String appointmentId,
    required String status,
    String? cancellationReason,
  }) async {
    try {
      final data = {
        'status': status,
        if (cancellationReason != null)
          'cancellation_reason': cancellationReason,
        if (status == 'cancelled')
          'cancelled_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService
          .from(_tableName)
          .update(data)
          .eq('id', appointmentId);
    } catch (e) {
      print('Error updating appointment status: $e');
      rethrow;
    }
  }

  /// Randevu sil
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _supabaseService.from(_tableName).delete().eq('id', appointmentId);
    } catch (e) {
      print('Error deleting appointment: $e');
      rethrow;
    }
  }

  /// Randevu istatistikleri
  Future<Map<String, dynamic>> getStats({
    required String venueId,
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await _supabaseService.rpc(
        'get_appointment_stats',
        params: {
          'p_venue_id': venueId,
          'p_date_from': fromDate.toIso8601String().split('T')[0],
          'p_date_to': toDate.toIso8601String().split('T')[0],
        },
      );

      return response[0] as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching appointment stats: $e');
      rethrow;
    }
  }

  /// Uzman müsaitlik durumu
  Future<List<Map<String, dynamic>>> getSpecialistAvailability({
    required String specialistId,
    required DateTime date,
    int startHour = 9,
    int endHour = 18,
  }) async {
    try {
      final response = await _supabaseService.rpc(
        'get_specialist_availability',
        params: {
          'p_specialist_id': specialistId,
          'p_date': date.toIso8601String().split('T')[0],
          'p_start_hour': startHour,
          'p_end_hour': endHour,
        },
      );

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching specialist availability: $e');
      rethrow;
    }
  }
}
