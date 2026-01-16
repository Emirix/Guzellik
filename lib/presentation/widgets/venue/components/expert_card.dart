import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../../../../data/models/expert.dart';

/// Premium expert card component
/// Displays expert information with photo, name, title, and rating
class ExpertCard extends StatelessWidget {
  final Expert expert;
  final VoidCallback? onTap;

  const ExpertCard({super.key, required this.expert, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.nude.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Photo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: expert.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: expert.photoUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AvatarUtils.getAvatarBackgroundColor(
                            expert.gender,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AvatarUtils.getAvatarBackgroundColor(
                            expert.gender,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.gray400,
                          ),
                        ),
                      )
                    : Container(
                        color: AvatarUtils.getAvatarBackgroundColor(
                          expert.gender,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.gray400,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Expert Name
            Text(
              expert.name,
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Title/Specialty
            Text(
              expert.title,
              style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
