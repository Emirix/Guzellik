import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';

/// Content for the fifth onboarding screen: Booking & Appointments
class AppointmentOnboardingContent extends StatelessWidget {
  const AppointmentOnboardingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: Lottie.asset(
                'assets/animations/appointment.json',
                errorBuilder: (context, error, stackTrace) =>
                    _buildMockup(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockup(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Calendar Grid Mockup
        Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Calendar Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ekim 2024',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 16),
              // Days Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  7,
                  (index) => _buildDayIndicator(index),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Time Slots Mockup
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeSlot('09:00', false),
            const SizedBox(width: 8),
            _buildTimeSlot('10:30', true), // Selected
            const SizedBox(width: 8),
            _buildTimeSlot('14:00', false),
          ],
        ),

        const SizedBox(height: 32),

        // Success Check animation placeholder
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Randevu Onaylandı!',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayIndicator(int index) {
    bool isSelected = index == 3;
    return Container(
      width: 28,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'][index],
            style: TextStyle(
              fontSize: 8,
              color: isSelected ? AppColors.white : AppColors.gray500,
            ),
          ),
          Text(
            '${14 + index}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.white : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String time, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }
}
