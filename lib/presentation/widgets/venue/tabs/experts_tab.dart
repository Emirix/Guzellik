import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../data/models/expert.dart';
import '../../../../data/models/specialist.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../components/expert_card.dart';

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

    final List<Expert> experts = hasRealSpecialists
        ? specialists.map((s) {
            return Expert(
              id: s.id,
              name: s.name,
              title: s.profession,
              photoUrl: s.photoUrl,
              rating: 5.0, // Default for now
              specialty: s.profession,
            );
          }).toList()
        : venue.expertTeam.map((expertData) {
            return Expert(
              id: expertData['id']?.toString() ?? '',
              name: expertData['name'] ?? 'İsimsiz Uzman',
              title: expertData['specialty'] ?? expertData['title'] ?? 'Uzman',
              photoUrl: expertData['photo_url'],
              rating: expertData['rating'] != null
                  ? (expertData['rating'] as num).toDouble()
                  : null,
              specialty: expertData['specialty'],
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
      itemCount: experts.length,
      itemBuilder: (context, index) {
        return ExpertCard(
          expert: experts[index],
          onTap: () {
            // TODO: Navigate to expert profile or booking
          },
        );
      },
    );
  }
}
