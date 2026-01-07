import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueQuickActionsV2 extends StatelessWidget {
  final Venue venue;

  const VenueQuickActionsV2({super.key, required this.venue});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: 'WhatsApp',
          iconColor: const Color(0xFF25D366),
          onTap: () => _launchUrl(
            'https://wa.me/905000000000',
          ), // Replace with real phone
        ),
        _buildActionButton(
          icon: Icons.call_outlined,
          label: 'Ara',
          iconColor: AppColors.primary,
          onTap: () =>
              _launchUrl('tel:+905000000000'), // Replace with real phone
        ),
        _buildActionButton(
          icon: Icons.map_outlined,
          label: 'Yol Tarifi',
          iconColor: Colors.blue,
          onTap: () => _launchUrl(
            'https://maps.google.com/?q=${venue.latitude},${venue.longitude}',
          ),
        ),
        _buildActionButton(
          icon: Icons.camera_alt_outlined,
          label: 'Instagram',
          iconColor: const Color(0xFFE1306C),
          onTap: () => _launchUrl(
            'https://instagram.com/linaestetik',
          ), // Replace with real IG
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.nude),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray700,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
