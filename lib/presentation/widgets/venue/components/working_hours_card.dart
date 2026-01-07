import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card displaying venue working hours
/// Highlights today's hours in green
class WorkingHoursCard extends StatelessWidget {
  final Map<String, String> hours;

  const WorkingHoursCard({super.key, required this.hours});

  String _getTodayKey() {
    final now = DateTime.now();
    final weekday = now.weekday;

    // Map weekday to Turkish day names
    switch (weekday) {
      case DateTime.monday:
      case DateTime.tuesday:
      case DateTime.wednesday:
      case DateTime.thursday:
      case DateTime.friday:
        return 'Hafta içi';
      case DateTime.saturday:
        return 'Cumartesi';
      case DateTime.sunday:
        return 'Pazar';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayKey = _getTodayKey();

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: hours.entries.map((entry) {
          final isToday = entry.key == todayKey;
          final isClosed = entry.value.toLowerCase() == 'kapalı';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isToday ? AppColors.success : AppColors.gray500,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  entry.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isClosed
                        ? AppColors.primary
                        : (isToday ? AppColors.success : AppColors.black),
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
