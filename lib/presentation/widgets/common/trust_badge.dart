import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Trust badge types for venues
enum TrustBadgeType {
  verified,   // Onaylı Mekan
  popular,    // En Çok Tercih Edilen
  hygiene,    // Hijyen Onaylı
}

/// Trust badge widget for displaying venue verification badges
class TrustBadge extends StatelessWidget {
  final TrustBadgeType type;
  final bool showLabel;
  final double size;
  
  const TrustBadge({
    super.key,
    required this.type,
    this.showLabel = true,
    this.size = 24,
  });
  
  @override
  Widget build(BuildContext context) {
    final badgeData = _getBadgeData();
    
    if (!showLabel) {
      return Icon(
        badgeData.icon,
        color: badgeData.color,
        size: size,
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeData.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeData.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeData.icon,
            color: badgeData.color,
            size: size * 0.8,
          ),
          const SizedBox(width: 4),
          Text(
            badgeData.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: badgeData.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  _BadgeData _getBadgeData() {
    switch (type) {
      case TrustBadgeType.verified:
        return _BadgeData(
          icon: Icons.verified,
          label: 'Onaylı Mekan',
          color: AppColors.verifiedBadge,
        );
      case TrustBadgeType.popular:
        return _BadgeData(
          icon: Icons.star,
          label: 'En Çok Tercih Edilen',
          color: AppColors.popularBadge,
        );
      case TrustBadgeType.hygiene:
        return _BadgeData(
          icon: Icons.health_and_safety,
          label: 'Hijyen Onaylı',
          color: AppColors.hygieneBadge,
        );
    }
  }
}

class _BadgeData {
  final IconData icon;
  final String label;
  final Color color;
  
  _BadgeData({
    required this.icon,
    required this.label,
    required this.color,
  });
}
