class ServiceCategory {
  final String id;
  final String name;
  final String subCategory;
  final String description;
  final int averageDurationMinutes;
  final String? icon;
  final String? imageUrl;
  final DateTime createdAt;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.subCategory,
    required this.description,
    required this.averageDurationMinutes,
    this.icon,
    this.imageUrl,
    required this.createdAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      subCategory:
          json['sub_category'] as String? ?? json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      averageDurationMinutes:
          (json['average_duration_minutes'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sub_category': subCategory,
      'description': description,
      'average_duration_minutes': averageDurationMinutes,
      'icon': icon,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
