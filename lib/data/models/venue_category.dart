class VenueCategory {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? imageUrl;
  final String? logoUrl;
  final String? description;
  final bool isActive;

  final int? order;

  VenueCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.imageUrl,
    this.logoUrl,
    this.description,
    this.isActive = true,
    this.order,
  });

  factory VenueCategory.fromJson(Map<String, dynamic> json) {
    return VenueCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'image_url': imageUrl,
      'logo_url': logoUrl,
      'description': description,
      'is_active': isActive,
      'order': order,
    };
  }
}
