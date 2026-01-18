import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Popüler hizmet modeli
/// En çok sunulan ve talep gören hizmetleri temsil eder
class PopularService extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String? imageUrl;
  final int venueCount;

  const PopularService({
    required this.id,
    required this.name,
    this.icon,
    this.imageUrl,
    required this.venueCount,
  });

  /// JSON'dan model oluştur
  factory PopularService.fromJson(Map<String, dynamic> json) {
    return PopularService(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      venueCount: (json['venue_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'image_url': imageUrl,
      'venue_count': venueCount,
    };
  }

  /// Kopyalama metodu
  PopularService copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageUrl,
    int? venueCount,
  }) {
    return PopularService(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      venueCount: venueCount ?? this.venueCount,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, imageUrl, venueCount];
}
