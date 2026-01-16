import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/specialist.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
    // Priority: 1. specialists (from Provider), 2. expertTeam (from Venue model), 3. Mock data
    final hasRealSpecialists = specialists.isNotEmpty;
    final hasExpertTeam = venue.expertTeam.isNotEmpty;

    final List<Specialist> experts = hasRealSpecialists
        ? specialists
        : (hasExpertTeam
              ? venue.expertTeam.map((e) {
                  if (e is Specialist) return e;
                  final data = e is Map<String, dynamic> ? e : {};
                  return Specialist(
                    id: data['id']?.toString() ?? '',
                    venueId: venue.id,
                    name: data['name'] ?? 'İsimsiz',
                    profession: data['role'] ?? data['specialty'] ?? 'Uzman',
                    photoUrl: data['image'] ?? data['photo_url'],
                    bio: data['bio'],
                    gender: data['gender'],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                }).toList()
              : [
                  Specialist(
                    id: '1',
                    venueId: venue.id,
                    name: 'Dr. Ayşe',
                    profession: 'Dermatolog',
                    photoUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuB9TT_rIHHBzi_pasiuMyN-qI0cBjxJUM0b8fadhatxKTNFFyY1-kUuL10pjuyeyvLc95r7MYILtlsFs7Gn9ZP2be2t-S4E39YyQ3I_7oHBQx8jNAE3yxm5Gzj9yQTtM762-3J8EHEv8fBPM0YXxZvOUuYkm7lrRbro-WJJJe_IZbQRcWhUwzJgJxxIzz7hfbrtc8NfiPCwZbJCRFeVS4r9dJcoFVt6Iq2MJy5Obd2hx7PFGs6YOUbOQq_nqX1nBxnb38nJh45gTw',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  Specialist(
                    id: '2',
                    venueId: venue.id,
                    name: 'Selin D.',
                    profession: 'Estetisyen',
                    photoUrl:
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAbLZiKbwQ5GFbrgTYLlppu8QhKNXgrX9d-E6g_qcF4_BYqYz0SXH6NMhpkaXtM8YcTTMMf4-_FI2xRieGuh5ZASxBJTMekWX1rRjb4yHCYDRhO-mmP0ZdWWkykhTvkTrO0ERX1cmnXTcy-T_IuMp-A3o7KK7-1AfBkq0b0-ecTbBXRpaNiaQiweN4lfrI9iBmwtzG1MWUfSD1bmh8w-VYzAM3eZPq9AAeKmpvpFJlxMKe-ZO0fgHkn16PeFxNfTxIEo_znqkmDVg',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                ]);

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
            itemCount: experts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final expert = experts[index];
              final bool isHighlighted = index == 0;

              return GestureDetector(
                onTap: () => _showSpecialistDetails(context, expert),
                child: _buildExpertItem(
                  name: expert.name,
                  role: expert.profession,
                  imageUrl: expert.photoUrl,
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
    bool isHighlighted = false,
  }) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          // Avatar with border (highlighted for first item)
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isHighlighted
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.nude,
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? Icon(Icons.person, size: 32, color: AppColors.gray400)
                  : null,
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
