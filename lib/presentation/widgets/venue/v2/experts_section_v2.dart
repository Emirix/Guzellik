import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/specialist.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../components/specialist_detail_bottom_sheet.dart';

class ExpertsSectionV2 extends StatelessWidget {
  final Venue venue;
  final List<Specialist> specialists;

  const ExpertsSectionV2({
    super.key,
    required this.venue,
    required this.specialists,
  });

  @override
  Widget build(BuildContext context) {
    if (specialists.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and "See All" button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uzman Kadromuz',
                style: AppTextStyles.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal scrolling expert list
        SizedBox(
          height: 145,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: specialists.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final expert = specialists[index];
              final bool isHighlighted = expert.isFeatured;

              return GestureDetector(
                onTap: () => _showSpecialistDetails(context, expert),
                child: _buildExpertItem(
                  name: expert.name,
                  role: expert.profession,
                  imageUrl: expert.photoUrl,
                  gender: expert.gender,
                  isHighlighted: isHighlighted,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpertItem({
    required String name,
    required String role,
    String? imageUrl,
    String? gender,
    bool isHighlighted = false,
  }) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          // Avatar with premium border and glow for featured experts
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isHighlighted
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
              gradient: isHighlighted
                  ? const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.gold,
                        AppColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AvatarUtils.getAvatarBackgroundColor(gender),
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: AvatarUtils.getAvatarIconColor(gender),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Role
          Text(
            role,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showSpecialistDetails(BuildContext context, Specialist specialist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpecialistDetailBottomSheet(specialist: specialist),
    );
  }
}
