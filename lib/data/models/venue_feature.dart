class VenueFeature {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String category;
  final String? description;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;

  VenueFeature({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.category,
    this.description,
    this.isActive = true,
    this.displayOrder = 0,
    required this.createdAt,
  });

  factory VenueFeature.fromJson(Map<String, dynamic> json) {
    return VenueFeature(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'category': category,
      'description': description,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VenueFeature copyWith({
    String? id,
    String? name,
    String? slug,
    String? icon,
    String? category,
    String? description,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return VenueFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to get category display name
  String getCategoryDisplayName() {
    switch (category) {
      case 'hygiene':
        return 'Hijyen & Güvenlik';
      case 'service':
        return 'Hizmet';
      case 'comfort':
        return 'Konfor';
      case 'payment':
        return 'Ödeme';
      case 'transport':
        return 'Ulaşım';
      case 'communication':
        return 'İletişim';
      default:
        return category;
    }
  }
}
