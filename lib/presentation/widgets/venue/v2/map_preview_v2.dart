import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MapPreviewV2 extends StatelessWidget {
  final Venue venue;

  const MapPreviewV2({super.key, required this.venue});

  Future<void> _openMaps() async {
    final url =
        'https://maps.google.com/?q=${venue.latitude},${venue.longitude}';
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map Preview with overlay button
        GestureDetector(
          onTap: _openMaps,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Map Image Container
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.gray100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBRdk742xm0vmkVHox80Jr0BH44aCwpN0b95Z4ji-QKbQq38QOhNcTG0tNd66TibSA-QtajQSV0_G8WaGcgeffUBCFVEuiKSK6IL_vAlxhEVYMBkL7TALEgvuBcg_fvidM0iDglX4GhZsY4yXV7bE2lt3pGsJdPvHpl1zpTsWU1Bqo6AK7IkaRDYt_zZ_ABKyF-jXnc20iRoaLNAI5d45y1DWvrn5I0PwEpUEjs7K7a6p5rbD17BQOZw8kZIb5TT8txitJqoAocLA',
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.8),
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.gray100,
                        child: Center(
                          child: Icon(
                            Icons.map_outlined,
                            size: 48,
                            color: AppColors.gray400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // "View on Map" Button Overlay
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Haritada Gör',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Address Text
        Text(
          venue.address,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.gray500,
            fontSize: 13,
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
