import 'package:flutter/material.dart';

class IconUtils {
  static IconData getCategoryIcon(String? iconName) {
    if (iconName == null) return Icons.category;

    switch (iconName.toLowerCase()) {
      case 'content_cut':
        return Icons.content_cut;
      case 'spa':
        return Icons.spa;
      case 'remove_red_eye':
        return Icons.remove_red_eye;
      case 'brush':
        return Icons.brush;
      case 'clean_hands':
        return Icons.clean_hands;
      case 'medical_services':
        return Icons.medical_services;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'hot_tub':
        return Icons.hot_tub;
      case 'face':
        return Icons.face;
      case 'bolt':
        return Icons.bolt;
      case 'accessibility':
        return Icons.accessibility;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'location_on':
        return Icons.location_on;
      case 'sell':
      case 'sell_outlined':
        return Icons.sell_outlined;
      default:
        return Icons.category;
    }
  }
}
