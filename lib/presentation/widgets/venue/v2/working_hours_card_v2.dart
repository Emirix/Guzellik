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
        // Header with title and open status badge
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
            // Open Status Badge with pulse animation
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated pulse dot
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(value),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF22C55E).withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Şu an Açık',
                    style: TextStyle(
                      color: const Color(0xFF15803D),
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
        // Hours Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.nude),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHourRow('Hafta içi', '09:00 - 19:00'),
              _buildDashedDivider(),
              _buildHourRow('Cumartesi', '09:00 - 17:00'),
              _buildDashedDivider(),
              _buildHourRow('Pazar', 'Kapalı', isClosed: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourRow(String day, String hours, {bool isClosed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: TextStyle(color: AppColors.gray500, fontSize: 14)),
          Text(
            hours,
            style: TextStyle(
              color: isClosed ? AppColors.primary : AppColors.gray900,
              fontWeight: isClosed ? FontWeight.w600 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: List.generate(
          50,
          (index) => Expanded(
            child: Container(
              height: 1,
              color: index.isEven ? AppColors.gray100 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
