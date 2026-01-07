import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class VenueIdentityV2 extends StatelessWidget {
  final Venue venue;

  const VenueIdentityV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Logo Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kadıköy, İstanbul', // TODO: Get from address or new field
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '•',
                          style: TextStyle(color: AppColors.gray400),
                        ),
                      ),
                      Text(
                        'Cilt Bakımı & Lazer', // TODO: Get from categories
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Logo Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: venue.imageUrl != null
                    ? Image.network(venue.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.business, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Rating and Follow Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Rating Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.nude.withOpacity(0.5)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '4.8',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    children: List.generate(5, (index) {
                      if (index < 4) {
                        return const Icon(
                          Icons.star,
                          color: Color(0xFFFFB800),
                          size: 14,
                        );
                      } else {
                        return const Icon(
                          Icons.star_half,
                          color: Color(0xFFFFB800),
                          size: 14,
                        );
                      }
                    }),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(124)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Follow Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Takip Et',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
