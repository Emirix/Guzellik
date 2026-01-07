import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/service.dart';
import '../components/service_card.dart';

class ServicesTab extends StatelessWidget {
  final String venueId;

  const ServicesTab({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return Consumer<VenueDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final grouped = provider.groupedServices;
        if (grouped.isEmpty) {
          return Center(
            child: Text(
              'Bu mekan için henüz hizmet eklenmemiş.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            String category = grouped.keys.elementAt(index);
            List<Service> services = grouped[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header
                Padding(
                  padding: EdgeInsets.only(bottom: 16, top: index > 0 ? 8 : 0),
                  child: Text(category, style: AppTextStyles.heading3),
                ),
                // Service Cards
                ...services.map(
                  (service) => ServiceCard(
                    service: service,
                    onInquiry: () {
                      // Navigate to overview or show contact options if we had a way to trigger them here
                      // For now, we'll just scroll to top or similar, but the button is there for visual consistency
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
