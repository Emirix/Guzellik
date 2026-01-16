import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: hours.entries.map((entry) {
          final isToday = entry.key == todayKey;
          final isClosed = entry.value.toLowerCase() == 'kapalı';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    color: isToday ? AppColors.primary : AppColors.gray600,
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                    color: isClosed
                        ? AppColors.gray400
                        : (isToday ? AppColors.primary : AppColors.gray900),
                    fontSize: 14,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
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
