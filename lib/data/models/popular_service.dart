import 'package:flutter/material.dart';

/// Popüler hizmet modeli
/// En çok aranan ve kullanılan hizmetleri temsil eder
class PopularService {
  final String id;
  final String name;
  final IconData icon;
  final int searchCount;
  final int venueCount;

  PopularService({
    required this.id,
    required this.name,
    required this.icon,
    this.searchCount = 0,
    this.venueCount = 0,
  });

  /// JSON'dan model oluştur
  factory PopularService.fromJson(Map<String, dynamic> json) {
    return PopularService(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: _getIconFromString(json['icon'] as String?),
      searchCount: json['search_count'] as int? ?? 0,
      venueCount: json['venue_count'] as int? ?? 0,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': _getIconString(icon),
      'search_count': searchCount,
      'venue_count': venueCount,
    };
  }

  /// Icon string'den IconData'ya dönüştür
  static IconData _getIconFromString(String? iconName) {
    if (iconName == null) return Icons.spa;

    switch (iconName.toLowerCase()) {
      case 'face':
        return Icons.face;
      case 'spa':
        return Icons.spa;
      case 'cut':
      case 'scissors':
        return Icons.cut;
      case 'brush':
        return Icons.brush;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      default:
        return Icons.spa;
    }
  }

  /// IconData'dan string'e dönüştür
  static String _getIconString(IconData icon) {
    if (icon == Icons.face) return 'face';
    if (icon == Icons.spa) return 'spa';
    if (icon == Icons.cut) return 'cut';
    if (icon == Icons.brush) return 'brush';
    if (icon == Icons.auto_awesome) return 'auto_awesome';
    if (icon == Icons.favorite) return 'favorite';
    if (icon == Icons.star) return 'star';
    return 'spa';
  }

  /// Kopyalama metodu
  PopularService copyWith({
    String? id,
    String? name,
    IconData? icon,
    int? searchCount,
    int? venueCount,
  }) {
    return PopularService(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      searchCount: searchCount ?? this.searchCount,
      venueCount: venueCount ?? this.venueCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PopularService && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
