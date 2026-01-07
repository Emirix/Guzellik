class Service {
  final String id;
  final String venueId;
  final String name;
  final String category;
  final double price;
  final int durationMinutes;
  final String? description;
  final String? beforePhotoUrl;
  final String? afterPhotoUrl;
  final String? expertName;

  Service({
    required this.id,
    required this.venueId,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMinutes,
    this.description,
    this.beforePhotoUrl,
    this.afterPhotoUrl,
    this.expertName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String? ?? '',
      venueId: json['venue_id'] as String? ?? '',
      name: json['name'] as String? ?? 'İsimsiz Hizmet',
      category: json['category'] as String? ?? 'Genel',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      beforePhotoUrl: json['before_photo_url'] as String?,
      afterPhotoUrl: json['after_photo_url'] as String?,
      expertName: json['expert_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'name': name,
      'category': category,
      'price': price,
      'duration_minutes': durationMinutes,
      'description': description,
      'before_photo_url': beforePhotoUrl,
      'after_photo_url': afterPhotoUrl,
      'expert_name': expertName,
    };
  }
}
