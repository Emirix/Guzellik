import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MapPreviewV2 extends StatelessWidget {
  final Venue venue;

  const MapPreviewV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBRdk742xm0vmkVHox80Jr0BH44aCwpN0b95Z4ji-QKbQq38QOhNcTG0tNd66TibSA-QtajQSV0_G8WaGcgeffUBCFVEuiKSK6IL_vAlxhEVYMBkL7TALEgvuBcg_fvidM0iDglX4GhZsY4yXV7bE2lt3pGsJdPvHpl1zpTsWU1Bqo6AK7IkaRDYt_zZ_ABKyF-jXnc20iRoaLNAI5d45y1DWvrn5I0PwEpUEjs7K7a6p5rbD17BQOZw8kZIb5TT8txitJqoAocLA',
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.8,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.near_me, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Haritada Gör',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          venue.address,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray500,
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
