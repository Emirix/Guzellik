import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WorkingHoursCardV2 extends StatelessWidget {
  final Venue venue;

  const WorkingHoursCardV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    final status = _getCurrentStatus();
    final isOpen = status == 'Açık';

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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isOpen
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOpen)
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
                    )
                  else
                    const Icon(Icons.circle, color: Colors.redAccent, size: 8),
                  const SizedBox(width: 6),
                  Text(
                    isOpen ? 'Şu an Açık' : 'Şu an Kapalı',
                    style: TextStyle(
                      color: isOpen ? const Color(0xFF15803D) : Colors.red[800],
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: _buildHoursList()),
        ),
      ],
    );
  }

  List<Widget> _buildHoursList() {
    final Map<String, String> dayNames = {
      'monday': 'Pazartesi',
      'tuesday': 'Salı',
      'wednesday': 'Çarşamba',
      'thursday': 'Perşembe',
      'friday': 'Cuma',
      'saturday': 'Cumartesi',
      'sunday': 'Pazar',
    };

    final List<Widget> widgets = [];
    final hours = venue.workingHours;

    final sortedKeys = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final dayName = dayNames[key]!;
      final value = hours[key]?.toString() ?? 'Belirtilmedi';
      final isClosed = value.toLowerCase() == 'kapalı';

      widgets.add(_buildHourRow(dayName, value, isClosed: isClosed));

      if (i < sortedKeys.length - 1) {
        widgets.add(_buildDashedDivider());
      }
    }

    return widgets;
  }

  String _getCurrentStatus() {
    try {
      final now = DateTime.now();
      final dayNames = [
        'sunday',
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
      ];
      final currentDayKey = dayNames[now.weekday % 7];
      final hoursRaw = venue.workingHours[currentDayKey];

      if (hoursRaw == null || hoursRaw.toString().toLowerCase() == 'kapalı') {
        return 'Kapalı';
      }

      final parts = hoursRaw.toString().split(' - ');
      if (parts.length != 2) return 'Açık'; // Fallback

      final startTime = _parseTime(parts[0]);
      final endTime = _parseTime(parts[1]);
      final currentTime = TimeOfDay.fromDateTime(now);

      if (_isTimeAfter(currentTime, startTime) &&
          _isTimeAfter(endTime, currentTime)) {
        return 'Açık';
      }
      return 'Kapalı';
    } catch (e) {
      return 'Açık';
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.trim().split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool _isTimeAfter(TimeOfDay time, TimeOfDay target) {
    if (time.hour > target.hour) return true;
    if (time.hour == target.hour && time.minute >= target.minute) return true;
    return false;
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
              color: isClosed ? Colors.redAccent : AppColors.gray900,
              fontWeight: FontWeight.w600,
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
