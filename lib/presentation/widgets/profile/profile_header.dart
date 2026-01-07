import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Profile header widget with avatar, name, email, and membership badge
class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final String membershipLevel;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.membershipLevel = 'Gold Üye',
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        children: [
          // Avatar with gradient border
          GestureDetector(
            onTap: onEditPressed,
            child: Stack(
              children: [
                // Gradient ring
                Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFC5A059), // Gold
                        AppColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDFBFB),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl!)
                              : null,
                          child: avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
                // Edit badge
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFDFBFB),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B0E11),
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 12),

          // Membership Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E7), Color(0xFFFFF0D4)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFC5A059).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC5A059).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars, size: 16, color: Color(0xFFC5A059)),
                const SizedBox(width: 6),
                Text(
                  membershipLevel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B6914),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
