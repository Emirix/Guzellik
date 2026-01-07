import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WorkingHoursCardV2 extends StatelessWidget {
  final Venue venue;

  const WorkingHoursCardV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Çalışma Saatleri',
              style: AppTextStyles.heading4.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Şu an Açık',
                    style: TextStyle(
                      color: Color(0xFF15803D),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
            children: [
              _buildHourRow('Hafta içi', '09:00 - 19:00', isLast: false),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Divider(
                  color: Color(0xFFF3F4F6),
                  thickness: 1,
                  height: 1,
                ),
              ),
              _buildHourRow('Cumartesi', '09:00 - 17:00', isLast: false),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Divider(
                  color: Color(0xFFF3F4F6),
                  thickness: 1,
                  height: 1,
                ),
              ),
              _buildHourRow('Pazar', 'Kapalı', isLast: true, isClosed: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourRow(
    String day,
    String hours, {
    required bool isLast,
    bool isClosed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              color: isClosed ? AppColors.primary : AppColors.gray900,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
