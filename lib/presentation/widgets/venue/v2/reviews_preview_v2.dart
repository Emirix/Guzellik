import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReviewsPreviewV2 extends StatelessWidget {
  final Venue venue;

  const ReviewsPreviewV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Değerlendirmeler',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Tümünü Gör (124)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.nude),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuCeucl3_oBgTbj0lGySuJQLcajEfFlGpdqTJTQlDoQa9OwgzQufwRRWiF6M0FWMJdAu0wHNok21uZKM3Qsdb2y339fN4wYMME9AikC5PFkDgmbeGq11sDKtWNLjP9Ac0IdI4Ru0mRFltbxj05HN2LjxC3nscVUy4TaxkT1WTI6xGMYa-RIKPgCs5SpQoGdiQD6ir1ud3j4ncVu1WhIAY7zkl-lE76XzCXHCd5CDhL-XfKcNHSV1m3qAA4kLmtQ_RS0ncej98RSR3g',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Elif K.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    '2 gün önce',
                    style: TextStyle(color: AppColors.gray400, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    color: Color(0xFFFFB800),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Dudak dolgusu işlemi için geldim, sonuçtan inanılmaz memnunum. Dr. Ayşe Hanım çok ilgiliydi, kesinlikle tavsiye ediyorum!',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray600,
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
