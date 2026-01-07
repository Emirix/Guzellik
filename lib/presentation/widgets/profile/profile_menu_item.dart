import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Profile menu item widget
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isPrimary = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isPrimary ? AppColors.primary : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B0E11),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Chevron
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
              ],
            ),
          ),
        ),

        // Divider
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 72),
            child: Divider(height: 1, thickness: 1, color: Colors.grey[100]),
          ),
      ],
    );
  }
}
