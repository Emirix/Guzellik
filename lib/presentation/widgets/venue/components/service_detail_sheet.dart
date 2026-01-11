import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/service.dart';

/// Service detail bottom sheet
class ServiceDetailSheet extends StatelessWidget {
  final Service service;

  const ServiceDetailSheet({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(service.name, style: AppTextStyles.heading2),
          const SizedBox(height: 16),

          // Visuals (Removed)
          const SizedBox(height: 8),

          // Details
          if (service.description != null) ...[
            Text('Açıklama', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            Text(
              service.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 20),
          ],

          Row(
            children: [
              _buildInfoItem(
                Icons.access_time,
                '${service.durationMinutes} dk',
              ),
              if (service.expertName != null) ...[
                const SizedBox(width: 20),
                _buildInfoItem(Icons.person_outline, service.expertName!),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Price and Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Başlangıç Fiyatı',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  Text(
                    '₺${service.price?.toStringAsFixed(0) ?? '0'}',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gray100,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text('Kapat', style: AppTextStyles.button),
              ),
            ],
          ),
          const SizedBox(height: 16), // Bottom padding for safe area
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.gray500),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }
}
