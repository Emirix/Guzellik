import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/expert.dart';
import '../../../../data/models/specialist.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../components/expert_card.dart';
import '../components/specialist_detail_bottom_sheet.dart';

class ExpertsTab extends StatelessWidget {
  final Venue venue;
  final List<Specialist> specialists;

  const ExpertsTab({super.key, required this.venue, required this.specialists});

  @override
  Widget build(BuildContext context) {
    final bool hasRealSpecialists = specialists.isNotEmpty;
    final bool hasExpertTeam = venue.expertTeam.isNotEmpty;

    if (!hasRealSpecialists && !hasExpertTeam) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'Bu mekan için henüz uzman bilgisi eklenmemiş.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
        ),
      );
    }

    final List<Specialist> displaySpecialists = hasRealSpecialists
        ? specialists
        : venue.expertTeam.map((expertData) {
            // Check if expertData is already a Specialist or a Map
            if (expertData is Specialist) return expertData;

            final Map<String, dynamic> data = expertData is Map<String, dynamic>
                ? expertData
                : {};

            return Specialist(
              id: data['id']?.toString() ?? '',
              venueId: venue.id,
              name: data['name'] ?? 'İsimsiz Uzman',
              profession: data['specialty'] ?? data['title'] ?? 'Uzman',
              photoUrl: data['photo_url'] ?? data['image'],
              bio: data['bio'],
              gender: data['gender'],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: displaySpecialists.length,
      itemBuilder: (context, index) {
        final specialist = displaySpecialists[index];
        final expert = Expert(
          id: specialist.id,
          name: specialist.name,
          title: specialist.profession,
          photoUrl: specialist.photoUrl,
          specialty: specialist.profession,
        );

        return ExpertCard(
          expert: expert,
          onTap: () => _showSpecialistDetails(context, specialist),
        );
      },
    );
  }

  void _showSpecialistDetails(BuildContext context, Specialist specialist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SpecialistDetailBottomSheet(specialist: specialist),
    );
  }
}
