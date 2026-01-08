import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Arama türleri
enum SearchType { venue, service, location }

/// Son arama modeli
/// Kullanıcının arama geçmişini saklar
class RecentSearch {
  final String id;
  final String query;
  final String? location;
  final DateTime timestamp;
  final SearchType type;
  final IconData icon;

  RecentSearch({
    String? id,
    required this.query,
    this.location,
    DateTime? timestamp,
    this.type = SearchType.service,
    this.icon = Icons.history,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  /// JSON'dan model oluştur
  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      id: json['id'] as String,
      query: json['query'] as String,
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: SearchType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SearchType.service,
      ),
      icon: Icons.history,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }

  /// Kopyalama metodu
  RecentSearch copyWith({
    String? id,
    String? query,
    String? location,
    DateTime? timestamp,
    SearchType? type,
    IconData? icon,
  }) {
    return RecentSearch(
      id: id ?? this.id,
      query: query ?? this.query,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecentSearch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
