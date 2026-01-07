import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/service.dart';
import '../before_after_viewer.dart';

/// Service detail bottom sheet
class ServiceDetailSheet extends StatelessWidget {
  final Service service;

  const ServiceDetailSheet({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final hasBeforeAfter =
        service.beforePhotoUrl != null && service.afterPhotoUrl != null;

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

          // Visuals
          if (hasBeforeAfter)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BeforeAfterViewer(
                      beforeImageUrl: service.beforePhotoUrl!,
                      afterImageUrl: service.afterPhotoUrl!,
                      serviceName: service.name,
                      description: service.description,
                    ),
                    fullscreenDialog: true,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      _buildImage(service.beforePhotoUrl!, 'Önce'),
                      Container(width: 2, color: AppColors.white),
                      _buildImage(
                        service.afterPhotoUrl!,
                        'Sonra',
                        isAfter: true,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (service.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                imageUrl: service.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: AppColors.gray100,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: AppColors.gray100,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),

          if (hasBeforeAfter || service.imageUrl != null)
            const SizedBox(height: 20),

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

  Widget _buildImage(String url, String label, {bool isAfter = false}) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          Positioned(
            top: 8,
            left: isAfter ? null : 8,
            right: isAfter ? 8 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isAfter ? AppColors.success : AppColors.black)
                    .withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
