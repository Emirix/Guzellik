import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/working_hours_card.dart';

class AboutTab extends StatelessWidget {
  final Venue venue;

  const AboutTab({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Contact Actions
        if (venue.socialLinks.isNotEmpty) ...[
          _buildContactActions(),
          const SizedBox(height: 24),
        ],

        // Description
        if (venue.description != null && venue.description!.isNotEmpty) ...[
          Text('Mekan Hakkında', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Text(
            venue.description!,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
          ),
          const SizedBox(height: 24),
        ],

        // Working Hours
        Text('Çalışma Saatleri', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        _buildWorkingHours(),
        const SizedBox(height: 24),

        // Location & Map
        Text('Konum', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        _buildLocationSection(context),
        const SizedBox(height: 24),

        // Payment Options
        if (venue.paymentOptions.isNotEmpty) ...[
          Text('Ödeme Seçenekleri', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: venue.paymentOptions.map((option) {
              return Chip(
                label: Text(option),
                backgroundColor: AppColors.gray50,
                side: BorderSide(color: AppColors.gray200),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Accessibility
        if (venue.accessibility.isNotEmpty) ...[
          Text('Özellikler', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          _buildAccessibilityInfo(),
        ],
      ],
    );
  }

  Widget _buildWorkingHours() {
    if (venue.workingHours.isEmpty) {
      return Text(
        'Çalışma saatleri bilgisi bulunmuyor.',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
      );
    }

    // Convert venue working hours to the format expected by WorkingHoursCard
    final Map<String, String> formattedHours = {};

    // Helper function to format a single day's hours
    String formatDayHours(dynamic dayData) {
      if (dayData == null) return 'Kapalı';

      if (dayData is Map) {
        final isOpen = dayData['open'] == true;
        if (!isOpen) return 'Kapalı';

        final start = dayData['start']?.toString() ?? '09:00';
        final end = dayData['end']?.toString() ?? '20:00';
        return '$start - $end';
      }

      return dayData.toString();
    }

    // Check if we have individual days or grouped format
    if (venue.workingHours.containsKey('monday')) {
      // Individual days format - group weekdays
      final mondayHours = formatDayHours(venue.workingHours['monday']);
      formattedHours['Hafta içi'] = mondayHours;
      formattedHours['Cumartesi'] = formatDayHours(
        venue.workingHours['saturday'],
      );
      formattedHours['Pazar'] = formatDayHours(venue.workingHours['sunday']);
    } else {
      // Already in grouped format
      venue.workingHours.forEach((key, value) {
        formattedHours[key] = formatDayHours(value);
      });
    }

    return WorkingHoursCard(hours: formattedHours);
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Placeholder for map - in production use google_maps_flutter
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: AppColors.gray400),
                      const SizedBox(height: 8),
                      Text(
                        'Harita Önizlemesi',
                        style: TextStyle(color: AppColors.gray500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                venue.address,
                style: TextStyle(fontSize: 14, color: AppColors.gray700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _openMaps(venue.latitude, venue.longitude),
            icon: const Icon(Icons.directions),
            label: const Text('Yol Tarifi Al'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibilityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: venue.accessibility.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(
                _getAccessibilityIcon(entry.key),
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_getAccessibilityLabel(entry.key)}: ${entry.value}',
                  style: TextStyle(fontSize: 14, color: AppColors.gray700),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getAccessibilityIcon(String key) {
    switch (key.toLowerCase()) {
      case 'parking':
        return Icons.local_parking;
      case 'wheelchair':
        return Icons.accessible;
      case 'wifi':
        return Icons.wifi;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _getAccessibilityLabel(String key) {
    switch (key.toLowerCase()) {
      case 'parking':
        return 'Otopark';
      case 'wheelchair':
        return 'Tekerlekli Sandalye Erişimi';
      case 'wifi':
        return 'Wi-Fi';
      default:
        return key;
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildContactActions() {
    final phone = venue.socialLinks['phone'] as String?;
    final whatsapp = venue.socialLinks['whatsapp'] as String?;

    return Row(
      children: [
        if (phone != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(phone),
              icon: const Icon(Icons.phone),
              label: const Text('Ara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        if (phone != null && whatsapp != null) const SizedBox(width: 12),
        if (whatsapp != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openWhatsApp(whatsapp),
              icon: const Icon(FontAwesomeIcons.whatsapp),
              label: const Text('WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
