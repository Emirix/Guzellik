import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Profile statistics widget showing appointments, favorites, and points
class ProfileStats extends StatelessWidget {
  final int appointments;
  final int favorites;
  final int points;

  const ProfileStats({
    super.key,
    required this.appointments,
    required this.favorites,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              value: appointments.toString(),
              label: 'Randevu',
              valueColor: const Color(0xFF1B0E11),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: favorites.toString(),
              label: 'Favori',
              valueColor: const Color(0xFF1B0E11),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              value: points.toString(),
              label: 'Puan',
              valueColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
