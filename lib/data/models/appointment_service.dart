/// Model for appointment-service junction table
/// Represents a single service within an appointment
class AppointmentService {
  final String id;
  final String appointmentId;
  final String serviceId;
  final int sortOrder;

  // Snapshot values (service details at time of booking)
  final String serviceName;
  final double? servicePrice;
  final int? serviceDurationMinutes;

  final DateTime? createdAt;

  AppointmentService({
    required this.id,
    required this.appointmentId,
    required this.serviceId,
    required this.sortOrder,
    required this.serviceName,
    this.servicePrice,
    this.serviceDurationMinutes,
    this.createdAt,
  });

  factory AppointmentService.fromJson(Map<String, dynamic> json) {
    return AppointmentService(
      id: (json['id'] ?? '').toString(),
      appointmentId: (json['appointment_id'] ?? '').toString(),
      serviceId: (json['service_id'] ?? '').toString(),
      sortOrder: int.tryParse(json['sort_order']?.toString() ?? '0') ?? 0,
      serviceName: (json['service_name'] ?? 'Hizmet').toString(),
      servicePrice: double.tryParse(json['service_price']?.toString() ?? '0'),
      serviceDurationMinutes: int.tryParse(
        json['service_duration_minutes']?.toString() ?? '0',
      ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'service_id': serviceId,
      'sort_order': sortOrder,
      'service_name': serviceName,
      'service_price': servicePrice,
      'service_duration_minutes': serviceDurationMinutes,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  AppointmentService copyWith({
    String? id,
    String? appointmentId,
    String? serviceId,
    int? sortOrder,
    String? serviceName,
    double? servicePrice,
    int? serviceDurationMinutes,
    DateTime? createdAt,
  }) {
    return AppointmentService(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      serviceId: serviceId ?? this.serviceId,
      sortOrder: sortOrder ?? this.sortOrder,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      serviceDurationMinutes:
          serviceDurationMinutes ?? this.serviceDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AppointmentService(id: $id, serviceName: $serviceName, price: $servicePrice, duration: $serviceDurationMinutes)';
  }
}
