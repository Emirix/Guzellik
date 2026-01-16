import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../../../../data/models/specialist.dart';

class SpecialistDetailBottomSheet extends StatelessWidget {
  final Specialist specialist;

  const SpecialistDetailBottomSheet({super.key, required this.specialist});

  @override
  Widget build(BuildContext context) {
    final bool isFemale = specialist.gender?.toLowerCase() == 'female';
    final Color accentColor = isFemale ? Colors.pink : Colors.blue;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),

          // Profile Image
          _buildProfileImage(accentColor),
          const SizedBox(height: 20),

          // Name and Profession
          Text(
            specialist.name,
            style: AppTextStyles.heading1.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              specialist.profession,
              style: AppTextStyles.subtitle2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bio Section
          if (specialist.bio != null && specialist.bio!.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hakkında',
                style: AppTextStyles.heading4.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              specialist.bio!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gray100,
                foregroundColor: AppColors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Kapat',
                style: AppTextStyles.buttonLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(Color accentColor) {
    final bool isHighlighted = specialist.isFeatured;

    return Container(
      width: 120,
      height: 120,
      padding: EdgeInsets.all(isHighlighted ? 4 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.shadowLight,
            blurRadius: isHighlighted ? 24 : 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: isHighlighted
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.gold, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Container(
        padding: EdgeInsets.all(isHighlighted ? 4 : 4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: specialist.photoUrl != null && specialist.photoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: specialist.photoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppColors.gray200,
                    highlightColor: AppColors.gray100,
                    child: Container(color: AppColors.gray200),
                  ),
                  errorWidget: (context, url, error) => _buildDefaultAvatar(),
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AvatarUtils.getAvatarBackgroundColor(specialist.gender),
      child: Icon(
        Icons.person,
        size: 60,
        color: AvatarUtils.getAvatarIconColor(specialist.gender),
      ),
    );
  }
}
