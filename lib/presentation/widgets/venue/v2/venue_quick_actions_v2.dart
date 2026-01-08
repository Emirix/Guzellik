import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: FontAwesomeIcons.whatsapp,
          label: 'WhatsApp',
          backgroundColor: const Color(0xFF25D366),
          iconColor: Colors.white,
          onTap: () => _launchUrl(
            'https://wa.me/905000000000',
          ), // Replace with real phone
        ),
        _buildActionButton(
          icon: Icons.call,
          label: 'Ara',
          backgroundColor: AppColors.primaryLight,
          iconColor: AppColors.primary,
          onTap: () =>
              _launchUrl('tel:+905000000000'), // Replace with real phone
        ),
        _buildActionButton(
          icon: Icons.near_me,
          label: 'Yol Tarifi',
          backgroundColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1976D2),
          onTap: () => _launchUrl(
            'https://maps.google.com/?q=${venue.latitude},${venue.longitude}',
          ),
        ),
        _buildActionButton(
          icon: FontAwesomeIcons.instagram,
          label: 'Instagram',
          backgroundColor: AppColors.primaryLight,
          iconColor: AppColors.primary,
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
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
