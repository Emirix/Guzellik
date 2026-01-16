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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: FontAwesomeIcons.whatsapp,
            label: 'WHATSAPP',
            iconColor: const Color(0xFF25D366),
            onTap: () =>
                _launchUrl('https://wa.me/${_phoneNumber ?? "905000000000"}'),
          ),
          _buildActionButton(
            icon: Icons.call,
            label: 'ARA',
            iconColor: AppColors.primary,
            onTap: () => _launchUrl('tel:+${_phoneNumber ?? "905000000000"}'),
          ),
          _buildActionButton(
            icon: Icons.map,
            label: 'YOL TARİFİ',
            iconColor: const Color(0xFF1976D2),
            onTap: () => _launchUrl(
              'https://maps.google.com/?q=${venue.latitude},${venue.longitude}',
            ),
          ),
          _buildActionButton(
            icon: FontAwesomeIcons.instagram,
            label: 'INSTAGRAM',
            iconColor: const Color(0xFFE1306C),
            onTap: () => _launchUrl(
              _instagramHandle != null
                  ? 'https://instagram.com/$_instagramHandle'
                  : 'https://instagram.com',
            ),
          ),
        ],
      ),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 22)),
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
