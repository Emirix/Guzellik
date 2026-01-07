class ServiceCategory {
  final String id;
  final String name;
  final String category;
  final String description;
  final int averageDurationMinutes;
  final String? icon;
  final DateTime createdAt;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.averageDurationMinutes,
    this.icon,
    required this.createdAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      averageDurationMinutes: (json['average_duration_minutes'] as num?)?.toInt() ?? 0,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'average_duration_minutes': averageDurationMinutes,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
