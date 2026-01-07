import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/venue.dart';
import '../../../core/theme/app_colors.dart';
import 'components/quick_action_button.dart';

/// Quick actions section for venue details
/// Displays WhatsApp, Call, Directions, and Instagram buttons
class VenueQuickActions extends StatelessWidget {
  final Venue venue;

  const VenueQuickActions({super.key, required this.venue});

  Future<void> _launchWhatsApp() async {
    final phone =
        venue.socialLinks['whatsapp'] as String? ??
        venue.socialLinks['phone'] as String?;
    if (phone != null) {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      final url = Uri.parse('https://wa.me/$cleanPhone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _launchPhone() async {
    final phone = venue.socialLinks['phone'] as String?;
    if (phone != null) {
      final url = Uri.parse('tel:$phone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  Future<void> _launchMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${venue.latitude},${venue.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchInstagram() async {
    final instagram = venue.socialLinks['instagram'] as String?;
    if (instagram != null) {
      final username = instagram
          .replaceAll('@', '')
          .replaceAll('https://instagram.com/', '');
      final url = Uri.parse('https://instagram.com/$username');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            icon: Icons.chat,
            label: 'WhatsApp',
            iconColor: const Color(0xFF25D366),
            onTap: _launchWhatsApp,
          ),
          QuickActionButton(
            icon: Icons.call,
            label: 'Ara',
            iconColor: AppColors.primary,
            onTap: _launchPhone,
          ),
          QuickActionButton(
            icon: Icons.map,
            label: 'Yol Tarifi',
            iconColor: Colors.blue,
            onTap: _launchMaps,
          ),
          QuickActionButton(
            icon: Icons.camera_alt,
            label: 'Instagram',
            iconColor: const Color(0xFFE1306C),
            onTap: _launchInstagram,
          ),
        ],
      ),
    );
  }
}
