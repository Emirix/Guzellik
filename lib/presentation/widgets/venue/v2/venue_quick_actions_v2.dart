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

  String? get _phoneNumber {
    // Try to get phone from socialLinks
    if (venue.socialLinks.containsKey('phone')) {
      return venue.socialLinks['phone']?.toString();
    }
    if (venue.socialLinks.containsKey('whatsapp')) {
      return venue.socialLinks['whatsapp']?.toString();
    }
    return null;
  }

  String? get _instagramHandle {
    if (venue.socialLinks.containsKey('instagram')) {
      return venue.socialLinks['instagram']?.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          icon: FontAwesomeIcons.whatsapp,
          label: 'WhatsApp',
          iconColor: const Color(0xFF25D366),
          onTap: () =>
              _launchUrl('https://wa.me/${_phoneNumber ?? "905000000000"}'),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.call_outlined,
          label: 'Ara',
          iconColor: AppColors.primary,
          onTap: () => _launchUrl('tel:+${_phoneNumber ?? "905000000000"}'),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.near_me_outlined,
          label: 'Yol Tarifi',
          iconColor: const Color(0xFF1976D2),
          onTap: () => _launchUrl(
            'https://maps.google.com/?q=${venue.latitude},${venue.longitude}',
          ),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: FontAwesomeIcons.instagram,
          label: 'Instagram',
          iconColor: const Color(0xFFE1306C),
          onTap: () => _launchUrl(
            _instagramHandle != null
                ? 'https://instagram.com/$_instagramHandle'
                : 'https://instagram.com',
          ),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Icon Container - White with border, matching design
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.nude, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 24)),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
