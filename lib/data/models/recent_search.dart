import 'package:flutter/material.dart';

/// Son arama modeli
/// Kullanıcının arama geçmişini saklar
class RecentSearch {
  final String id;
  final String query;
  final DateTime timestamp;
  final IconData icon;

  RecentSearch({
    required this.id,
    required this.query,
    required this.timestamp,
    this.icon = Icons.history,
  });

  /// JSON'dan model oluştur
  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      id: json['id'] as String,
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      icon: Icons.history,
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {'id': id, 'query': query, 'timestamp': timestamp.toIso8601String()};
  }

  /// Kopyalama metodu
  RecentSearch copyWith({
    String? id,
    String? query,
    DateTime? timestamp,
    IconData? icon,
  }) {
    return RecentSearch(
      id: id ?? this.id,
      query: query ?? this.query,
      timestamp: timestamp ?? this.timestamp,
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
