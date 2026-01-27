import 'appointment_service.dart';

/// Model for appointments
/// Supports multiple services per appointment
class Appointment {
  final String id;
  final String venueId;
  final String customerId;
  final String? specialistId;

  final DateTime appointmentDate;
  final String startTime; // "14:30" formatında
  final String endTime;
  final int totalDurationMinutes; // Tüm hizmetlerin toplam süresi

  final String status; // pending, confirmed, completed, cancelled, no_show
  final double? totalPrice; // Tüm hizmetlerin toplam fiyatı

  final String? notes;
  final String? cancellationReason;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? cancelledAt;

  // İlişkili hizmetler (birden fazla)
  final List<AppointmentService> services;

  // JOIN'den gelen ek bilgiler
  final String? customerName;
  final String? customerPhone;
  final String? specialistName;

  Appointment({
    required this.id,
    required this.venueId,
    required this.customerId,
    this.specialistId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.totalDurationMinutes,
    required this.status,
    this.totalPrice,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
    this.cancelledAt,
    this.services = const [],
    this.customerName,
    this.customerPhone,
    this.specialistName,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Services JSONB'den parse et
    List<AppointmentService> servicesList = [];
    final servicesJson = json['services'];
    if (servicesJson != null && servicesJson is List) {
      servicesList = servicesJson
          .where((s) => s is Map<String, dynamic>)
          .map((s) => AppointmentService.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return Appointment(
      id: (json['id'] ?? json['appointment_id'] ?? '').toString(),
      venueId: (json['venue_id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      specialistId: json['specialist_id']?.toString(),
      appointmentDate: json['appointment_date'] != null
          ? DateTime.tryParse(json['appointment_date'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      startTime: _normalizeTime(json['start_time']),
      endTime: _normalizeTime(json['end_time']),
      totalDurationMinutes:
          int.tryParse(json['total_duration_minutes']?.toString() ?? '0') ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0'),
      notes: json['notes']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      services: servicesList,
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      specialistName: json['specialist_name']?.toString(),
    );
  }

  static String _normalizeTime(dynamic time) {
    if (time == null) return '';
    final timeStr = time.toString();
    if (timeStr.isEmpty) return '';
    // HH:MM:SS formatından HH:MM formatına çevir
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }
    return timeStr;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'customer_id': customerId,
      'specialist_id': specialistId,
      'appointment_date': appointmentDate.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'total_duration_minutes': totalDurationMinutes,
      'status': status,
      'total_price': totalPrice,
      'notes': notes,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? venueId,
    String? customerId,
    String? specialistId,
    DateTime? appointmentDate,
    String? startTime,
    String? endTime,
    int? totalDurationMinutes,
    String? status,
    double? totalPrice,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    List<AppointmentService>? services,
    String? customerName,
    String? customerPhone,
    String? specialistName,
  }) {
    return Appointment(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      customerId: customerId ?? this.customerId,
      specialistId: specialistId ?? this.specialistId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      services: services ?? this.services,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      specialistName: specialistName ?? this.specialistName,
    );
  }

  /// Hizmet isimlerini birleştir (UI'da gösterim için)
  String get servicesDisplay {
    if (services.isEmpty) return 'Hizmet belirtilmemiş';
    return services.map((s) => s.serviceName).join(', ');
  }

  /// Durum rengini al
  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'confirmed':
        return '#4CAF50'; // Green
      case 'completed':
        return '#2196F3'; // Blue
      case 'cancelled':
        return '#F44336'; // Red
      case 'no_show':
        return '#9E9E9E'; // Gray
      default:
        return '#757575'; // Default gray
    }
  }

  /// Durum metni
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'confirmed':
        return 'Onaylandı';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      case 'no_show':
        return 'Gelmedi';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'Appointment(id: $id, customer: $customerName, date: $appointmentDate, time: $startTime-$endTime, status: $status, services: ${services.length})';
  }
}
