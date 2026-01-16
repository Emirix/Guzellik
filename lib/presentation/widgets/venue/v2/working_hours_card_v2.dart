import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';

class WorkingHoursCardV2 extends StatefulWidget {
  final Venue venue;

  const WorkingHoursCardV2({super.key, required this.venue});

  @override
  State<WorkingHoursCardV2> createState() => _WorkingHoursCardV2State();
}

class _WorkingHoursCardV2State extends State<WorkingHoursCardV2>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
            const Text(
              'Çalışma Saatleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusDot(context, isOpen),
                const SizedBox(width: 8),
                Text(
                  isOpen ? 'Şu an Açık' : 'Şu an Kapalı',
                  style: TextStyle(
                    color: isOpen ? const Color(0xFF15803D) : Colors.red[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(children: _buildHoursList()),
        ),
      ],
    );
  }

  String _formatDayHours(dynamic dayData) {
    if (dayData == null) return 'Kapalı';

    if (dayData is Map) {
      final isOpen = dayData['open'] == true;
      if (!isOpen) return 'Kapalı';

      final start = dayData['start']?.toString() ?? '09:00';
      final end = dayData['end']?.toString() ?? '20:00';
      return '$start - $end';
    }

    return dayData.toString();
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
    final hours = widget.venue.workingHours;

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
      final value = _formatDayHours(hours[key]);
      final isClosed = value.toLowerCase() == 'kapalı';

      widgets.add(_buildHourRow(dayName, value, isClosed: isClosed));

      if (i < sortedKeys.length - 1) {
        widgets.add(const SizedBox(height: 8));
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
      final hoursRaw = widget.venue.workingHours[currentDayKey];

      // Use the formatted hours
      final formattedHours = _formatDayHours(hoursRaw);

      if (formattedHours.toLowerCase() == 'kapalı') {
        return 'Kapalı';
      }

      final parts = formattedHours.split(' - ');
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            day,
            style: TextStyle(color: AppColors.gray500, fontSize: 14),
          ),
        ),
        Text(
          hours,
          style: TextStyle(
            color: isClosed ? AppColors.gray400 : AppColors.gray900,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDot(BuildContext context, bool isOpen) {
    // Check if animations should be disabled for accessibility
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    if (!isOpen || disableAnimations) {
      // Static dot for closed status or when animations are disabled
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isOpen ? const Color(0xFF22C55E) : Colors.redAccent,
          shape: BoxShape.circle,
        ),
      );
    }

    // Animated pulsing dot for open status
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Color(0xFF22C55E).withValues(alpha: _pulseAnimation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
