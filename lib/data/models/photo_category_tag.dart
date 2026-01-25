class PhotoCategoryTag {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;

  PhotoCategoryTag({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
  });

  factory PhotoCategoryTag.fromJson(Map<String, dynamic> json) {
    return PhotoCategoryTag(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'description': description,
    };
  }
}
