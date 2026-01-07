import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ExpertsSectionV2 extends StatelessWidget {
  final Venue venue;

  const ExpertsSectionV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    // Mock data if venue.expertTeam is empty
    final experts = venue.expertTeam.isNotEmpty
        ? venue.expertTeam
        : [
            {
              'name': 'Dr. Ayşe',
              'role': 'Dermatolog',
              'image':
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuB9TT_rIHHBzi_pasiuMyN-qI0cBjxJUM0b8fadhatxKTNFFyY1-kUuL10pjuyeyvLc95r7MYILtlsFs7Gn9ZP2be2t-S4E39YyQ3I_7oHBQx8jNAE3yxm5Gzj9yQTtM762-3J8EHEv8fBPM0YXxZvOUuYkm7lrRbro-WJJJe_IZbQRcWhUwzJgJxxIzz7hfbrtc8NfiPCwZbJCRFeVS4r9dJcoFVt6Iq2MJy5Obd2hx7PFGs6YOUbOQq_nqX1nBxnb38nJh45gTw',
            },
            {
              'name': 'Selin D.',
              'role': 'Estetisyen',
              'image':
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAbLZiKbwQ5GFbrgTYLlppu8QhKNXgrX9d-E6g_qcF4_BYqYz0SXH6NMhpkaXtM8YcTTMMf4-_FI2xRieGuh5ZASxBJTMekWX1rRjb4yHCYDRhO-mmP0ZdWWkykhTvkTrO0ERX1cmnXTcy-T_IuMp-A3o7KK7-1AfBkq0b0-ecTbBXRpaNiaQiweN4lfrI9iBmwtzG1MWUfSD1bmh8w-VYzAM3eZPq9AAeKmpvpFJlxMKe-ZO0fgHkn16PeFxNfTxIEo_znqkmDVg',
            },
            {
              'name': 'Merve K.',
              'role': 'Lazer Uzm.',
              'image':
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDM0UdDqO9n7v8mAIkjj32O_zT--GHD_qjf0lOSqFKpuO3EMjZv3jOADMJXJ5aDoZuShiDen8If6sZr38PxVs3zhxpAnIqRUUu76qpOKsMQITgfUIrVsLSIm4znzWqf1pX2jHWplu0kv4-NTWxU2xhoYj8Oj6Y88sWzAJJICPxtKe1ztwCEFXa3C3Nny_QEkl6qwiSavzgE_UaJQs5UPvv6Uw9YjEkN_CgwkZ0cck-6QZtzwXXLjwa42f-QQUjtmx500VKsmEtWIA',
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                child: const Text(
                  'Tümü',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 130,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: experts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final expert = experts[index];
              final bool isHighlighted = index == 0;

              return Column(
                children: [
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
                      backgroundImage: NetworkImage(
                        (expert['image'] as String?) ?? '',
                      ),
                      child: (expert['image'] as String?) == null
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.gray400,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (expert['name'] as String?) ?? 'İsimsiz',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    (expert['role'] as String?) ?? 'Uzman',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
