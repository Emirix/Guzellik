import 'package:flutter/material.dart';

class IconUtils {
  static IconData getCategoryIcon(String? iconName) {
    if (iconName == null) return Icons.category;

    final name = iconName.toLowerCase().trim();

    switch (name) {
      case 'content_cut':
      case 'equipment':
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
      case 'home_work':
      case 'interior':
        return Icons.home_work_outlined;
      case 'storefront':
      case 'exterior':
        return Icons.storefront_outlined;
      case 'people':
      case 'team':
        return Icons.people_outline;
      case 'auto_awesome':
      case 'service_result':
        return Icons.auto_awesome_outlined;
      case 'shopping_bag':
      case 'products':
        return Icons.shopping_bag_outlined;
      case 'verified_user':
      case 'certificates':
        return Icons.verified_user_outlined;
      case 'play_circle':
      case 'service_in_progress':
        return Icons.play_circle_outline;
      case 'not_interested':
        return Icons.not_interested;
      case 'tag':
        return Icons.tag;
      default:
        return Icons.category;
    }
  }
}
