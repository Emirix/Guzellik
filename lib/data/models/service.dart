class Service {
  final String id;
  final String venueServiceId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;
  final String? expertName;
  final DateTime createdAt;

  // Populated from function/view joins
  final String? venueId;
  final String? category;
  final double? price;
  final int? durationMinutes;

  Service({
    required this.id,
    required this.venueServiceId,
    required this.name,
    this.description,
    this.imageUrl,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
    this.expertName,
    required this.createdAt,
    this.venueId,
    this.category,
    this.price,
    this.durationMinutes,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String? ?? '',
      venueServiceId: json['venue_service_id'] as String? ?? '',
      name: json['name'] as String? ?? 'İsimsiz Hizmet',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      beforePhotoUrl: json['before_photo_url'] as String?,
      afterPhotoUrl: json['after_photo_url'] as String?,
      expertName: json['expert_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      venueId: json['venue_id'] as String?,
      category: json['category'] as String? ?? 'Genel',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_service_id': venueServiceId,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'before_photo_url': beforePhotoUrl,
      'after_photo_url': afterPhotoUrl,
      'expert_name': expertName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
